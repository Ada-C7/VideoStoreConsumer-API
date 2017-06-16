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

  ###### Attempt 1 ######

  # def new
  #   @movie = Movie.new()
  # end
  # this would return an HTML form for creating a new movie
  # I just want to add a new movie

  def create #add to rental library
    @movie = Movie.new(data)
    if @movie.save
      respond_to do |format|
        format.json{}
      end
      flash[:status] = :success

    else
      flash[:status] = :failure
    end
  end

  ###### ########## ######

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

  def require_movie
    @movie = Movie.find_by(title: params[:title])
    unless @movie
      render status: :not_found, json: { errors: { title: ["No movie with title #{params["title"]}"] } }
    end
  end
end
