# frozen_string_literal: true

require 'page_cursor'

class PageCursorResolver
  MAX_CURSOR_COUNT = 5

  attr_reader :object, :context

  def initialize(object, context)
    @object = object
    @context = context
  end

  def page_cursors
    return if total_pages <= 1

    {
      around: around_cursors,
      first: first_cursor,
      last: last_cursor,
      previous: previous_cursor
    }.compact
  end

  def total_pages
    return 0 if object_items.size.zero?
    return 1 if nodes_per_page.nil?

    (object_items.size.to_f / nodes_per_page).ceil
  end

  def total_count
    object_items.size
  end

  private

  def object_items
    return object.nodes unless object.respond_to?(:items)

    object.items
  end

  def around_cursors
    around_page_numbers.map { |page_num| page_cursor(page_num) }
  end

  def first_cursor
    exceeds_max_cursor_count = total_pages > MAX_CURSOR_COUNT
    include_first_cursor =
      exceeds_max_cursor_count && !around_page_numbers.include?(1)
    return unless include_first_cursor

    page_cursor(1)
  end

  def last_cursor
    exceeds_max_cursor_count = total_pages > MAX_CURSOR_COUNT
    include_last_cursor =
      exceeds_max_cursor_count && !around_page_numbers.include?(total_pages)
    return unless include_last_cursor

    page_cursor(total_pages)
  end

  def previous_cursor
    include_previous_cursor = current_page > 1
    return unless include_previous_cursor

    page_cursor(current_page - 1)
  end

  def page_cursor(page_number)
    PageCursor.as_hash(current_page, page_number, nodes_per_page)
  end

  def around_page_numbers # rubocop:disable Metrics/AbcSize
    if total_pages <= MAX_CURSOR_COUNT
      (1..total_pages).to_a
    elsif current_page <= 3
      (1..4).to_a
    elsif current_page >= total_pages - 2
      ((total_pages - 3)..total_pages).to_a
    else
      [current_page - 1, current_page, current_page + 1]
    end
  end

  def current_page
    first_node = object.edge_nodes.first
    item_index = object_items.index(first_node) || 0
    nodes_before = item_index + 1
    nodes_before / nodes_per_page + 1
  end

  def nodes_per_page
    object.first || object.last
  end
end
