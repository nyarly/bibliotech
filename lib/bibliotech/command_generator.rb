require 'caliph'

require 'bibliotech/builders/gzip'
require 'bibliotech/builders/postgres'
require 'bibliotech/builders/mysql'

module BiblioTech
  class CommandGenerator

    include Caliph::CommandLineDSL

    attr_accessor :config

    def initialize(config)
      @config = config
    end

    def export(options = nil)
      options = config.merge(options || {})
      command = cmd
      command = Builders::Export.for(options).go(command)
      Builders::FileOutput.for(options).go(command)
    end

    def import(options = nil)
      options = config.merge(options || {})
      command = cmd()
      command = Builders::Import.for(options).go(command)
      Builders::FileInput.for(options).go(command)
    end

    def fetch(remote, filename, options = nil)
      options = config.merge(options || {})
      local_path = options.local_file(filename)
      cmd("mkdir") do |cmd|
        cmd.options << "--parents"
        cmd.options << File::dirname(local_path)
      end & cmd("scp") do |cmd|
        options.optionally{ cmd.options << "-i #{options.id_file(remote)}" }
        cmd.options << options.remote_file(remote, filename)
        cmd.options << local_path
      end
    end

    def push(remote, filename, options = nil)
      options = config.merge(options || {})
      cmd("scp") do |cmd|
        cmd.options << options.local_file(filename)
        cmd.options << options.remote_file(remote, filename)
      end
    end

    def remote_cli(remote, *command_options)
      options = {}
      if command_options.last.is_a? Hash
        options = command_options.pop
      end
      options = config.merge(options)
      command_on_remote = cmd("cd") do |cmd|
        cmd.options << options.root_dir_on(remote)
      end & cmd("bundle", "exec", "bibliotech", *command_options)
      cmd("ssh") do |cmd|
        cmd.options << "-n" #because we're not going to be doing any input
        options.optionally{ cmd.options << "-i #{options.id_file(remote)}" }
        options.optionally{ cmd.options << "-l #{options.remote_user(remote)}" }

        cmd.options << options.remote_host(remote)

        options.optionally{ cmd.options << "-p #{options.remote_port(remote)}" } #ok


        options.optionally do
          options.ssh_options(remote).each do |opt|
            cmd.options << "-o #{opt}"
          end
        end
      end - escaped_command(command_on_remote)
    end

    def wipe()
      raise NotImplementedError
    end
    def delete()
      raise NotImplementedError
    end
    def create()
      raise NotImplementedError
    end
  end
end
