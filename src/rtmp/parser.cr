require "xml"

require "./nodes.cr"

module RTMP::Parser
  extend self

  def children(node : XML::Node)
    node.children.select(&.element?)
  end

  def parse(xml_content : String) : RTMPNode
    document = XML.parse(xml_content)
    rtmp_node = document.xpath_node("//rtmp")
    return RTMPNode.new unless rtmp_node

    parse_rtmp(rtmp_node)
  end

  def parse_rtmp(node : XML::Node) : RTMPNode
    rtmp = RTMPNode.new

    children(node).each do |child|
      case child.name
      when "nginx_version"
        rtmp.nginx_version = child.content
      when "nginx_rtmp_version"
        rtmp.nginx_rtmp_version = child.content
      when "compiler"
        rtmp.compiler = child.content
      when "built"
        rtmp.built = Time.parse_utc(child.content, "%h %e %Y %T")
      when "pid"
        rtmp.pid = child.content.to_i?
      when "uptime"
        rtmp.uptime = child.content.to_i64?
      when "naccepted"
        rtmp.accepted_streams = child.content.to_i64?
      when "bw_in"
        rtmp.bandwidth_in_bits = child.content.to_i64?
      when "bw_out"
        rtmp.bandwidth_out_bits = child.content.to_i64?
      when "bytes_in"
        rtmp.bytes_in = child.content.to_i64?
      when "bytes_out"
        rtmp.bytes_out = child.content.to_i64?
      when "server"
        rtmp.servers << parse_server(child)
      else nil
      end
    end

    rtmp
  end

  def parse_server(node : XML::Node) : ServerNode
    server = ServerNode.new

    children(node).each do |child|
      case child.name
      when "application"
        server.applications << parse_application(child)
      else nil
      end
    end

    server
  end

  def parse_application(node : XML::Node) : ApplicationNode
    app = ApplicationNode.new
    live_node : XML::Node? = nil

    children(node).each do |child|
      case child.name
      when "name"
        app.name = child.content
      when "live"
        live_node = child
      else nil
      end
    end

    return app unless live_node

    # Most of the information for `application` is inside of `live`. Probably
    # for HLS/DASH stats?
    children(live_node).each do |child|
      case child.name
      when "nclients"
        app.client_count = child.content.to_i64?
      when "stream"
        app.streams << parse_stream(child)
      else nil
      end
    end

    app
  end

  def parse_stream(node : XML::Node) : StreamNode
    stream = StreamNode.new

    children(node).each do |child|
      case child.name
      when "name"
        stream.name = child.content
      when "time"
        stream.time = child.content.to_i64?
      when "bw_in"
        stream.bandwidth_in_bits = child.content.to_i64?
      when "bw_out"
        stream.bandwidth_out_bits = child.content.to_i64?
      when "bytes_in"
        stream.bytes_in = child.content.to_i64?
      when "bytes_out"
        stream.bytes_out = child.content.to_i64?
      when "bw_audio"
        stream.bandwidth_audio = child.content.to_i64?
      when "bw_video"
        stream.bandwidth_video = child.content.to_i64?
      when "nclients"
        stream.client_count = child.content.to_i64?
      when "publishing"
        stream.publishing = true
      when "active"
        stream.active = true
      when "client"
        stream.clients << parse_client(child)
      when "meta"
        stream.meta = parse_stream_meta(child)
      else nil
      end
    end

    stream
  end

  def parse_client(node : XML::Node) : ClientNode
    client = ClientNode.new

    children(node).each do |child|
      case child.name
      when "id"
        client.id = child.content
      when "address"
        client.address = child.content
      when "time"
        client.time = child.content.to_i64?
      when "flashver"
        client.flash_ver = child.content
      when "swfurl"
        client.swf_url = child.content
      when "dropped"
        client.dropped_frames = child.content.to_i64?
      when "avsync"
        client.avsync = child.content.to_i64?
      when "timestamp"
        client.timestamp = child.content.to_i64?
      when "publishing"
        client.publishing = true
      when "active"
        client.active = true
      else nil
      end
    end

    client
  end

  def parse_stream_meta(node : XML::Node) : StreamMetaNode
    meta = StreamMetaNode.new
    video : XML::Node? = nil
    audio : XML::Node? = nil

    children(node).each do |child|
      case child.name
      when "video"
        video = child
      when "audio"
        audio = child
      else nil
      end
    end

    if video
      children(video).each do |child|
        case child.name
        when "width"
          meta.video_width = child.content.to_i64?
        when "height"
          meta.video_height = child.content.to_i64?
        when "frame_rate"
          meta.video_frame_rate = child.content.to_i64?
        when "codec"
          meta.video_codec = child.content
        when "profile"
          meta.video_profile = child.content
        when "compat"
          meta.video_compat = child.content.to_i64?
        when "level"
          meta.video_level = child.content
        else nil
        end
      end
    end

    if audio
      children(audio).each do |child|
        case child.name
        when "codec"
          meta.audio_codec = child.content
        when "profile"
          meta.audio_profile = child.content
        when "channels"
          meta.audio_channels = child.content.to_i64?
        when "sample_rate"
          meta.audio_sample_rate = child.content.to_i64?
        else nil
        end
      end
    end

    meta
  end
end
