require 'rubygems'
require 'hpricot'
require 'open-uri'

doc = Hpricot.parse(File.read("2010-06-03.xml"))

(doc/:division).each do |division|
  # we need to minus one off the second to last bit of the id
  # so we do a fucked up nasty hack
  gid = division.attributes['id'][25..-1].split('.')
  gid[1] = gid[1].to_i+1
  puts "URL: http://www.openaustralia.org/debate/?id=" + gid[0] + "." + gid[1].to_s + "." + gid[2]
  puts "Ayes: " + division.at("divisioncount").attributes['ayes']
  puts "Noes: " + division.at("divisioncount").attributes['noes']
end

