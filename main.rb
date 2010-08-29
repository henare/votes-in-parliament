$LOAD_PATH.unshift File.dirname(__FILE__) + '/lib'

require 'rubygems'
require 'sinatra'
require 'vip'

# Set to true for application debugging (i.e. local files, rather than remote)
@debug = true

get '/' do
  @dates = get_debate_list
  erb :index
end


get '/:date' do |@date|
  today = Vip.new(@date)
  @number_of_divisions = today.div_count

  erb :day
end

get '/:date/:division' do |@date, division|
  today = Vip.new(@date)

  @division = division
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
