require 'rubygems'
require 'hpricot'
require 'open-uri'

def get_debate_list
  # TODO: Sort the list
  dates = Array.new
  if LOCAL_STORAGE
    Dir['data/*.xml'].each do |f|
      dates << '<li><a href="/' + f[5..14] + '">' + f[5..14] + "</a></li>\n"
    end
  else
    url = "http://data.openaustralia.org/scrapedxml/representatives_debates/"
    doc = Hpricot.parse(open(url))
    doc.search("a").each do |a|
      if a.inner_text[-3..-1] == "xml"
        dates << '<li><a href="/' + a.inner_text[0..9] + '">' + a.inner_text[0..9] + "</a></li>\n"
      end
    end
  end
  dates
end

class Vip

  def initialize(date)
    if LOCAL_STORAGE
      @doc = Hpricot.parse(open("data/#{date}.xml"))
    else
      url = "http://data.openaustralia.org/scrapedxml/representatives_debates/"
      @doc = Hpricot.parse(open("#{url}#{date}.xml"))
    end
  end

  # How many divisions today?
  def div_count
    (@doc/:division).count
  end

  # Show me the OA URL for a debate
  def get_url(vote)
    vote = vote.to_i - 1
    gid = (@doc/:division)[vote].previous.previous.attributes['id'][25..-1]
    gid = "http://www.openaustralia.org/debate/?id=" + gid
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
  def get_voters(vote)
    vote = vote.to_i - 1
    aye = Array.new
    no = Array.new
    division = (@doc/:division)[vote]
    (division/:memberlist).each do |l|
      (l/:member).each do |m|
        if m.attributes['vote'] == "aye"
          aye << m.inner_text
        else
          no << m.inner_text
        end
      end
    end
    votes = { 'ayes' => aye, 'noes' => no }
  end

end
