require 'rubygems'
require 'hpricot'
require 'open-uri'

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
    gid = (@doc/:division)["#{vote}".to_i]
    # we need to minus one off the second to last bit of the id
    # so we do a fucked up nasty hack
    gid = gid.attributes['id'][25..-1].split('.')
    gid[1] = gid[1].to_i+1
    gid = "http://www.openaustralia.org/debate/?id=" + gid[0] + "." + gid[1].to_s + "." + gid[2]
  end

  # Gets all the voters for a division, returns a two arrays in a hash
  # of names of ayes and noes
  def get_voters(vote)
    aye = Array.new
    no = Array.new
    division = (@doc/:division)["#{vote}".to_i]
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
