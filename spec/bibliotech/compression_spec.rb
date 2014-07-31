require 'spec_helper'

module BiblioTech
  describe Compression do

    let :generator do
      double(CommandGenerator)
    end

    describe 'for' do
      it do
        expect(Compression.for("my_archive.sql.gz", generator)).to be_a(Compression::Gzip)
      end

      it do
        expect(Compression.for("my_archive.sql.bz2", generator)).to be_a(Compression::Bzip2)
      end

      it do
        expect(Compression.for("my_archive.sql.7z", generator)).to be_a(Compression::SevenZip)
      end

      it do
        expect(Compression.for("my_archive.sql", generator)).to equal(generator)
      end
    end
  end
end
