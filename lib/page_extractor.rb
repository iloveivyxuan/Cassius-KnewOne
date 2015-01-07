require 'nokogiri'
require 'open-uri'

module PageExtractor
  USER_AGENT = 'Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.116 Safari/537.36'

  RULES = [{
             name: 'Amazon',
             url_pattern: /(amazon|z)\.(com|cn)/,
             selectors: {
               title: '#btAsinTitle > span, #btAsinTitle, #productTitle, #mocaBBProductTitle',
               description: '#productDescription, #postBodyPS',
               images:
               proc do |_, html|
                 images = {}
                 html.scan(%r{http://ec.\.images-amazon\.com/images/I/.*?\.jpg}).each do |url|
                   id =   url[%r{(?<=/I/)[^.]+}]
                   size = url[%r{(?<=\._[A-Z]{2})\d+}].to_i
                   if !images.has_key?(id) || images[id][:size] < size
                     images[id] = {url: url, size: size}
                   end
                 end
                 images.map { |_, h| h[:url] }
               end
             }
           }, {
             name: 'Expansys',
             url_pattern: /expansys\.com\.hk/,
             selectors: {
               title: 'h1',
               images: proc { |doc| doc.css('#image img').attr('rel').value }
             }
           }, {
             name: 'DemoHour',
             url_pattern: /demohour\.com/,
             selectors: {
               title: 'h1',
               description: 'projects-home-right h2',
               images: proc { |doc| doc.css('#project_poster_video img').attr('src').value }
             }
           }, {
             name: 'Fancy',
             url_pattern: /fancy\.com/,
             selectors: {
               title: 'span.title',
               description: proc { |doc| doc.css('meta[property="og:description"]').attr('content').value },
               images: proc { |doc| doc.css('meta[property="og:image"]').attr('content').value }
             }
           }, {
             name: 'JD',
             url_pattern: /jd\.com/,
             selectors: {
               title: 'h1',
               description: 'h2',
               images: proc { |doc| doc.css('#preview img').attr('src').value }
             }
           }, {
             name: 'Open Graph',
             url_pattern: /.*/,
             selectors: {
               title: proc { |doc| doc.css('meta[property="og:title"]').attr('content').value },
               description: proc { |doc| doc.css('meta[property="og:description"]').attr('content').value },
               images: proc { |doc| doc.css('meta[property="og:image"]').attr('content').value }
             }
           }, {
             name: 'Twitter Card',
             url_pattern: /.*/,
             selectors: {
               title: proc { |doc| doc.css('meta[property="twitter:title"]').attr('content').value },
               description: proc { |doc| doc.css('meta[property="twitter:description"]').attr('content').value },
               images: proc { |doc| doc.css('meta[property="twitter:image"]').attr('content').value }
             }
           }, {
             name: 'Fallback',
             url_pattern: /.*/,
             selectors: {
               title: 'head > title',
               description: 'head > title',
               images: proc do |doc|
                 doc.css('img').map { |element| element.attr('src') }
               end
             }
           }]

  def self.extract(url)
    html = begin
             open(url, 'User-Agent' => USER_AGENT).read
           rescue
             nil
           end

    return nil unless html

    doc = Nokogiri::HTML(html)

    RULES.each do |rule|
      next unless rule[:url_pattern].match(url)

      begin
        info = {url: url}
        rule[:selectors].each do |key, selector|
          value = case selector
                  when Proc
                    selector.call(doc, html)
                  when Regexp
                    html.scan(selector)
                  when String
                    doc.css(selector).map(&:text).map(&:strip)
                  else
                    raise 'Illegal selector'
                  end

          raise 'Try other rules' unless value

          if key == :images
            info[key] = Array(value).uniq
            info[key].map! { |path| URI.join(url, path).to_s rescue nil }.compact!
          else
            info[key] = Array(value).first
          end
        end

        return info
      rescue => e
        # raise
        # p e
        next
      end
    end

    nil
  end
end

# # examples
# [
# 'http://www.amazon.com/dp/B00CU0NSCU',
# 'http://www.amazon.com/dp/B001FWYGJS',
# 'http://www.amazon.com/dp/B004XC6GJ0',
# 'http://www.amazon.com/dp/B00FJK5KVK',
# 'http://www.amazon.com/dp/B00CEKXJ3Y',
# 'http://www.amazon.cn/dp/B007AAWCPE',
# 'http://www.amazon.cn/dp/B005U6CFBQ',
# 'http://fancy.com/things/596719893366182299/Long-Horn-Deluxe-Convertible-Sofa',
# 'http://item.jd.com/1092249.html',
# 'http://www.demohour.com/projects/340820',
# 'https://www.kickstarter.com/projects/1060791749/city-of-darkness-revisited'
# ].each do |url|
#   puts url
#   s = Time.now.to_i
#   puts PageExtractor::extract(url)
#   e = Time.now.to_i
#   puts "#{e - s}s"
# end
