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
    # check if the movie is already in the rails db by checking if there is a movie in the rails db with the same title and release date from params (use find by)
    # if the movie already exists in the rails db, then increase the inventory by 1
    # set inventory to 1 when we create the movie in the rails db

    movie = Movie.find_by(title: params[:title], release_date: params[:release_date])
    if movie
      movie.inventory += 1
      movie.save
    else
      movie = Movie.new(movie_params)
      movie.inventory = 1
      if movie.save
        render status: :ok, json: {id: movie.id}
      else
        render status: :bad_request, json: { errors: movie.errors.messages }
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
    params.require(:movie).permit(:title, :overview, :release_date, :inventory, :image_url)
  end
end
