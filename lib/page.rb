require 'open-uri'
require 'nokogiri'
require 'pry'

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
  end

end