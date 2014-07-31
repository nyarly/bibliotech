module BiblioTech
  class Config
    class MissingConfig < KeyError; end

    CONFIG_STEPS = {
      :database_config_file =>  [ "database_config_file" ]             ,
      :database_config_env  =>  [ "database_config_env"  ]             ,
      :filename             =>  [ "backups"              , "filename"  ]  ,
      :path                 =>  [ "backups"              , "dir"       ]  ,
      :compressor           =>  [ "backups"              , "compress"  ]  ,
      :prune_schedule       =>  [ "backups"              , "keep"      ]  ,
      :backup_frequency     =>  [ "backups"              , "frequency" ]  ,
      :db_adapter           =>  [ "database_config"      , "adapter"   ]  ,
      :db_host              =>  [ "database_config"      , "host"      ]  ,
      :db_port              =>  [ "database_config"      , "port"      ]  ,
      :db_database          =>  [ "database_config"      , "database"  ]  ,
      :db_username          =>  [ "database_config"      , "username"  ]  ,
      :db_password          =>  [ "database_config"      , "password"  ]  ,
    }

    def initialize(valise)
      @valise = valise
    end

    attr_reader :valise
    attr_writer :hash

    def hash
      @hash ||= stringify_keys(valise.contents("config.yaml"))
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

    def merge(other_hash)
      self.class.new(valise).tap do |newbie|
        newbie.hash = hash.merge(stringify_keys(other_hash))
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
      raise MissingConfig, "No value configured at any of: #{steps_chain.map{|steps| steps.join(">")}}"
    end

    def local
      extract(["local"])
    end

    def remote
      extract(["remote"])
    end

    def local_get(key)
      steps = steps_for(key)
      extract(steps, [local] + steps)
    rescue MissingConfig
      extract(steps)
    end

    def remote_get(remote_name, key)
      steps = [remote_name] + steps_for(key)
      extract(steps, ["remotes"] + steps)
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

    def backup_frequency
      @backup_frequency ||= regularize_frequency(local_get(:backup_frequency))
    end

    def each_prune_schedule
      local_get(:prune_schedule).each do |frequency, limit|
        real_frequency = regularize_frequency(frequency)
        unless real_frequency % backup_frequency == 0
          raise "Pruning frequency #{real_frequency}:#{frequency} is not a multiple of backup frequency: #{backup_frequency}:#{local_get(:backup_frequency)}"
        end
        yield(real_frequency, limit)
      end
    end

    def database_config
      hash["database_config"] ||= valise.contents(local_get(:database_config_file))[local_get(:database_config_env)]
    end

    #@group File management
    def file
      ::File.join(path, filename)
    end

    def filename
      local_get(:filename)
    end

    def path
      local_get(:path)
    end

    def expander
      if remote.nil?
        local_get(:expander)
      else
        remote_get(remote, :expander)
      end
    end

    def compressor
      local_get(:compressor)
    end
    #@endgroup

    #@group Database
    def adapter
      database_config
      local_get(:db_adapter)
    end

    def host
      database_config
      local_get(:db_host)
    end

    def port
      database_config
      local_get(:db_port)
    end

    def username
      database_config
      local_get(:db_username)
    end

    def database
      database_config
      local_get(:db_database)
    end

    def password
      database_config
      local_get(:db_password)
    end
    #@endgroup
  end
end
