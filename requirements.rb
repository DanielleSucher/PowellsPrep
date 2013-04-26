%w(rubygems
  bundler/setup
  json
  open-uri
  mechanize
  mongo
  rest-client
  ./lib/amazon_wishlist_scraper
  ./lib/book_database
  ./lib/book).each do |lib|
  require lib
end
