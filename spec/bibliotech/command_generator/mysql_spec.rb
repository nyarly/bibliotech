require 'spec_helper'

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

    describe :export do
      let :command do generator.export(options) end
      subject do command end

      context 'with username and database' do
        let :config  do base_config end
        let :options do base_options end

        it { should == "mysqldump -u #{username} #{db_name}" }

        context 'and password' do
          let :config do base_config.merge({ :password => password }) end

          it { should include("mysqldump", "--password='#{password}'","-u #{username}", "#{db_name}") }
          it { should =~ /^mysqldump/ }
          it { should =~ /#{db_name}$/ }
          #TODO: Refactor remaining specs into the above format
        end

        context 'and hostname' do
          let :config do base_config.merge({ :host => host }) end

          it { should == "mysqldump -h #{host} -u #{username} #{db_name}" }
        end

        context 'plus filename and path' do
          let :options do base_options.merge({ :filename => filename, :path => path}) end

          it { should == "mysqldump -u #{username} #{db_name} > #{path}/#{filename}" }

          context 'and compressor' do
            let :options do base_options.merge({
              :filename => filename,
              :path => path,
              :compressor => :gzip
            })
            end

            it { should == "mysqldump -u #{username} #{db_name} | gzip > #{path}/#{filename}.gz" }
          end
        end

        context 'with the whole shebang' do
          let :options do base_options.merge({ :filename => filename, :path => path, :compressor => :gzip}) end
          let :config  do base_config.merge({ :host => host, :password => password }) end

          it { should == "mysqldump -h #{host} -u #{username} --password='#{password}' #{db_name} | gzip > #{path}/#{filename}.gz" }
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

        it { should == "cat #{path}/#{filename} | mysql -u #{username} #{db_name}" }

        context "plus password" do
          let :config do base_config.merge({ :password => password }) end

          it { should == "cat #{path}/#{filename} | mysql -u #{username} --password='#{password}' #{db_name}" }

          context 'and compressor' do
            let :options do base_options.merge({
              :filename => filename + '.gz',
              :path => path,
              :compressor => :gzip
            })
            end

            it { should == "gunzip #{path}/#{filename}.gz | mysql -u #{username} --password='#{password}' #{db_name}" }
          end
        end
      end
    end



  end
end
