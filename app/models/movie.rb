class Movie < ApplicationRecord
  attr_accessor :external_id

  has_many :rentals
  has_many :customers, through: :rentals

  def available_inventory
    self.inventory - Rental.where(movie: self, returned: false).length
  end

  def image_url
    orig_value = read_attribute :image_url
    if !orig_value
      # MovieWrapper::DEFAULT_IMG_URL

      movies = MovieWrapper.search(title)
      image_url = movies[0][:image_url]
      self[:image_url] = image_url
      self.save!

      MovieWrapper.construct_image_url(image_url)
    else
      MovieWrapper.construct_image_url(orig_value)
    end
  end
end
