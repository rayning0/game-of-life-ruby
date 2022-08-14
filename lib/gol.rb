require 'io/wait'

# Game of Life board
class World
  attr_reader :rows, :cols, :grid, :cells

  def initialize(rows = 3, cols = 3)
    @rows = rows
    @cols = cols

    @grid = Array.new(rows) do |row|
              Array.new(cols) do |col|
                Cell.new(row, col)
              end
            end

    @cells = grid.flatten
  end

  def live_cells
    cells.select { |cell| cell.alive? }
  end

  def live_neighbors_of(cell)
    live = []
    x, y = cell.x, cell.y
    neighbors = [*x - 1..x + 1].product([*y - 1..y + 1])
      .reject { |c| c == [x, y] }

    neighbors.each do |neighbor|
      x, y = neighbor[0], neighbor[1]
      next if x < 0 || x >= rows || y < 0 || y >= cols
      live << [x, y] if grid[x][y].alive?
    end

    live
  end

  def randomly_populate
    cells.each do |cell|
      cell.alive = [true, false].sample
    end
  end
end

# each individual square on board
class Cell
  attr_reader :x, :y
  attr_accessor :alive

  def initialize(x = 0, y = 0)
    @x, @y = x, y
    @alive = false
  end

  def alive?
    alive
  end

  def dead?
    !alive
  end

  def lives
    @alive = true
  end

  def dies
    @alive = false
  end
end

# game play, with 4 rules, for specific initial setup
class Game
  attr_reader :world, :seeds
  def initialize(world = World.new, seeds = [])
    @world = world
    @seeds = seeds
    seeds.each do |seed|
      world.grid[seed[0]][seed[1]].lives
    end
  end

  def tick
    next_live_cells, next_dead_cells = [], []

    world.cells.each do |cell|
      neighbors = world.live_neighbors_of(cell).count
      if cell.alive?
        # Rule 1
        next_dead_cells << cell if neighbors < 2
        # Rule 2
        next_live_cells << cell if neighbors.between?(2, 3)
        # Rule 3
        next_dead_cells << cell if neighbors > 3
      else
        # Rule 4
        next_live_cells << cell if neighbors == 3
      end
    end

    next_dead_cells.each { |cell| cell.dies }
    next_live_cells.each { |cell| cell.lives }
  end
end

# plain text output in Terminal, w/o sound
class Window
  ALIVE = "o".encode('utf-8')
  DEAD = ".".encode('utf-8')

  attr_reader :width, :height, :game, :dx, :dy, :cols, :rows, :title

  def initialize(width, height)
    @width, @height = width, height
    @cols, @rows = width, height
    @title = "Raymond Gan's Game of Life"
    @gen = 1

    @game = Game.new(World.new(@rows, @cols))
    @game.world.randomly_populate
  end

  def update
    game.tick
    @gen += 1
  end

  def display
    puts title.center(width * 2)
    puts "Generation: #{@gen}  Live cells: #{game.world
      .live_cells.count}".center(width * 2)

    rows.times do |row|
      cols.times do |col|
        cell = game.world.grid[row][col]
        text = cell.alive? ? ALIVE : DEAD
        print "#{text} "
      end
      puts
    end
  end

  def run
    loop do
      system('clear') # clears terminal screen
      display
      input = char_if_pressed

      if input == ' ' # space bar restarts game
        @gen = 0
        game.world.randomly_populate
      end

      sleep(1)
      update
      break if input == "\e" # ESC key quits
    end
  end

  private

  def char_if_pressed # captures background key press
    begin
      system('stty raw -echo') # turn raw input on
      input = $stdin.getc if $stdin.ready?
      input.chr if input
    ensure
      system('stty -raw echo') # turn raw input off
    end
  end
end
