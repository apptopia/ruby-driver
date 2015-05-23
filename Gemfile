source 'https://rubygems.org/'

gemspec

gem 'snappy',        :group => [:development, :test]
gem 'lz4-ruby',      :group => [:development, :test]
gem 'rake-compiler', :group => [:development, :test]
gem 'cliver',        :group => [:development, :test]

group :development do
  platforms :mri_19 do
    gem 'perftools.rb'
    gem 'guard'
    gem 'guard-nanoc'
    gem 'byte_buffer', git: 'git://github.com/apptopia/byte_buffer.git'
  end
end

group :test do
  gem 'rspec'
  gem 'rspec-wait'
  gem 'rspec-collection_matchers'
  gem 'simplecov'
  gem 'cucumber'
  gem 'aruba'
  gem 'os'
  gem 'minitest'
end

group :docs do
  gem 'yard'

  platforms :mri_19 do
    gem 'gherkin'
    gem 'htmlbeautifier'
    gem 'nanoc'
    gem 'nanoc-toolbox'
    gem 'compass'
    gem 'bootstrap-sass'
    gem 'nokogiri'
    gem 'rubypants'
    gem 'rouge'
    gem 'redcarpet'
    gem 'ditaarb'
  end
end
