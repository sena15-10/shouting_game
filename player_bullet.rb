# player_bullet.rb
require 'gosu'

class Bullet 
  attr_accessor :power,:x, :y
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

  def remove
    @x -= 1000
    @y -= 1000
  end
end

class ChargeBullet < Bullet
  MAX_CHARGE_TIME = 2000
  MIN_POWER = 10
  MAX_POWER = 100
  USE_GAUGE = 10

  attr_accessor :scale, :power,:x, :y

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

class Missile < Bullet
  USE_GAUGE = 500

  INITIAL_SPEED = 8
  attr_accessor :x,:y,:power
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

class Laser
  USE_GAUGE = 8

  attr_accessor :x, :y, :width, :height, :firing,:power

  INITIAL_WIDTH = 0

  def initialize(player)
    @player = player
    @width = INITIAL_WIDTH
    @height = 10
    @max_width = Gosu.screen_width + 2000
    @image = Gosu::Image.new('img/laser.png')
    @firing = false
    @power = 1
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
    @y = @player.y + @player.height.to_f / 2
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

  def remove
    puts "   "
  end
  def hit?(enemy)
    
    if @width < 0
      puts "レーザーは発射されていません"
      return false 
    end
    
    # レーザーの当たり判定領域を計算
    laser_left = @x
    laser_right = @x + @width
    laser_top = @y
    laser_bottom = @y + @height
    
    # 敵の当たり判定領域を計算
    enemy_left = enemy.x - enemy.image_width / 2
    enemy_right = enemy.x + enemy.image_width / 2
    enemy_top = enemy.y - enemy.image_height / 2
    enemy_bottom = enemy.y + enemy.image_height / 2
    
    # 衝突判定の結果をデバッグ出力
    collision = !(laser_right < enemy_left || 
    laser_left > enemy_right || 
    laser_bottom < enemy_top || 
    laser_top > enemy_bottom)
    
    puts "レーザー座標: (#{laser_left},#{laser_top}) - (#{laser_right},#{laser_bottom})"
    puts "敵の座標: (#{enemy_left},#{enemy_top}) - (#{enemy_right},#{enemy_bottom})"
    puts "衝突判定結果: #{collision}"
    
    collision
  end
end




