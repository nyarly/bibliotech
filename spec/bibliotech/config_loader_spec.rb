require 'spec_helper'
module BiblioTech
  describe ConfigLoader do
    describe 'initialization' do

      context 'with a filename provided' do
        let :path do '/some/path/database.yml' end
        let :file do mock(File) end
        let :hash do { :some => :values } end

        it "should load that file and parse with yaml" do
          File.should_receive(:open).with(path).and_return(file)
          YAML.should_receive(:load).with(file).and_return(hash)
          ConfigLoader.new(path)
        end

        it "should produce an error if the file does not contain database configs" do
          pending
        end

        it "should make the equivalent hash available at config" do
          File.stub(:open).and_return(file)
          YAML.stub(:load).and_return(hash)
          loader = ConfigLoader.new(path)
          loader.config.should == hash
        end
      end

    end
  end
end
