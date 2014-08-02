require 'bibliotech'
require 'caliph'
require 'valise'

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
      Pruner.new(config.merge(options))
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
      return unless pruner(options).backup_needed?(time)
      options["backups"] ||= options[:backups] || {}
      options["backups"]["filename"] = prune_list(options).filename_for(time)
      export(options)
    end

    #pull a dump from a remote
    def get(options)
      @shell.run(commands.fetch(options))
    end

    #push a dump to a remote
    def send(options)
      @shell.run(commands.push(options))
    end

    #clean up the DB dumps
    def prune(options=nil)
      pruner(option || {}).go
    end

    #return the latest dump of the DB
    def latest(options)
      pruner_list(options).most_recent.path
    end

    def remote_cli(remote, command, options)
      @shell.run(commands.ssh_cli(remote, command, options))
    end
  end

  App = Application
end
