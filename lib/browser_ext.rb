class Browser
  def wechat?
    !!(ua.downcase =~ /micromessenger/)
  end

  def desktop?
    !(mobile? || tablet?)
  end

  def ucbrowser?
    !!(ua.downcase =~ /ucbrowser/)
  end

  def ucweb?
    !!(ua.downcase =~ /ucweb/)
  end

  def uc?
    ucbrowser? || ucweb?
  end
end
