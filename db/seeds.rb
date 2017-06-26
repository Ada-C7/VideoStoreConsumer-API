customer_data = JSON.parse(File.read('db/seeds/customers.json'))

customer_data.each do |customer|
  Customer.create!(customer)
end

JSON.parse(File.read('db/seeds/movies.json')).each do |movie|
  # movies = MovieWrapper.search(movie["title"])
  year = movie["release_date"][0..3]
  poster_url = MovieWrapper.search_poster(movie["title"], year)

  movie["image_url"] = poster_url
  Movie.create!(movie)
end
