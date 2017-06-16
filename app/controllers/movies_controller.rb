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
    movie = Movie.new(movie_params)
    # movie.available_inventory = movie.inventory
    if Movie.find_by(overview: params[:overview])
      movie.inventory += 1
      # movie.save
    else
      movie.inventory = 1
      if movie.save
        # movie.available_inventory = movie.inventory
        render status: :ok, json: {id: movie.id}
      else
        render status: :bad_request, json: {errors: movie.errors.messages}
      end
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
  params.permit(:title, :overview, :release_date, :inventory, :available_inventory)
  end
end
