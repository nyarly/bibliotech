require 'bibliotech/application'
require 'bibliotech/backups/pruner'
require 'file-sandbox'
module BiblioTech
  describe Backups::Pruner do
    include FileSandbox

    before :each do
      sandbox.new :directory => "db_backups"
    end

    let :app do
      App.new
    end

    let :pruner do
      app.pruner({:backups => {
        :frequency => "daily",
        :prefix => "testing",
        :keep => {:daily => 100},
        :dir => "db_backups"
      }})
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
