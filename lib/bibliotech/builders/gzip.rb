require 'bibliotech/builders/file'

module BiblioTech
  module Builders
    class GzipExpander < FileInput
      register(/.*\.gz\z/)
      register(/.*\.gzip\z/)

      def go(command)
        command = cmd("gunzip", file) | command
      end
    end

    class ExplicitGzipExpander < GzipExpander
      register :gzip

      def file
        file = super
        unless PATTERNS.any?{|pattern| pattern =~ file}
          return file + ".gz"
        end
        file
      end
    end

    class GzipCompressor < FileOutput
      PATTERNS = [ /.*\.gz\z/, /.*\.gzip\z/ ]
      PATTERNS.each do |pattern|
        register pattern
      end

      def go(cmd)
        cmd |= %w{gzip}
        cmd.redirect_stdout(file)
        cmd
      end
    end

    class ExplicitGzipCompressor < GzipCompressor
      register :gzip

      def file
        file = super
        unless PATTERNS.any?{|pattern| pattern =~ file}
          return file + ".gz"
        end
        file
      end
    end
  end
end
