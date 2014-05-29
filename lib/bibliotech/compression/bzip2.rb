module BiblioTech
  class Compression::Bzip2 < Compression
    register /\.bz2\Z/, self
    register /\.bzip2\Z/, self
  end
end
