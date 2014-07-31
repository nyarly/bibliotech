require 'bibliotech/backups/pruner'
module BiblioTech::Backups
  describe PruneList do
    subject :pruner do
      PruneList.new("/some/path/for/files", "testing")
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

    describe "producing a record" do
      subject :record do
        pruner.build_record("testing-2014-07-30_03:14.sql.gz")
      end

      it { is_expected.to be_a(FileRecord) }
      it "should have a good time" do
        expect(record.timestamp).to eql Time.new(2014, 7, 30, 3, 14, 0, 0)
      end
    end
  end
end
