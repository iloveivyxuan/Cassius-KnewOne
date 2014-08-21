module AdoptionsHelper
  def adoption_status(status)
    case status
    when :waiting
      "领养进行中"
    when :denied
      "领养失败"
    when :approved
      "领养成功"
    end
  end

  def adopted_by(thing, user)
    Adoption.where(thing: thing, user: user).exists?
  end
end
