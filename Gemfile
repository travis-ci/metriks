# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.2.2'

gemspec

gem 'beefcake'

group :test do
  gem 'minitest'
  gem 'rake'
  gem 'rbtree', platform: :mri_18
  gem 'riemann-client'
end

group :development, :test do
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rspec'
  gem 'simplecov'
  gem 'simplecov-console'
end
