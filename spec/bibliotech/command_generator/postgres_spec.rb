require 'spec_helper'

module BiblioTech
  describe CommandGenerator do
    let :generator do
      CommandGenerator.new(config)
    end

    let   (:db_name){    "db_name"       }
    let   (:username){   "user_name"     }
    let   (:password){   "password123"   }
    let   (:host){       "127.0.0.1"     }
    let   (:filename){   "export.pg"     }
    let   (:path){       "/some/path"    }


    let   (:base_options){{}}

    let :base_config_hash do
      { "database_config" =>
        {
          "adapter" => :postgres,
          "database" => db_name,
          "username" => username
        }
      }

    end

    let(:config_hash){ base_config_hash }
    let(:options){ base_options }

    let :config do
      Config.new(nil).tap do |config|
        config.hash = config_hash
      end
    end

    def first_cmd
      command.commands[0]
    end

    def second_cmd
      command.commands[1]
    end

    describe :export do
      let :command do
        generator.export(options)
      end

      subject do
        command
      end

      context 'with username and database' do
        let :config_hash  do
          base_config_hash
        end

        context 'and password' do
          let :config_hash do
            base_config_hash.tap do |hash|
              hash["database_config"]["password"] = password
            end
          end

          it { is_expected.to be_a(Caliph::CommandLine) }
          it { expect(command.executable).to eq('pg_dump') }
          it { expect(command.options).to eq(["-Fc", "-U #{username}", "#{db_name}"]) }
          it { expect(command.env['PGPASSWORD']).to eq(password) }
        end

        context 'and hostname' do
          let :config_hash do
            base_config_hash.tap do |hash|
              hash["database_config"]["host"] = host
            end
          end

          it { expect(command.options).to eq(["-Fc", "-h #{host}", "-U #{username}", "#{db_name}"]) }
        end

        context 'plus filename and path and compressor' do
          let :options do
            base_options.merge( :backups => {
              :dir => path,
              :filename => filename,
              :compress => :gzip
            })
          end

          it { expect(command).to be_a(Caliph::PipelineChain) }
          it { expect(command.commands[1].redirections).to eq([ "1>#{path}/#{filename}.gz" ]) }

          context "first command" do
            it { expect(first_cmd.executable).to eq('pg_dump') }
            it { expect(first_cmd.options).to eq(["-Fc", "-U #{username}", "#{db_name}"]) }
          end
          context "second command" do
            it { expect(second_cmd.executable).to eq('gzip') }
          end
        end

        context 'with the whole shebang' do
          let :options do
            base_options.merge( :backups => {
              :filename => filename,
              :dir => path,
              :compress => :gzip
            })
          end
          let :config_hash  do
            base_config_hash.tap do |hash|
              hash["database_config"] = hash["database_config"].merge({ "host" => host, "password" => password })
            end
          end

          it { expect(second_cmd.redirections).to eq(["1>#{path}/#{filename}.gz"]) }

          context "first command" do
            it { expect(first_cmd.executable).to eq("pg_dump") }
            it { expect(first_cmd.options).to eq(["-Fc", "-h #{host}", "-U #{username}", "#{db_name}"]) }
            it { expect(first_cmd.env['PGPASSWORD']).to eq(password) }
          end

          context "second command" do
            it { expect(second_cmd.executable).to eq('gzip') }
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
          base_options.merge(:backups => { :filename => filename, :dir => path })
        end

        it { expect(command.redirections).to eq(["0<#{path}/#{filename}"]) }
        it { expect(command.executable).to eq('pg_restore')}
        it { expect(command.options).to eq(["-Oc", "-U #{username}", "-d #{db_name}" ]) }

        context "plus password" do
          let :config_hash do
            base_config_hash.tap do |hash|
              hash["database_config"]["password"] = password
            end
          end

          it { expect(command.options).to eq(["-Oc", "-U #{username}", "-d #{db_name}"]) }
          it { expect(command.env['PGPASSWORD']).to eq(password) }

          context 'and compressor' do
            let :options do
              base_options.merge(:backups => {
                :filename => filename + '.gz',
                :dir => path,
                :compressor => :gzip
              })
            end

            it { expect(command).to be_a(Caliph::PipelineChain) }
            it { expect(first_cmd.executable).to eq('gunzip') }
            it { expect(first_cmd.options).to eq(["-c", "#{path}/#{filename}.gz"]) }
          end
        end
      end
    end
  end
end
