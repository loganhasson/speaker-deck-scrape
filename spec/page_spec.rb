require_relative '../lib/page'

describe Page do

  let(:speaker_page) {Page.new("https://speakerdeck.com/p/all?page=2")}

  it "should have a url" do
    speaker_page.url.should eq("https://speakerdeck.com/p/all?page=2")
  end

  it "should have deck urls" do
    Page::DECKS.first.should include("https://")
  end

end