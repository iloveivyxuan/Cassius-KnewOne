require 'mini_magick'
class ZtoWayBill < WayBill
  def initialize
    @image = MiniMagick::Image.open(Rails.root.join('lib/waybill/zto_white_board.gif'))
  end

  def draw_body_from_order(order)
    set_text(450, 320, SENDER)

    addr1 = ADDRESS
    set_text(420, 400, addr1[0..16])
    set_text(420, 500, addr1[17..-1])

    set_text(500, 600, COMPANY)

    set_text(500, 700, PHONE)

    # =====

    contact = order.address

    set_text(1550, 320, contact.name)

    addr2 = "#{contact.province} #{contact.district} #{contact.street}"
    set_text(1500, 400, addr2[0..16])
    set_text(1500, 500, addr2[17..-1])

    set_text(1600, 700, contact.phone)

    # =====

    set_text(660, 1220, Date.today.to_s)

    self
  end
end
