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
    movie = Movie.new(title: params[:title], overview: params[:overview], release_date: params[:release_date], inventory: params[:inventory], image_url: params[:image_url])

    # movie.inventory ||= rand(8)

    if movie.save
      render json: {id: movie.id}, status: :ok
    else
      render json: { errors: movie.errors.messages }, status: :bad_request
    end
  end

  def destroy
    movie = Movie.find_by(id: params[:id])
    if movie
      if movie.destroy
        render json: {id: movie.id}, status: :ok
      else
        render json: { errors: movie.errors.messages }, status: :bad_request
      end
    else
      render json: { errors: "This Movie does not exist in the database" }, status: :not_found
    end
  end

  private

  def require_movie
    @movie = Movie.find_by(title: params[:title])
    unless @movie
      render status: :not_found, json: { errors: { title: ["No movie with title #{params["title"]}"] } }
    end
  end
end
