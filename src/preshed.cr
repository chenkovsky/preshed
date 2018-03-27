require "./preshed/*"

# TODO: Write documentation for `Preshed`
module Preshed
  class Map(V) # UInt64 => UInt64
    include Enumerable({UInt64, V})

    struct Cell(V)
      @key : UInt64
      @value : V
      property :key, :value

      def initialize(@key, @value)
      end
    end

    EMPTY_KEY = 0_u64

    @cells : Pointer(Cell(V))
    @size : UInt64
    @capacity : UInt64
    @default : V

    getter :capacity, :size

    def initialize(@default : V, initial_size : Int = 8)
      initial_size = 8 if initial_size == 0
      initial_size = Math.pw2ceil(initial_size)
      @capacity = initial_size.to_u64
      @size = 0_u64
      @cells = Pointer(Cell(V)).malloc(@capacity, Cell(V).new(EMPTY_KEY, @default))
    end

    def []=(key : UInt64, val : V)
      cell = find_cell key
      if cell.value.key == EMPTY_KEY
        cell.value.key = key
        @size += 1
      end
      cell.value.value = val
      resize if (@size + 1) * 5 >= (@capacity * 3)
      self
    end

    def [](key : UInt64) : V
      cell = find_cell key
      return @default if cell.value.key != key
      return cell.value.value
    end

    def delete(key : UInt64) : V?
      cell = find_cell key
      return nil if cell.value.key != key
      cell.value.key = EMPTY_KEY
      value = cell.value.value
      cell.value.value = @default
      @size -= 1
      return value
    end

    private def find_cell(key : UInt64, cells = @cells, capacity = @capacity) : Cell(V)*
      i = key & (capacity - 1)
      while (cells + i).value.key != EMPTY_KEY && (cells + i).value.key != key
        i = (i + 1) & (capacity - 1)
      end
      return cells + i
    end

    def each
      (0...@capacity).each do |i|
        if (@cells + i).value.key != EMPTY_KEY
          yield (@cells + i).value.key, (@cells + i).value.value
        end
      end
    end

    private def resize
      new_capacity = @capacity * 2
      cells = Pointer(Cell(V)).malloc(new_capacity, Cell(V).new(EMPTY_KEY, @default))
      each do |k, v|
        cell = find_cell k, cells, new_capacity
        cell.value = Cell(V).new(k, v)
      end
      @capacity = new_capacity
      @cells = cells
    end
  end
end
