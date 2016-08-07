require 'active_model_serializers/serialization_context'
module ActiveModelSerializers
  class SerializationContext
    attr_reader :request_parameters

    def initialize(*args)
      options = args.extract_options!
      if args.size == 1
        request = args.pop
        options[:request_url] = request.original_url[/\A[^?]+/]
        options[:query_parameters] = request.query_parameters
        options[:request_parameters] = request.request_parameters
      end
      @request_url = options.delete(:request_url)
      @query_parameters = options.delete(:query_parameters)
      @request_parameters = options.delete(:request_parameters)
      @url_helpers = options.delete(:url_helpers) || self.class.url_helpers
      @default_url_options = options.delete(:default_url_options) || self.class.default_url_options
    end
  end
end
