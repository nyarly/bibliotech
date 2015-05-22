require 'bibliotech/backups/scheduler'

module BiblioTech
  class Config
    class MissingConfig < KeyError; end

    CONFIG_STEPS = {
      :database_config_file => [ "database_config_file" ] ,
      :database_config_env  => [ "database_config_env"  ] ,
      :root_path            => [ "path" ]                 ,
      :host                 => [ "host" ]                 ,
      :port                 => [ "port" ]                 ,
      :user                 => [ "user" ]                 ,
      :rsa_files            => [ "rsa_files" ]            ,
      :ssh_options          => [ "ssh_options" ]          ,
      :fetch_dir            => [ "fetched_dir" ]          ,
      :log_target           => [ "log"                    , "target"    ],
      :log_level            => [ "log"                    , "level"     ],
      :file                 => [ "backups"                , "file"      ] ,
      :filename             => [ "backups"                , "filename"  ] ,
      :backup_path          => [ "backups"                , "dir"       ] ,
      :compressor           => [ "backups"                , "compress"  ] ,
      :prune_schedule       => [ "backups"                , "keep"      ] ,
      :backup_name          => [ "backups"                , "prefix"    ] ,
      :backup_frequency     => [ "backups"                , "frequency" ] ,
      :db_adapter           => [ "database_config"        , "adapter"   ] ,
      :db_host              => [ "database_config"        , "host"      ] ,
      :db_port              => [ "database_config"        , "port"      ] ,
      :db_database          => [ "database_config"        , "database"  ] ,
      :db_username          => [ "database_config"        , "username"  ] ,
      :db_password          => [ "database_config"        , "password"  ] ,
    }

    def initialize(valise)
      @valise = valise
    end

    attr_reader :valise
    attr_writer :hash

    def hash
      @hash ||= stringify_keys(valise.exts(".yaml", ".yml").contents("config"))
    end

    def stringify_keys(hash) # sym -> string
      hash.keys.each do |key|
        if key.is_a?(Symbol)
          hash[key.to_s] = hash.delete(key)
        end
        if hash[key.to_s].is_a?(Hash)
          hash[key.to_s] = stringify_keys(hash[key.to_s])
        end
      end
      hash
    end

    def merge_hashes(left, right)
      left.merge(right) do |key, ours, theirs|
        if ours.is_a?(Hash) and theirs.is_a?(Hash)
          merge_hashes(ours, theirs)
        else
          theirs
        end
      end
    end

    def merge(other_hash)
      self.class.new(valise).tap do |newbie|
        newbie.hash = merge_hashes(hash, stringify_keys(other_hash))
      end
    end

    def steps_for(key)
      CONFIG_STEPS.fetch(key)
    end

    def optional(&block)
      yield
    rescue MissingConfig
    end
    alias optionally optional

    def extract(*steps_chain)
      steps_chain.each do |steps|
        begin
          return steps.inject(hash) do |hash, step|
            raise MissingConfig if hash.nil?
            hash.fetch(step)
          end
        rescue KeyError
        end
      end
      raise MissingConfig, "No value configured at any of: #{steps_chain.map{|steps| steps.join(">")}.join(", ")}"
    end

    def local
      extract(["local"])
    end

    def remote
      extract(["remote"])
    end

    def local_get(key)
      steps = steps_for(key)
      steps_chain =
        begin
          [steps, [local] + steps]
        rescue MissingConfig
          [steps]
        end
      extract(*steps_chain)
    end

    def remote_get(remote_name, key)
      steps = [remote_name] + steps_for(key)
      extract(steps, ["remotes"] + steps)
    end

    def log_target
      target_path = local_get(:log_target)
      case target_path
      when "STDERR", "stderr"
        return $stderr
      when "STDOUT", "stdout"
        return $stdout
      else
        require 'fileutils'
        FileUtils.mkdir_p(File.dirname(target_path))
        return File.open(target_path, "a")
      end
    rescue
      warn "Trouble opening configured log file - logging to stderr"
      warn $!.inspect
      return $STDERR
    end

    def log_level
      level = "debug"
      optionally do
        level = local_get(:log_level)
      end
      return BiblioTech::Logging.log_level(level)
    end

    def ssh_options(for_remote)
      steps = steps_for(:ssh_options) + [for_remote]
      steps_chain =
        begin
          [steps, [local] + steps]
        rescue MissingConfig
          [steps]
        end
      extract(steps_chain)
    end

    def id_file(for_remote)
      steps = steps_for(:rsa_files) + [for_remote]
      steps_chain =
        begin
          [steps, [local] + steps]
        rescue MissingConfig
          [steps]
        end
      extract(steps_chain)
    end

    def local_path
      local_get(:fetch_dir)
    rescue MissingConfig
      local_get(:root_path)
    end

    def local_file(filename)
      File::join(local_path, filename)
    end

    def root_dir_on(remote)
      remote_get(remote, :root_path)
    end

    def remote_host(remote)
      remote_get(remote, :host)
    end

    def remote_port(remote)
      remote_get(remote, :port)
    end

    def remote_user(remote)
      remote_get(remote, :user)
    end

    def remote_path(remote)
      path = "#{remote_host(remote)}:#{root_dir_on(remote)}"
      begin
        "#{remote_user(remote)}@#{path}"
      rescue MissingConfig
        path
      end
    end

    def remote_file(remote, filename)
      File::join(remote_path(remote), filename)
    end

    SCHEDULE_SHORTHANDS = {
      "hourly"      => 60,
      "hourlies"    => 60,
      "daily"       => 60 * 24,
      "dailies"     => 60 * 24,
      "weekly"      => 60 * 24 * 7,
      "weeklies"    => 60 * 24 * 7,
      "monthly"     => 60 * 24 * 30,
      "monthlies"   => 60 * 24 * 30,
      "quarterly"   => 60 * 24 * 120,
      "quarterlies" => 60 * 24 * 120,
      "yearly"      => 60 * 24 * 365,
      "yearlies"    => 60 * 24 * 365,
    }
    def regularize_frequency(frequency)
      Integer( SCHEDULE_SHORTHANDS.fetch(frequency){ frequency } )
    rescue ArgumentError
      raise "#{frequency.inspect} is neither a number of minutes or a shorthand. Try:\n  #{SCHEDULE_SHORTHANDS.keys.join(" ")}"
    end

    def backup_name
      local_get(:backup_name)
    end

    def backup_frequency
      @backup_frequency ||= regularize_frequency(local_get(:backup_frequency))
    end

    def prune_schedules
      prune_hash = local_get(:prune_schedule)
      prune_hash.map do |frequency, limit|
        next if limit == "none"
        real_frequency = regularize_frequency(frequency)
        unless real_frequency % backup_frequency == 0
          raise "Pruning frequency #{real_frequency}:#{frequency} is not a multiple of backup frequency: #{backup_frequency}:#{local_get(:backup_frequency)}"
        end
        limit =
          case limit
          when "all"
            nil
          else
            Integer(limit)
          end
        [frequency, real_frequency, limit]
      end.compact.sort_by do |freq_name, frequency, limit|
        frequency
      end.tap do |list|
        if list.empty?
          require 'pp'
          raise "No backups will be kept by prune schedule: #{prune_hash.pretty_inspect}"
        end
      end.map do |freq_name, frequency, limit|
        Backups::Scheduler.new(freq_name, frequency, limit)
      end
    end

    def database_config
      local_get(:database_config)
    end

    def app_db_config
      @app_db_config ||=
        begin
          db_config = YAML::load(File::read(local_get(:database_config_file)))
          db_config.fetch(local_get(:database_config_env)) do
            require 'pp'
            raise KeyError, "No #{local_get(:database_config_env)} in #{db_config.pretty_inspect}"
          end
        end
    end

    def db_get(field)
      local_get(field)
    rescue MissingConfig => mc
      app_db_config.fetch(steps_for(field).last) do
        raise mc
      end
    end

    #@group File management
    def backup_file
      local_get(:file)
    rescue MissingConfig
      ::File.join(backup_path, filename)
    end

    def filename
      local_get(:filename)
    end

    def backup_path
      local_get(:backup_path)
    end

    def expander
      if remote.nil?
        local_get(:compressor)
      else
        remote_get(remote, :compressor)
      end
    end

    def compressor
      local_get(:compressor)
    end
    #@endgroup

    #@group Database
    def adapter
      db_get(:db_adapter)
    end

    def host
      db_get(:db_host)
    end

    def port
      db_get(:db_port)
    end

    def username
      db_get(:db_username)
    end

    def database
      db_get(:db_database)
    end

    def password
      db_get(:db_password)
    end
    #@endgroup
  end
end
