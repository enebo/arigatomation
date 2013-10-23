module Arigatomation
  module PointLike
    def +(other) Arigatomation::Point.new(x + other.x, y + other.y); end
    def -(other) Arigatomation::Point.new(x - other.x, y - other.y); end
    def *(scalar) Arigatomation::Point.new(x * scalar, y * scalar); end
    def to_s; "[#{x}, #{y}]"; end
    def between?(min, max)
      min.x <= x && x <= max.x && min.y <= y && y <= max.y
    end
  end

  class Point
    include Arigatomation::PointLike
    attr_accessor :x, :y

    def initialize(x, y) @x, @y = x, y; end
  end

  def Point(x, y)
    Arigatomation::Point.new(x, y)
  end
  module_function :Point

  ORIGIN = Point(0, 0)
end
