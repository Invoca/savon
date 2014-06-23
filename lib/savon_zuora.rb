require "savon_zuora/version"
require "savon_zuora/config"
require "savon_zuora/client"
require "savon_zuora/model"

module SavonZuora
  extend Config

  # Yields this module to a given +block+. Please refer to the
  # <tt>SavonZuora::Config</tt> module for configuration options.
  def self.configure
    yield self if block_given?
  end

end
