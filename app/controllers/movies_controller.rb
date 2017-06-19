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
    movie_data = {
      title: params[:title],
      overview: params[:overview],
      release_date: params[:release_date],
      image_url: params[:image_url]#[31..-1]
    }

    # puts movie_data

    movie = Movie.new(movie_data)
    existing_movie = Movie.find_by(title: params[:title], release_date: params[:release_date])
    # if existing_movie.nil?
      if movie.save
        render status: :ok, json: movie
      else
      render status: :error
      end
    # end
  end


  private

  def require_movie
    @movie = Movie.find_by(title: params[:title])
    unless @movie
      render status: :not_found, json: { errors: { title: ["No movie with title #{params["title"]}"] } }
    end
  end
end
