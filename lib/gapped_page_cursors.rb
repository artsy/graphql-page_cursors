# frozen_string_literal: true

class GappedPageCursors
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
      first: first_cursor,
      last: last_cursor,
      previous: previous_cursor
    }.compact
  end

  private

  def around_cursors
    around_page_numbers.map { |page_num| page_cursor(page_num) }
  end

  def first_cursor
    include_first_cursor = !around_page_numbers.include?(1)
    return unless include_first_cursor

    page_cursor(1)
  end

  def last_cursor
    include_last_cursor = !around_page_numbers.include?(total_pages)
    return unless include_last_cursor

    page_cursor(total_pages)
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
    if current_page <= 3
      (1..4).to_a
    elsif current_page >= total_pages - 2
      ((total_pages - 3)..total_pages).to_a
    else
      [current_page - 1, current_page, current_page + 1]
    end
  end
end
