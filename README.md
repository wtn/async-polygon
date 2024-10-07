# Async::Polygon

A stub asynchronous HTTP/2 client for [polygon.io](https://polygon.io/docs/). Made with [async-http](https://github.com/socketry/async-http).

## Installation

```bash
gem install async-polygon
```

## Usage

### Create a client

An API key is required and can be set in the `POLYGON_API_KEY` environment variable or specified at client initialization:

```ruby
client = Async::Polygon::Client.new api_key: '2qKgb9s3qUIwt6B2zGSqrVe6H5v44y6m'
```

By default, requests are rate limited to 5 per minute. For subscription tiers above basic, initialize a client with `basic: false` to remove the restriction.

### Make a request

```ruby
uri = URI 'https://api.polygon.io/v3/reference/tickers'
uri.query = URI.encode_www_form ticker: 'SPY', date: '2024-10-04'
client = Async::Polygon::Client.new
res = client.get uri
fail if ! res.success?
data = JSON.parse res.read
```

### Make requests asynchronously

```ruby
client = Async::Polygon::Client.new basic: false
ticker_symbols = %w[AAPL MSFT NVDA GOOGL AMZN BRK.A WMT JPM AFMJF FLMMF NGXXF]
date = Date.new 2024, 10, 4
count = 99
start = Process.clock_gettime(Process::CLOCK_MONOTONIC)

Sync do
  count.times do
    Async do
      uri = URI 'https://api.polygon.io/v3/reference/tickers'
      uri.query = URI.encode_www_form ticker: ticker_symbols.sample, date: date.to_s
      res = client.get uri
      fail if ! res.success?
    end
  end
end

finish = Process.clock_gettime(Process::CLOCK_MONOTONIC)
duration = finish - start

puts "#{duration.round 2} seconds elapsed (#{(count/duration).round 2} per sec)"
```

Starting with the hundredth request, non-basic clients are rate limited [per usage recommendations](https://polygon.io/knowledge-base/article/what-is-the-request-limit-for-polygons-restful-apis).

## TODO

* Add a WebSocket client using [async-websocket](https://github.com/socketry/async-websocket).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
