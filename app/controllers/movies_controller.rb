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

  def show
    render(
    status: :ok,
    json: @movie.as_json(
    only: [:title, :overview, :release_date, :inventory],
    methods: [:available_inventory]
    )
    )
  end

  def create

    modified_params = movie_params
    modified_params[:image_url] = modified_params[:image_url].gsub("https://image.tmdb.org/t/p/w185","")
    movie = Movie.new(modified_params)

    if movie.save
      render status: :ok, json: { title: movie.title }
    else
      render status: :bad_request, json: { errors: movie.errors.messages }
    end
  end

  private

  def require_movie
    @movie = Movie.find_by(title: params[:title])
    unless @movie
      render status: :not_found, json: { errors: { title: ["No movie with title #{params["title"]}"] } }
    end
  end

  def movie_params
    params.require(:movie).permit(:id, :title, :overview, :release_date, :image_url, :external_id)
  end
end
