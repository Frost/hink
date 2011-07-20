require 'github'

describe GitHub do
  describe "recognize github references" do
    it "should handle :account references" do
      GitHub.extract_references("gh:Frost").should == [{:account => "Frost", :repo => nil, :issue => nil}]
      GitHub.extract_references("look at gh:Frost").should == [{:account => "Frost", :repo => nil, :issue => nil}]
      GitHub.extract_references("gh:Frost is a github account").should == [{:account => "Frost", :repo => nil, :issue => nil}]
    end

    it "should handle :account/:repo references" do
      GitHub.extract_references("gh:Frost/url-grabber").should == [{:account => "Frost", :repo => "url-grabber", :issue => nil}]
      GitHub.extract_references("look at gh:Frost/url-grabber").should == [{:account => "Frost", :repo => "url-grabber", :issue => nil}]
      GitHub.extract_references("gh:Frost/url-grabber is a github repo").should == [{:account => "Frost", :repo => "url-grabber", :issue => nil}]
    end

    it "should handle :account/:repo#:issue references" do
      GitHub.extract_references("gh:Frost/url-grabber#1").should == [{:account => "Frost", :repo => "url-grabber", :issue => 1}]
      GitHub.extract_references("look at gh:Frost/url-grabber#1").should == [{:account => "Frost", :repo => "url-grabber", :issue => 1}]
      GitHub.extract_references("gh:Frost/url-grabber#1 is a github issue").should == [{:account => "Frost", :repo => "url-grabber", :issue => 1}]
    end

    it "should handle multiple references" do
      GitHub.extract_references("gh:Frost gh:Frost/url-grabber gh:Frost/url-grabber#1").should == [
        {:account => "Frost", :repo => nil, :issue => nil},
        {:account => "Frost", :repo => "url-grabber", :issue => nil},
        {:account => "Frost", :repo => "url-grabber", :issue => 1}
      ]
    end
  end

  describe "convert github references to urls" do
    it "should handle :account references" do
      GitHub.reference_url({:account => "Frost", :repo => nil, :issue => nil}).should == "https://github.com/Frost"
    end

    it "should handle :account/:repo references" do
      GitHub.reference_url({:account => "Frost", :repo => "url-grabber", :issue => nil}).should == "https://github.com/Frost/url-grabber"
    end

    it "should handle :account/:repo#:issue references" do
      GitHub.reference_url({:account => "Frost", :repo => "url-grabber", :issue => 1}).should == "https://github.com/Frost/url-grabber/issues/1"
    end
  end
end
