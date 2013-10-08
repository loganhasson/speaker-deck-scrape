require 'open-uri'
require 'nokogiri'
require 'pry'

class Deck

  attr_accessor :url, :noko_doc, :title, :author, :date, :stars, :views, :category

  def initialize(url)
    @url = url
    @noko_doc = Nokogiri::HTML(open(url))
    scrape
    @link = "https://speakerdeck.com/#{@noko_doc.css('.talk-listing-meta .title a').attr("href").value}"
  end
  
  def scrape
    # scrape_title
    # scrape_author
    scrape_date
    # scrape_stars
    # scrape_views
    scrape_category
  end

  # def scrape_title
  #   @title = self.noko_doc.css('#talk-details h1').text.strip.split(' ').join(' ')
  #   puts "Title: " + self.title
  # end

  # def scrape_author
  #   @author = self.noko_doc.css('#talk-details h2 a').text.strip
  #   puts "Author: " + self.author
  # end

  def scrape_date
    @date = self.noko_doc.css('.talk-details p mark')
    puts self.date
  end

  # def scrape_stars
  #   @stars = self.noko_doc.css('.stargazers').children.first.text.scan(/\d/).join.to_i
  #   puts "Stars: " + self.stars.to_s
  # end

  # def scrape_views
  #   @views = self.noko_doc.css('.views span').text.scan(/\d/).join.to_i
  #   puts "Views: " + self.views.to_s
  # end

  def scrape_category
    @category = self.noko_doc.css('.talk-details p mark a')
    puts self.category
  end

end