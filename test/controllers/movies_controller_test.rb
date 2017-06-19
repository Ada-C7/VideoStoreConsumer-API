require 'test_helper'

class MoviesControllerTest < ActionDispatch::IntegrationTest
  describe "index" do
    it "returns a JSON array" do
      get movies_url
      assert_response :success
      @response.headers['Content-Type'].must_include 'json'

      # Attempt to parse
      data = JSON.parse @response.body
      data.must_be_kind_of Array
    end

    it "should return many movie fields" do
      get movies_url
      assert_response :success

      data = JSON.parse @response.body
      data.each do |movie|
        movie.must_include "title"
        movie.must_include "release_date"
      end
    end

    it "returns all movies when no query params are given" do
      get movies_url
      assert_response :success

      data = JSON.parse @response.body
      data.length.must_equal Movie.count

      expected_names = {}
      Movie.all.each do |movie|
        expected_names[movie["title"]] = false
      end

      data.each do |movie|
        expected_names[movie["title"]].must_equal false, "Got back duplicate movie #{movie["title"]}"
        expected_names[movie["title"]] = true
      end
    end
  end

  describe "show" do
    it "Returns a JSON object" do
      get movie_url(title: movies(:one).title)
      assert_response :success
      @response.headers['Content-Type'].must_include 'json'

      # Attempt to parse
      data = JSON.parse @response.body
      data.must_be_kind_of Hash
    end

    it "Returns expected fields" do
      get movie_url(title: movies(:one).title)
      assert_response :success

      movie = JSON.parse @response.body
      movie.must_include "title"
      movie.must_include "overview"
      movie.must_include "release_date"
      movie.must_include "inventory"
      movie.must_include "available_inventory"
    end

    it "Returns an error when the movie doesn't exist" do
      get movie_url(title: "does_not_exist")
      assert_response :not_found

      data = JSON.parse @response.body
      data.must_include "errors"
      data["errors"].must_include "title"

    end
  end

  describe "create" do

    it "affects the model when creating a new movie" do
      proc {
        post movies_url, params: {  movie:
          { title: "Spongebob",
            overview: "Square Pants",
            release_date: "2001",
            inventory: 5,
            image_url: ""}
          }
        }.must_change 'Movie.count', 1
        must_respond_with :ok
      end

      it "won't create with missing title" do
        proc {
          post movies_url, params: {  movie:
            {
              overview: "Square Pants",
              release_date: "2001",
              inventory: 5,
              image_url: ""}
            }
          }.must_change 'Movie.count', 0
          must_respond_with :bad_request

          body = JSON.parse(response.body)
          body.must_equal "errors" => {
            "title" => ["can't be blank" ]
          }

        end

        it "won't create a movie with missing inventory count" do

          proc {
            post movies_url, params: {  movie:
              { title: "Movie!",
                overview: "Square Pants",
                release_date: "2001",
                image_url: ""}
              }
            }.must_change 'Movie.count', 0
            must_respond_with :bad_request

            body = JSON.parse(response.body)
            body.must_equal "errors" => {"inventory"=>["can't be blank", "is not a number"]
            }
        end

        it "won't create a movie that already exists" do
          proc {
            post movies_url, params: {
              movie:
              {
                title: movies(:one).title,
                overview: movies(:one).overview,
                release_date: movies(:one).release_date,
                image_url: movies(:one).image_url,
                inventory: movies(:one).inventory
              }
            }
          }.must_change 'Movie.count', 0

          body = JSON.parse(response.body)
          body.must_equal "errors" => {"movie"=>[" is already in Video Store"]
          }
        end
      end
end
