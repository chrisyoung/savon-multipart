require 'mail'

module Savon
  module Multipart
    class Response < Savon::Response
      attr_reader :parts

      def initialize(*args)
        @parts = []
        super
      end

      def attachments
        if multipart?
          parse_body unless @has_parsed_body
          @parts.attachments
        else
          []
        end
      end

      def body
        parse_body unless @has_parsed_body
        nori.parse(@parts.first.body.to_s)
      end

      private
      def multipart?
        http.headers['Content-Type'] =~ /^multipart/i
      end

      def boundary
        return unless multipart?
        @boundary ||= Mail::Field.new('Content-Type', http.headers['Content-Type']).parameters['boundary']
      end

      def parse_body
        @parts = Mail::Part.new(
          :headers => http.headers,
          :body => http.body
        ).body.split!(boundary).parts
        @has_parsed_body = true
      end
    end
  end
end
