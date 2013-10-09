require 'open-uri'
require 'nokogiri'
require 'pry'
require 'drb/drb'
require 'colorize'

require_relative 'deck'

class Page

  attr_accessor :url, :noko_doc, :link, :client


  def initialize(url, client)
    @url = url
    @client = client
    done = false
    wait_time = 0
    while !done && wait_time < 30
      begin
        @noko_doc = Nokogiri::HTML(open(url))
        done = true
      rescue
        wait_time += 2
        sleep(wait_time)
      end
    end
    puts "#{wait_time} seconds for last request.".red if wait_time != 0
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
      Deck.new(deck, self.client)
    end
  end

  def self.start_client(num)

    address="druby://localhost:8787"
    DRb.start_service

    num.times do
      user = "User_#{rand(1000..4000)}"
      page_service = DRbObject.new_with_uri(address)
      while page_data = page_service.get_next_page(user)
        Page.new(page_data[:url], user)
        puts "Processing page #{page_data[:page]} at #{page_data[:url]}"
        page_service.update_page(page_data[:page], Deck.all, user)
        Deck.reset_all
      end
    end
  end

  def self.run
    50.times do
      system('ruby page.rb &')
    end
  end

end

if ARGV[0] == 'go'
  Page.run
else
  Page.start_client(1)
end

# ADDRESS="druby://localhost:8787"

# DRb.start_service
# page_service = DRbObject.new_with_uri(ADDRESS)

# while page_data = page_service.get_next_page
#   Page.new(page_data[:url], ARGV.first)
#   puts "Processing page #{page_data[:page]} at #{page_data[:url]}"
#   page_service.update_page(page_data[:page], Deck.all, ARGV.first)
#   Deck.reset_all
# end