class Browser
  def wechat?
    !!(ua.downcase =~ /micromessenger/)
  end

  def desktop?
    !(mobile? || tablet?)
  end
end
