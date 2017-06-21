customer_data = JSON.parse(File.read('db/seeds/customers.json'))

customer_data.each do |customer|
  Customer.create!(customer)
end

JSON.parse(File.read('db/seeds/movies.json')).each do |movie|
  # movie["image_url"] = "test"
  movies = MovieWrapper.search(movie["title"])
  image_url = movies[0][:image_url]
  movie["image_url"] = "https://image.tmdb.org/t/p/w185" + image_url
  Movie.create!(movie)
end
