require 'open-uri'
require 'nokogiri'
require 'pry'
require 'chronic'
require 'sqlite3'

class Deck

  attr_accessor :url, :noko_doc, :title, :author, :date, :stars, :views, :category, :link

  DECKS = []

  def initialize(url)
    @url = url
    @noko_doc = Nokogiri::HTML(open(url))
    scrape
    @link = "https://speakerdeck.com/#{@noko_doc.css('.talk-listing-meta .title a').attr("href").value}"
    DECKS << self
    save
  end
  
  def scrape
    scrape_title
    scrape_author
    scrape_date
    scrape_stars
    scrape_views
    scrape_category
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

  def save
    begin
      speaker_deck = SQLite3::Database.new( "speaker_deck.db" )
      speaker_deck.execute "CREATE TABLE IF NOT EXISTS decks(id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        author TEXT,
        date DATE,
        category TEXT,
        url TEXT,
        stars INTEGER,
        views INTEGER)"

      speaker_deck.execute "INSERT INTO decks (title,
        author,
        date,
        category,
        url,
        stars,
        views) VALUES (?,?,?,?,?,?,?)", [self.title,
                                         self.author,
                                         self.date,
                                         self.category,
                                         self.link,
                                         self.stars,
                                         self.views]

      puts self.title + "saved!"
    ensure
      speaker_deck.close if speaker_deck
    end
  end

end