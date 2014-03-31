# encoding: utf-8
require 'mini_magick'

class WayBill
  attr_reader :image

  COMPANY = 'KnewOne.com'
  SENDER = '超熊'
  ADDRESS = '广东省 深圳市 南山区 香山西街8号南门波托菲诺香山里一期5栋3A'
  PHONE = '400-999-2512'

  def to_io_stream
    self.image.to_blob
  end

  def draw_body_from_order(order)
    # abstract stub
  end

  protected

  def set_text(x, y, text, color = 'black', size = 48, font = Rails.root.join('lib/waybill/wqy-microhei.ttc'))
    self.image.combine_options do |c|
      c.font font
      c.fill color
      c.pointsize size
      c.encoding 'UTF-8'
      c.draw <<-CMD
   	  text #{x},#{y} "#{text}"
      CMD
    end
  end
end
