# frozen_string_literal: true

require 'page_cursor'
require 'basic_page_cursors'
require 'gapped_page_cursors'

class PageCursorResolver
  MAX_CURSOR_COUNT = 5

  attr_reader :object, :context

  def initialize(object, context)
    @object = object
    @context = context
  end

  def page_cursors
    return if total_pages <= 1

    if total_pages <= MAX_CURSOR_COUNT
      BasicPageCursors.as_hash(total_pages, current_page, per_page)
    else
      GappedPageCursors.as_hash(total_pages, current_page, per_page)
    end
  end

  def total_pages
    return 0 if object_items.size.zero?

    (object_items.size.to_f / per_page).ceil
  end

  def total_count
    object_items.size
  end

  private

  def object_items
    return object.nodes unless object.respond_to?(:items)

    object.items
  end

  def current_page
    first_node = object.edge_nodes.first
    item_index = object_items.index(first_node) || 0
    nodes_before = item_index + 1
    nodes_before / per_page + 1
  end

  def per_page
    object.first || object.last || 1
  end
end
