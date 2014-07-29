require 'spec_helper'
require 'pry'

module BiblioTech
  describe CommandGenerator, "for mysql" do
    let :config do
      Config.new(nil).tap do |config|
        config.hash = config_hash
      end
    end
    let :generator do
      CommandGenerator.new(config)
    end
    let( :db_name  )  { "db_name"     }
    let( :username )  { "user_name"   }
    let( :password )  { "password123" }
    let( :host     )  { "127.0.0.1"   }
    let( :filename )  { "export.sql"  }
    let( :path     )  { "/some/path"  }

    let :base_config_hash do
      { "database_config" => {
        "adapter" => :mysql,
        "database" => db_name,
        "username" => username
      }}
    end
    let(:config_hash){ base_config_hash }

    let(:options){ {} }

    def first_cmd
      command.commands[0]
    end

    def second_cmd
      command.commands[1]
    end

    describe :export do
      subject :command do
        generator.export(options)
      end

      context 'with username and database' do
        context 'and password' do
          let :config_hash do
            #binding.pry
            base_config_hash.tap do |hash|
              hash["database_config"]["password"] = password
            end
          end

          it { should be_a(Caliph::CommandLine) }
          it { command.executable.should == 'mysqldump' }
          it { command.options.should == ["-u #{username}", "--password='#{password}'", "#{db_name}"] }
        end

        context 'and hostname' do
          let :config_hash do
            base_config_hash.tap do |hash|
              hash["database_config"]["host"] = host
            end
          end

          it { command.options.should == ["-h #{host}", "-u #{username}", "#{db_name}"] }
        end

        context 'plus filename and path' do
          let :options do
            {:backups => { :filename => filename, :dir => path}}
          end

          context 'and compressor' do
            let :options do
              { :backups => {
                :filename => filename,
                :dir => path,
                :compress => :gzip
              }}
            end

            it { command.should be_a(Caliph::PipelineChain) }
            it { second_cmd.redirections.should ==   [ "1>#{path}/#{filename}.gz" ] }

            context "first command" do
              it { first_cmd.executable.should == 'mysqldump' }
              it { first_cmd.options.should ==  ["-u #{username}", "#{db_name}"] }
            end
            context "second command" do
              it { second_cmd.executable.should == 'gzip' }
            end
          end
        end

        context 'with the whole shebang' do
          let :options do
            { :backups => { :filename => filename, :dir => path, :compress => :gzip} }
          end
          let :config_hash  do
            base_config_hash.tap do |hash|
              hash["database_config"].merge!( "host" => host, "password" => password)
            end
          end

          it { second_cmd.redirections.should == ["1>#{path}/#{filename}.gz"] }

          context "first command" do
            it { first_cmd.executable.should == "mysqldump" }
            it { first_cmd.options.should == ["-h #{host}", "-u #{username}", "--password='#{password}'", "#{db_name}"] }
          end

          context "second command" do
            it { second_cmd.executable.should == 'gzip' }
          end
        end
      end
    end


    describe :import do
      let :command do
        generator.import(options)
      end

      subject do
        command
      end

      context 'with username, database, file, and path' do
        let :options do
          { :backups => { :filename => filename, :dir => path }}
        end

        it { command.should be_a(Caliph::CommandLine) }

        it { command.redirections.should == ["0<#{path}/#{filename}"] }
        it { command.executable.should == 'mysql'}
        it { command.options.should == ["-u #{username}", db_name ] }

        context "plus password" do
          let :config_hash do
            base_config_hash.tap do |hash|
              hash["database_config"]["password"] = password
            end
          end

          it { command.options.should == ["-u #{username}","--password='#{password}'", "#{db_name}"] }

          context 'and compressor' do
            let :options do
              { :backups => {
                :filename => filename + '.gz',
                :dir => path,
                :compress => :gzip
              } }
            end

            it { command.should be_a(Caliph::PipelineChain) }
            it { first_cmd.executable.should == 'gunzip' }
            it { first_cmd.options.should == ["#{path}/#{filename}.gz"] }
          end
        end
      end
    end



  end
end
