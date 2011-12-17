module Formatters
  class Base
    attr_reader :uri, :template, :response

    def initialize(uri, template = "")
      @uri = uri
      @template = template
    end

    def perform_request!
      raise NotImplementedError, "Not yet implemented"
    end

    def parse_response!
      raise NotImplementedError, "Not yet implemented"
    end

    def to_s
      ""
    end

    def self.parse(uri, template)
      instance = self.class.new(uri, template)
      instance.perform_request!
      instance.parse_response!
      instance.to_s
    end
  end
end
