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
    PAGES << self
    get_links
    if PAGES.size % 50 == 0
      puts PAGES.size
    else
      print '.'
    end
  end

  def get_links
    @noko_doc.css('.talk-listing-meta').each do |deck|
      DECKS << "https://speakerdeck.com/#{deck.css('.title a').attr("href").value}"
    end
  end

  def self.create_decks
   DECKS.each do |deck|
      Deck.new(deck)
    end
  end

end