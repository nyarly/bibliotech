require 'spec_helper'
require 'pry'

module BiblioTech
  describe CommandGenerator::MySql do
    let :generator do CommandGenerator::MySql.new(config) end
    let :db_name   do "db_name"         end
    let :username  do "user_name"       end
    let :password  do "password123"     end
    let :host      do "127.0.0.1"       end
    let :filename  do "export.sql"       end
    let :path  do "/some/path"      end

    let :base_config do
      { :database => db_name,
        :username => username
      }
    end
    let :base_options do {} end

    # these two used in specs where command is a CommandChain containing two
    # commands
    let :first_cmd do command.commands.first end
    let :second_cmd do command.commands[1] end

    describe :export do
      let :command do generator.export(options) end
      subject do command end

      context 'with username and database' do
        let :config  do
          #binding.pry
          base_config
        end
        let :options do base_options end

        context 'and password' do
          let :config do
            #binding.pry
            base_config.merge({ :password => password })
          end

          it { should be_a(Caliph::CommandLine) }
          it { command.executable.should == 'mysqldump' }
          it { command.options.should == ["-u #{username}", "--password='#{password}'", "#{db_name}"] }
        end

        context 'and hostname' do
          let :config do
            #binding.pry
            base_config.merge({ :host => host })
          end

          it { command.options.should == ["-h #{host}", "-u #{username}", "#{db_name}"] }
        end

        context 'plus filename and path' do
          let :options do base_options.merge({ :filename => filename, :path => path}) end

          context 'and compressor' do
            let :options do base_options.merge({
              :filename => filename,
              :path => path,
              :compressor => :gzip
            })
            end

            it { command.should be_a(Caliph::PipelineChain) }
            it { command.redirections.should ==   [ "1>#{path}/#{filename}.gz" ] }

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
          let :options do base_options.merge({ :filename => filename, :path => path, :compressor => :gzip}) end
          let :config  do base_config.merge({ :host => host, :password => password }) end

          it { command.redirections.should == ["1>#{path}/#{filename}.gz"] }

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
      let :command do generator.import(options) end

      subject do command end

      context 'with username, database, file, and path' do
        let :config  do base_config end
        let :options do
          base_options.merge({ :filename => filename, :path => path })
        end

        it { command.should be_a(Caliph::PipelineChain) }

        it { first_cmd.executable.should == 'cat' }
        it { first_cmd.options.should == ["#{path}/#{filename}"] }
        it { second_cmd.executable.should == 'mysql'}
        it { second_cmd.options.should == ["-u #{username}", db_name ] }

        context "plus password" do
          let :config do base_config.merge({ :password => password }) end

          it { second_cmd.options.should == ["-u #{username}","--password='#{password}'", "#{db_name}"] }

          context 'and compressor' do
            let :options do base_options.merge({
              :filename => filename + '.gz',
              :path => path,
              :compressor => :gzip
            })
            end

            it { first_cmd.executable.should == 'gunzip' }
            it { first_cmd.options.should == ["#{path}/#{filename}.gz"] }
          end
        end
      end
    end



  end
end
