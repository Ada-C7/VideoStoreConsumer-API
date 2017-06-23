require 'test_helper'

class MoviesControllerTest < ActionDispatch::IntegrationTest
  describe "create" do
    it "creates a new movie" do
      post new_movie_path params: { title: "WowMovie!", overview: "MyText", release_date: "2017-01-11", inventory: 4 }
      assert_response :success
      Movie.last.title.must_equal movies(:one).title
    end

    it "returns the id of the movie if successful" do
      post new_movie_path(movies(:one))
      body = JSON.parse(response.body)
      body.must_be_kind_of Hash
      body["id"].must_equal Movie.last.id
    end

    # checks that if the movie already exisit in our library, then it return error message
  end

  describe "destroy" do
    it "deletes a movie" do
      Movie.destroy_all
      post new_movie_path params: { title: "WowMovie!", overview: "MyText", release_date: "2017-01-11", inventory: 4 }
      movie_id = Movie.first.id
      delete delete_movie_path(movie_id)
      assert_response :success
      body = JSON.parse(response.body)
      body.must_be_kind_of Hash
      body["id"].must_equal movie_id
      Movie.count.must_equal 0
    end

    it "Doens't delete movie if the id passed is invalid" do
      Movie.destroy_all
      post new_movie_path params: { title: "WowMovie!", overview: "MyText", release_date: "2017-01-11", inventory: 4 }
      delete delete_movie_path(23424556)
      assert_response :not_found
      Movie.count.must_equal 1
      body = JSON.parse(response.body)
      body.must_be_kind_of Hash
      body["errors"].must_equal "This Movie does not exist in the database"
    end
  end



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
end
