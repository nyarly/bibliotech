require 'spec_helper'

module BiblioTech
  describe CommandGenerator do

    describe "class methods" do
      describe "for_config" do
        it "should look up the adapter in the registry" do
          pending
        end
      end

      describe "supported_adapters" do
        it "should return whichever adapters are registered"
      end
    end

    describe "skeleton methods" do
      let :generator do CommandGenerator.new end
      let :config do { :some => :values } end
      let :filename do "filename" end

      it "should raise_error an error when calling export" do
        expect do
          generator.export(config, filename)
        end.to raise_error(NotImplementedError)
      end

      it "should raise_error an error when calling import" do
        expect do
          generator.import(config, filename)
        end.to raise_error(NotImplementedError)
      end

      it "should raise_error an error when calling wipe" do
        expect do
          generator.wipe(config)
        end.to raise_error(NotImplementedError)
      end

      it "should raise_error an error when calling delete" do
        expect do
          generator.delete(config)
        end.to raise_error(NotImplementedError)
      end

      it "should raise_error an error when calling create" do
        expect do
          generator.create(config)
        end.to raise_error(NotImplementedError)
      end
    end
  end
end

