require 'gosu'

# color graphics version, w/ sound
class GameWindow < Gosu::Window
  ALIVE = Gosu::Color::YELLOW
  DEAD = Gosu::Color::BLACK

  attr_reader :width, :height, :game, :dx, :dy, :cols, :rows, :beep, :text

  def initialize(width, height)
    @width, @height = width, height
    super(width, height, false)
    self.caption = "Raymond Gan's Game of Life"
    @dx, @dy = 10, 10
    @cols, @rows = width / dx, height / dy
    @gen = 1

    @beep = Gosu::Sample.new(self, './media/beep.wav')
    @text = Gosu::Font.new(self, 'Arial', 20)

    @game = Game.new(World.new(@rows, @cols))
    @game.world.randomly_populate
  end

  def update
    game.tick
    @gen += 1
  end

  def draw
    game.world.cells.each do |cell|
      col, row = cell.y, cell.x
      color = cell.alive? ? ALIVE : DEAD

      draw_quad(  col * dx, row * dy + 20,       color,
        (col + 1) * dx - 1, row * dy + 20,       color,
                  col * dx, (row + 1) * dy + 19, color,
        (col + 1) * dx - 1, (row + 1) * dy + 19, color)
    end

    live_cells = game.world.live_cells

    # speed (sound pitch) on scale 0-100%
    # more live cells => higher pitched sound
    speed = 100 * live_cells / (cols * rows)
    text.draw("Gen: #{@gen}    Live cells: #{live_cells}\
      Sound pitch: #{speed}", width / 5, 0, 0)
    beep.play(10, speed) # volume, pitch
  end

  def button_down(id)
    case id
    when Gosu::KbSpace  # space bar restarts game
      @gen = 0
      game.world.randomly_populate
    when Gosu::KbEscape # ESC key quits
      close
    end
  end

  def needs_cursor?
    true
  end
end
