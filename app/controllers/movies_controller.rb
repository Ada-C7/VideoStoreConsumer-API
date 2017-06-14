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
    movie = Movie.new

    movie.title = params[:title]
    movie.image_url = params[:image_url]
    movie.overview = params[:overview]
    movie.release_date = params[:release_date]
    movie.inventory = params[:inventory]

    if
      movie.save
      render status: :ok, json: {id: movie.id, title: movie.title}
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

  # def movie_params
  #   params.require(:movie).permit(:id, :title, :release_date, :overview, :inventory, :image_url)
  # end
end
