require 'open-uri'
require 'nokogiri'
require 'pry'
require 'drb/drb'

require_relative 'deck'

class Page

  attr_accessor :url, :noko_doc, :link


  def initialize(url)
    @url = url
    @noko_doc = Nokogiri::HTML(open(url))
    @decks = []
    get_links
    create_decks
  end

  def get_links
    @noko_doc.css('.talk-listing-meta').each do |deck|
      @decks << "https://speakerdeck.com/#{deck.css('.title a').attr("href").value}"
    end
  end

  def create_decks
    @decks.each do |deck|
      begin
        Deck.new(deck)
        # sleep(0.5)
      rescue
        puts deck + " was not saved."
      end
    end
  end

end

ADDRESS="druby://localhost:8787"

DRb.start_service
page_service = DRbObject.new_with_uri(ADDRESS)

while page_data = page_service.get_next_page
  Page.new(page_data[:url])
  puts "Processing page #{page_data[:page]} at #{page_data[:url]}"
  page_service.update_page(page_data[:page], Deck.all)
  Deck.reset_all
end