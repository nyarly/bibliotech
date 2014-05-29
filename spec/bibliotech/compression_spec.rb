require 'spec_helper'

module BiblioTech
  describe Compression do

    let :generator do
      double(CommandGenerator)
    end

    describe 'for' do
      it do
        Compression.for("my_archive.sql.gz", generator).should be_a(Compression::Gzip)
      end

      it do
        Compression.for("my_archive.sql.bz2", generator).should be_a(Compression::Bzip2)
      end

      it do
        Compression.for("my_archive.sql.7z", generator).should be_a(Compression::SevenZip)
      end

      it do
        Compression.for("my_archive.sql", generator).should equal(generator)
      end
    end
  end
end
