module BiblioTech
  class Compression::Gzip < Compression
    register /\.gz\Z/, self
    register /\.gzip\Z/, self
  end
end
