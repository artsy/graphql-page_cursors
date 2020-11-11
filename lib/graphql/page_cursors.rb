# frozen_string_literal: true

require 'graphql'

require 'page_cursor_resolver'

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

    attr_reader :resolver

    def initialize(object, context)
      super(object, context)
      @resolver = PageCursorResolver.new(object, context)
    end

    def page_cursors
      resolver.page_cursors
    end

    def total_pages
      resolver.total_pages
    end

    def total_count
      resolver.total_count
    end
  end
end
