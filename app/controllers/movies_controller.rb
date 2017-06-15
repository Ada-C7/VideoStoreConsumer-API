class MoviesController < ApplicationController
    before_action :require_movie, only: [:show]

    def index
        data = if params[:query]
                   MovieWrapper.search(params[:query])
               else
                   Movie.all
               end

        render status: :ok, json: data
    end

    def create
        if Movie.where(title: movie_params[:title], release_date: movie_params[:release_date]).empty?
            movie = Movie.new(movie_params)
            if movie.save
                render status: :ok, json: { id: movie.id }
            else
                render status: :bad_request, json: { errors: movie.errors.messages }
            end
        else
            render status: :bad_request, json: { errors: movie.errors.messages }
        end
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

    def require_movie
        @movie = Movie.find_by(title: params[:title])
        unless @movie
            render status: :not_found, json: { errors: { title: ["No movie with title #{params['title']}"] } }
        end
    end

    def movie_params
        params.permit(:title, :overview, :release_date, :image_url, :external_id)
    end
end
