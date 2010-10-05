require 'rubygems'
require 'hpricot'
require 'open-uri'

def get_debate_list(house)
  # TODO: Sort the list
  dates = Array.new
  if LOCAL_STORAGE
    Dir["data/#{house}_debates/*.xml"].each do |f|
      puts f
      dates << "<li><a href=\"/#{house}/" + f[-14..-5] + '">' + f[-14..-5] + "</a></li>\n"
    end
  else
    url = "http://data.openaustralia.org/scrapedxml/#{house}_debates/"
    doc = Hpricot.parse(open(url))
    doc.search("a").each do |a|
      if a.inner_text[-3..-1] == "xml"
        dates << "<li><a href=\"/#{house}/" + a.inner_text[0..9] + '">' + a.inner_text[0..9] + "</a></li>\n"
      end
    end
  end
  dates
end

class Vip

  def initialize(date, house)
    if LOCAL_STORAGE
      @doc = Hpricot.parse(open("data/#{house}_debates/#{date}.xml"))
    else
      url = "http://data.openaustralia.org/scrapedxml/#{house}_debates/"
      @doc = Hpricot.parse(open("#{url}#{date}.xml"))
    end
  end

  # How many divisions today?
  def div_count
    (@doc/:division).count
  end

  # Show me the OA URL for a debate
  def get_url(vote, house)
    # IMPROVE: This doesn't feel right
    if house == "representatives"
      gid_house = "debate"
    elsif house == "senate"
      gid_house = "senate"
    end
    vote = vote.to_i - 1
    gid = (@doc/:division)[vote].previous.previous.attributes['id'].split('/')[-1]
    gid = "http://www.openaustralia.org/#{gid_house}/?id=" + gid
  end

  # What time did a division happen?
  def get_division_time(vote)
    time = (@doc/:division)[vote.to_i - 1].attributes['time']
  end

  # Get the debate text immedately prior to the division
  def get_vote_question(vote)
    vote = vote.to_i - 1
    (@doc/:division)[vote].previous.previous.inner_text
  end

  # Gets all the voters for a division, returns a two arrays in a hash
  # of names of ayes and noes
  def get_voters(vote, house)
    vote = vote.to_i - 1
    aye = Array.new
    no = Array.new
    division = (@doc/:division)[vote]

    # Gets more detail about the voter by parsing more OA XML, such as party
    if LOCAL_STORAGE
      if house == "senate"
        uri = "data/senators.xml"
      elsif house == "representatives"
        uri = "data/representatives.xml"
      end
    else
      if house == "senate"
        uri = "http://data.openaustralia.org/members/senators.xml"
      elsif house == "representatives"
        uri = "http://data.openaustralia.org/members/representatives.xml"
      end
    end
    members = Hpricot.parse(open(uri))

    (division/:memberlist).each do |l|
      (l/:member).each do |m|
        party = members.search("member[@id=#{m.attributes['id']}]").first[:party]
        if house = "representatives"
          url = "http://www.openaustralia.org/mp/?m=" + m.attributes['id'][25..-1]
        elsif house == "senate"
          url = "http://www.openaustralia.org/mp/?m=" + m.attributes['id'][23..-1]
        end
        if m.attributes['vote'] == "aye"
          aye << { :name => m.inner_text,
                   :party => party,
                   :url => url
                 }
        else
          no << { :name => m.inner_text,
                  :party => party,
                  :url => url
                }
        end
      end
    end
    votes = { 'ayes' => aye, 'noes' => no }
  end
end
