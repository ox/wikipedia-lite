require 'sinatra'
require 'sinatra/reloader' if development?

require 'json'
require 'sinatra/json'

require 'redis'
$redis = Redis.new

require 'redcarpet'
$markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, space_after_headers: true, fenced_code_blocks: true)

require './helpers'
require './page'

# show all pages
get "/" do
  pages = Page.get_all

  haml :index, locals: { pages: pages }
end

# render a page by title
get "/wiki/:name" do |name|
  page = Page.get_by_title(name)

  if page == {}
    haml :page_not_found, locals: { page_name: name }
  else
    haml :render_page, locals: { page: page }
  end
end

# edit a page by title
get "/edit/:title" do |title|
  page = Page.get_by_title(title)

  if page == {}
    page["title"] = title
  end

  haml :edit_page, locals: { page: page }
end

# submitting a new page
post "/edit" do
  page = Page.get_by_id(params["id"])
  page.merge!(params)
  new_page = Page.save(page)

  redirect to "/wiki/#{new_page["sanitized_title"]}"
end

# shortcut for creating a new page with a particular title
get "/new/:title" do |title|
  page = {"title" => title}
  haml :edit_page, locals: { page: page }
end

# create a new page
get "/new" do
  haml :edit_page, locals: { page: {} }
end

# deleting pages by id
get "/delete/:id" do |id|
  Page.delete_by_id(id)
  redirect to "/"
end

post "/search" do
  sane_title = sanitize_string(params[:search])
  page = Page.get_by_title(sane_title)
  if page == {}
    redirect to "/new/#{sane_title}"
  else
    redirect to "/wiki/#{sane_title}"
  end
end

# API
get "/api/get_all_titles" do
  titles = []
  pages = Page.get_all

  pages.each do |page|
    titles << page["title"]
  end

  json titles
end
