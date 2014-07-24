require 'spec_helper'

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
            CommandGenerator.supported_adapters().should == [:type_1]
          end
          it "should return the correct adapter, instantiated with the config" do
            CommandOne.should_receive(:new).and_return(return_adapter)
            CommandGenerator.for(config).should == return_adapter
          end
        end

        context "with two classes registered" do
          before do
            CommandGenerator.register(:type_1, CommandOne)
            CommandGenerator.register(:type_2, CommandTwo)
          end
          it "should return a single registered class" do
            CommandGenerator.supported_adapters().should include(:type_1, :type_2)
          end
        end
        context "with one class registered twice" do
          before do
            CommandGenerator.register(:type_1, CommandOne)
            CommandGenerator.register(:type_1a, CommandOne)
          end
          it "should list single supported adapter" do
            CommandGenerator.supported_adapters().should == [:type_1, :type_1a]
          end
        end

      end
    end

    describe "skeleton methods" do
      let :generator do CommandGenerator.new(config) end
      let :config do { :some => :values } end
      let :filename do "filename" end

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
