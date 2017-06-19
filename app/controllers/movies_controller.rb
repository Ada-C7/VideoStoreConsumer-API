class MoviesController < ApplicationController
  before_action :require_movie, only: [:show]

  def index
    data = Movie.all

    render status: :ok, json: data
  end

  def search

    data = MovieWrapper.search(params[:query])

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
    @movie = Movie.new(movie_params)
    if @movie.save
      render json: @movie, status: :ok
    else
      render status: :not_found, json: { errors: { movie: ["Movie could not be saved."] } }
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
    params.require(:movie).permit(:title, :overview, :release_date, :external_id, :image_url)
  end
end
