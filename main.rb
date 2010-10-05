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
  # TODO: Only show the house(s) available
  haml :index
end

get '/:house/?' do |house|
  @dates = get_debate_list(house)
  haml :dates
end

get '/:house/:date/?' do |@house, @date|
  today = Vip.new(@date, @house)
  @number_of_divisions = today.div_count
  @page_title = "Division summary for #{@date}"
  @divisions = Array.new
  for i in (1..@number_of_divisions)
    i = i.to_s
    @divisions << { :date => @date,
                    :time => today.get_division_time(i),
                    :division_number => i,
                    :url => today.get_url(i, @house),
                    :question => today.get_vote_question(i) }
  end

  if params[:format] == "json"
    content_type :json
    @divisions.to_json
  else
    haml :day
  end
end

get '/:house/:date/:division/?' do |@house, @date, division|
  today = Vip.new(@date, @house)
  @page_title = "Votes for division number #{division}, held at #{today.get_division_time(division)} for day #{@date}"

  @division = { :division_number => division,
                :url => today.get_url(division, @house),
                :time => today.get_division_time(division),
                :ayes => today.get_voters(division, @house)['ayes'],
                :noes => today.get_voters(division, @house)['noes'] }

  if params[:format] == "json"
    content_type :json
    @division.to_json
  else
    haml :votes
  end
end

helpers do
  def link_to(text, url)
    "<a href=\"#{url}\">#{text}</a>"
  end
end
