require_relative '../lib/movie_wrapper'
customer_data = JSON.parse(File.read('db/seeds/customers.json'))

customer_data.each do |customer|
  Customer.create!(customer)
end

JSON.parse(File.read('db/seeds/movies.json')).each do |movie|
  movies = MovieWrapper.search(movie["title"])
  movies.first.save unless movies.empty?
end
