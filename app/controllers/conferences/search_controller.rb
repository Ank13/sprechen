class Conferences::SearchController < ApplicationController

  autocomplete :topic, :name

  def new
  end

  def create
    @search = Conferences::Search.create(params[:conferences_search])
    @results = @search.results
    render :show
  end

  def show
  end

end