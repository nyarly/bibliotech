require 'spec_helper'
require 'bibliotech/command_runner'


module BiblioTech
  describe CommandRunner do
    let :config do
      double(Config,
        :db_config => {},
        :environment => :development
      )
    end

    let :generator do
      double(CommandGenerator,
        :export => 'export command'
      )
    end

    let :command do "some cli command" end

    let :runner do
      CommandRunner.new(config)
    end

    before do
      CommandGenerator.stub(:for).and_return(generator)
    end

    describe "single commands" do
      it 'should do export' do
        generator.should_receive(:export).and_return(command)
        Kernel.should_receive(:system).with(command)
        runner.export('path/to/file')
      end

      it 'should do import' do
        generator.should_receive(:import).and_return(command)
        Kernel.should_receive(:system).with(command)
        runner.import('path/to/file')
      end
    end
  end
end
