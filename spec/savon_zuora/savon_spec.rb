require "spec_helper"

describe SavonZuora do

  describe ".configure" do
    around do |example|
      SavonZuora.reset_config!
      example.run
      SavonZuora.reset_config!
      SavonZuora.log = false  # disable logging
    end

    describe "log" do
      it "should default to true" do
        SavonZuora.log?.should be_true
      end

      it "should set whether to log HTTP requests" do
        SavonZuora.configure { |config| config.log = false }
        SavonZuora.log?.should be_false
      end

      context "when instructed to filter" do
        before do
          SavonZuora.log = true
        end

        context "and no log filter set" do
          it "should not filter the message" do
            SavonZuora.logger.expects(SavonZuora.log_level).with(Fixture.response(:authentication))
            SavonZuora.log(Fixture.response(:authentication), :filter)
          end
        end

        context "and multiple log filters" do
          before do
            SavonZuora.configure { |config| config.log_filter = ["logType", "logTime"] }
          end

          it "should filter element values" do
            filtered_values = /Notes Log|2010-09-21T18:22:01|2010-09-21T18:22:07/

            SavonZuora.logger.expects(SavonZuora.log_level).with do |msg|
              msg !~ filtered_values &&
              msg.include?('<ns10:logTime>***FILTERED***</ns10:logTime>') &&
              msg.include?('<ns10:logType>***FILTERED***</ns10:logType>') &&
              msg.include?('<ns11:logTime>***FILTERED***</ns11:logTime>') &&
              msg.include?('<ns11:logType>***FILTERED***</ns11:logType>')
            end

            SavonZuora.log(Fixture.response(:list), :filter)
          end
        end
      end
    end

    describe "logger" do
      it "should set the logger to use" do
        MyLogger = Class.new
        SavonZuora.configure { |config| config.logger = MyLogger }
        SavonZuora.logger.should == MyLogger
      end

      it "should default to Logger writing to STDOUT" do
        SavonZuora.logger.should be_a(Logger)
      end
    end

    describe "log_level" do
      it "should default to :debug" do
        SavonZuora.log_level.should == :debug
      end

      it "should set the log level to use" do
        SavonZuora.configure { |config| config.log_level = :info }
        SavonZuora.log_level.should == :info
      end
    end

    describe "raise_errors" do
      it "should default to true" do
        SavonZuora.raise_errors?.should be_true
      end

      it "should not raise errors when disabled" do
        SavonZuora.raise_errors = false
        SavonZuora.raise_errors?.should be_false
      end
    end

    describe "soap_version" do
      it "should default to SOAP 1.1" do
        SavonZuora.soap_version.should == 1
      end

      it "should return 2 if set to SOAP 1.2" do
        SavonZuora.soap_version = 2
        SavonZuora.soap_version.should == 2
      end

      it "should raise an ArgumentError in case of an invalid version" do
        lambda { SavonZuora.soap_version = 3 }.should raise_error(ArgumentError)
      end
    end
  end

end
