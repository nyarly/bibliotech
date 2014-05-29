module BiblioTech
  class Compression::SevenZip < Compression
    register /\.7z\Z/, self
  end
end
