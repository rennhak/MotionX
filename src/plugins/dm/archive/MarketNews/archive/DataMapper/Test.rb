#! /usr/bin/ruby
#

# DataMapper promised to be better than ActiveRecord lets try it.

# http://rubypond.com/articles/2008/10/05/datamapper-migrations/
require 'rubygems'
require 'data_mapper'
require 'dm-core'

DataMapper.setup(:default, 'sqlite3::memory:')
# DataMapper.
