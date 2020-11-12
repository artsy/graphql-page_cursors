# frozen_string_literal: true

require 'base64'

class PageCursor
  def self.as_hash(current_page, page_number, per_page)
    new(current_page, page_number, per_page).to_hash
  end

  attr_reader :current_page, :page_number, :per_page

  def initialize(current_page, page_number, per_page)
    @current_page = current_page
    @page_number = page_number
    @per_page = per_page
  end

  def to_hash
    {
      cursor: encoded_cursor,
      is_current: current?,
      page: page_number
    }
  end

  private

  def current?
    current_page == page_number
  end

  def encoded_cursor
    previous_page = page_number - 1
    return '' if previous_page.zero?

    after_cursor = previous_page * per_page
    encoded = Base64.strict_encode64(after_cursor.to_s)
    encoded.tr('+/', '-_').delete('=')
  end
end
