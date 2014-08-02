require 'cinch'
require 'htmlentities'
require 'config'
require 'mechanize'
require 'json'

# Fetch some info from GitHub
#
# The DEFAULTS[:template] is just a default Liquid output template.
# It can be overridden in config.yml by defining the github.output_format key.
#
# The DEFAULTS[:regex] regex matches some github resource
# It consists basically of three catching groups,
# none of which are actually necessary.
# The three groups are:
# - user
# - repo
# - issue_or_commit
# A vaild github username contains alphanumeric characters and/or dashes,
# and does not start with a dash.
# Same thing goes for the repo
# The issue_or_commit part either points to an issue or commit,
# depending on how it looks:
# - #1234     -- points to an issue
# - @01234567 -- points to a commit
class Github
  include Cinch::Plugin

  DEFAULTS = {
    template: '[GitHub] {{ title }} | {{ url }}',
    regex: /\bgh:([a-z][\-\da-z]+)?(\/[a-z][\-\da-z]+)?(#\d+|@[\da-z]+)?\b/i,
    url: 'https://api.github.com'
  }

  set(
    prefix: '',
    react_on: :channel
  )
  match(DEFAULTS[:regex], method: :execute)

  def execute(m, user, repo, issue_or_commit)
    query_options = self.class.prepare_query(m,
                                             user: user,
                                             repo: repo,
                                             issue_or_commit: issue_or_commit
                                            )

    if query_options[:query_type] != :none
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
      defaults = Hink.config[:github][:channels][m.channel.name.to_sym] || {}
      options = defaults.merge(options)

      restructure_options_by_query_type(options)
    end

    def restructure_options_by_query_type(options)
      options[:query_type] = query_type(options)
      options[:issue_or_commit].gsub!(/^[#@]/, '') if options[:issue_or_commit]
      case options[:query_type]
      when :issue then options[:issue] = options[:issue_or_commit]
      when :commit then options[:commit] = options[:issue_or_commit]
      end
      options
    end

    def query_type(options)
      if options[:user]
        return :user unless options[:repo]
        options[:repo].gsub!(/^\//, '')

        return case options[:issue_or_commit]
               when /^#/ then :issue
               when /^@/ then :commit
        else :repo
        end
      end
      :none
    end

    def perform_query(options)
      query_type = options.delete(:query_type)
      send("#{query_type}_query", options)
    end

    def user_query(options = {})
      json = agent.get("https://api.github.com/users/#{options[:user]}").body
      json = JSON.load(json)
      { 'title' => json['name'], 'url' => json['html_url'] }
    end

    def repo_query(options = {})
      url = [
        DEFAULTS[:url],
        'repos', options[:user], options[:repo]
      ].join('/')
      json = JSON.load(agent.get(url).body)
      {
        'title' => "#{json['owner']['login']}/#{json['name']}",
        'url' => json['html_url']
      }
    end

    def commit_query(options = {})
      url = [
        'https://github.com',
        options[:user], options[:repo],
        'commit', options[:commit]
      ].join('/')
      commit = JSON.load(agent.get("#{url}.json").body)['commit']
      {
        'title' => "(#{commit['author']['name']}) #{commit['message']}",
        'url' => url
      }
    end

    def issue_query(options = {})
      url = [
        DEFAULTS[:url],
        'repos', options[:user], options[:repo],
        'issues', options[:issue]
      ].join('/')
      json = JSON.load(agent.get(url).body)
      {
        'title' => "##{json['number']} - #{json['title']}",
        'url' => json['html_url']
      }
    end

    def agent
      Mechanize.new
    end

    ##
    # Take a hash with two keys and compile the output  using a liquid template
    # response_hash should be something like:
    #   {'title' => 'foo bar baz', 'url' => 'https://foo.bar.baz'}
    def compile_output(response_hash)
      template = Hink.config[:github][:output_format] || DEFAULTS[:template]
      Liquid::Template.parse(template).render(response_hash)
    end
  end
end
