#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "strscan"

SQL_PATH = File.expand_path("../ikulibro.sql", __dir__)
OUT_PATH = File.expand_path("../data/reviews.yml", __dir__)

unless File.exist?(SQL_PATH)
  warn "SQL dump not found at #{SQL_PATH}"
  exit 1
end

sql = File.binread(SQL_PATH)
sql.force_encoding("UTF-8")
sql = sql.encode("UTF-8", invalid: :replace, undef: :replace, replace: "")
sql = sql.scrub

# Extract the raw VALUES(...) list for a given table.
def statement_end(sql, start_idx)
  in_string = false
  escape = false
  idx = start_idx
  while idx < sql.length
    ch = sql[idx]
    if in_string
      if escape
        escape = false
      elsif ch == "\\"
        escape = true
      elsif ch == "'"
        in_string = false
      end
    else
      if ch == "'"
        in_string = true
      elsif ch == ";"
        return idx
      end
    end
    idx += 1
  end
  nil
end

def extract_values(sql, table)
  marker = "INSERT INTO `#{table}` VALUES "
  start_idx = sql.index(marker)
  return nil unless start_idx

  start_idx += marker.length
  end_idx = statement_end(sql, start_idx)
  return nil unless end_idx

  sql[start_idx...end_idx]
end

# Parse a MySQL VALUES list into an array of rows.
# Handles strings in single quotes with backslash-escapes.
def parse_values_list(values_list)
  rows = []
  scanner = StringScanner.new(values_list)

  until scanner.eos?
    scanner.skip(/\s*,\s*/)
    next if scanner.skip(/\s*;/)

    unless scanner.skip(/\s*\(/)
      # If we can't find a row start, consume one char to avoid infinite loop.
      scanner.getch
      next
    end

    row = []
    loop do
      scanner.skip(/\s*/)

      if scanner.scan(/NULL/i)
        value = nil
      elsif scanner.peek(1) == "'"
        scanner.getch # opening quote
        str = +""
        until scanner.eos?
          ch = scanner.getch
          if ch == "\\"
            esc = scanner.getch
            case esc
            when "n" then str << "\n"
            when "r" then str << "\r"
            when "t" then str << "\t"
            when "\\" then str << "\\"
            when "'" then str << "'"
            when "\"" then str << "\""
            else
              # Unknown escape, keep as-is
              str << esc.to_s
            end
          elsif ch == "'"
            break
          else
            str << ch
          end
        end
        value = str
      else
        # number or bare token
        token = scanner.scan(/[^,\)]+/)
        token = token&.strip
        value = if token.nil? || token.empty?
          nil
        elsif token.include?(".")
          token.to_f
        elsif token =~ /\A-?\d+\z/
          token.to_i
        else
          token
        end
      end

      row << value
      scanner.skip(/\s*/)

      if scanner.skip(/\s*,\s*/)
        next
      elsif scanner.skip(/\s*\)/)
        break
      else
        # Try to recover to end of row.
        scanner.scan(/[^\)]*/)
        scanner.skip(/\)/)
        break
      end
    end

    rows << row
  end

  rows
end

reviews_values = extract_values(sql, "reviews")
images_values = extract_values(sql, "images")

if reviews_values.nil? || images_values.nil?
  warn "Could not find INSERT statements for reviews/images in SQL dump"
  exit 1
end

reviews_rows = parse_values_list(reviews_values)
images_rows = parse_values_list(images_values)

# images: id, url, review_id, created_at, updated_at
images_by_review = Hash.new { |h, k| h[k] = [] }
images_rows.each do |id, url, review_id, created_at, updated_at|
  next if review_id.nil?
  images_by_review[review_id] << {
    "id" => id,
    "url" => url,
    "created_at" => created_at,
    "updated_at" => updated_at
  }
end

# reviews: id, name, review, created_at, updated_at
reviews = reviews_rows.map do |id, name, review, created_at, updated_at|
  {
    "id" => id,
    "name" => name,
    "review" => review,
    "created_at" => created_at,
    "updated_at" => updated_at,
    "images" => images_by_review[id]
  }
end

# Sort newest first (created_at desc) but keep stable for nil timestamps
reviews.sort_by! { |r| r["created_at"].to_s }
reviews.reverse!

File.write(OUT_PATH, { "reviews" => reviews }.to_yaml)
puts "Wrote #{reviews.size} reviews to #{OUT_PATH}"
