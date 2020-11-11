# frozen_string_literal: true

require 'graphql'

require 'graphql/page_cursors/version'

module GraphQL
  class PageCursor < GraphQL::Schema::Object
    field :cursor, String, 'first cursor on the page', null: false
    field :is_current, Boolean, 'is this the current page?', null: false
    field :page, Int, 'page number out of totalPages', null: false
  end

  class PageCursors < GraphQL::Schema::Object
    field :first, PageCursor, 'optional, may be included in field around', null: true
    field :last, PageCursor, 'optional, may be included in field around', null: true
    field :around, [PageCursor], null: false
    field :previous, PageCursor, null: true
  end

  class PageCursorConnection < GraphQL::Types::Relay::BaseConnection
    field :page_cursors, PageCursors, null: true
    field :total_pages, Int, null: true
    field :total_count, Int, null: true

    MAX_CURSOR_COUNT = 5

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
      return 0 if object.items.size.zero?
      return 1 if nodes_per_page.nil?

      (object.items.size.to_f / nodes_per_page).ceil
    end

    def total_count
      object.items.size
    end

    private

    def around_cursors
      around_page_numbers.map { |page_num| page_cursor(page_num) }
    end

    def first_cursor
      exceeds_max_cursor_count = total_pages > MAX_CURSOR_COUNT
      include_first_cursor =
        exceeds_max_cursor_count && around_page_numbers.exclude?(1)
      return unless include_first_cursor

      page_cursor(1)
    end

    def last_cursor
      exceeds_max_cursor_count = total_pages > MAX_CURSOR_COUNT
      include_last_cursor =
        exceeds_max_cursor_count && around_page_numbers.exclude?(total_pages)
      return unless include_last_cursor

      page_cursor(total_pages)
    end

    def previous_cursor
      include_previous_cursor = current_page > 1
      return unless include_previous_cursor

      page_cursor(current_page - 1)
    end

    def page_cursor(page_num)
      {
        cursor: cursor_for_page(page_num),
        is_current: current_page == page_num,
        page: page_num
      }
    end

    def cursor_for_page(page_num)
      return '' if page_num == 1

      after_cursor = (page_num - 1) * nodes_per_page
      encode(after_cursor.to_s)
    end

    def current_page
      nodes_before / nodes_per_page + 1
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

    def nodes_before
      node_offset(object.edge_nodes.first) - 1
    end

    def nodes_after
      node_offset(object.edge_nodes.last)
    end

    def node_offset(node)
      # this was previously accomplished by calling a private method:
      # object.send(:offset_from_cursor, object.cursor_from_node(object.edge_nodes.first))
      object.items.index(node) + 1
    end

    def nodes_per_page
      object.first || object.last
    end

    # borrowed from https://graphql-ruby.org/api-doc/1.10.6/Base64Bp.html
    def encode(value)
      str = Base64.strict_encode64(value)
      str.tr!('+/', '-_')
      str.delete!('=')
      str
    end
  end
end
