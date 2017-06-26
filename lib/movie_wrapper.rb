class MovieWrapper
  BASE_URL = "https://api.themoviedb.org/3/"
  KEY = ENV["MOVIEDB_KEY"]

  BASE_IMG_URL = "https://image.tmdb.org/t/p/"
  DEFAULT_IMG_SIZE = "w185"
  DEFAULT_IMG_URL = "https://dummyimage.com/185x278/feaa03/ffffff.png&text=Poster+unavailable"

  def self.search(query)

    url = BASE_URL + "search/movie?api_key=" + KEY + "&query=" + query
    # puts url
    response =  HTTParty.get(url)
    if response["total_results"] == 0
      return []
    else
      movies = response["results"].map do |result|
        self.construct_movie(result)
      end
      return movies
    end
  end

  def self.search_poster(title, year)
    url = BASE_URL + "search/movie?api_key=" + KEY + "&query=" + title + "&year=" + year

    response =  HTTParty.get(url)
    puts response


    if response["total_results"] > 0
      result = response["results"][0]
      image_url = result["poster_path"]

      poster_url = "#{BASE_IMG_URL}" + "#{DEFAULT_IMG_SIZE}" + image_url

      return poster_url
    else
      return "#{DEFAULT_IMG_URL}"
    end
  end

  private

  def self.construct_movie(api_result)
    image_url = MovieWrapper.create_poster_url(api_result["poster_path"])

    Movie.new(
    title: api_result["title"],
    overview: api_result["overview"],
    release_date: api_result["release_date"],
    image_url: image_url,
    external_id: api_result["id"]
    )
  end

  def self.create_poster_url(poster_path)
    if poster_path
      "#{BASE_IMG_URL}" + "#{DEFAULT_IMG_SIZE}" + "#{poster_path}"
    else
      "#{DEFAULT_IMG_URL}"
    end
  end
end
