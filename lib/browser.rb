class Browser
  def wechat?
    !!(ua.downcase =~ /micromessenger/)
  end
end
