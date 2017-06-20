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

  ###### Added Create Method ######

  def create #add to rental library
    @movie = Movie.create(input)
  end

  ###### ################## ######

  def show
    render(
      status: :ok,
      json: @movie.as_json(
        only: [:title, :overview, :release_date, :inventory],
        methods: [:available_inventory]
        )
      )
  end

  ###### Working on Update method ######

  def update
    # want to be able to update inventory count
    @movie = Movie.find(params[:id])
    if @movie[:inventory] <= 9
      @movie.increment!(:inventory, 1)
    end
  end

  ###### ######################## ######

  private

  def require_movie
    @movie = Movie.find_by(title: params[:title])
    unless @movie
      render status: :not_found, json: { errors: { title: ["No movie with title #{params["title"]}"] } }
    end
  end

  #### for create method ####
  def input
    return params.require(:movie).permit(:title, :overview, :release_date, :inventory, :image_url)
  end
  ### ################## ###
end
