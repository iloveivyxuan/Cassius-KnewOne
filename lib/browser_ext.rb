class Browser
  NAMES.merge!({
    wechat: "Wechat",
    desktop: "Desktop",
    ucbrowser: "UCBrowser",
    ucweb: "UCWeb",
    uc: "UC",
  })

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

  def possible_names
    NAMES.keys.select do |id|
      try :"#{id}?"
    end
  end
end
