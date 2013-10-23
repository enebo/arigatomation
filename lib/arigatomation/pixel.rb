module Arigatomation
  class Pixel
    attr_accessor :raw
    
    def initialize(raw_value)
      @raw = raw_value
    end
    
    def red; (0xff0000 & @raw) >> 16; end
    def green; (0x00ff00 & @raw) >> 8; end
    def blue; 0x0000ff & @raw; end
    
    # From http://www.bobpowell.net/grayscale.htm
    def luminance; 0.3 * red + 0.59 * green + 0.11 * blue; end
    
    # Is supplied pixel +/- range_pixel close enough to this
    # pixel?  range_pixel is a set of delta values for RGB.
    def approx(pixel, range_pixel)
      top = pixel + range_pixel
      bottom = pixel - range_pixel
      @raw >= bottom.raw && @raw <= top.raw
    end
    
    def eql?(pixel) @raw == pixel.raw; end
    def hash; @raw; end
    def ==(pixel) @raw == pixel.raw; end
    def +(pixel) self.class.new @raw + pixel.raw; end
    def -(pixel) self.class.new @raw - pixel.raw; end
    def inspect; "Pixel(#{to_s})"; end
    def to_str; to_s; end
    
    def to_s
      value = @raw.to_s(16)
      value = value + ('0' * (6 - value.length()))
      "0x#{value}"
    end
    
    def self.bgr2rgb(value)
      red = (value & 0x0000ff) << 16
      green = value & 0x00ff00
      blue = (value & 0xff0000) >> 16
      
      red | green | blue;
    end
  end
  
  def Pixel(raw_value)
    Arigatomation::Pixel.new(raw_value)
  end
end
