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
    movie = Movie.new(movie_params)
    if movie.save
      render json: movie.as_json, status: :ok
    else
      render json: {errors: {movie: ["Unable to add to #{params[:title]} your Movie Store!"]} }
    end
    # create new movie with title
    # Save it to DB.
    # Send it to front end backbone.
    # Add to collecction
    # Rerender.
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
