require 'open-uri'
require 'nokogiri'
require 'pry'
require_relative './page.rb'

class SpeakerDeck

  attr_accessor :max_page, :noko_doc

  MAIN_URL = "https://speakerdeck.com/p/all"

  PAGES = []

  def initialize
    @noko_doc = Nokogiri::HTML(open(MAIN_URL))
    @max_page = @noko_doc.css('.last a').attr("href").value.scan(/\d/).join.to_i
  end

  def make_pages_array
    (1..self.max_page).each {|num| PAGES << num}
  end

  def create_pages
    PAGES.each do |page|
      Page.new("https://speakerdeck.com/p/all?page=#{page}")
    end
  end

  def self.delete_pages
    PAGES.clear
  end

end