require 'rubygems'
require 'hpricot'
require 'open-uri'

def get_debate_list
  # For testing:
  #url = "./Index\ of\ _scrapedxml_representatives_debates.html"
  url = "http://data.openaustralia.org/scrapedxml/representatives_debates/"
  doc = Hpricot.parse(open(url))
  dates = Array.new
  doc.search("a").each do |a|
    if a.inner_text[-3..-1] == "xml"
      dates << '<li><a href="/' + a.inner_text[0..9] + '">' + a.inner_text[0..9] + '</a></li>'
    end
  end
  dates
end

class Vip

  def initialize(date)
    # For testing:
    #url = "./"
    url = "http://data.openaustralia.org/scrapedxml/representatives_debates/"
    @doc = Hpricot.parse(open("#{url}#{date}.xml"))
  end

  # How many divisions today?
  def div_count
    (@doc/:division).count
  end

  # Show me the OA URL for a debate
  def get_gid(vote)
    vote = vote.to_i - 1
    gid = (@doc/:division)[vote]
    # FIXME: The below tries to derive the correct GID for the speech the
    # division is referring to but it doesn't seem to work well
    gid = gid.attributes['id'][25..-1].split('.')
    gid[1] = gid[1].to_i+1
    gid = "http://www.openaustralia.org/debate/?id=" + gid[0] + "." + gid[1].to_s + "." + gid[2]
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
