require 'valise'
require 'spec_helper'
require 'file-sandbox'

module BiblioTech
  describe Config do
    include FileSandbox

    describe "database.yml" do
      before :each do
        sandbox.new :file => 'config/database.yml', :with_contents => YAML::dump(
          {

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
          })
      end

      describe 'initialization' do
        let :valise do
          Valise.define do
            defaults do
              file "config.yaml", {
                "database_config_file" => "config/database.yml",
                "database_config_env" => "development",
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
              expect(config.database).to eql "dev_db"
            end
          end

          context "with specified environment" do
            it "should make the string-specified hash available at config" do
              expect(config.merge("database_config_env" => "production").database).to eql "prod_db"
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

      describe "partial override of database.yml" do
        let :valise do
          Valise.define do
            defaults do
              file "config.yaml", {
                "database_config_file" => "config/database.yml",
                "database_config_env" => "development",
                "database_config" => {
                  "username" => "codemonkey"
                }
              }
            end
          end
        end

        subject :config do
          BiblioTech::Config.new(valise)
        end

        it "should blend the bibliotech config and Rails config" do
          expect(config.database).to eql("dev_db")
          expect(config.username).to eql("codemonkey")
        end
      end
    end

    describe 'default config' do
      let :valise do
        Application.new.valise
      end

      subject :config do
        Config.new(valise)
      end
    end

    describe "schedule shorthands" do
      let :config do
        Config.new(nil).tap do |config|
          config.hash =  config_hash
        end
      end

      let :config_hash do
        { "backups" => {
          "frequency" => 60,
          "keep" => {
            60 => 24,
            1440 => 7
          }}}
      end

      let :schedule_array do
        config.prune_schedules.map do |sched|
          [sched.frequency, sched.limit]
        end
      end

      context "simple numerics" do
        it "should produce correct schedule" do
          expect(schedule_array).to contain_exactly([60, 24], [1440, 7])
        end
      end

      context "environment overrides" do
        let :config_hash do
          { "backups" => {
            "frequency" => 60,
            "keep" => {
              "hourly" => 1
            }},
            "production" => {
              "backups" => {
                "keep" => {
                  "hourly" => 12
                }
              }
            },
            "local" => "production"
          }
        end

        it "should prefer the local config" do
          expect(schedule_array).to contain_exactly([60, 12])
        end
      end

      context "mismatched frequency" do
        let :config_hash do
          { "backups" => {
            "frequency" => 59,
            "keep" => {
              60 => 24,
              1440 => 7
            }}}
        end

        it "should raise an error" do
          expect do
            schedule_array
          end.to raise_error(/59/)
        end
      end

      context "with garbage input" do
        let :config_hash do
          { "backups" => {
            "frequency" => "sometimes",
            "keep" => {
              "often" => 24,
              "regular" => 7,
              "chocolate" => 4
            }}}
        end

        it "should raise an error" do
          expect do
            schedule_array
          end.to raise_error
        end
      end


      context "with 'none'" do
        let :config_hash do
          { "backups" => {
            "frequency" => "daily",
            "keep" => {
              "hourly" => "none",
              "daily" => "all"
            }
          }}
        end

        it "should not raise error" do
          expect(schedule_array).to contain_exactly([60*24, nil])
        end
      end

      context "accidentally empty" do
        let :config_hash do
          { "backups" => {
            "frequency" => "daily",
            "keep" => {
              "hourly" => "none",
              "daily" => "none"
            }
          }}
        end

        it "should raise an error" do
          expect do
            schedule_array
          end.to raise_error
        end
      end

      context "with shorthand words" do
        let :config_hash do
          { "backups" => {
            "frequency" => "hourly",
            "keep" => {
              "hourlies" => 24,
              "daily" => 7,
              "weeklies" => 4,
              "monthly" => "all"
            }}}
        end

        it "should produce correct schedule" do
          expect(schedule_array).to contain_exactly([60, 24], [60*24, 7], [60*24*7, 4], [60*24*30, nil])
        end
      end
    end
  end
end
