require "savon_zuora/version"
require "savon_zuora/config"
require "savon_zuora/client"
require "savon_zuora/model"

module SavonZuora
  extend self

  def client(*args, &block)
    Client.new(*args, &block)
  end

  def configure
    yield config
  end

  def config
    @config ||= Config.default
  end

  attr_writer :config

end
