class Query < ApplicationRecord
  require 'open-uri'
  
  before_save :check_url
  after_save :lets_do_some_scrapping

  def lets_do_some_scrapping
    page = Nokogiri::HTML(open(self.url))
    
    links = page.css("a")

    raise links.count.inspect

  end

protected

  def check_url
    unless self.url[/\Ahttp:\/\//] || self.url[/\Ahttps:\/\//]
      self.url = "http://#{self.url}"
    end
  end

end
