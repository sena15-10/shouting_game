# player.rb
require 'gosu'
require_relative 'player_bullet'

class Player
  attr_accessor :x, :y, :width, :height, :player_bullet, :hp, :gauge
  
  PLAYER_SPEED = 6

  def initialize
    @player = Gosu::Image.new('img/starfighter.png')
    @x = 0.0
    @y = Gosu.screen_height / 2.0
    @width = @player.width - 5
    @height = @player.height - 5
    @attacks = []
    @charging = false
    @charge_start_time = nil
    @charge_bullet = nil
    @player_bullet = :bullet    
    @selected_attack = :s
    @opaque_color = Gosu::Color.argb(0xff_ffffff)
    @semi_transparent_color = Gosu::Color.argb(0x80_ffffff)
    @w_key_button = Gosu::Image.new('img/Wkey_button.png')
    @d_key_button = Gosu::Image.new('img/Dkey_button.png')
    @s_key_button = Gosu::Image.new('img/Skey_button.png')
    @a_key_button = Gosu::Image.new('img/Akey_button.png')
    @laser = Laser.new(self)
    @hp = 2000
    @max_hp = 2000
    @gauge = 2000
    @max_gauge = 2000
    @charge_time = 0
  end

  def draw
    @player.draw(@x, @y, 2)
    @attacks.each(&:draw)
    @laser.draw
    draw_bars
    # 既存のキー描画コード
    draw_key_button(@w_key_button, 100, Gosu.screen_height - (127 * 2 + 100), :w, @opaque_color, @semi_transparent_color)
    draw_key_button(@a_key_button, 17, Gosu.screen_height - 256, :a, @opaque_color, @semi_transparent_color)
    draw_key_button(@s_key_button, 100, Gosu.screen_height - 127, :s, @opaque_color, @semi_transparent_color)
    draw_key_button(@d_key_button, 60 + @s_key_button.width, Gosu.screen_height - 256, :d, @opaque_color, @semi_transparent_color)
  end
  
  def draw_key_button(button, x, y, key_symbol, opaque_color, semi_transparent_color)
    color = (@selected_attack == key_symbol) ? opaque_color : semi_transparent_color
    button.draw(x, y, 1, 1, 1, color)
  end

  def draw_bars
    # ゲージバーの背景
    Gosu.draw_rect(10, 10, 200, 20, Gosu::Color::GRAY, 3)
    # ゲージバーの現在値
    gauge_width = (@gauge / @max_gauge.to_f) * 200
    Gosu.draw_rect(10, 10, gauge_width, 20, Gosu::Color::BLUE, 4)

    # HPバーの背景
    Gosu.draw_rect(10, 40, 200, 20, Gosu::Color::GRAY, 3)
    # HPバーの現在値
    hp_width = (@hp / @max_hp.to_f) * 200
    Gosu.draw_rect(10, 40, hp_width, 20, Gosu::Color::RED, 4)
  end

  def update
    move
    @attacks.each(&:update)
    handle_charging
    @attacks.reject!(&:out_of_bounds?)
    @laser.update
    recover_gauge
    laser_remove
  end
  
  def move
    @x -= PLAYER_SPEED if Gosu.button_down?(Gosu::KB_LEFT)
    @x += PLAYER_SPEED if Gosu.button_down?(Gosu::KB_RIGHT)
    @y -= PLAYER_SPEED if Gosu.button_down?(Gosu::KB_UP)
    @y += PLAYER_SPEED if Gosu.button_down?(Gosu::KB_DOWN)

    @x = [[@x, 0].max, Gosu.screen_width - @player.width].min
    @y = [[@y, 0].max, Gosu.screen_height - @player.height].min
  end

  def start_charging
    @charging = true
    @charge_start_time = Gosu.milliseconds
    @charge_bullet = nil
  end

  def release_charge
    if @charging
      
      @charge_time = Gosu.milliseconds - @charge_start_time
      @attacks << ChargeBullet.new(@x + @player.width, @y + @player.height / 2, @charge_time)
      @charging = false
      @charge_bullet = nil
      @charge_time = 0
    end
  end

  def handle_charging
    if @charging
      @charge_time = Gosu.milliseconds - @charge_start_time 
      if ChargeBullet::MAX_CHARGE_TIME > @charge_time
        @gauge -= ChargeBullet::USE_GAUGE 
      end
      @charge_time = [@charge_time, ChargeBullet::MAX_CHARGE_TIME].min
      if @charge_bullet.nil?
        @charge_bullet = ChargeBullet.new(@x + @player.width, @y + @player.height / 2, @charge_time)
      else
        scale = 1 + (@charge_time.to_f / ChargeBullet::MAX_CHARGE_TIME) * 2
        power = ChargeBullet::MIN_POWER + (@charge_time.to_f / ChargeBullet::MAX_CHARGE_TIME) * (ChargeBullet::MAX_POWER - ChargeBullet::MIN_POWER)
        @charge_bullet.scale = scale
        @charge_bullet.power = power
        @charge_bullet.y = @y + @player.height / 2
      end
    end
  end

  def laser_remove
    if @player_bullet == :laser
      if Gosu.button_down?(Gosu::KB_SPACE)
        @gauge -= Laser::USE_GAUGE
      end
    end
  end

  def stop_laser
    @laser.stop_firing
  end

  def attack
    case @player_bullet 
      when :bullet
        if @gauge >= Bullet::USE_GAUGE
          @attacks << Bullet.new(@x + @player.width, @y + @player.height / 2)
          @gauge -= Bullet::USE_GAUGE
        end
      when :charge_bullet
        if @gauge >= ChargeBullet::USE_GAUGE
          start_charging
          
        end
      when :laser
        if @gauge >= Laser::USE_GAUGE
          @laser.start_firing
          @gauge -= Laser::USE_GAUGE
        end
      when :missile
        if @gauge >= Missile::USE_GAUGE
          @attacks << Missile.new(self)
          @gauge -= Missile::USE_GAUGE
        end
    end
      @gauge -= Laser::USE_GAUGE
  end

  def player_bullet_change(key)
    case key
      when "w"
        @player_bullet = :charge_bullet
        @selected_attack = :w
      when "s"
        @player_bullet = :bullet
        @selected_attack = :s
      when "d"
        @player_bullet = :laser
        @selected_attack = :d
      when "a"
        @player_bullet = :missile
        @selected_attack = :a
    end
  end

  def recover_gauge
    if ChargeBullet::MAX_CHARGE_TIME > @charge_time
      @gauge += 3 if @gauge < @max_gauge
    end
  end

  def damage(damage)
    @hp -= damage
  end
end
