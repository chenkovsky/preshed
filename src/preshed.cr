require "./preshed/*"

# TODO: Write documentation for `Preshed`
module Preshed
  class Map # UInt64 => UInt64
    struct Cell
      @key : UInt64
      @value : Void*
      property :key, :value

      def initialize(@key, @value)
      end
    end

    EMPTY_KEY = 0_u64

    @cells : Pointer(Cell)
    @size : UInt64
    @capacity : UInt64

    getter :capacity, :size

    def initialize(initial_size : Int = 8)
      initial_size = 8 if initial_size == 0
      initial_size = Math.pw2ceil(initial_size)
      @capacity = initial_size.to_u64
      @size = 0_u64
      @cells = Pointer(Cell).malloc(@capacity)
      (0...@capacity).each do |i|
        @cells[i] = Cell.new(EMPTY_KEY, Pointer(Void).null)
      end
    end

    def include?(key : UInt64)
      !self[key]?.nil?
    end

    def []=(key : UInt64, val : Void*)
      cell = find_cell key
      if cell.value.key == EMPTY_KEY
        cell.value.key = key
        @size += 1
      end
      cell.value.value = val
      resize if (@size + 1) * 5 >= (@capacity * 3)
      self
    end

    def []?(key : UInt64) : Void*?
      cell = find_cell key
      return nil if cell.value.key != key
      return cell.value.value
    end

    def [](key : UInt64) : Void*
      ret = self[key]?
      raise IndexError.new if ret.is_a?(Nil)
      return ret
    end

    def delete(key : UInt64) : Void*?
      cell = find_cell key
      return nil if cell.value.key != key
      cell.value.key = EMPTY_KEY
      value = cell.value.value
      cell.value.value = Pointer(Void).null
      @size -= 1
      return value
    end

    private def find_cell(key : UInt64) : Cell*
      i = key & (@capacity - 1)
      while (@cells + i).value.key != EMPTY_KEY && (@cells + i).value.key != key
        i = (i + 1) & (@capacity - 1)
      end
      return @cells + i
    end

    private def resize
      new_capacity = @capacity * 2
      @cells = @cells.realloc(new_capacity)
      (@capacity...new_capacity).each do |i|
        @cells[i] = Cell.new(EMPTY_KEY, Pointer(Void).null)
      end
      @capacity = new_capacity
    end
  end
end
