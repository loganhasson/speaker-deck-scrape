require 'open-uri'
require 'nokogiri'
require 'pry'
require 'chronic'
require 'sqlite3'
require 'colorize'

class Deck

  attr_accessor :url, :noko_doc, :title, :author, :date, :stars, :views,
                :category, :link, :pdf, :client

  @@count = 0

  DECKS = []

  def initialize(url, client)
    @url = url
    @client = client
    puts "Crawling #{@url}"
    puts ""
    @noko_doc = Nokogiri::HTML(open(url))
    DECKS << self
    scrape
    @link = "https://speakerdeck.com#{@noko_doc.css('.talk-listing-meta .title a').attr("href").value}"
  end
  
  def scrape
    @@count += 1
    # puts "Overall Progress"
    # print "#{((@@count.to_f/Page::DECKS.size)*100).round(2)}% ".red
    # print "["
    # print ("="*((@@count.to_f/Page::DECKS.size)*50.floor) + ">").ljust(50, ' ')
    # puts "]"
    scrape_title
    scrape_author
    scrape_date
    scrape_stars
    scrape_views
    scrape_category
    scrape_pdf
  end

  def self.all
    DECKS
  end

  def self.reset_all
    DECKS.clear
  end

  def scrape_title
    @title = self.noko_doc.css('#talk-details h1').text.strip.split(' ').join(' ')
  end

  def scrape_author
    @author = self.noko_doc.css('#talk-details h2 a').text.strip
  end

  def scrape_date
    @date = self.noko_doc.css('#talk-details p mark').text[/.*\d{4}/].strip
  end

  def scrape_stars
    @stars = self.noko_doc.css('.stargazers').children.first.text.scan(/\d/).join.to_i
  end

  def scrape_views
    @views = self.noko_doc.css('.views span').text.scan(/\d/).join.to_i
  end

  def scrape_category
    @category = self.noko_doc.css('#talk-details p mark a').text.strip
  end

  def scrape_pdf
    @pdf = self.noko_doc.css('a[id="share_pdf"]').attr('href').text
    # system("mkdir -p pdfs")
    # system("wget #{@pdf} -O pdfs/#{@pdf.split('/').last}")
  end

end