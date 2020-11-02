require "kemal"

require "./rtmp/parser.cr"
require "./rtmp/metrics.cr"

def get_url(domain)
  "http://#{domain}/stat"
end

get "/:domain" do |env|
  domain = env.params.url["domain"]

  sample_start = Time.monotonic
  stat_request = HTTP::Client.get(get_url(domain))
  sample_request_end = Time.monotonic

  parsed_node = RTMP::Parser.parse(stat_request.body)
  metrics = RTMP::Metrics.new(parsed_node)
  sample_process_end = Time.monotonic

  env.response.content_type = "text/plain"
  render "src/views/prometheus.ecr"
end

Kemal.run
