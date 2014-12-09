require 'mini_magick'
class SfWayBill < WayBill
  ACCOUNT = '7559366000'

  def initialize
    @image = MiniMagick::Image.open(Rails.root.join('lib/waybill/sf_white_board.gif'))
  end

  def draw_body_from_order(order)
    set_text(310, 440, COMPANY)
    set_text(980, 440, SENDER)

    addr1 = ADDRESS
    set_text(310, 600, addr1[0..16])
    set_text(310, 680, addr1[17..-1])

    set_text(310, 520, PHONE)

    # =====

    contact = order.address

    set_text(980, 860, contact.name)

    addr2 = "#{contact.province} #{contact.city} #{contact.district} #{contact.street}"
    set_text(310, 1000, addr2[0..16])
    set_text(310, 1100, addr2[17..-1])

    set_text(830, 950, contact.phone)

    # =====

    base_y = 1180
    order.order_items.each do |i|
      set_text(210, base_y, "#{i.thing_title}x#{i.quantity}")
      base_y += 48
    end

    # =====

    set_text(1650, 1080, ACCOUNT)

    # =====

    set_text(1430, 1300, Time.now.month)
    set_text(1550, 1300, Time.now.day)

    self
  end
end
