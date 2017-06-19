class Movie < ApplicationRecord
  attr_accessor :external_id

  has_many :rentals
  has_many :customers, through: :rentals

  def available_inventory
    self.inventory - Rental.where(movie: self, returned: false).length
  end

  def image_url
    orig_value = read_attribute :image_url
    puts "original value"
    puts orig_value
    if !orig_value
      MovieWrapper::DEFAULT_IMG_URL
    elsif orig_value.include? MovieWrapper::DEFAULT_IMG_SIZE
      orig_value
    else
      MovieWrapper.construct_image_url(orig_value)
      # puts "movie image"
      # puts movie_image
    end
  end
end
