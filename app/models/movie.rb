class Movie < ApplicationRecord
  attr_accessor :external_id

  has_many :rentals
  has_many :customers, through: :rentals

  def available_inventory
    self.inventory - Rental.where(movie: self, returned: false).length
  end

  def image_url
    orig_value = read_attribute :image_url
    if !orig_value || orig_value == "http://lorempixel.com/185/278/"
      MovieWrapper::DEFAULT_IMG_URL
    else
      # using slice to remove the part of the url i do not want printed twice, the ! will modify the original variable
      orig_value.slice!('https://image.tmdb.org/t/p/w185')
      MovieWrapper.construct_image_url(orig_value)
    end
  end
end
