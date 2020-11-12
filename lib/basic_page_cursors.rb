# frozen_string_literal: true

class BasicPageCursors
  def self.as_hash(total_pages, current_page, per_page)
    new(total_pages, current_page, per_page).to_hash
  end

  attr_reader :total_pages, :current_page, :per_page

  def initialize(total_pages, current_page, per_page)
    @total_pages = total_pages
    @current_page = current_page
    @per_page = per_page
  end

  def to_hash
    {
      around: around_cursors,
      previous: previous_cursor
    }
  end

  private

  def around_cursors
    around_page_numbers.map { |page_num| page_cursor(page_num) }
  end

  def previous_cursor
    include_previous_cursor = current_page > 1
    return unless include_previous_cursor

    page_cursor(current_page - 1)
  end

  def page_cursor(page_number)
    PageCursor.as_hash(current_page, page_number, per_page)
  end

  def around_page_numbers
    (1..total_pages).to_a
  end
end
