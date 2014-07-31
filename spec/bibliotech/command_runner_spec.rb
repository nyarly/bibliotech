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
      allow(CommandGenerator).to receive(:for).and_return(generator)
    end

    describe "single commands" do
      it 'should do export' do
        expect(generator).to receive(:export).and_return(command)
        expect(shell).to receive(:run).with(command)
        runner.export('path/to/file')
      end

      it 'should do import' do
        expect(generator).to receive(:import).and_return(command)
        expect(shell).to receive(:run).with(command)
        runner.import('path/to/file')
      end
    end
  end
end
