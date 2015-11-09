require "savon_zuora/soap/xml"
require "savon_zuora/soap/fault"
require "savon_zuora/soap/invalid_response_error"
require "savon_zuora/http/error"

module SavonZuora
  module SOAP

    # = SavonZuora::SOAP::Response
    #
    # Represents the SOAP response and contains the HTTP response.
    class Response

      include NoriLoader

      # Expects an <tt>HTTPI::Response</tt> and handles errors.
      def initialize(response)
        self.http = response
        raise_errors if SavonZuora.raise_errors?
      end

      attr_accessor :http

      # Returns whether the request was successful.
      def success?
        !soap_fault? && !http_error?
      end

      # Returns whether there was a SOAP fault.
      def soap_fault?
        soap_fault.present?
      end

      # Returns the <tt>SavonZuora::SOAP::Fault</tt>.
      def soap_fault
        @soap_fault ||= Fault.new http
      end

      # Returns whether there was an HTTP error.
      def http_error?
        http_error.present?
      end

      # Returns the <tt>SavonZuora::HTTP::Error</tt>.
      def http_error
        @http_error ||= HTTP::Error.new http
      end

      # Shortcut accessor for the SOAP response body Hash.
      def [](key)
        body[key]
      end

      # Returns the SOAP response header as a Hash.
      def header
        if !hash.has_key? :envelope
          raise SavonZuora::SOAP::InvalidResponseError, "Unable to parse response body '#{to_xml}'"
        end
        hash[:envelope][:header]
      end

      # Returns the SOAP response body as a Hash.
      def body
        if !hash.has_key? :envelope
          raise SavonZuora::SOAP::InvalidResponseError, "Unable to parse response body '#{to_xml}'"
        end
        hash[:envelope][:body]
      end

      alias to_hash body

      # Traverses the SOAP response body Hash for a given +path+ of Hash keys and returns
      # the value as an Array. Defaults to return an empty Array in case the path does not
      # exist or returns nil.
      def to_array(*path)
        result = path.inject body do |memo, key|
          return [] unless memo[key]
          memo[key]
        end

        result.kind_of?(Array) ? result.compact : [result].compact
      end

      # Returns the complete SOAP response XML without normalization.
      def hash
        @hash ||= nori.parse(to_xml)
      end

      # Returns the SOAP response XML.
      def to_xml
        http.body
      end

      # Returns a <tt>Nokogiri::XML::Document</tt> for the SOAP response XML.
      def doc
        @doc ||= Nokogiri::XML(to_xml)
      end

      # Returns an Array of <tt>Nokogiri::XML::Node</tt> objects retrieved with the given +path+.
      # Automatically adds all of the document's namespaces unless a +namespaces+ hash is provided.
      def xpath(path, namespaces = nil)
        doc.xpath(path, namespaces || xml_namespaces)
      end

    private

      def raise_errors
        raise soap_fault if soap_fault?
        raise http_error if http_error?
      end

      def xml_namespaces
        @xml_namespaces ||= doc.collect_namespaces
      end

    end
  end
end
