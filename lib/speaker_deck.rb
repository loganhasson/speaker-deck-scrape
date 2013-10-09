require 'open-uri'
require 'nokogiri'
require 'pry'
require 'drb/drb'

require_relative 'deck'

class SpeakerDeck

  attr_accessor :max_page, :noko_doc, :url

  PAGES = []

  def initialize(url)
    @url = url
    @noko_doc = Nokogiri::HTML(open(url))
    @max_page = @noko_doc.css('.last a').attr("href").value.scan(/\d/).join.to_i
    make_pages
  end

  def make_pages
    (1..max_page).each { |page| PAGES[page] = :pending }
  end

  def get_next_page(client_id)
    page = PAGES.find_index { |i| i == :pending }
    if page
      puts "#{client_id} requesting page # #{page}"
      PAGES[page] = :crawling
      { 
        :page => page,
        :url => "https://speakerdeck.com/p/all?page=#{page}"
      }
    else
      nil
    end
  end

  def self.sweep
    # Pending
  end

  def self.clear_db
    begin
      speaker_deck = SQLite3::Database.new( "speaker_deck_drb.db" )
      speaker_deck.execute "DELETE FROM decks;"
    ensure
      speaker_deck.close if speaker_deck
    end
  end
  
  def update_page(page, decks, client)
    puts "Received update from #{client} (#{page}: #{decks.size})"
    decks.each do |deck|
      self.save(deck)
    end
    PAGES[page] = :complete
  end

  def save(deck)
    begin
      speaker_deck = SQLite3::Database.new( "speaker_deck_drb.db" )
      speaker_deck.execute "CREATE TABLE IF NOT EXISTS decks(id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        author TEXT,
        date DATE,
        category TEXT,
        url TEXT,
        stars INTEGER,
        views INTEGER,
        pdf TEXT,
        client TEXT)"

      speaker_deck.execute "INSERT INTO decks (title,
        author,
        date,
        category,
        url,
        stars,
        views,
        pdf,
        client) VALUES (?,?,?,?,?,?,?,?,?)", [deck.title,
                                              deck.author,
                                              deck.date,
                                              deck.category,
                                              deck.link,
                                              deck.stars,
                                              deck.views,
                                              deck.pdf,
                                              deck.client]
    ensure
      speaker_deck.close if speaker_deck
    end
  end

end

speaker_deck = SQLite3::Database.new( "speaker_deck_drb.db" )
speaker_deck.execute "CREATE TABLE IF NOT EXISTS decks(id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          author TEXT,
          date DATE,
          category TEXT,
          url TEXT,
          stars INTEGER,
          views INTEGER,
          pdf TEXT,
          client TEXT)"
SpeakerDeck.clear_db

ADDRESS="druby://localhost:8787"

FRONT_OBJECT=SpeakerDeck.new("https://speakerdeck.com/p/all")

#$SAFE = 1   # disable eval() and friends

DRb.start_service(ADDRESS, FRONT_OBJECT)
DRb.thread.join

# speaker_deck = SpeakerDeck.new
# speaker_deck.make_pages_array
# speaker_deck.create_pages
# Page.create_decks