class Review < ApplicationRecord

  has_many :images

  def self.desc
    order(created_at: :desc)
  end

end
