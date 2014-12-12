require 'mini_magick'
class SfWayBill < WayBill
  ACCOUNT = '7559366000'

  def initialize
    @image = MiniMagick::Image.open(Rails.root.join('lib/waybill/sf_white_board.gif'))
  end

  def draw_body_from_order(order)
    set_text(380, 360, COMPANY)
    set_text(980, 360, SENDER)

    addr1 = ADDRESS
    set_text(380, 510, addr1[0..16])
    set_text(380, 580, addr1[17..-1])

    set_text(380, 440, PHONE)

    # =====

    contact = order.address

    set_text(980, 740, contact.name)

    addr2 = "#{contact.province} #{contact.city} #{contact.district} #{contact.street}"
    set_text(330, 890, addr2[0..16])
    set_text(330, 960, addr2[17..-1])

    set_text(830, 830, contact.phone)

    # =====

    base_y = 1060
    order.order_items.each do |i|
      set_text(260, base_y, "#{i.thing_title}x#{i.quantity}")
      base_y += 48
    end

    # =====

    set_text(1600, 940, ACCOUNT)

    # =====

    set_text(1460, 1080, SENDER)

    set_text(1400, 1140, Time.now.month)
    set_text(1500, 1140, Time.now.day)

    # =====

    set_text(1740, 220, 'AT755')

    self
  end
end
