require 'bibliotech/backups/calendar_scheduler'

module BiblioTech::Backups
  describe CalendarScheduler do
    describe "naming" do
      it "[]" do
        expect(CalendarScheduler.new([], nil).name).to eq "every-minute"
      end
      it "[]" do
        expect(CalendarScheduler.new([9], nil).name).to eq "Hourly at :09"
      end
      it "[]" do
        expect(CalendarScheduler.new([3,9], nil).name).to eq "Daily at 03:09"
      end
      it "[]" do
        expect(CalendarScheduler.new([10,3,9], nil).name).to eq "Monthly on day 10, at 03:09"
      end
      it "[5,10,3,0]" do
        expect(CalendarScheduler.new([5,10,3,9], nil).name).to eq "Yearly: May 10, at 03:09"
      end
    end
    let(:test_jitter){ 0 }

    let :unfiltered_files do
      file_dates.map do |time|
        FileRecord.new("", time - test_jitter/2 + rand(test_jitter))
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
        CalendarScheduler.new( [0], nil)
      end

      context "when there's superfrequent backups over 12 hours" do
        let :file_dates do
          (0..11).flat_map do |hour|
            [0,15,18,45].map do |minute|
              Time.new(2015, 12,9,hour, minute, 0, 0)
            end
          end
        end

        it "should mark 13 files kept" do
          expect(kept_files.count).to eql 13
        end
      end
    end

    describe "with a limit" do
      let :scheduler do
        CalendarScheduler.new( [1,0,0], 6)
      end

      context "when there's just enough backups" do
        let :file_dates do
          (1..6).map do |month|
            Time.new(2015, month, 1, 0, 0, 0, 0)
          end
        end

        it "should mark 6 files kept" do
          expect(kept_files.count).to eql 6
        end
      end

      context "when there's more than enough backups" do
        let :file_dates do
          (1..10).map do |month|
            Time.new(2015, month, 1, 0, 0, 0, 0)
          end
        end

        it "should mark 6 files kept" do
          expect(kept_files.count).to eql 6
        end
      end

      context "when the total backup interval is too short" do
        let :file_dates do
          (1..4).flat_map do |month|
            [1,4].map do |day|
              Time.new(2015, month, day, 0, 0, 0, 0)
            end
          end
        end

        it "should mark 5 files kept" do
          expect(kept_files.count).to eql 4
        end
      end
    end
  end
end
