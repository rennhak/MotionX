#!/usr/bin/ruby -w

require 'DataMapper'


class User
  include DataMapper::Resource
  
  property :id,     Serial
  property :login,  String
  
end

