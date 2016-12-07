class Query < ApplicationRecord
  require 'open-uri'
  require 'open_uri_redirections'
  require 'rubygems'
  require 'mechanize'

  
  before_save :check_url
  after_save :lets_do_some_scrapping

  def lets_do_some_scrapping
    #use nokogiri to get all href (a) tags from page
    page = Nokogiri::HTML(open(self.url))
    
    # agent = Mechanize.new
    # agent.get(self.url)

    #go through list of a tags and remove any duplicates with uniq!
    links = page.css("a").map { | link| link['href'] }.uniq!    
    
    #remove any a tags that don't contain http or https
    links.select! { |link| link[/\Ahttp:\/\//] || link[/\Ahttps:\/\//] }

    #cycle through every page on domain and get all the links from them
    links.map! do |link|
      agent = Mechanize.new
      agent.get(link)
      agent.page.parser.css('a').map { | link| link['href'] }.uniq!
    end

    #get all the links into a single array, remove an nil values and remove duplicates
    all_links = links.flatten.compact.uniq!
    all_links.select! { |link| link[/\Ahttp:\/\//] || link[/\Ahttps:\/\//] }

    raise all_links.count.inspect

  end


protected

  def check_url
    unless self.url[/\Ahttp:\/\//] || self.url[/\Ahttps:\/\//]
      self.url = "http://#{self.url}"
    end
  end

end
