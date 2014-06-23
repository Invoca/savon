require "savon_zuora/error"

module Savon
  module SOAP
    # = SavonZuora::SOAP::InvalidResponseError
    #
    # Represents an error when the response was not a valid SOAP envelope.
    class InvalidResponseError < Error
    end
  end
end
