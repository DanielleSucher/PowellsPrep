class Book
  attr_accessor :_id, :amazon_total_cost, :attributes, :author, :cheaper_at_powells, :isbn, :locations, :title

  def self.all
    database.all(:books).map { |book| Book.new book }
  end

  def self.create(attributes)
    book = new(attributes)
    book.save
  end

  def self.export_locations
    File.open('powells_shopping_list.txt', 'w') do |f|
      locations.each do |store_name, major_sections|
        f.puts "\n\n#{store_name.split('-').map { |w| w.capitalize }.join(' ')}"
        major_sections.sort.each do |major_section, minor_sections|
          f.puts "#{' ' * 5}#{major_section}"
          minor_sections.sort.each do |minor_section, shelf_locations|
            f.puts "#{' ' * 5 * 2}#{minor_section}"
            shelf_locations.sort.each do |shelf_location, books|
              f.puts "#{' ' * 5 * 3}shelf: #{shelf_location}"
              books.sort_by { |book| book[:author].split(' ').last }.each do |book|
                f.puts "#{' ' * 5 * 4}#{book[:title]} - #{book[:author]} - #{book[:isbn]} - #{book[:price]}"
              end
            end
          end
        end
      end
    end
  end

  def self.find(isbn)
    database.find_book isbn
  end

  def self.mark_all_cheaper_at_powells
    all.each do |book|
      book.cheaper_at_powells = book.locations.any? { |loc| loc['price'] && loc['price'].to_f < book.amazon_total_cost.to_f }
      book.save
    end
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
     locations: locations,
     cheaper_at_powells: cheaper_at_powells}
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

    def self.all_cheaper_at_powells
      database.find_books('cheaper_at_powells' => true).map { |book| Book.new book }
    end

    def self.database
      BookDatabase.new
    end

    def self.locations
      return @locations if @locations
      @locations = {}
      all_cheaper_at_powells.each do |book|
        book.locations.each do |loc|
          next if loc['store'].match(/warehouse/) || loc['price'].nil? || loc['price'].to_f >= book.amazon_total_cost.to_f
          @locations[loc['store']] ||= {}
          @locations[loc['store']][loc['major_section']] ||= {}
          @locations[loc['store']][loc['major_section']][loc['minor_section']] ||= {}
          shelf_location = loc['shelf_location'] || 'unknown'
          @locations[loc['store']][loc['major_section']][loc['minor_section']][shelf_location] ||= Set.new
          @locations[loc['store']][loc['major_section']][loc['minor_section']][shelf_location] << {title: book.title,
                                                                                                   author: book.author,
                                                                                                   isbn: book.isbn,
                                                                                                   price: loc['price']}
        end
      end
      @locations
    end

    def set_attributes
      @attributes.each { |key, value| send :"#{key}=", value }
    end

end
