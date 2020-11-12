# frozen_string_literal: true

require 'page_cursor_resolver'

RSpec.describe PageCursorResolver do
  describe '#total_pages' do
    it 'returns 0 if items is empty' do
      expect(PageCursorResolver.new(double(:object, items: []), nil).total_pages).to eq 0
    end
    it 'returns 1 if first and last are nil' do
      expect(PageCursorResolver.new(double(:object, items: [1], first: nil, last: nil), nil).total_pages).to eq 1
    end
    it 'returns the number of pages needed to display all items' do
      expect(PageCursorResolver.new(double(:object, items: [1], first: 1), nil).total_pages).to eq 1
      expect(PageCursorResolver.new(double(:object, items: [1, 2, 3], first: 2), nil).total_pages).to eq 2
      expect(PageCursorResolver.new(double(:object, items: [1], first: nil, last: 1), nil).total_pages).to eq 1
      expect(PageCursorResolver.new(double(:object, items: [1, 2, 3], first: nil, last: 2), nil).total_pages).to eq 2
    end
    it 'raises an error when items is nil' do
      expect { PageCursorResolver.new(double(:object, items: nil, first: nil, last: 2), nil).total_pages }.to raise_error(NoMethodError)
    end
    it 'raises an error when first is 0 or first is nil and last is 0' do
      expect { PageCursorResolver.new(double(:object, items: [1], first: 0), nil).total_pages }.to raise_error(FloatDomainError)
      expect { PageCursorResolver.new(double(:object, items: [1], first: nil, last: 0), nil).total_pages }.to raise_error(FloatDomainError)
    end
  end
  describe '#total_count' do
    it 'returns the number of items' do
      expect(PageCursorResolver.new(double(:object, items: []), nil).total_count).to eq 0
      expect(PageCursorResolver.new(double(:object, items: [1]), nil).total_count).to eq 1
      expect(PageCursorResolver.new(double(:object, items: [1, 2]), nil).total_count).to eq 2
    end
    it 'raises an error when items is nil' do
      expect { PageCursorResolver.new(double(:object, items: nil), nil).total_count }.to raise_error(NoMethodError)
    end
  end
  describe '#nodes_per_page' do
    it 'returns the value of first if it is set' do
      expect(PageCursorResolver.new(double(:object, first: 0), nil).nodes_per_page).to eq 0
      expect(PageCursorResolver.new(double(:object, first: 1), nil).nodes_per_page).to eq 1
      expect(PageCursorResolver.new(double(:object, first: 1, last: 2), nil).nodes_per_page).to eq 1
    end
    it 'returns the value of last if it is set but first is not' do
      expect(PageCursorResolver.new(double(:object, first: nil, last: 0), nil).nodes_per_page).to eq 0
      expect(PageCursorResolver.new(double(:object, first: nil, last: 1), nil).nodes_per_page).to eq 1
    end
  end
end
