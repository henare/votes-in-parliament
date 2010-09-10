$LOAD_PATH.unshift File.dirname(__FILE__) + '/lib'

require 'rubygems'
require 'sinatra'
require 'haml'
require 'json'
require 'vip'

# Set to true to get the XML files from the 'data'directory
# and not dynamically from data.openaustralia.org
LOCAL_STORAGE = false

get '/' do
  @dates = get_debate_list
  haml :index
end

get '/:date/?' do |@date|
  today = Vip.new(@date)
  @number_of_divisions = today.div_count
  @page_title = "Division summary for #{@date}"
  @divisions = Array.new
  for i in (1..@number_of_divisions)
    i = i.to_s
    @divisions << { :date => @date,
                    :time => today.get_division_time(i),
                    :division_number => i,
                    :url => today.get_url(i),
                    :question => today.get_vote_question(i) }
  end

  if params[:format] == "json"
    @divisions.to_json
  else
    haml :day
  end
end

get '/:date/:division/?' do |@date, division|
  today = Vip.new(@date)

  @division = division
  @url = today.get_url(division)
  @time = today.get_division_time(division)
  @page_title = "Votes for division number #{@division}, held at #{@time} for day #{@date}"

  @ayes = Array.new
  today.get_voters(division)['ayes'].each do |v|
    @ayes << v
  end

  @noes = Array.new
  today.get_voters(division)['noes'].each do |v|
    @noes << v
  end

  haml :votes
end

helpers do
  def link_to(text, url)
    "<a href=\"#{url}\">#{text}</a>"
  end
end
