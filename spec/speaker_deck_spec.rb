require_relative '../lib/speaker_deck'

describe SpeakerDeck do

  let(:speaker) {SpeakerDeck.new}

  it "should have a url" do
    SpeakerDeck::MAIN_URL.should_not eq(nil)
  end

  it "should know what the max page of the site is" do
    speaker.max_page.should > 2000
  end

  it "should have a pages array" do
    SpeakerDeck::PAGES.should be_a(Array)
  end

  it "should put every page in the pages array" do
    speaker.make_pages_array
    SpeakerDeck::PAGES.size.should == speaker.max_page
  end

  it "should be able to reset the pages array" do
    SpeakerDeck.delete_pages
    SpeakerDeck::PAGES.size.should == 0
  end

  it "should create Page instances" do
    speaker.make_pages_array
    speaker.create_pages
    Page::PAGES.size.should == speaker.max_page
  end
end