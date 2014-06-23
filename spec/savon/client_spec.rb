require "spec_helper"
require "integration/support/server"

describe SavonInvoca::Client do

  before :all do
    @server = IntegrationServer.run
  end

  after :all do
    @server.stop
  end

  describe ".new" do
    it "supports a block without arguments to create a client with global options" do
      client = SavonInvoca.client do
        wsdl Fixture.wsdl(:authentication)
      end

      expect(client.globals[:wsdl]).to eq(Fixture.wsdl(:authentication))
    end

    it "supports a block with one argument to create a client with global options" do
      client = SavonInvoca.client do |globals|
        globals.wsdl Fixture.wsdl(:authentication)
      end

      expect(client.globals[:wsdl]).to eq(Fixture.wsdl(:authentication))
    end

    it "builds an HTTPI request for Wasabi" do
      http_request = mock
      wsdl_request = mock(:build => http_request)
      SavonInvoca::WSDLRequest.expects(:new).with(instance_of(SavonInvoca::GlobalOptions)).returns(wsdl_request)

      Wasabi::Document.any_instance.expects(:request=).with(http_request)
      SavonInvoca.client(:wsdl => "http://example.com")
    end

    it "raises if initialized with anything other than a Hash" do
      expect { SavonInvoca.client("http://example.com") }.
        to raise_error(SavonInvoca::InitializationError, /Some code tries to initialize SavonInvoca with the "http:\/\/example\.com" \(String\)/)
    end

    it "raises if not initialized with either a :wsdl or both :endpoint and :namespace options" do
      expect { SavonInvoca.client(:endpoint => "http://example.com") }.
        to raise_error(SavonInvoca::InitializationError, /Expected either a WSDL document or the SOAP endpoint and target namespace options/)
    end
  end

  describe "#globals" do
    it "returns the current set of global options" do
      expect(new_client.globals).to be_an_instance_of(SavonInvoca::GlobalOptions)
    end
  end

  describe "#operations" do
    it "returns all operation names" do
      operations = new_client.operations
      expect(operations).to eq([:authenticate])
    end

    it "raises when there is no WSDL document" do
      expect { new_client_without_wsdl.operations }.to raise_error("Unable to inspect the service without a WSDL document.")
    end
  end

  describe "#operation" do
    it "returns a new SOAP operation" do
      operation = new_client.operation(:authenticate)
      expect(operation).to be_a(SavonInvoca::Operation)
    end

    it "raises if there's no such SOAP operation" do
      expect { new_client.operation(:does_not_exist) }.
        to raise_error(ArgumentError)
    end

    it "does not raise when there is no WSDL document" do
      new_client_without_wsdl.operation(:does_not_exist)
    end
  end

  describe "#call" do
    it "calls a new SOAP operation" do
      locals = { :message => { :symbol => "AAPL" } }
      soap_response = new_soap_response

      wsdl = Wasabi::Document.new('http://example.com')
      operation = SavonInvoca::Operation.new(:authenticate, wsdl, SavonInvoca::GlobalOptions.new)
      operation.expects(:call).with(locals).returns(soap_response)

      SavonInvoca::Operation.expects(:create).with(
        :authenticate,
        instance_of(Wasabi::Document),
        instance_of(SavonInvoca::GlobalOptions)
      ).returns(operation)

      response = new_client.call(:authenticate, locals)
      expect(response).to eq(soap_response)
    end

    it "supports a block without arguments to call an operation with local options" do
      client = new_client(:endpoint => @server.url(:repeat))

      response = client.call(:authenticate) do
        message(:symbol => "AAPL" )
      end

      expect(response.http.body).to include("<symbol>AAPL</symbol>")
    end

    it "supports a block with one argument to call an operation with local options" do
      client = new_client(:endpoint => @server.url(:repeat))

      # supports instance variables!
      @instance_variable = { :symbol => "AAPL" }

      response = client.call(:authenticate) do |locals|
        locals.message(@instance_variable)
      end

      expect(response.http.body).to include("<symbol>AAPL</symbol>")
    end

    it "accepts arguments for the message tag" do
      client   = new_client(:endpoint => @server.url(:repeat))
      response = client.call(:authenticate, :attributes => { "ID" => "ABC321"})

      expect(response.http.body).to include('<tns:authenticate ID="ABC321">')
    end

    it "raises when the operation name is not a symbol" do
      expect { new_client.call("not a symbol") }.to raise_error(
        ArgumentError,
        "Expected the first parameter (the name of the operation to call) to be a symbol\n" \
        "Actual: \"not a symbol\" (String)"
      )
    end
  end

  def new_http_response(options = {})
    defaults = { :code => 200, :headers => {}, :body => Fixture.response(:authentication) }
    response = defaults.merge options

    HTTPI::Response.new response[:code], response[:headers], response[:body]
  end

  def new_soap_response(options = {})
    http = new_http_response(options)
    globals = SavonInvoca::GlobalOptions.new
    locals = SavonInvoca::LocalOptions.new

    SavonInvoca::Response.new(http, globals, locals)
  end

  def new_client(globals = {})
    globals = { :wsdl => Fixture.wsdl(:authentication), :log => false }.merge(globals)
    SavonInvoca.client(globals)
  end

  def new_client_without_wsdl(globals = {})
    globals = { :endpoint => "http://example.co", :namespace => "http://v1.example.com", :log => false }.merge(globals)
    SavonInvoca.client(globals)
  end

end
