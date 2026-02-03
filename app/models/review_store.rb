# frozen_string_literal: true

require "yaml"

class ReviewEntry
  attr_reader :id, :name, :review, :created_at, :updated_at, :images

  def initialize(id:, name:, review:, created_at:, updated_at:, images: [])
    @id = id
    @name = name
    @review = review
    @created_at = created_at
    @updated_at = updated_at
    @images = images
  end
end

class ReviewImage
  attr_reader :id, :url, :created_at, :updated_at

  def initialize(id:, url:, created_at:, updated_at:)
    @id = id
    @url = url
    @created_at = created_at
    @updated_at = updated_at
  end
end

class ReviewStore
  DATA_PATH = Rails.root.join("data", "reviews.yml")

  class << self
    def all_desc
      all.sort_by { |r| r.created_at.to_s }.reverse
    end

    def all
      reload_if_changed!
      @all ||= load_entries
    end

    def reload!
      @all = load_entries
      @mtime = data_mtime
      @all
    end

    private

    def reload_if_changed!
      current_mtime = data_mtime
      reload! if @mtime != current_mtime
    end

    def data_mtime
      File.exist?(DATA_PATH) ? File.mtime(DATA_PATH) : nil
    end

    def load_entries
      raw = File.exist?(DATA_PATH) ? YAML.load_file(DATA_PATH) : {}
      items = raw["reviews"] || []

      items.map do |item|
        images = Array(item["images"]).map do |img|
          ReviewImage.new(
            id: img["id"],
            url: img["url"],
            created_at: img["created_at"],
            updated_at: img["updated_at"]
          )
        end

        ReviewEntry.new(
          id: item["id"],
          name: item["name"],
          review: item["review"],
          created_at: item["created_at"],
          updated_at: item["updated_at"],
          images: images
        )
      end
    end
  end
end
