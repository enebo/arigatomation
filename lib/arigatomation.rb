require 'arigatomation/autoit'
require 'arigatomation/pixel'
require 'arigatomation/box'
require 'arigatomation/point'
require 'arigatomation/pixel_source'
require 'arigatomation/pixel_box'
require 'arigatomation/live_pixel_box'

module Arigatomation
  # All point functions should be relative to client windows size
  ABSOLUTE_COORD = 1
  CLIENT_COORD = 2

  # Commonly used luminance block
  LUMINANCE = proc { |p| p.luminance < 80 }
  LUMINANCE_BINARY = proc {|pixel| pixel.luminance < 80 ? " " : "#" }

  def find_array_around(source, find_me)
    source.contains find_me
  end

  # Find HWND for handle we want.  handle_info is a hash which can contain:
  # :title - Title of window you want
  # :class - Class of window you want
  #
  # In both title or class you can use a string for exact match or a regular
  # expression to specify you are doing a more complex search.
  def handle_for(handle_info)
    impl_specific_handle_for(handle_info) # Look in ffi or autoit
  end

  class EmptyFingerprintError < TypeError
  end
end

module Win
  module User32
    # We needed to load User32 before point so we are including after both
    # are fully loaded. 
    class Point
      include Arigatomation::PointLike

      def x
        self[:x]
      end

      def y
        self[:y]
      end
    end
  end
end
