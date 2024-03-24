require 'bundler'
Bundler.require
require_relative 'setup_dll'

class Game
  attr_reader :field, :score

  def initialize
    @score = 0
    @field = []
    add_new()
  end

  def shift(direction)
    new_field = []
    puts "Before:"
    draw
    case direction
    when :up
      4.times do |y|
        squash([fetch(0, y)&.v, fetch(1, y)&.v, fetch(2, y)&.v, fetch(3, y)&.v]).each_with_index do |v, i|
          new_field << Cell.new(i, y, v)
        end
      end
    when :left
      4.times do |x|
        squash([fetch(x, 0)&.v, fetch(x, 1)&.v, fetch(x, 2)&.v, fetch(x, 3)&.v]).each_with_index do |v, i|
          new_field << Cell.new(x, i, v)
        end
      end
    when :right
      4.times do |x|
        squash([fetch(x, 3)&.v, fetch(x, 2)&.v, fetch(x, 1)&.v, fetch(x, 0)&.v]).each_with_index do |v, i|
          new_field << Cell.new(x, 3-i, v)
        end
      end
    when :down
      4.times do |y|
        squash([fetch(3, y)&.v, fetch(2, y)&.v, fetch(1, y)&.v, fetch(0, y)&.v]).each_with_index do |v, i|
          new_field << Cell.new(3-i, y, v)
        end
      end
    end
    @field = new_field
    add_new()
    puts "after"
    draw
  end

  def squash(arr)
    first = nil
    arr.compact!
    arr.each_with_index do |el, i|
      if el == first
        arr[i-1] = 2 * first
        @score += 2 * first
        arr[i] = nil
      else
        first = el
      end
    end
    arr.compact!
    arr
  end

  def add_new
    value = [2,2,2,2,4].sample # 20% chance of getting 4
    loop do
      x, y = rand(4), rand(4)
      c = fetch(x, y)
      unless c
        @field << Cell.new(x, y, value)
        break
      end
    end
  end

  def fetch(x, y)
    @field.find { _1.x == x && _1.y == y }
  end

  def draw
    4.times do |x|
      4.times do |y|
        if c = fetch(x, y)
          print "[#{c.v}]"
        else
          print "[ ]"
        end
      end
      puts
    end
  end
end


class Cell
  attr_reader :x, :y, :v

  COLORS = {
    2 => SKYBLUE,
    4 => GOLD,
    8 => GREEN,
    16 => PINK,
    32 => YELLOW,
    64 => PURPLE,
    128 => DARKBLUE,
    256 => ORANGE,
    512 => DARKGREEN,
    1024 => MAROON,
    2048 => DARKPURPLE
  }

  def initialize(x, y, v)
    @x, @y, @v = x, y, v
  end

  def color
    COLORS[v]
  end
end

class Window
  include Raylib

  RECT_SIZE = 100
  PADDING = 10
  SCREEN_HEIGHT = 5 * RECT_SIZE + 5 * PADDING
  SCREEN_WIDTH = 4 * RECT_SIZE + 5 * PADDING

  def initialize
    @game = Game.new
  end

  def run
    SetTargetFPS(60)
    SetConfigFlags(FLAG_MSAA_4X_HINT)

    InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "2048")
      until WindowShouldClose()
        update
        draw
      end
    CloseWindow()
  end

  def update
    if IsKeyPressed(KEY_UP)
      @game.shift(:up)
    end

    if IsKeyPressed(KEY_DOWN)
      @game.shift(:down)
    end

    if IsKeyPressed(KEY_LEFT)
      @game.shift(:left)
    end

    if IsKeyPressed(KEY_RIGHT)
      @game.shift(:right)
    end
  end

  def draw
    BeginDrawing()
      ClearBackground(BEIGE)
      draw_field
    EndDrawing()
  end

  def draw_field
    # rec = Rectangle.create(0, RECT_SIZE, 4* RECT_SIZE + 5* PADDING, 4* RECT_SIZE + 5* PADDING)
    # DrawRectangleRounded(rec, 0.02, 10, BLUE_COLOR)
    16.times do |i|
      x = (i % 4) * (PADDING + RECT_SIZE)
      y = (i / 4) * (PADDING + RECT_SIZE)
      rec = Rectangle.create(PADDING + x, PADDING + RECT_SIZE + y, RECT_SIZE, RECT_SIZE)
      DrawRectangleRounded(rec, 0.2, 10, BROWN)
    end

    @game.field.each do |cell|
      x = cell.y * (PADDING + RECT_SIZE)
      y = cell.x * (PADDING + RECT_SIZE)
      rec = Rectangle.create(PADDING + x, PADDING + RECT_SIZE + y, RECT_SIZE, RECT_SIZE)
      DrawRectangleRounded(rec, 0.2, 10, cell.color)
      DrawText(
        "#{cell.v}",
        PADDING + cell.y * (PADDING + RECT_SIZE) + RECT_SIZE / 3.0,
        PADDING + RECT_SIZE + cell.x * (PADDING + RECT_SIZE) + RECT_SIZE / 3.0,
        35,
        DARKBROWN
      )
    end

    DrawText("Score: #{@game.score}", PADDING, PADDING, 35, BROWN)
  end
end

Window.new.run
