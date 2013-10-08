require 'open-uri'
require 'nokogiri'
require 'pry'

require_relative './deck.rb'

class Page

  attr_accessor :url, :noko_doc, :link

  PAGES = []
  DECKS = []

  def initialize(url)
    @url = url
    @noko_doc = Nokogiri::HTML(open(url))
    PAGES << 1
    get_links
    system('clear')
    puts "[#{((PAGES.size.to_f/SpeakerDeck::PAGES.size)*100).round(2)}%]"
  end

  def get_links
    @noko_doc.css('.talk-listing-meta').each do |deck|
      DECKS << "https://speakerdeck.com/#{deck.css('.title a').attr("href").value}"
    end
  end

  def self.create_decks
    DECKS.each do |deck|
      begin
        Deck.new(deck)
        sleep(0.5)
      rescue
        puts deck + " was not saved."
      end
    end
  end

end