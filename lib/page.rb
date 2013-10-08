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
    @link = "https://speakerdeck.com/#{@noko_doc.css('.talk-listing-meta .title a').attr("href").value}"
    PAGES << self
    DECKS << @link
    create_decks
  end

  def create_decks
   DECKS.each do |deck|
      Deck.new(deck)
    end
  end

end