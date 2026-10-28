# frozen_string_literal: true

require "sinatra/base"
require "json"

# A tiny in-memory "todo" service.
class App < Sinatra::Base
  set :show_exceptions, false
  set :todos, []
  set :next_id, 1

  helpers do
    def json(data, status_code = 200)
      status status_code
      content_type :json
      JSON.generate(data)
    end

    def payload
      JSON.parse(request.body.read.to_s)
    rescue JSON::ParserError
      halt json({ error: "invalid JSON" }, 400)
    end
  end

  get "/" do
    @todos = settings.todos
    erb :index
  end

  get "/health" do
    json(status: "ok")
  end

  get "/todos" do
    json(settings.todos)
  end

  post "/todos" do
    data = payload
    title = data["title"].to_s.strip
    halt json({ error: "title is required" }, 422) if title.empty?

    todo = { id: settings.next_id, title: title, done: false }
    settings.next_id += 1
    settings.todos << todo
    json(todo, 201)
  end

  get "/todos/:id" do
    todo = settings.todos.find { |t| t[:id] == params[:id].to_i }
    halt json({ error: "not found" }, 404) unless todo
    json(todo)
  end

  delete "/todos/:id" do
    removed = settings.todos.reject! { |t| t[:id] == params[:id].to_i }
    halt json({ error: "not found" }, 404) unless removed
    status 204
  end
end
