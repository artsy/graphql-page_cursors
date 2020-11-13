# frozen_string_literal: true

require 'base_page_cursors'

class BasicPageCursors < BasePageCursors
  private

  def around_page_numbers
    (1..total_pages).to_a
  end

  def first_cursor; end

  def last_cursor; end

  def previous_cursor
    return unless current_page > 1

    cursor_for(current_page - 1)
  end
end
