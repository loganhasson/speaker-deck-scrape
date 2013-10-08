require 'pry'
class Page

  PAGES = []

  def initialize(url)
    @url = url
    PAGES << self
  end

end