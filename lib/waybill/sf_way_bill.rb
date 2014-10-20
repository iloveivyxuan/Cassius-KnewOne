require 'mini_magick'
class SfWayBill < WayBill
  ACCOUNT = '7559366000'

  def initialize
    @image = MiniMagick::Image.open(Rails.root.join('lib/waybill/sf_white_board.gif'))
  end

  def draw_body_from_order(order)
    set_text(300, 435, COMPANY)
    set_text(925, 435, SENDER)

    addr1 = ADDRESS
    set_text(250, 525, addr1[0..16])
    set_text(250, 600, addr1[17..-1])

    set_text(525, 700, PHONE)

    # =====

    contact = order.address

    set_text(925, 910, contact.name)

    addr2 = "#{contact.province} #{contact.city} #{contact.district} #{contact.street}"
    set_text(250, 1000, addr2[0..16])
    set_text(250, 1075, addr2[17..-1])

    set_text(525, 1160, contact.phone)

    # =====

    base_y = 1360
    order.order_items.each do |i|
      set_text(200, base_y, "#{i.thing_title}x#{i.quantity}")
      base_y += 48
    end

    # =====

    set_text(1720, 460, ACCOUNT)

    # =====

    set_text(1800, 1080, Time.now.month)
    set_text(1950, 1080, Time.now.day)
    set_text(2080, 1080, Time.now.hour)
    set_text(2200, 1080, Time.now.min)

    self
  end
end
