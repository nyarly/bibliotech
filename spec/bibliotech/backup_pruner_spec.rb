require 'bibliotech/application'
require 'bibliotech/backups/pruner'
require 'bibliotech/backups/scheduler'
require 'file-sandbox'
module BiblioTech
  describe Backups::Pruner do
    include FileSandbox

    before :each do
      sandbox.new :directory => "db_backups"
      sandbox.new :file => '.bibliotech/config.yaml', :with_contents => "log:\n  target: ../tmp/test.log"
    end

    let :app do
      App.new
    end

    let :schedule do
      {:daily => 100}
    end

    let :config do
      double(Config).tap do |config|
        allow(config).to receive(:backup_path){ "db_backups" }
        allow(config).to receive(:backup_name){ "testing" }
        allow(config).to receive(:backup_frequency){ 60 * 24 }
        allow(config).to receive(:schedules){ [ Backup::Scheduler.new("daily", 60 * 24, 100) ] }
      end
    end

    let :pruner do
      Backups::Pruner.new(config)
    end

    it "should generate a filename for current time" do
      expect(pruner.filename_for(Time.now.utc)).to match(/testing/)
    end

    context "without existing files" do
      it "should return true from #backup_needed?" do
        expect(pruner.backup_needed?(Time.now.utc)).to be_truthy
      end
    end

    context "with an existing file" do
      before :each do
        sandbox.new :file => "db_backups/backup-2014-08-12_00:00.sql.7z"
      end

      it "should something latest" do
        expect(app.latest("local" => "production")).to eql "db_backups/backup-2014-08-12_00:00.sql.7z"
      end
    end

    context "with a recent file" do
      before :each do
        sandbox.new :file => "db_backups/#{pruner.filename_for(Time.now.utc - 120)}"
      end

      it "should return false from #backup_needed?" do
        expect(pruner.backup_needed?(Time.now.utc)).to be_falsey
      end
    end

    context "with an old file" do
      before :each do
        sandbox.new :file => "db_backups/#{pruner.filename_for(Time.now.utc - (24 * 60 * 60 + 120))}"
      end

      it "should return true from #backup_needed?" do
        expect(pruner.backup_needed?(Time.now.utc)).to be_truthy
      end
    end

    context "marking for pruning" do
      before :each do
        allow(config).to receive(:prune_schedules){
          [
            Backups::Scheduler.new("hourlies", 60, 48),
            Backups::Scheduler.new("dailies", 24 * 60, 14),
            Backups::Scheduler.new("weeklies", 7 * 24 * 60, 8),
            Backups::Scheduler.new("monthlies", 30 * 24 * 60, nil)
          ]
        }

        Logging.log.debug{ "Start test" }
      end

      it "should have schedules" do
        expect(pruner.schedules.length).to eq(4)
      end

      it "should keep single backup" do
        sandbox.new :file => "db_backups/#{pruner.filename_for(Time.now.utc)}"

        expect(pruner.pruneable).to be_empty

        expect(pruner.list.length).to eq(1)
        pruner.list.each do |record|
          expect(record.keep?).to eq(true)
        end
      end

      it "should keep 48 hours of backup" do
        now = Time.now.utc
        (0..47).each do |interval|
          sandbox.new :file => "db_backups/#{pruner.filename_for(Time.now.utc - interval * 60 * 60)}"
        end

        expect(pruner.pruneable).to be_empty

        expect(pruner.list.length).to eq(48)
        pruner.list.each do |record|
          expect(record.keep?).to eq(true)
        end
      end

      it "should prune old backups" do
        now = Time.now.utc
        (0..470).each do |interval|
          sandbox.new :file => "db_backups/#{pruner.filename_for(now - interval * 60 * 60)}"
        end

        expect(pruner.pruneable.length).to eq(471 - 48 - (14 - 2) - 1) # 2 dailies hourly etc.

        expect(pruner.list.length).to eq(471)
      end


      context "repruning" do
        shared_examples_for "well mannered pruner" do
          it "should not re-prune old backups" do
            (0..47).each do |interval|
              sandbox.new :file => "db_backups/#{pruner.filename_for(now - interval * 60 * 60)}"
            end
            (0..11).each do |interval|
              sandbox.new :file => "db_backups/#{pruner.filename_for(now - 48 * 60 * 60 - interval * 24 * 60 * 60)}"
            end
            sandbox.new :file => "db_backups/#{pruner.filename_for(now - 48 * 60 * 60 - 12 * 24 * 60 * 60 - 7 * 24 * 60 * 60)}"

            expect(pruner.pruneable).to be_empty

            expect(pruner.list.length).to eq(48 + 12 + 1)
            pruner.list.each do |record|
              expect(record.keep?).to eq(true)
            end
          end
        end

        context "right now" do
          it_behaves_like "well mannered pruner" do
            let :now do
              Time.now.utc
            end
          end
        end

        context "30 minutes ago" do
          it_behaves_like "well mannered pruner" do
            let :now do
              Time.now.utc - 30 * 60
            end
          end
        end

        context "60 minutes ago" do
          it_behaves_like "well mannered pruner" do
            let :now do
              Time.now.utc - 60 * 60
            end
          end
        end

        context "90 minutes ago" do
          it_behaves_like "well mannered pruner" do
            let :now do
              Time.now.utc - 90 * 60
            end
          end
        end
      end
    end
  end

  describe Backups::PruneList do
    subject :pruner do
      Backups::PruneList.new("/some/path/for/files", "testing")
    end

    it "should warn when other files are present" do
      expect(pruner).to receive(:warn)
      pruner.build_record("some.random.file")
    end

    it "should fail when correct prefix doesn't match timestamp" do
      expect do
        pruner.build_record("testing-WACKYTIMESTAMP.sql.gz")
      end.to raise_error
    end

    describe "creating filenames" do
      it "should match filenames it creates" do
        time = Time.new(2014, 7, 30, 3, 14, 37, 0)
        record = pruner.build_record(Backups::PruneList.filename_for("testing", time))
        expect(record.timestamp).to be_within(60).of(time)
      end
    end

    describe "producing a record" do
      subject :record do
        pruner.build_record("testing-2014-07-30_03:14.sql.gz")
      end

      it { is_expected.to be_a(Backups::FileRecord) }
      it "should have a good time" do
        expect(record.timestamp).to eql Time.new(2014, 7, 30, 3, 14, 0, 0)
      end
    end
  end
end
