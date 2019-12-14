require "spec_helper"

describe SavonZuora do

  it "provides a shortcut for creating a new client" do
    SavonZuora.client("http://example.com").should be_a(SavonZuora::Client)
  end

  it "memoizes the global config" do
    SavonZuora.config.should equal(SavonZuora.config)
  end

  it "yields the global config to a block" do
    SavonZuora.configure do |config|
      config.should equal(SavonZuora.config)
    end
  end

  describe ".config" do
    it "defaults to a log facade" do
      SavonZuora.config.logger.should be_a(SavonZuora::Logger)
    end

    it "defaults to raise errors" do
      SavonZuora.config.raise_errors.should be_true
    end

    it "defaults to SOAP 1.1" do
      SavonZuora.config.soap_version.should == 1
    end
  end

end
