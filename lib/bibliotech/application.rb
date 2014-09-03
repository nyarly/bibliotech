require 'bibliotech'
require 'caliph'
require 'valise'
require 'bibliotech/backups/pruner'

module BiblioTech
  class Application
    attr_accessor :config_path, :config_hash
    attr_writer :shell

    def initialize
      @memos = {}
      @shell = Caliph.new
      @config_path = %w{/etc/bibliotech /usr/share/bibliotech ~/.bibliotech ./.bibliotech ./config/bibliotech}
    end

    def valise
      @memos[:valise] ||=
        begin
          dirs = config_path
          Valise::define do
            dirs.reverse.each do |dir|
              rw dir
            end
            ro from_here(%w{.. default_configuration}, up_to("lib"))
            handle "*.yaml", :yaml, :hash_merge
            handle "*.yml", :yaml, :hash_merge
          end
        end
    end

    def config
      @memos[:config] ||= Config.new(valise)
    end

    def commands
      @memos[:command] ||= CommandGenerator.new(config)
    end

    def pruner(options)
      Backups::Pruner.new(config.merge(options))
    end

    def prune_list(options)
      pruner(options).list
    end

    def reset
      @memos.clear
    end

    def import(options)
      @shell.run(commands.import(options))
    end

    def export(options)
      @shell.run(commands.export(options))
    end

    def create_backup(options)
      time = Time.now.utc
      pruner = pruner(options)
      return unless pruner.backup_needed?(time)
      options["backups"] ||= options[:backups] || {}
      options["backups"]["filename"] = pruner.filename_for(time)
      export(options)
    end

    #pull a dump from a remote
    def get(remote, options)
      @shell.run(commands.fetch(remote, options))
    end

    #push a dump to a remote
    def send(remote, options)
      @shell.run(commands.push(remote, options))
    end

    #clean up the DB dumps
    def prune(options=nil)
      pruner(options || {}).go
    end

    #return the latest dump of the DB
    def latest(options = nil)
      pruner(options || {}).most_recent.path
    end

    def remote_cli(remote, command, *options)
      @shell.run(commands.remote_cli(remote, command, *options))
    end
  end

  App = Application
end
