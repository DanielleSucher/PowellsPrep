class Book
  attr_accessor :_id, :amazon_total_cost, :attributes, :author, :isbn, :locations, :title

  def self.all
    database.all(:books).map { |book| Book.new book }
  end

  def self.find(isbn)
    database.find_book isbn
  end

  def self.create(attributes)
    book = new(attributes)
    book.save
  end

  def initialize(attributes={})
    @attributes = attributes
    set_attributes
  end

  def attributes
    {amazon_total_cost: amazon_total_cost,
     author: author,
     isbn: isbn,
     title: title,
     locations: locations}
  end

  def locations
    @locations ||= []
    # each location has this format:
    # { store: args[:store],
    #   major_section: args[:major_section],
    #   minor_section: args[:minor_section],
    #   shelf_location: args[:shelf_location],
    #   price: args[:price] }
  end

  def save
    Book.database.save_book self
  end

  def update_locations(new_locations)
    if new_locations
      locations.concat new_locations
      save
    end
  end

  private

    def self.database
      BookDatabase.new
    end

    def set_attributes
      @attributes.each { |key, value| send :"#{key}=", value }
    end

end