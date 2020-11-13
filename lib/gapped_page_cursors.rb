# frozen_string_literal: true

require 'base_page_cursors'

class GappedPageCursors < BasePageCursors
  private

  def around_page_numbers
    if current_page <= 3
      (1..4).to_a
    elsif current_page >= total_pages - 2
      ((total_pages - 3)..total_pages).to_a
    else
      [current_page - 1, current_page, current_page + 1]
    end
  end

  def first_cursor
    return if around_page_numbers.include?(1)

    cursor_for(1)
  end

  def last_cursor
    return if around_page_numbers.include?(total_pages)

    cursor_for(total_pages)
  end

  def previous_cursor
    return unless current_page > 1

    cursor_for(current_page - 1)
  end
end
