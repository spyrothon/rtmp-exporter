require "xml"
require "auto_initialize"

module RTMP
  abstract struct Node
    include AutoInitialize
  end

  struct RTMPNode < Node
    property! nginx_version : String?
    property! nginx_rtmp_version : String?
    property! compiler : String?
    property! built : Time?
    property! pid : Int32?
    property! uptime : Int64?
    property! accepted_streams : Int64?
    property! bandwidth_in_bits : Int64?
    property! bandwidth_out_bits : Int64?
    property! bytes_in : Int64?
    property! bytes_out : Int64?
    property servers : Array(ServerNode) = [] of ServerNode
  end

  struct ServerNode < Node
    property applications : Array(ApplicationNode) = [] of ApplicationNode
  end

  struct ApplicationNode < Node
    property! name : String?
    property! client_count : Int64?
    # This is techically encapsulated in a `live` node, but it doesn't serve
    # any useful purpose.
    property streams : Array(StreamNode) = [] of StreamNode
  end

  struct StreamNode < Node
    property! name : String?
    property! time : Int64?
    property! bandwidth_in_bits : Int64?
    property! bandwidth_out_bits : Int64?
    property! bytes_in : Int64?
    property! bytes_out : Int64?
    property! bandwidth_audio : Int64?
    property! bandwidth_video : Int64?
    property! client_count : Int64?
    property! publishing : Bool?
    property! active : Bool?
    property clients : Array(ClientNode) = [] of ClientNode
    property! meta : StreamMetaNode?
  end

  struct ClientNode < Node
    property! id : String?
    property! address : String?
    property! time : Int64?
    property! flash_ver : String?
    property! swf_url : String?
    property! dropped_frames : Int64?
    property! avsync : Int64?
    property! timestamp : Int64?
    property! publishing : Bool?
    property! active : Bool?
  end

  struct StreamMetaNode < Node
    property! video_width : Int64?
    property! video_height : Int64?
    property! video_frame_rate : Int64?
    property! video_codec : String?
    property! video_profile : String?
    property! video_compat : Int64?
    property! video_level : String?

    property! audio_codec : String?
    property! audio_profile : String?
    property! audio_channels : Int64?
    property! audio_sample_rate : Int64?
  end
end
