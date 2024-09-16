require 'nokogiri'
require 'open-uri'

ARGV.each do |arg|
  puts arg
end

url = "https://example.com"
doc = Nokogiri::HTML(URI.open(url))
puts doc.title

# Print the working directory.
puts Dir.pwd

# Print the veresion of the Ruby interpreter.
puts RUBY_VERSION
