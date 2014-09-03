require 'spec_helper'
require 'bibliotech/application'

module BiblioTech
  describe CommandGenerator do
    describe "class methods", :pending => true do
      describe "adapter lookup" do
        class CommandOne < CommandGenerator; end;
        class CommandTwo < CommandGenerator; end;
        let :class_1        do CommandOne end
        let :class_2        do CommandTwo end
        let :config         do { :adapter => :type_1 } end
        let :return_adapter do double(CommandGenerator) end

        before do
          CommandGenerator.class_eval do
            @adapter_registry = nil
          end
        end

        context "with one class registered" do
          before do
            CommandGenerator.register(:type_1, CommandOne)
          end
          it "should list single supported adapter" do
            expect(CommandGenerator.supported_adapters()).to eq([:type_1])
          end
          it "should return the correct adapter, instantiated with the config" do
            expect(CommandOne).to receive(:new).and_return(return_adapter)
            expect(CommandGenerator.for(config)).to eq(return_adapter)
          end
        end

        context "with two classes registered" do
          before do
            CommandGenerator.register(:type_1, CommandOne)
            CommandGenerator.register(:type_2, CommandTwo)
          end
          it "should return a single registered class" do
            expect(CommandGenerator.supported_adapters()).to include(:type_1, :type_2)
          end
        end
        context "with one class registered twice" do
          before do
            CommandGenerator.register(:type_1, CommandOne)
            CommandGenerator.register(:type_1a, CommandOne)
          end
          it "should list single supported adapter" do
            expect(CommandGenerator.supported_adapters()).to eq([:type_1, :type_1a])
          end
        end
      end
    end

    describe "skeleton methods" do
      let :generator do
        CommandGenerator.new(config)
      end

      let :app do
        Application.new
      end

      let :config do
        app.config
      end

      it "should produce a remote_cli command" do
        expect(generator.remote_cli("staging", "latest").command).to match(/\Assh.*-- '.*bibliotech latest'\z/)
      end

      it "should produce a fetch command" do
        expect(generator.fetch("staging", "latest.sql.gz").command).to match(/scp.*@.*latest\.sql\.gz.*latest\.sql\.gz\z/)
      end

      it "should produce a push command" do
        expect(generator.push("staging", "latest.sql.gz").command).to match(/\Ascp.*latest\.sql\.gz.*@.*latest\.sql\.gz\z/)
      end

      it "should raise_error an error when calling wipe" do
        expect do
          generator.wipe()
        end.to raise_error(NotImplementedError)
      end

      it "should raise_error an error when calling delete" do
        expect do
          generator.delete()
        end.to raise_error(NotImplementedError)
      end

      it "should raise_error an error when calling create" do
        expect do
          generator.create()
        end.to raise_error(NotImplementedError)
      end
    end
  end
end
