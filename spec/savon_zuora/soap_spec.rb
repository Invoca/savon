require "spec_helper"

describe SavonZuora::SOAP do

  it "should contain the SOAP namespace for each supported SOAP version" do
    SavonZuora::SOAP::VERSIONS.each do |soap_version|
      SavonZuora::SOAP::NAMESPACE[soap_version].should be_a(String)
      SavonZuora::SOAP::NAMESPACE[soap_version].should_not be_empty
    end
  end

  it "should contain a Rage of supported SOAP versions" do
    SavonZuora::SOAP::VERSIONS.should == (1..2)
  end

end
