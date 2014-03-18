class ReviewsController < ApplicationController

  def index
    @reviews = Review.desc.all
  end
end
