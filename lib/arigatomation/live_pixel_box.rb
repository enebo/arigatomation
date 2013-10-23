module Arigatomation
  # A Pixel source backed by current window
  class LivePixelBox < Arigatomation::Box
    include Arigatomation::PixelSource, Arigatomation

    def [](point) pixel_at(point); end
  end
end