require 'spec_helper'
require 'github'

describe Github do
  context "DEFAULTS" do
    describe "github_regex" do
      subject do
        Github::DEFAULTS[:github_regex]
      end

      it "should match a user query" do
        (subject =~ "gh:Frost").should_not be_nil
        $1.should == "Frost"
      end

      it "should match a repo query" do
        (subject =~ "gh:Frost/hink").should_not be_nil
        $1.should == "Frost"
        $2.should == "/hink"
      end

      it "should match a issue query" do
        (subject =~ "gh:Frost/hink#24").should_not be_nil
        $1.should == "Frost"
        $2.should == "/hink"
        $3.should == "#24"
      end
      it "should match a commit query" do
        (subject =~ "gh:Frost/hink@06921b39").should_not be_nil
        $1.should == "Frost"
        $2.should == "/hink"
        $3.should == "@06921b39"
      end
    end
  end

  describe "prepare_query" do
    def m
      OpenStruct.new(channel: OpenStruct.new(name: "#test-hink"))
    end

    context "without proper channel conf" do
      before(:each) do
        Hink.stub(:config).and_return({github: {channels: {}}})
      end

      describe "missing user" do
        subject do
          Github.prepare_query(m, {})
        end

        it "has query_type :none" do
          subject[:query_type].should == :none
        end
      end

      describe "user queries" do
        subject do
          Github.prepare_query(m, user: "Frost")
        end

        it "calculates proper query type" do
          subject[:query_type].should == :user
        end

        it "calculates proper user name" do
          subject[:user].should == "Frost"
        end

      end

      describe "repo queries" do
        subject do
          Github.prepare_query(m, user: "Frost", repo: "/hink")
        end

        it "calculates proper query type" do
          subject[:query_type].should == :repo
        end

        it "calculates proper user name" do
          subject[:user].should == "Frost"
        end

        it "calculates proper repo name" do
          subject[:repo].should == "hink"
        end
      end

      describe "commit queries" do
        subject do
          Github.prepare_query(m, user: "Frost", repo: "/hink", issue_or_commit: "@06921b39")
        end

        it "calculates proper query type" do
          subject[:query_type].should == :commit
        end

        it "calculates proper user name" do
          subject[:user].should == "Frost"
        end

        it "calculates proper repo name" do
          subject[:repo].should == "hink"
        end

        it "calculates proper commit sha hash" do
          subject[:commit].should == "06921b39"
        end
      end


    end
    
    context "with proper channel conf" do
      before(:each) do
        Hink.stub(:config).and_return({github: {channels: {"#test-hink".to_sym => {}}}})
      end

      describe "missing user" do
        subject do
          Github.prepare_query(m, {})
        end

        it "has query_type :none" do
          subject[:query_type].should == :none
        end
      end

      describe "user queries" do
        subject do
          Github.prepare_query(m, user: "Frost")
        end

        it "calculates proper query type" do
          subject[:query_type].should == :user
        end

        it "calculates proper user name" do
          subject[:user].should == "Frost"
        end

      end

      describe "repo queries" do
        subject do
          Github.prepare_query(m, user: "Frost", repo: "/hink")
        end

        it "calculates proper query type" do
          subject[:query_type].should == :repo
        end

        it "calculates proper user name" do
          subject[:user].should == "Frost"
        end

        it "calculates proper repo name" do
          subject[:repo].should == "hink"
        end
      end

      describe "commit queries" do
        subject do
          Github.prepare_query(m, user: "Frost", repo: "/hink", issue_or_commit: "@06921b39")
        end

        it "calculates proper query type" do
          subject[:query_type].should == :commit
        end

        it "calculates proper user name" do
          subject[:user].should == "Frost"
        end

        it "calculates proper repo name" do
          subject[:repo].should == "hink"
        end

        it "calculates proper commit sha hash" do
          subject[:commit].should == "06921b39"
        end
      end
    end


    describe "issue queries" do
      subject do
        Github.prepare_query(m, user: "Frost", repo: "/hink", issue_or_commit: "#24")
      end

      it "calculates proper query type" do
        subject[:query_type].should == :issue
      end

      it "calculates proper user name" do
        subject[:user].should == "Frost"
      end

      it "calculates proper repo name" do
        subject[:repo].should == "hink"
      end

      it "calculates proper issue number" do
        subject[:issue].should == "24"
      end
    end
  end

  describe "query methods" do
    before(:all) do
      include WebMock::API
    end

    it "performs issue queries" do
      stub_request(:get, "https://api.github.com/repos/Frost/hink/issues/24").to_return(
        status: 200,
        body: {
          number: '24', 
          title: 'Add custom output formats for sites to UrlGrabber plugin', 
          html_url: 'https://github.com/Frost/hink/issues/24'
        }.to_json
      )
      hash = Github.perform_query(query_type: :issue, user: "Frost", repo: "hink",issue: "24")
      hash['url'].should == "https://github.com/Frost/hink/issues/24"
      hash['title'].should == "#24 - Add custom output formats for sites to UrlGrabber plugin"
    end

    it "performs commit queries" do
      stub_request(:get, "https://github.com/Frost/hink/commit/06921b39.json").to_return(
        status: 200,
        body: {
          commit: {
            author: {name: "Martin Frost"},
            message: "moved rspec to development group in gemfile"
          }
        }.to_json
      )
      hash = Github.perform_query(query_type: :commit, user: "Frost", repo: "hink", commit: "06921b39")
      hash['url'].should == "https://github.com/Frost/hink/commit/06921b39"
      hash['title'].should == "(Martin Frost) moved rspec to development group in gemfile"
    end

    it "performs repo queries" do
      stub_request(:get, "https://api.github.com/repos/Frost/hink").to_return(
        status: 200,
        body: {
          owner: {login: "Frost"},
          name: "hink",
          html_url: "https://github.com/Frost/hink"
        }.to_json
      )
      hash = Github.perform_query(query_type: :repo, user: "Frost", repo: "hink")
      hash['url'].should == "https://github.com/Frost/hink"
      hash['title'].should == "Frost/hink"
    end

    it "performs user queries" do
      stub_request(:get, "https://api.github.com/users/Frost").to_return(
        status: 200,
        body: {
          name: 'Martin Frost',
          html_url: 'https://github.com/Frost'
        }.to_json
      )
      hash = Github.perform_query(query_type: :user, user: "Frost")
      hash['url'].should == "https://github.com/Frost"
      hash['title'].should == "Martin Frost"
    end
  end

end
