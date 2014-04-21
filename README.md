# Authorizator::Client

The authorizator-client gem is the Ruby client to give access to the ideas4all's Authorizator service to other services. It:

  - gives the caller access to the Authorizator service's api through common Ruby modules, classes and methods.
  - communicates with the Authorizator service's api via the OAuth2 protocol,
  - take care of security concerns in a transparent way to the caller,
  - parses responses and returns plain Ruby objects from the http json responses.


## Installation

Add this line to your application's Gemfile:

    gem 'authorizator-client'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install authorizator-client

## Usage

Run

    bundle exec rspec spec/README_FOR_USERS_spec.rb

test to see info of how to use this gem.

