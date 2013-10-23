require 'win32ole'

# Assumes that unless you explicitly have a handle method in class you include
# this in you will pass in one explicitly everytime.
module Arigatomation
  module AutoIT
    def self.included(clazz)
      $AUTO_IT = WIN32OLE.new('AutoItX3.Control') if $AUTO_IT.nil?
    end
    
    def coordinate_mode(mode)
      opt("MouseCoordMode", mode) # Make all positions relative to client window
      opt("PixelCoordMode", mode) # Make all positions relative to client window
    end
    
    #  def active?(handle=handle); $AUTO_IT.WinActive(handle); end
    #  def handle_for(title); $AUTO_IT.WinGetHandle(title); end
    
    # FIXME: Add regexp support if ever needed
    def impl_specific_handle_for(opts)
      str = []
      str << "CLASS:#{opts[:class]}" if opts[:class]
      str << "TITLE:#{opts[:title]}" if opts[:title]
      "[" + str.join(";") + "]"
    end
    
    def focus(handle=handle)
      $AUTO_IT.WinActivate(handle)
    end
    
    def left_click(location, mouse_move=true)
      move(location) if mouse_move
      $AUTO_IT.MouseClick 'left', location.x, location.y
    end
    
    def right_click(location, mouse_move=true)
      move(location) if mouse_move
      $AUTO_IT.MouseClick 'right', location.x, location.y
    end
    
    def move(location); $AUTO_IT.MouseMove location.x, location.y; end
    def opt(option, value=""); $AUTO_IT.Opt(option, value); end
    def pixel_at(point)
      Arigatomation::Pixel.new $AUTO_IT.PixelGetColor(point.x, point.y)
    end
    def properties(handle); $AUTO_IT.WinGetState(handle); end
    
    # Size of entire window including decorations (border + titlebar)
    def window_size(handle=handle)
      [$AUTO_IT.WinGetPosWidth(handle, ""), $AUTO_IT.WinGetPosHeight(handle, "")]
    end
    
    # Size of the actual client window inside the window decorations
    def client_window_size(handle=handle)
      [$AUTO_IT.WinGetClientSizeWidth(handle), $AUTO_IT.WinGetClientSizeHeight(handle)]
    end
    
    def window_location(handle=handle)
      Arigatomation::Point($AUTO_IT.WinGetPosX(handle), $AUTO_IT.WinGetPosY(handle))
    end
    
    def send_string(string)
      $AUTO_IT.Send(string)
    end
  end
end

module Arigatomation
  include Arigatomation::AutoIT
end