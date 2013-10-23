module Arigatomation
  class Box
    include Enumerable
    
    attr_accessor :ulc, :lrc
    
    def initialize(ulc, lrc)
      $log.debug "#{self.class.name}.new ulc=#{ulc} lrc=#{lrc}" if $log
      @ulc, @lrc = ulc, lrc
    end
    def each; each_row { |j| each_column { |i| yield Arigatomation::Point(i, j) } }; end
    def each_row; @ulc.y.upto(@lrc.y) { |j| yield j }; end
    def each_column; @ulc.x.upto(@lrc.x) { |i| yield i }; end
    def height; @lrc.y - @ulc.y; end
    def width; @lrc.x - @ulc.x; end
    def empty?; width <= 0 && height <= 0; end
  end
end
