$LOAD_PATH.unshift File.dirname(__FILE__) + '/lib'

require 'rubygems'
require 'sinatra'
require 'vip'

# Set to true to get the XML files from the 'data'directory
# and not dynamically from data.openaustralia.org
LOCAL_STORAGE = true

get '/' do
  @dates = get_debate_list
  erb :index
end

get '/:date' do |@date|
  today = Vip.new(@date)
  @number_of_divisions = today.div_count

  @divisions = Array.new
  for i in (1..@number_of_divisions)
    i = i.to_s
    @divisions << '<li><a href="' + @date + '/' + i + '">' + today.get_division_time(i) + '</a> - ' +
      '<a href="' + today.get_url(i) + '">Division question:</a> ' + today.get_vote_question(i) + '</li>'
  end

  erb :day
end

get '/:date/:division' do |@date, division|
  today = Vip.new(@date)

  @division = division
  @url = today.get_url(division)
  @time = today.get_division_time(division)

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
