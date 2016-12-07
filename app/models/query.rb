class Query < ApplicationRecord
  require 'open-uri'
  require 'open_uri_redirections'
  
  before_save :check_url
  after_save :lets_do_some_scrapping

  def lets_do_some_scrapping
    #use nokogiri to get all href (a) tags from page
    page = Nokogiri::HTML(open(self.url))
    
    #go through list of a tags and remove any duplicates with uniq!
    links = page.css("a").map { | link| link['href'] }.uniq!
    
    #remove any a tags that don't contain http or https
    links.select! { |link| link[/\Ahttp:\/\//] || link[/\Ahttps:\/\//] }

    clean_links = links.map do |link|
      Nokogiri::HTML(open(link, :allow_redirections => :all))
    end

    raise clean_links.inspect

  end


protected

  def check_url
    unless self.url[/\Ahttp:\/\//] || self.url[/\Ahttps:\/\//]
      self.url = "http://#{self.url}"
    end
  end

end
