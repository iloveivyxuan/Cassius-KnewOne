require 'nokogiri'
require 'open-uri'

module PageExtractor
  USER_AGENT = 'Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.116 Safari/537.36'

  RULES = [{
    name: 'Amazon.com',
    url_pattern: /amazon\.com/,
    selectors: {
      title: '#productTitle',
      description: '#feature-bullets',
      images: %r{http://ec.\.images-amazon\.com/images/I/.*?\.jpg}
    }
  }, {
    name: 'Amazon.cn',
    url_pattern: /(amazon|z)\.cn/,
    selectors: {
      title: '.parseasinTitle',
      description: '#postBodyPS',
      # NOT WORKING YET
      images: %r{(?<="hiResImage":")http://ec.\.images-amazon\.com/images/I/.*?\.jpg}
    }
  }, {
    name: 'DemoHour',
    url_pattern: /demohour\.com/,
    selectors: {
      title: 'h1',
      description: 'h2',
      images: lambda { |doc| doc.css('#project_poster_video img').attr('src').value }
    }
  }, {
    name: 'Fancy',
    url_pattern: /fancy\.com/,
    selectors: {
      title:  'span.title',
      description: lambda { |doc| doc.css('meta[property="og:description"]').attr('content').value },
      images: lambda { |doc| doc.css('meta[property="og:image"]').attr('content').value }
    }
  }, {
    name: 'JD',
    url_pattern: /jd\.com/,
    selectors: {
      title: 'h1',
      description: 'h2',
      images: lambda { |doc| doc.css('#preview img').attr('src').value }
    }
  }, {
    name: 'Open Graph',
    url_pattern: /.*/,
    selectors: {
      title:  lambda { |doc| doc.css('meta[property="og:title"]').attr('content').value },
      description: lambda { |doc| doc.css('meta[property="og:description"]').attr('content').value },
      images: lambda { |doc| doc.css('meta[property="og:image"]').attr('content').value }
    }
  }, {
    name: 'Twitter Card',
    url_pattern: /.*/,
    selectors: {
      title:  lambda { |doc| doc.css('meta[property="twitter:title"]').attr('content').value },
      description: lambda { |doc| doc.css('meta[property="twitter:description"]').attr('content').value },
      images: lambda { |doc| doc.css('meta[property="twitter:image"]').attr('content').value }
    }
  }, {
    name: 'Fallback',
    url_pattern: /.*/,
    selectors: {
      title:  'head > title',
      description: 'head > title',
      images: lambda do |doc|
        doc.css('img').map { |element| element.attr('src') }
      end
    }
  }]

  def self.extract(url)
    RULES.each do |rule|
      next unless rule[:url_pattern].match(url)

      html = open(url, 'User-Agent' => USER_AGENT).read
      doc = Nokogiri::HTML(html)

      begin
        info = {}
        rule[:selectors].each do |key, selector|
          info[key] = case selector
                      when Proc
                        selector.call(doc)
                      when Regexp
                        html[selector]
                      when String
                        doc.css(selector).text
                      else
                        raise 'Illegal selector'
                      end.strip
        end

        info[:images] = Array(info[:images])

        return info
      rescue => e
        # raise
        p e
        next
      end
    end

    nil
  end
end

# # examples
# [
# 'http://fancy.com/things/596719893366182299/Long-Horn-Deluxe-Convertible-Sofa',
# 'http://item.jd.com/1092249.html',
# # 'http://www.amazon.cn/gp/product/B005U6CFBQ/',
# 'http://www.amazon.com/gp/product/B001FWYGJS/',
# 'http://www.demohour.com/projects/340820',
# 'https://www.kickstarter.com/projects/1060791749/city-of-darkness-revisited'
# ].each do |url|
#   puts url
#   s = Time.now.to_i
#   puts PageExtractor::extract(url)
#   e = Time.now.to_i
#   puts "#{e - s}s"
# end
