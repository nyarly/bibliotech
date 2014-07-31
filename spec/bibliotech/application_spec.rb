require 'bibliotech/application'

module BiblioTech
  describe Application do
    subject :application do
      Application.new
    end

    it "should load successfully" do
      expect(application.commands).to be_a CommandGenerator
    end
  end
end
