# Load the Rails application.
require File.expand_path('../application', __FILE__)

puts "before init. ENV['RAILS_ENV'] = #{ENV['RAILS_ENV']}"

# Initialize the Rails application.
Rails.application.initialize!

puts 'after init.'
