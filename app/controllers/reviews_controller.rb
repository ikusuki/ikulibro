class ReviewsController < ApplicationController

  def index
    @reviews = ReviewStore.all_desc
  end

end
