class MoviesController < ApplicationController
  before_action :require_movie, only: [:show]

  def index
    if params[:query]
      data = MovieWrapper.search(params[:query])
    else
      data = Movie.all
    end
    render status: :ok, json: data
  end

  def create
    print "In create method:"

    movie_data = {
      title: movie_params[:title],
      overview: movie_params[:overview],
      release_date: movie_params[:release_date],
      image_url: movie_params[:image_url][31..-1]
    }

    movie = Movie.new(movie_data)
    existing_movie = Movie.find_by(title: params[:title])
    if existing_movie.nil?
      movie.save
    end
  end


  def show
    render(
    status: :ok,
    json: @movie.as_json(
    only: [:title, :overview, :release_date, :inventory],
    methods: [:available_inventory]
    )
    )
  end

  private
  def movie_params
    params.require(:movie).permit(:title, :overview, :release_date, :image_url)
  end

  def require_movie
    @movie = Movie.find_by(title: params[:title])
    unless @movie
      render status: :not_found, json: { errors: { title: ["No movie with title #{params["title"]}"] } }
    end
  end
end
