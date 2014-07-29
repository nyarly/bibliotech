require 'valise'
require 'spec_helper'

module BiblioTech
  describe Config do
    describe 'initialization' do
      let :valise do
        Valise.define do
          defaults do
            file "config.yaml", {
              "database_config_file" => "database.yml",
              "database_config_env" => "development",
            }
            file "database.yml", {
              "development" =>
              { "username" => 'root',
                "database"  => 'dev_db',
                "adapter"   => 'mysql',
              },
              "production" =>
              { "username" => 'root',
                "database"  => 'prod_db',
                "adapter"   => 'mysql2',
              }
            }
          end
        end
      end

      subject :config do
        BiblioTech::Config.new(valise)
      end

      context "if the file contains database configs" do
        context "with default(development) environment" do
          it "should make the development hash available at config" do
            config.database.should == "dev_db"
          end
        end

        context "with specified environment" do
          it "should make the string-specified hash available at config" do
            config.merge("database_config_env" => "production").database.should == "prod_db"
          end
        end
      end

      context "when the file contains bad configs" do
        context "with no matching environment" do
          it "should raise an error" do
            expect do
              config.merge("database_config_env" => "only_for_pretend").database
            end.to raise_error(KeyError)
          end
        end
      end
    end
  end
end
