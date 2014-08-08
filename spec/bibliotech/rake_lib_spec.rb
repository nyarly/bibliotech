require 'bibliotech/rake_lib'

module BiblioTech
  describe Tasklib do
    let :mock_shell do
      double("Caliph::Shell")
    end

    subject :rakelib do
      Tasklib.new do |lib|
        lib.app.shell = mock_shell
      end
    end

    it "should something something" do
      expect(rakelib).not_to be_nil

    end

  end
end
