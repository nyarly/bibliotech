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

    let :shell do
      double("Caliph::Shell")
    end

    let :runner do
      CommandRunner.new(config).tap do |runner|
        runner.shell = shell
      end
    end

    before do
      CommandGenerator.stub(:for).and_return(generator)
    end

    describe "single commands" do
      it 'should do export' do
        generator.should_receive(:export).and_return(command)
        shell.should_receive(:run).with(command)
        runner.export('path/to/file')
      end

      it 'should do import' do
        generator.should_receive(:import).and_return(command)
        shell.should_receive(:run).with(command)
        runner.import('path/to/file')
      end
    end
  end
end
