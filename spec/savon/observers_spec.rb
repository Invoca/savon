require "spec_helper"
require "integration/support/server"

describe SavonInvoca do

  before :all do
    @server = IntegrationServer.run
  end

  after :all do
    @server.stop
  end

  describe ".observers" do
    after :each do
      SavonInvoca.observers.clear
    end

    it "allows to register an observer for every request" do
      observer = Class.new {

        def notify(operation_name, builder, globals, locals)
          @operation_name = operation_name

          @builder = builder
          @globals = globals
          @locals  = locals

          # return nil to execute the request
          nil
        end

        attr_reader :operation_name, :builder, :globals, :locals

      }.new

      SavonInvoca.observers << observer

      new_client.call(:authenticate)

      expect(observer.operation_name).to eq(:authenticate)

      expect(observer.builder).to be_a(SavonInvoca::Builder)
      expect(observer.globals).to be_a(SavonInvoca::GlobalOptions)
      expect(observer.locals).to  be_a(SavonInvoca::LocalOptions)
    end

    it "allows to register an observer which mocks requests" do
      observer = Class.new {

        def notify(*)
          # return a response to mock the request
          HTTPI::Response.new(201, { "X-Result" => "valid" }, "valid!")
        end

      }.new

      SavonInvoca.observers << observer

      response = new_client.call(:authenticate)

      expect(response.http.code).to eq(201)
      expect(response.http.headers).to eq("X-Result" => "valid")
      expect(response.http.body).to eq("valid!")
    end

    it "raises if an observer returns something other than nil or an HTTPI::Response" do
      observer = Class.new {

        def notify(*)
          []
        end

      }.new

      SavonInvoca.observers << observer

      expect { new_client.call(:authenticate) }.
        to raise_error(SavonInvoca::Error, "Observers need to return an HTTPI::Response " \
                                     "to mock the request or nil to execute the request.")
    end
  end

  def new_client
    SavonInvoca.client(
      :endpoint  => @server.url(:repeat),
      :namespace => "http://v1.example.com",
      :log       => false
    )
  end

end
