# frozen_string_literal: true

require 'base_page_cursors'

class NullPageCursors < BasePageCursors
  def to_hash; end
end
