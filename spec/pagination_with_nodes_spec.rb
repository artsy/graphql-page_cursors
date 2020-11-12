# frozen_string_literal: true

require 'page_cursor_resolver'

describe 'pagination' do
  context 'with 0 items' do
    it 'has no pages or cursors' do
      object = double(:object, nodes: [], first: nil, last: nil, edge_nodes: [])
      results = PageCursorResolver.new(object, nil)

      expect(results.total_pages).to eq 0
      expect(results.total_count).to eq 0
      expect(results.page_cursors).to be_nil
    end
  end

  context 'with 1 item' do
    let(:item) { double :item }

    it 'has 1 page for 1 item and no cursors' do
      object = double(:object, nodes: [item], first: nil, last: nil, edge_nodes: [])
      results = PageCursorResolver.new(object, nil)

      expect(results.total_pages).to eq 1
      expect(results.total_count).to eq 1
      expect(results.page_cursors).to be_nil
    end
  end

  context 'with 20 items and 10 per page' do
    let(:item) { double :item }
    let(:items) { [item] * 20 }

    it 'has 2 pages for 20 total artsyRobots' do
      object = double(:object, nodes: items, first: 10, last: nil)
      results = PageCursorResolver.new(object, nil)
      expect(results.total_pages).to eq 2
      expect(results.total_count).to eq 20
    end

    it 'has 2 around pages' do
      # object.items = full set
      # object.edge_nodes = subset of items to be returned in query
      edge_nodes = items.first(10)
      object = double(:object, nodes: items, first: 10, last: nil, edge_nodes: edge_nodes)
      results = PageCursorResolver.new(object, nil)
      page_cursors = results.page_cursors

      expect(page_cursors[:first]).to be_nil
      expect(page_cursors[:last]).to be_nil
      expect(page_cursors[:previous]).to be_nil

      around = page_cursors[:around]
      expect(around.count).to eq 2
      expect(around[0][:is_current]).to be true
      expect(around[0][:cursor]).to_not eq around[1][:cursor]
      expect(around[0][:cursor]).to match(/^\D*$/)
      expect(around[0][:page]).to eq 1
      expect(around[1][:is_current]).to be false
      expect(around[1][:page]).to eq 2
    end
  end

  context 'with 60 items and 10 per page' do
    let(:items) { Array(1..60).map { |i| double "item_#{i}" } }

    context 'on page 1' do
      it 'has 4 around pages and a last page' do
        edge_nodes = items.first(10)
        object = double(:object, nodes: items, first: 10, last: nil, edge_nodes: edge_nodes)
        results = PageCursorResolver.new(object, nil)

        page_cursors = results.page_cursors
        expect(page_cursors[:first]).to be_nil
        expect(page_cursors[:last][:page]).to eq 6
        expect(page_cursors[:previous]).to be_nil

        around = page_cursors[:around]
        expect(around.count).to eq 4
        expect(around.first[:is_current]).to be true
        expect(around.first[:page]).to eq 1
        expect(around.last[:is_current]).to be false
        expect(around.last[:page]).to eq 4
      end
    end

    context 'on page 3' do
      it 'has 4 around pages and a last page' do
        edge_nodes = items.first(10)
        object = double(:object, nodes: items, first: 10, last: nil, edge_nodes: edge_nodes)
        results = PageCursorResolver.new(object, nil)

        page_cursors = results.page_cursors
        page_three_cursor = page_cursors[:around][2][:cursor]
        edge_nodes = items.drop(20).first(10)
        object = double(:object, nodes: items, first: 10, after: page_three_cursor, last: nil, edge_nodes: edge_nodes)
        results = PageCursorResolver.new(object, nil)

        page_cursors = results.page_cursors
        expect(page_cursors[:first]).to be_nil
        expect(page_cursors[:last][:page]).to eq 6
        expect(page_cursors[:previous][:page]).to eq 2
        around = page_cursors[:around]
        expect(around.count).to eq 4
        expect(around.first[:is_current]).to be false
        expect(around.first[:page]).to eq 1
        expect(around.last[:is_current]).to be false
        expect(around.last[:page]).to eq 4
      end
    end

    context 'on page 5' do
      it 'has 3 around pages and both first and last page' do
        edge_nodes = items.first(10)
        object = double(:object, nodes: items, first: 10, last: nil, edge_nodes: edge_nodes)
        results = PageCursorResolver.new(object, nil)

        page_cursors = results.page_cursors
        # around is expected to be [1, 2, 3, 4] when we are on the first page
        page_four_cursor = page_cursors[:around][3][:cursor]
        edge_nodes = items.drop(30).first(10)
        object = double(:object, nodes: items, first: 10, after: page_four_cursor, last: nil, edge_nodes: edge_nodes)
        results = PageCursorResolver.new(object, nil)

        page_cursors = results.page_cursors
        # around is expected to be [3, 4, 5] when we are on the fourth page
        page_five_cursor = page_cursors[:around].last[:cursor]
        edge_nodes = items.drop(40).first(10)
        object = double(:object, nodes: items, first: 10, after: page_five_cursor, last: nil, edge_nodes: edge_nodes)
        results = PageCursorResolver.new(object, nil)

        page_cursors = results.page_cursors
        expect(page_cursors[:first][:page]).to eq 1
        expect(page_cursors[:last]).to be_nil
        expect(page_cursors[:previous][:page]).to eq 4
        around = page_cursors[:around]
        expect(around.count).to eq 4
        expect(around.first[:is_current]).to be false
        expect(around.first[:page]).to eq 3
        expect(around[1][:is_current]).to be false
        expect(around[1][:page]).to eq 4
        expect(around[2][:is_current]).to be true
        expect(around[2][:page]).to eq 5
        expect(around.last[:is_current]).to be false
        expect(around.last[:page]).to eq 6
      end
    end
  end
end
