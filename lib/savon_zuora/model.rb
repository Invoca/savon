module SavonZuora

  # = SavonZuora::Model
  #
  # Model for SOAP service oriented applications.
  module Model

    def self.extended(base)
      base.setup
    end

    def setup
      class_action_module
      instance_action_module
    end

    # Accepts one or more SOAP actions and generates both class and instance methods named
    # after the given actions. Each generated method accepts an optional SOAP body Hash and
    # a block to be passed to <tt>SavonZuora::Client#request</tt> and executes a SOAP request.
    def actions(*actions)
      actions.each do |action|
        define_class_action(action)
        define_instance_action(action)
      end
    end

  private

    # Defines a class-level SOAP action method.
    def define_class_action(action)
      class_action_module.module_eval %{
        def #{action.to_s.snakecase}(body = nil, &block)
          response = client.request :wsdl, #{action.inspect}, :body => body, &block
          SavonZuora.hooks.select(:model_soap_response).call(response) || response
        end
      }
    end

    # Defines an instance-level SOAP action method.
    def define_instance_action(action)
      instance_action_module.module_eval %{
        def #{action.to_s.snakecase}(body = nil, &block)
          self.class.#{action.to_s.snakecase} body, &block
        end
      }
    end

    # Class methods.
    def class_action_module
      @class_action_module ||= Module.new do

        # Returns the memoized <tt>SavonZuora::Client</tt>.
        def client(&block)
          @client ||= SavonZuora::Client.new(&block)
        end

        # Sets the SOAP endpoint to the given +uri+.
        def endpoint(uri)
          client.wsdl.endpoint = uri
        end

        # Sets the target namespace.
        def namespace(uri)
          client.wsdl.namespace = uri
        end

        # Sets the WSDL document to the given +uri+.
        def document(uri)
          client.wsdl.document = uri
        end

        # Sets the HTTP headers.
        def headers(headers)
          client.http.headers = headers
        end

        # Sets basic auth +login+ and +password+.
        def basic_auth(login, password)
          client.http.auth.basic(login, password)
        end

        # Sets WSSE auth credentials.
        def wsse_auth(*args)
          client.wsse.credentials(*args)
        end

      end.tap { |mod| extend(mod) }
    end

    # Instance methods.
    def instance_action_module
      @instance_action_module ||= Module.new do

        # Returns the <tt>SavonZuora::Client</tt> from the class instance.
        def client(&block)
          self.class.client(&block)
        end

      end.tap { |mod| include(mod) }
    end

  end
end
