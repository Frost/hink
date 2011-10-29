require 'cinch'
require 'htmlentities'
require 'config'
require 'httparty'
require 'json'

class Github
  include Cinch::Plugin

  # The DEFAULTS[:output_template] is just a default Liquid output template.
  # It can be overridden in config.yml by defining the github.output_format key.
  #
  # The DEFAULTS[:github_regex] regex matches some github resource
  # It consists basically of three catching groups, none of which are actually necessary.
  # The three groups are:
  # - user
  # - repo
  # - issue_or_commit
  # A vaild github username contains alphanumeric characters and/or dashes, and does not start with a dash.
  # Same thing goes for the repo
  # The issue_or_commit part either points to an issue or commit, depending on how it looks:
  # - #1234     -- points to an issue
  # - @01234567 -- points to a commit
  DEFAULTS = {
    output_template: "[GitHub] {{ title }} | {{ url }}",
    github_regex: /\bgh:([a-z][\-\da-z]+)?(\/[a-z][\-\da-z]+)?(#\d+|@[\da-z]+)?\b/i
  }

  prefix ''
  match DEFAULTS[:github_regex], method: :execute
  react_on :channel

  def execute(m, user, repo, issue_or_commit)
    query_options = self.class.prepare_query(m, user: user, repo: repo, issue_or_commit: issue_or_commit)
    unless query_options[:query_type] == :none
      response_hash = self.class.perform_query(query_options)
      m.reply(self.class.compile_output(response_hash))
    end
  end

  class << self
    ##
    # Take a bunch of input (user, repo, issue, commit) 
    # and calculate what api to perform the query against.
    # Outputs query_type: :none if the options aren't suitable.
    def prepare_query(m, options = {})
      options = Hink.config[:github][:channels][m.channel.name.to_sym].merge(options)

      query_type = if options[:user]
        if options[:repo]
          options[:repo].gsub!(/^\//, '')
          case options[:issue_or_commit]
          when /^#/
            options[:issue] = options[:issue_or_commit].gsub(/^#/, '')
            :issue
          when /^@/
            options[:commit] = options[:issue_or_commit].gsub(/^@/, '')
            :commit
          else :repo
          end
        else
          :user
        end
      else
        :none
      end
      
      options.merge(query_type: query_type)
    end

    def perform_query(options)
      query_type = options.delete(:query_type)      
      self.send("#{query_type}_query", options)
    end

    def user_query(options = {})
      json = HTTParty.get("https://api.github.com/users/#{options[:user]}").body
      json = JSON.load(json)
      {'title' => json['name'], 'url' => json['html_url']}
    end

    def repo_query(options = {})
      json = HTTParty.get("https://api.github.com/repos/#{options[:user]}/#{options[:repo]}").body
      json = JSON.load(json)
      {'title' => "#{json['owner']['login']}/#{json['name']}", 'url' => json['html_url']}
    end

    def commit_query(options = {})
      url = "https://github.com/#{options[:user]}/#{options[:repo]}/commit/#{options[:commit]}"
      json = HTTParty.get("#{url}.json").body
      json = JSON.load(json)
      {'title' => "(#{json['commit']['author']['name']}) #{json['commit']['message']}", 'url' => url}
    end

    def issue_query(options = {})
      json = HTTParty.get("https://api.github.com/repos/#{options[:user]}/#{options[:repo]}/issues/#{options[:issue]}").body
      json = JSON.load(json)
      {'title' => "##{json['number']} - #{json['title']}", 'url' => json['html_url']}
    end

    ##
    # Take a hash with two keys and compile the output string using a liquid template
    # response_hash should be something like {'title' => 'foo bar baz', 'url' => 'https://foo.bar.baz'}
    def compile_output(response_hash)
      template = Hink.config[:github][:output_format] || DEFAULTS[:output_template]
      Liquid::Template.parse(template).render(response_hash)
    end
  end
end
