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
    @max_page = 5 # @noko_doc.css('.last a').attr("href").value.scan(/\d/).join.to_i
    make_pages
  end

  def make_pages
    (1..max_page).each { |page| PAGES[page] = :pending }
  end

  def get_next_page
    page = PAGES.find_index { |i| i == :pending }
    puts "Client requesting page ##{page}"
    if page
      { 
        :page => page,
        :url => "https://speakerdeck.com/p/all?page=#{page}"
      }
    else
      nil
    end
  end

  def update_page(page, decks)
    puts "Received update from client (#{page}: #{decks.size})"
    decks.each &:save
    PAGES[page] = :complete
  end

  # def self.clean_up
  #   PAGES.clear
  # end

end

ADDRESS="druby://localhost:8787"

FRONT_OBJECT=SpeakerDeck.new("https://speakerdeck.com/p/all")

#$SAFE = 1   # disable eval() and friends

DRb.start_service(ADDRESS, FRONT_OBJECT)
DRb.thread.join

# speaker_deck = SpeakerDeck.new
# speaker_deck.make_pages_array
# speaker_deck.create_pages
# Page.create_decks