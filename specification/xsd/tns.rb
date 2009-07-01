require 'xsd/qname'

# {http://foo.example.com/tns}VideoComplexType
class VideoComplexType
  @@schema_type = "VideoComplexType"
  @@schema_ns = "http://foo.example.com/tns"
  @@schema_element = []

  def initialize
  end
end

# {http://foo.example.com/tns}MediaComplexType
class MediaComplexType
  @@schema_type = "MediaComplexType"
  @@schema_ns = "http://foo.example.com/tns"
  @@schema_attribute = {XSD::QName.new(nil, "name") => "SOAP::SOAPString", XSD::QName.new(nil, "description") => "SOAP::SOAPString", XSD::QName.new(nil, "filename") => "SOAP::SOAPString", XSD::QName.new(nil, "path") => "SOAP::SOAPString", XSD::QName.new(nil, "data") => "SOAP::SOAPString", XSD::QName.new(nil, "codec") => "SOAP::SOAPString"}
  @@schema_element = []

  def xmlattr_name
    (@__xmlattr ||= {})[XSD::QName.new(nil, "name")]
  end

  def xmlattr_name=(value)
    (@__xmlattr ||= {})[XSD::QName.new(nil, "name")] = value
  end

  def xmlattr_description
    (@__xmlattr ||= {})[XSD::QName.new(nil, "description")]
  end

  def xmlattr_description=(value)
    (@__xmlattr ||= {})[XSD::QName.new(nil, "description")] = value
  end

  def xmlattr_filename
    (@__xmlattr ||= {})[XSD::QName.new(nil, "filename")]
  end

  def xmlattr_filename=(value)
    (@__xmlattr ||= {})[XSD::QName.new(nil, "filename")] = value
  end

  def xmlattr_path
    (@__xmlattr ||= {})[XSD::QName.new(nil, "path")]
  end

  def xmlattr_path=(value)
    (@__xmlattr ||= {})[XSD::QName.new(nil, "path")] = value
  end

  def xmlattr_data
    (@__xmlattr ||= {})[XSD::QName.new(nil, "data")]
  end

  def xmlattr_data=(value)
    (@__xmlattr ||= {})[XSD::QName.new(nil, "data")] = value
  end

  def xmlattr_codec
    (@__xmlattr ||= {})[XSD::QName.new(nil, "codec")]
  end

  def xmlattr_codec=(value)
    (@__xmlattr ||= {})[XSD::QName.new(nil, "codec")] = value
  end

  def initialize
    @__xmlattr = {}
  end
end

# {http://foo.example.com/tns}SoundComplexType
class SoundComplexType
  @@schema_type = "SoundComplexType"
  @@schema_ns = "http://foo.example.com/tns"
  @@schema_element = []

  def initialize
  end
end

# {http://foo.example.com/tns}PictureComplexType
class PictureComplexType
  @@schema_type = "PictureComplexType"
  @@schema_ns = "http://foo.example.com/tns"
  @@schema_element = []

  def initialize
  end
end
