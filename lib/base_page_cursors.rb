# frozen_string_literal: true

class BasePageCursors
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
    around_page_numbers.map { |page_number| cursor_for(page_number) }
  end

  def around_page_numbers
    raise 'Implement in subclass'
  end

  def first_cursor
    raise 'Implement in subclass'
  end

  def last_cursor
    raise 'Implement in subclass'
  end

  def previous_cursor
    raise 'Implement in subclass'
  end

  def cursor_for(page_number)
    PageCursor.as_hash(current_page, page_number, per_page)
  end
end
