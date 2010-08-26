$LOAD_PATH.unshift File.dirname(__FILE__) + '/lib'

require 'rubygems'
require 'sinatra'
require 'vip'

get '/:date' do |date|
  today = Vip.new(date)
  #today = Vip.new('2010-06-03')
  
  @number_of_divisions = today.div_count
  erb :index
end

get '/:date/:division' do |date, division|
  today = Vip.new(date)
  #today = Vip.new('2010-06-03')
  
  @division = division
  @date = date
  @url = today.get_gid(division)
  
  @ayes = Array.new
  today.get_voters(division)['ayes'].each do |v|
    @ayes << "<li>" + v + "</li>"
  end
  
  @noes = Array.new
  today.get_voters(division)['noes'].each do |v|
    @noes << "<li>" + v + "</li>"
  end
  
  erb :votes
end
