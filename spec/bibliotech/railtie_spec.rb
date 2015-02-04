require 'rails/railtie'
require 'bibliotech/railtie'

describe "Bibliotech::Railtie" do
  it "should exist" do
    expect(defined? BiblioTech::Railtie).to be_truthy
  end
end
