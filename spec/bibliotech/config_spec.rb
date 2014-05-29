require 'spec_helper'

module BiblioTech
  class ::Hash
    def deep_merge(second)
      merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
      self.merge(second, &merger)
    end
  end

  describe Config do
    describe 'initialization' do
      before do
        File.stub(:open).and_return(file)
        YAML.stub(:load).and_return(hash)
      end

      context 'with a filename provided' do
        let :path do '/some/path/database.yml' end
        let :file do double(File) end
        let :valid_hash do
          { :development =>
            { :username => 'root',
              :database  => 'dev_db',
              :adapter   => 'mysql',
            },
            :production =>
            { :username => 'root',
              :database  => 'dev_db',
              :adapter   => 'mysql2',
            }
          }
        end

        context "if the file contains database configs" do
          let :hash do valid_hash end
          it "should load that file and parse with yaml" do
            File.should_receive(:open).with(path).and_return(file)
            YAML.should_receive(:load).with(file).and_return(hash)
            Config.load(path)
          end

          context "with default(development) environment" do
            it "should make the development hash available at config" do
              config = Config.load(path)
              config.db_config.should == valid_hash[:development]
            end
          end

          context "with specified environment" do
            it "should make the symbol-specified hash available at config" do
              config = Config.load(path, :production)
              config.db_config.should == valid_hash[:production]
            end

            it "should make the string-specified hash available at config" do
              config = Config.load(path, 'production')
              config.db_config.should == valid_hash[:production]
            end
          end

        end

        context "when the file contains bad configs" do
          context "with no environments" do
            let :hash do { :some => 'values'} end
            it "should raise an error" do
              expect do
                Config.load(path)
              end.to raise_error
            end
          end

          context "with no matching environment" do
            let :hash do  valid_hash.reject(){|k,v| k == :development } end
            it "should raise an error" do
              expect do
                Config.load(path)
              end.to raise_error
            end
          end

          context "with no adapter" do
            let :hash do
              valid_hash.deep_merge({
                :development => { :adapter => nil },
              })
            end

            it "should raise an error" do
              expect do
                Config.load(path)
              end.to raise_error
            end
          end

        end
      end

    end
  end
end
