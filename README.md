SavonZuora [![Build Status](https://secure.travis-ci.org/rubiii/savon_zuora.png?branch=master)](http://travis-ci.org/rubiii/savon_zuora)
=====

Heavy metal SOAP client

[Documentation](http://savon_zuorarb.com) | [RDoc](http://rubydoc.info/gems/savon_zuora) |
[Mailing list](https://groups.google.com/forum/#!forum/savon_zuorarb) | [Twitter](http://twitter.com/savon_zuorarb)

Installation
------------

SavonZuora is available through [Rubygems](http://rubygems.org/gems/savon_zuora) and can be installed via:

```
$ gem install savon_zuora
```

Introduction
------------

``` ruby
require "savon_zuora"

# create a client for your SOAP service
client = SavonZuora.client("http://service.example.com?wsdl")

client.wsdl.soap_actions
# => [:create_user, :get_user, :get_all_users]

# execute a SOAP request to call the "getUser" action
response = client.request(:get_user) do
  soap.body = { :id => 1 }
end

response.body
# => { :get_user_response => { :first_name => "The", :last_name => "Hoff" } }
```

Documentation
-------------

Continue reading at [savon_zuorarb.com](http://savon_zuorarb.com)
