# player_bullet.rb
require 'gosu'

class Bullet
  SPEED = 10
  USE_GAUGE = 60

  def initialize(x, y)
    @x = x
    @y = y
    @image = Gosu::Image.new('img/bullet.png')
    @power = 30
  end

  def draw
    @image.draw(@x, @y, 1)
  end

  def update
    @x += SPEED
  end

  def out_of_bounds?
    @x > Gosu.screen_width
  end
end

class ChargeBullet < Bullet
  MAX_CHARGE_TIME = 2000
  MIN_POWER = 10
  MAX_POWER = 100
  USE_GAUGE = 10

  attr_accessor :scale, :power, :y

  def initialize(x, y, charge_time)
    super(x, y)
    @image = Gosu::Image.new('img/bullet.png')
    @charge_time = [charge_time, MAX_CHARGE_TIME].min
    @power = MIN_POWER + (@charge_time / MAX_CHARGE_TIME.to_f) * (MAX_POWER - MIN_POWER)
    @speed = 10 + (@charge_time / MAX_CHARGE_TIME.to_f) * 5
    @scale = 1 + (@charge_time / MAX_CHARGE_TIME.to_f) * 3
    @use_gauge = USE_GAUGE + (@charge_time / MAX_CHARGE_TIME.to_f) * USE_GAUGE
  end

  def update
    @x += @speed
  end

  def draw
    @image.draw(@x, @y, 1, @scale, @scale)
  end

  def out_of_bounds?
    @x > Gosu.screen_width
  end
end

class Laser
  USE_GAUGE = 8

  attr_accessor :x, :y, :width, :height, :firing

  INITIAL_WIDTH = 0

  def initialize(player)
    @player = player
    @width = INITIAL_WIDTH
    @height = 10
    @max_width = Gosu.screen_width + 5000
    @image = Gosu::Image.new('img/laser.png')
    @firing = false
    @power = 5
  end

  def start_firing
    @firing = true
  end

  def stop_firing
    @firing = false
    @width = 0
  end

  def update
    if @firing
      if @width < @max_width
        @width += 85
      end
    else
      @width = INITIAL_WIDTH
    end
    @x = @player.x + @player.width.to_f
    @y = @player.y + @player.height.to_f / 2 - @height / 2
  end

  def draw
    if @width > 0
      scale_x = @width.to_f / @image.width
      @image.draw(@x, @y, 1, scale_x, 1)
    end
  end

  def out_of_bounds?
    false
  end
end

class Missile
  USE_GAUGE = 500

  INITIAL_SPEED = 8

  def initialize(player)
    @player = player
    @speed = INITIAL_SPEED
    @image = Gosu::Image.new('img/missile.png')
    @power = 80
    @x = player.x
    @y = player.y
  end

  def update
    @x += @speed
  end

  def draw 
    @image.draw(@x, @y, 1)
  end

  def out_of_bounds?
    @x > Gosu.screen_width
  end
end
