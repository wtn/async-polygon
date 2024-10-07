# frozen_string_literal: true

require 'async/http'

module Async
  module Polygon
    class Client
      def initialize(api_key: ENV['POLYGON_API_KEY'], basic: true)
        api_key.to_s.length == 32 \
          or raise ArgumentError, 'API key required'
        set_pace basic
        @auth_headers = {'authorization' => "Bearer #{api_key}"}
        @client = Async::HTTP::Internet.new
        @request_semaphore = Async::Semaphore.new @reconnect_after
        @completion_semaphore = Async::Semaphore.new @reconnect_after
        @reset_mutex = Mutex.new
      end

      def get(uri)
        ensure_client_readiness
        @request_semaphore.acquire
        @completion_semaphore.acquire do
          Sync do
            @client.get uri, @auth_headers
          end
        end
      end

      private

      def set_pace(basic)
        if basic
          @reconnect_after =  5  # free tier
          @reset_delay     = 60
        else
          @reconnect_after = 99  # go fast
          @reset_delay     =  1
        end
      end

      def ensure_client_readiness
        if @request_semaphore.blocking?  # time to reset
          Sync do
            @reset_mutex.synchronize do
              return if ! @request_semaphore.blocking?
              @reconnect_after.times { @completion_semaphore.acquire }  # wait for requests
              @client.close
              @client = Async::HTTP::Internet.new
              sleep @reset_delay
              @reconnect_after.times { @completion_semaphore.release }
              @reconnect_after.times { @request_semaphore.release }
            end
          end
        end
      end
    end
  end
end
