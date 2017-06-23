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
    existing_movie = Movie.find_by(title: params["title"])
    if existing_movie
      puts existing_movie
      existing_movie.inventory += 1
      if existing_movie.save
        render status: :ok, json: {
          id: existing_movie.id
        }
      else
        render status: :bad_request, json: {errors: 'could not add movie'}
      end
    else
      new_movie = Movie.create(movie_params)
      if new_movie.id
          render status: :ok, json:{
              id: new_movie.id
          }
      else
          render status: :bad_request, json: {errors: 'could not create movie'}
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
      params.require(:movie).permit(:title, :overview, :release_date, :image_url)

  end
end
