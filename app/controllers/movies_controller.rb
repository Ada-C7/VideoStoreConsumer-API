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
    # movie_data = {
    #   title: params[:title],
    #   overview: params[:overview],
    #   release_date: params[:release_date],
    #   image_url: params[:image_url]#[31..-1]
    # }

    movie = Movie.new(movie_params)

    if movie.save
      # if Movie.find_by(title: params[:title], release_date: params[:release_date])
        render status: :ok, json: movie
    else
      render status: :error, json: {errors: movie.errors.messages}
    end
  end


  private

  def movie_params
    params.permit(:title, :overview, :release_date, :image_url)
  end

  def require_movie
    @movie = Movie.find_by(title: params[:title])
    unless @movie
      render status: :not_found, json: { errors: { title: ["No movie with title #{params["title"]}"] } }
    end
  end
end
