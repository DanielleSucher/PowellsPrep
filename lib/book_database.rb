include Mongo

class BookDatabase

  def all(type)
    collection(type).find.to_a
  end

  def client
    @client ||= MongoClient.new 'localhost', 27017
  end

  def collection(type)
    database.collection(type.to_s)
  end

  def database
    @database ||= client.db 'powells'
  end

  def find_book(isbn)
    collection(:books).find({"isbn" => isbn}).to_a.first
  end

  def find_books(constraints)
    collection(:books).find(constraints).to_a
  end

  def save_book(book)
    if find_book book.isbn
      collection(:books).update({"isbn" => book.isbn}, book.attributes)
    else
      collection(:books).insert book.attributes
    end
  end
end