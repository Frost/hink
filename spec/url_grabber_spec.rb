require 'url-grabber'

describe UrlGrabber do
  describe "extract_urls" do
  end

  describe "sanitize_title" do
    it "should not mess with sane titles" do
      UrlGrabber.sanitize_title("").should == ""
      UrlGrabber.sanitize_title("ab").should == "ab"
    end

    it "should handle linebreaks" do
      UrlGrabber.sanitize_title("a\nb").should == "a b"
      UrlGrabber.sanitize_title(" a\nb ").should == "a b"
      UrlGrabber.sanitize_title(" a\n\n\nb ").should == "a   b"
      UrlGrabber.sanitize_title("\nab\n").should == "ab"
      UrlGrabber.sanitize_title("\n\n\nab\n\n\n").should == "ab"
    end

    it "should handle whitespace" do
      UrlGrabber.sanitize_title("a b").should == "a b"
      UrlGrabber.sanitize_title(" a b ").should == "a b"
      UrlGrabber.sanitize_title("   a   b   ").should == "a   b"
    end
  end

  describe "extract_title" do
  end

  describe "bitlyfy" do
  end
end
