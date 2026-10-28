# frozen_string_literal: true

ENV["RACK_ENV"] = "test"

require "minitest/autorun"
require "rack/test"
require "json"
require_relative "../app"

class AppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    App
  end

  def setup
    App.settings.todos.clear
    App.set :next_id, 1
  end

  def test_health
    get "/health"
    assert_equal 200, last_response.status
    assert_equal({ "status" => "ok" }, JSON.parse(last_response.body))
  end

  def test_create_and_fetch_todo
    post "/todos", { title: "write tests" }.to_json
    assert_equal 201, last_response.status
    id = JSON.parse(last_response.body)["id"]

    get "/todos/#{id}"
    assert_equal 200, last_response.status
    assert_equal "write tests", JSON.parse(last_response.body)["title"]
  end

  def test_validation_error
    post "/todos", { title: "  " }.to_json
    assert_equal 422, last_response.status
  end

  def test_not_found_and_delete
    get "/todos/99"
    assert_equal 404, last_response.status

    post "/todos", { title: "temp" }.to_json
    delete "/todos/1"
    assert_equal 204, last_response.status
  end

  def test_index_page_renders
    post "/todos", { title: "<b>x</b>" }.to_json
    get "/"
    assert_equal 200, last_response.status
    assert_includes last_response.body, Rack::Utils.escape_html("<b>x</b>")
    refute_includes last_response.body, "<b>x</b>"
  end
end
