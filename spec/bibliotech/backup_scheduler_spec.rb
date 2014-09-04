require 'bibliotech/backups/scheduler'

module BiblioTech::Backups
  describe Scheduler do
    let(:test_jitter){ 0 }

    let :unfiltered_files do
      (0..interval).step(frequency).map do |seconds| #e.g. every 15 seconds for 8 hours
        seconds = seconds - test_jitter/2 + rand(test_jitter)
        FileRecord.new("", Time.now - seconds)
      end
    end

    let :filtered_files do
      scheduler.mark(unfiltered_files)
    end

    let :kept_files do
      filtered_files.select do |record|
        record.keep?
      end
    end

    describe "without a limit" do
      let :scheduler do
        Scheduler.new(60, nil)
      end

      context "when there's more than enough backups" do
        let(:interval){ 60*60*12 - 1}
        let(:frequency) { 15 }
        let(:test_jitter){ 60 }

        it "should mark 8 files kept" do
          expect(kept_files.count).to eql 12
        end
      end
    end

    describe "with a limit" do
      let :scheduler do
        Scheduler.new(60, 8)
      end

      context "when there's just enough backups" do
        let(:interval){ 60*60*8 - 1 }
        let(:frequency){ 60*8 }
        let(:test_jitter){ 60 }

        it "should mark 8 files kept" do
          expect(kept_files.count).to eql 8
        end

        context "even if we're pruning much later" do
          let :filtered_files do
            unfiltered_files.each do |record|
              record.timestamp += 60*60*24
            end

            scheduler.mark(unfiltered_files)
          end

          it "should mark 8 files kept" do
            expect(kept_files.count).to eql 8
          end
        end
      end

      context "when there are no backups yet" do
        let(:unfiltered_files){ [] }

        it "should return 0 kept files" do
          expect(kept_files.count).to eql 0
        end
      end

      context "when there's more than enough backups" do
        let(:interval){ 60*60*12 }
        let(:frequency) { 15 }
        let(:test_jitter){ 60 }

        it "should mark 8 files kept" do
          expect(kept_files.count).to eql 8
        end
      end

      context "when there are too few backups" do
        let(:interval){ 60*60*4 - 1 }
        let(:frequency){ 60*8 }
        let(:test_jitter){ 60 }

        it "should mark 4 files kept" do
          expect(kept_files.count).to eql 4
        end
      end

      context "when files already marked to keep" do
        let :filtered_files do
          unfiltered_files.each do |record|
            record.keep = true
          end

          scheduler.mark(unfiltered_files)
        end

        let(:interval){ 60*60*12 }
        let(:frequency) { 15 }
        let(:test_jitter){ 60 }

        it "should not unmark any" do
          expect(kept_files.length).to eql(unfiltered_files.length)
        end
      end
    end
  end
end
