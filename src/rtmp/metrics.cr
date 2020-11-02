class RTMP::Metrics
  def initialize(@node : RTMPNode)
  end

  def node_bandwidth_in_bytes
    to_bytes(@node.bandwidth_in_bits?)
  end

  def node_bandwidth_out_bytes
    to_bytes(@node.bandwidth_out_bits?)
  end

  def node_bytes_in
    @node.bytes_in || 0
  end

  def node_bytes_out
    @node.bytes_out || 0
  end

  def node_accepted_streams
    @node.accepted_streams
  end

  def node_uptime
    @node.uptime
  end

  def client_counts_by_application
    apps = {} of String => Int64
    self.applications.each do |app|
      apps[app.name] = app.client_count
    end

    apps
  end

  def bandwidth_in_by_app_stream
    streams = {} of Tuple(String, String) => Int64
    self.applications.each do |app|
      app.streams.each do |stream|
        streams[{app.name, stream.name}] = to_bytes(stream.bandwidth_in_bits)
      end
    end

    streams
  end

  def bandwidth_out_by_app_stream
    streams = {} of Tuple(String, String) => Int64
    self.applications.each do |app|
      app.streams.each do |stream|
        streams[{app.name, stream.name}] = to_bytes(stream.bandwidth_out_bits)
      end
    end

    streams
  end

  def ingress_by_app_stream
    streams = {} of Tuple(String, String) => Int64
    self.applications.each do |app|
      app.streams.each do |stream|
        streams[{app.name, stream.name}] = stream.bytes_in
      end
    end

    streams
  end

  def egress_by_app_stream
    streams = {} of Tuple(String, String) => Int64
    self.applications.each do |app|
      app.streams.each do |stream|
        streams[{app.name, stream.name}] = stream.bytes_out
      end
    end

    streams
  end

  def clients_by_app_stream
    streams = {} of Tuple(String, String) => Int64
    self.applications.each do |app|
      app.streams.each do |stream|
        streams[{app.name, stream.name}] = stream.client_count
      end
    end

    streams
  end

  def clients_by_app_stream
    streams = {} of Tuple(String, String) => Int64
    self.applications.each do |app|
      app.streams.each do |stream|
        streams[{app.name, stream.name}] = stream.client_count
      end
    end

    streams
  end

  def each_app_stream(&block : (ApplicationNode, StreamNode) -> _)
    self.applications.each do |app|
      app.streams.each do |stream|
        block.call(app, stream)
      end
    end
  end

  def each_app_stream_client(&block : (ApplicationNode, StreamNode, ClientNode) -> _)
    self.applications.each do |app|
      app.streams.each do |stream|
        stream.clients.each do |client|
          block.call(app, stream, client)
        end
      end
    end
  end

  private def applications
    @streams ||= @node.servers.flat_map(&.applications).as(Array(ApplicationNode))
  end

  private def to_bytes(bits : Int64?)
    bits ? bits // 8_i64 : 0_i64
  end
end
