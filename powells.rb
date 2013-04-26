require './requirements'

class Powells
  def store_books_in_database
    wishlist_items = amazon_scraper.scrape
    wishlist_items do |book|
      find_and_save_book book
    end
  end

  def update_book_locations
    Book.all.each do |book|
      book.update_locations location_data(book.isbn)
    end
  end

  private

    def amazon_scraper
      @scraper ||= AmazonWishlistScraper.new
    end

    def api_key
      @api_key ||= ENV['API_KEY']
    end

    def base_url
      @base_url ||= "http://api.powells.com/v0c/#{api_key}"
    end

    def find_and_save_book(book)
      search_string = "#{book[:title]} #{book[:author]}".split(/[^a-zA-Z']+/).join('+')
      if isbn = get_isbn(search_string)
        book[:isbn] = isbn
        save_book book
      end
    end

    def get_isbn(search_string)
      response = JSON.parse RestClient.get("#{base_url}/search/#{search_string}")
      return response['results'].first['isbn'] if response && response['results']
      nil
    end

    def location_data(isbn)
      response = JSON.parse RestClient.get("#{base_url}/inventory/#{isbn}")
      return nil unless response && response['results']
      parse_api_results_for_location_data response['results']
    end

    def parse_api_results_for_location_data(results)
      location_data = []
      results.each do |result|
        result[1]['locations'].each do |store_name, details|
          details.each do |detail_id, detail_contents|
            location_data << parse_location_details(store_name, detail_contents)
          end
        end
      end
      location_data
    end

    def parse_location_details(store_name, detail_contents)
      { store: store_name,
        major_section: detail_contents['section']['major'],
        minor_section: detail_contents['section']['minor'],
        shelf_location: detail_contents['shelf_location'],
        price: detail_contents['price'] }
    end

    def save_book(book)
      Book.create isbn: book[:isbn],
                  amazon_total_cost: book[:amazon_total_cost],
                  author: book[:author],
                  title: book[:title]
    end
end
