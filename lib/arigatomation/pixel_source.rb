require 'digest/md5'

module Arigatomation
  # Methods for boxes which contain pixels (contract: ulc, lrc, [], and []=)
  module PixelSource
    # Create a PixelBox at a point in time.
    def capture(upper_left=ulc, lower_right=lrc)
      $log.debug "#{self.class.name}.capture ulc=#{ulc} lrc=#{lrc} sulc=#{upper_left} slrc=#{lower_right}"
      inject(Arigatomation::PixelBox.new(Arigatomation::ORIGIN, lower_right - upper_left)) do |newbox, p|
        newbox[p - upper_left] = self[p] if p.between? upper_left, lower_right
        newbox
      end
    rescue
      $log.error "Problem making capture: #{$!}"
    end

    # Does the pixel source contain the supplied box within it.  The optional
    # fuzz parameter allows you to match RGB values +- the fuzz.
    def contains(box, fuzz=Arigatomation::Pixel(0x020202))
      each do |p|
        return p if self[p].approx(box[Arigatomation::ORIGIN], fuzz) && box.match(self, p, fuzz)
      end
      false
    end

    # Crop the current PixelBox to a smaller LivePixelBox given the provided
    # block.  The contract of the block is to return true if the current location
    # can be cropped given the provided pixel.
    def crop
      block = block_given? ? Proc.new : Arigatomation::LUMINANCE
      left_x, right_x, top_y, bottom_y = lrc.x, ulc.x, lrc.y, ulc.y
      changed = false

      each do |point|
        if !block.call(self[point])
          changed = true
          left_x = point.x if point.x < left_x
          right_x = point.x if point.x > right_x
          top_y = point.y if point.y < top_y
          bottom_y = point.y if point.y > bottom_y
        end
      end

      return self unless changed
      $log.debug "CROPPED to #{[left_x, top_y, right_x, bottom_y].join(", ")}"
      capture(Arigatomation::Point.new(left_x, top_y), Arigatomation::Point.new(right_x, bottom_y))
    rescue
      $log.error "Crop error: #{$!}"
    end

    # Returns a fingerprint for this pixel box.  A fingerprint is the middle
    # line of the pixelbox downscaled to a one bit string.  If the fingerprint
    # is empty (dimensionless), then it will raise an EmptyFingerprintError.
    def fingerprint(raise_on_error=false)
      # Make copy in case it is live pixel source to reduce number of pixel gets
      box = capture.crop { |p| p.luminance < 80 }
      raise Arigatomation::EmptyFingerprintError.new if raise_on_error && box.empty?
      binary_string = box.as_string {|pixel| pixel.luminance < 80 ? " " : "#" }
      finger_print = MD5.hexdigest(binary_string)
      $log.debug "Finger_print #{finger_print}"
      finger_print
    end

    def simple_fingerprint(&pixel_equation)
      # Make copy in case it is live pixel source to reduce number of pixel gets
      box = capture#.crop { |p| p.luminance < 80 }
      mid = box.height / 2 + box.ulc.y
      finger_print = ""
      box.each_column do |i|
        if block_given?
          finger_print << (pixel_equation[box[Point.new(i, mid)]] ? " " : "#") if (i % 2 != 0)
        else
          finger_print << (box[Point.new(i, mid)].luminance < 80 ? " " : "#") if (i % 2 != 0)
        end
      end
      finger_print
    end

    # Does this pixel source contain the other pixel source at the supplied
    # achor.  If fuzz is supplied this will do more generous matching (see
    # approx for more info).
    def match(other, anchor, fuzz=Pixel(0))
      each { |p| return false if !other[anchor + p].approx(self[p], fuzz)}
      true
    end

    def print(out=$stdout)
      block = block_given? ? Proc.new : proc { |p| p.to_s }
      each do |point|
        out.write block.call(self[point])
        out.puts "" if point.x == lrc.x
      end
    end

    def as_string
      converter = block_given? ? Proc.new : proc {|p| p }
      inject("") do |str, p|
        str << converter.call(self[p]) << (p.x == @lrc.x ? "\n" : "")
      end
    end

    # Looks for differences with the supplied 'other' pixel source and returns
    # only different regions from other. The rest is filled with (0,0,0).
    def -(other)
      blank = Arigatomation::Pixel(0)
      new_box = Arigatomation::PixelBox.new(ulc, lrc)
      each do |point|
        first, second = self[point], other[point]
        new_box[point] = first != second ? second : blank
      end
      new_box
    end
  end
end
