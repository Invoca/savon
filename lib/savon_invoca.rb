module SavonInvoca

  Error                = Class.new(RuntimeError)
  InitializationError  = Class.new(Error)
  InvalidResponseError = Class.new(Error)

  def self.client(globals = {}, &block)
    Client.new(globals, &block)
  end

  def self.observers
    @observers ||= []
  end

  def self.notify_observers(operation_name, builder, globals, locals)
    observers.inject(nil) do |response, observer|
      observer.notify(operation_name, builder, globals, locals)
    end
  end

end

require "savon_invoca/version"
require "savon_invoca/client"
require "savon_invoca/model"
