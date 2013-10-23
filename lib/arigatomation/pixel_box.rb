module Arigatomation
  # A Pixel Source which is mutable and self-managed (e.g. not live)
  class PixelBox < Box
    include Arigatomation::PixelSource
    
    def initialize(ulc, lrc)
      super(ulc, lrc)
      @array = Array.new(lrc.x - ulc.x + 1) { Array.new(lrc.y - ulc.y + 1) { 0 }}
    end
    
    def [](point) @array[point.x][point.y]; end
    def []=(point, value) @array[point.x][point.y] = value; end
  end
end
