class AmazonWishlistScraper
  def initialize
    @agent = Mechanize.new
    @agent.user_agent = "Mozilla/5.0 (Macintosh; U; PPC Mac OS X Mach-O; en-US; rv:1.8.1.1) Gecko/20061204 Firefox/2.0.0.1"
    @url = <<-EOS
      http://www.amazon.com/registry/wishlist/#{ENV['AMAZON_USER_ID']}/ref=cm_wl_sb_o?
      reveal=unpurchased&filter=all&sort=date-added&layout=compact&x=6&y=13
      EOS
  end

  def scrape
    get_asins
    get_info_for_all_products
    products
  end

  private

    def asins
      @asins ||= []
    end

    def get_asins
      @page = @agent.get @url
      get_asins_from_page
      num_pages = @page.parser.css('span.num-pages').first.text.to_i
      (num_pages - 1).times do |i|
        @page = @agent.get "#{@url}&page=#{i + 2}"
        get_asins_from_page
      end
    end

    def get_asins_from_page
      @page.parser.css('span.productTitle a').each do |link|
        url = link['href']
        if asin = url.match(/\/dp\/([\d\w]+)\//).to_a[1]
          asins << asin
        end
      end
    end

    def get_info_for_all_products
      asins.each do |asin|
        url = offer_url asin
        get_product_info url
        sleep 1
      end
    end

    def get_product_info(url)
      parser = @agent.get(url).parser
      title = parser.css('.producttitle').first.text
      author = parser.css('#olpProductByLine').text.match(/by\s([\w\s]+)\\?n?/).to_a[1].strip
      tbody = parser.css('tbody.result')
      price = tbody.search('.price').first.text.match(/[\d\.]+/).to_a[0].to_f rescue 0
      shipping = tbody.search('.price_shipping').first.text.match(/[\d\.]+/).to_a[0].to_f rescue 0
      products << {title: title, author: author, amazon_total_cost: (price + shipping).round(2)}
    rescue => e
      puts e
    end

    def offer_url(asin)
      "http://www.amazon.com/gp/offer-listing/#{asin}/"
    end

    def products
      @products ||= []
    end
end
