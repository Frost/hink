require 'spec_helper'
require 'plugins/github'

describe Github do
  context "DEFAULTS" do
    describe "github_regex" do
      subject do
        Github::DEFAULTS[:github_regex]
      end

      it "should match a user query" do
        expect(subject =~ "gh:Frost").to_not be_nil
        expect($1).to eq("Frost")
      end

      it "should match a repo query" do
        expect(subject =~ "gh:Frost/hink").to_not be_nil
        expect($1).to eq("Frost")
        expect($2).to eq("/hink")
      end

      it "should match a issue query" do
        expect(subject =~ "gh:Frost/hink#24").to_not be_nil
        expect($1).to eq("Frost")
        expect($2).to eq("/hink")
        expect($3).to eq("#24")
      end
      it "should match a commit query" do
        expect(subject =~ "gh:Frost/hink@06921b39").to_not be_nil
        expect($1).to eq("Frost")
        expect($2).to eq("/hink")
        expect($3).to eq("@06921b39")
      end
    end
  end

  describe "prepare_query" do
    def m
      OpenStruct.new(channel: OpenStruct.new(name: "#test-hink"))
    end

    context "without proper channel conf" do
      before(:each) do
        allow(Hink).to receive_messages(config: {github: {channels: {}}})
      end

      describe "missing user" do
        subject do
          Github.prepare_query(m, {})
        end

        it "has query_type :none" do
          expect(subject[:query_type]).to eq(:none)
        end
      end

      describe "user queries" do
        subject do
          Github.prepare_query(m, user: "Frost")
        end

        it "calculates proper query type" do
          expect(subject[:query_type]).to eq(:user)
        end

        it "calculates proper user name" do
          expect(subject[:user]).to eq("Frost")
        end

      end

      describe "repo queries" do
        subject do
          Github.prepare_query(m, user: "Frost", repo: "/hink")
        end

        it "calculates proper query type" do
          expect(subject[:query_type]).to eq(:repo)
        end

        it "calculates proper user name" do
          expect(subject[:user]).to eq("Frost")
        end

        it "calculates proper repo name" do
          expect(subject[:repo]).to eq("hink")
        end
      end

      describe "commit queries" do
        subject do
          Github.prepare_query(m, user: "Frost", repo: "/hink", issue_or_commit: "@06921b39")
        end

        it "calculates proper query type" do
          expect(subject[:query_type]).to eq(:commit)
        end

        it "calculates proper user name" do
          expect(subject[:user]).to eq("Frost")
        end

        it "calculates proper repo name" do
          expect(subject[:repo]).to eq("hink")
        end

        it "calculates proper commit sha hash" do
          expect(subject[:commit]).to eq("06921b39")
        end
      end


    end
    
    context "with proper channel conf" do
      before(:each) do
        allow(Hink).to receive_messages(config: {github: {channels: { :"#test-test" => {}}}})
      end

      describe "missing user" do
        subject do
          Github.prepare_query(m, {})
        end

        it "has query_type :none" do
          expect(subject[:query_type]).to eq(:none)
        end
      end

      describe "user queries" do
        subject do
          Github.prepare_query(m, user: "Frost")
        end

        it "calculates proper query type" do
          expect(subject[:query_type]).to eq(:user)
        end

        it "calculates proper user name" do
          expect(subject[:user]).to eq("Frost")
        end

      end

      describe "repo queries" do
        subject do
          Github.prepare_query(m, user: "Frost", repo: "/hink")
        end

        it "calculates proper query type" do
          expect(subject[:query_type]).to eq(:repo)
        end

        it "calculates proper user name" do
          expect(subject[:user]).to eq("Frost")
        end

        it "calculates proper repo name" do
          expect(subject[:repo]).to eq("hink")
        end
      end

      describe "commit queries" do
        subject do
          Github.prepare_query(m, user: "Frost", repo: "/hink", issue_or_commit: "@06921b39")
        end

        it "calculates proper query type" do
          expect(subject[:query_type]).to eq(:commit)
        end

        it "calculates proper user name" do
          expect(subject[:user]).to eq("Frost")
        end

        it "calculates proper repo name" do
          expect(subject[:repo]).to eq("hink")
        end

        it "calculates proper commit sha hash" do
          expect(subject[:commit]).to eq("06921b39")
        end
      end
    end


    describe "issue queries" do
      subject do
        Github.prepare_query(m, user: "Frost", repo: "/hink", issue_or_commit: "#24")
      end

      it "calculates proper query type" do
        expect(subject[:query_type]).to eq(:issue)
      end

      it "calculates proper user name" do
        expect(subject[:user]).to eq("Frost")
      end

      it "calculates proper repo name" do
        expect(subject[:repo]).to eq("hink")
      end

      it "calculates proper issue number" do
        expect(subject[:issue]).to eq("24")
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
      expect(hash['url']).to eq("https://github.com/Frost/hink/issues/24")
      expect(hash['title']).to eq("#24 - Add custom output formats for sites to UrlGrabber plugin")
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
      expect(hash['url']).to eq("https://github.com/Frost/hink/commit/06921b39")
      expect(hash['title']).to eq("(Martin Frost) moved rspec to development group in gemfile")
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
      expect(hash['url']).to eq("https://github.com/Frost/hink")
      expect(hash['title']).to eq("Frost/hink")
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
      expect(hash['url']).to eq("https://github.com/Frost")
      expect(hash['title']).to eq("Martin Frost")
    end
  end

end
