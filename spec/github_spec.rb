require 'github'

describe GitHub do
  describe "recognize github references" do
    it "should handle :account references" do
      GitHub.extract_references("gh:Frost").should == [{:account => "Frost", :repo => nil, :issue => nil, :commit => nil}]
      GitHub.extract_references("look at gh:Frost").should == [{:account => "Frost", :repo => nil, :issue => nil, :commit => nil}]
      GitHub.extract_references("gh:Frost is a github account").should == [{:account => "Frost", :repo => nil, :issue => nil, :commit => nil}]
    end

    it "should handle :account/:repo references" do
      GitHub.extract_references("gh:Frost/url-grabber").should == [{:account => "Frost", :repo => "url-grabber", :issue => nil, :commit => nil}]
      GitHub.extract_references("look at gh:Frost/url-grabber").should == [{:account => "Frost", :repo => "url-grabber", :issue => nil, :commit => nil}]
      GitHub.extract_references("gh:Frost/url-grabber is a github repo").should == [{:account => "Frost", :repo => "url-grabber", :issue => nil, :commit => nil}]
    end

    it "should handle :account/:repo#:issue references" do
      GitHub.extract_references("gh:Frost/url-grabber#1").should == [{:account => "Frost", :repo => "url-grabber", :issue => 1, :commit => nil}]
      GitHub.extract_references("look at gh:Frost/url-grabber#1").should == [{:account => "Frost", :repo => "url-grabber", :issue => 1, :commit => nil}]
      GitHub.extract_references("gh:Frost/url-grabber#1 is a github issue").should == [{:account => "Frost", :repo => "url-grabber", :issue => 1, :commit => nil}]
    end

    it "should handle multiple references" do
      GitHub.extract_references("gh:Frost gh:Frost/url-grabber gh:Frost/url-grabber#1").should == [
        {:account => "Frost", :repo => nil, :issue => nil, :commit => nil},
        {:account => "Frost", :repo => "url-grabber", :issue => nil, :commit => nil},
        {:account => "Frost", :repo => "url-grabber", :issue => 1, :commit => nil}
      ]
    end
  end

  describe "handle defaults" do
    before do
      $config = {}
      $config[:github] = {}
      $config[:github][:"#withdefault"] = {:account => "Frost", :repo => "url-grabber", :issue => 1, :commit => nil}
    end

    it "should handle empty reference" do
      GitHub.merge_reference_with_default({:account => nil, :repo => nil, :issue => nil}, "#withdefault").should == {:account => "Frost", :repo => "url-grabber", :issue => 1, :commit => nil}
      GitHub.merge_reference_with_default({:account => nil, :repo => nil, :issue => nil}, "#withoutdefault").should == {:account => nil, :repo => nil, :issue => nil, :commit => nil}
    end

    it "should handle :account references" do
      GitHub.merge_reference_with_default({:account => "Koronen", :repo => nil, :issue => nil}, "#withdefault").should == {:account => "Koronen", :repo => nil, :issue => nil, :commit => nil}
      GitHub.merge_reference_with_default({:account => "Koronen", :repo => nil, :issue => nil}, "#withoutdefault").should == {:account => "Koronen", :repo => nil, :issue => nil, :commit => nil}
    end

    it "should handle (:account)/:repo references" do
      GitHub.merge_reference_with_default({:account => nil, :repo => "spargris", :issue => nil}, "#withdefault").should == {:account => "Frost", :repo => "spargris", :issue => nil, :commit => nil}
      GitHub.merge_reference_with_default({:account => "Koronen", :repo => "spargris", :issue => nil}, "#withdefault").should == {:account => "Koronen", :repo => "spargris", :issue => nil, :commit => nil}
      GitHub.merge_reference_with_default({:account => "Koronen", :repo => "spargris", :issue => nil}, "#withoutdefault").should == {:account => "Koronen", :repo => "spargris", :issue => nil, :commit => nil}
    end

    it "should handle (:account)(/:repo)#:issue references" do
      GitHub.merge_reference_with_default({:account => nil, :repo => nil, :issue => 2}, "#withdefault").should == {:account => "Frost", :repo => "url-grabber", :issue => 2, :commit => nil}
      GitHub.merge_reference_with_default({:account => nil, :repo => "spargris", :issue => 2}, "#withdefault").should == {:account => "Frost", :repo => "spargris", :issue => 2, :commit => nil}
      GitHub.merge_reference_with_default({:account => "Koronen", :repo => "spargris", :issue => 2}, "#withoutdefault").should == {:account => "Koronen", :repo => "spargris", :issue => 2, :commit => nil}
    end
  end

  describe "convert github references to urls" do
    describe "output valid references" do
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

    describe "not output incomplete references" do
      it "should handle :account references" do
        GitHub.reference_url({:account => nil, :repo => "url-grabber", :issue => 1}).should == nil
      end

      it "should handle :account/:repo references" do
        GitHub.reference_url({:account => nil, :repo => nil, :issue => 1}).should == nil
      end

      it "should handle :account/:repo#:issue references" do
        GitHub.reference_url({:account => nil, :repo => nil, :issue => 1}).should == nil
      end
    end
  end
end
