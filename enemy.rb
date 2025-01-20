require_relative 'enemy_bullet'
DEBUG_FONT = Gosu::Font.new(40)
MAX_HP = 5000 

class Enemy
  attr_accessor :x, :y, :image, :hp

  MAX_HP = 5000

  def initialize
    @hp = MAX_HP
    @x = 0
    @y = 0
    @image_height = 0
    @image_width = 0
    @image = nil
  end

  def draw 
    current_time = Gosu.milliseconds - @start_time
    frame = (current_time / @animation_speed) % @animation.size
    img = @animation[frame]
    @image_height,@image_width = img.height,img.width
    img.draw(@x - img.width / 2.0, @y - img.height / 2.0,
             2, 1, 1, @color, :add)
    @attack_bullets.each(&:draw)
  end

  def damage(amount)
    @hp -= amount
    @hp = 0 if @hp < 0
  end

  def inherit_hp(hp) # 現在のHPを継承する
    @hp = hp
  end

  def hit?(bullet_x, bullet_y)
    enemy_left = @x - @image_width / 2
    enemy_right = @x + @image_width / 2
    enemy_top = @y - @image_height / 2
    enemy_bottom = @y + @image_height / 2

    collision = !(bullet_x > enemy_right || 
                  bullet_x < enemy_left || 
                  bullet_y > enemy_bottom || 
                  bullet_y < enemy_top)

    collision
  end

  def off_screen?
    @x < -@animation.first.width
  end
end

class ChipChapa < Enemy
  attr_accessor :x, :y, :attack_bullets, :image_height, :image_width

  def initialize
    super
    @animation = Gosu::Image::load_tiles("img/chipchap.png", 500, 281)
    @x = Gosu.screen_width
    @y = rand(0..Gosu.screen_height)
    @image_width = 0
    @image_height = 0
    @color = Gosu::Color::WHITE
    @animation_speed = 100  
    @start_time = Gosu.milliseconds
    @attack_bullet = ChipChapa_Bullet.new(self)
    @attack_bullets = []
    @fire_interval = 100
    @cnt = 0
  end

  def update
    read_attack_bullets
    @x -= 5
    @attack_bullet.update
  end

  def draw
    current_time = Gosu.milliseconds - @start_time
    frame = (current_time / @animation_speed) % @animation.size
    img = @animation[frame]
    @image_height,@image_width = img.height,img.width
    img.draw(@x, @y, 2, 1, 1, @color, :add)
    @attack_bullet.draw
  end

  def off_screen?
    super
  end

  def read_attack_bullets
    @attack_bullets = @attack_bullet.bullets
  end
end

class Huh < Enemy
  attr_accessor :x, :y, :attack_bullets, :image_height, :image_width

  def initialize
    super
    @animation = Gosu::Image::load_tiles("img/nekomeme/huh.png", 600, 346)        
    @x = Gosu.screen_width  - 100
    @y = 640
    @image_width = 0
    @image_height = 0
    @color = Gosu::Color::WHITE
    @animation_speed = 100
    @start_time = Gosu.milliseconds
    @fire_interval = 30
    @attack_bullets = []
    @cnt = 0
  end

  def update
    @y = 640 + 500 * Math.sin(Gosu.milliseconds / 1000.0)
    @cnt += 1
    if @fire_interval < @cnt
      @attack_bullets << Hidden_bullet.new(@x,@y,5)
      @cnt = 0
    end
    @attack_bullets.each(&:update)
    @attack_bullets.reject!(&:out_of_bounds?)
  end

  def draw
    super
  end

  def hit?(bullet_x, bullet_y)
    image_side_left = @x - @image_width / 3
    image_side_right = @x + @image_width / 3
    image_side_up = @y - @image_height / 3
    image_side_down = @y + @image_height / 3

    if bullet_x.between?(image_side_left, image_side_right) && bullet_y.between?(image_side_up, image_side_down)
      return true
    end
    return false
  end

  def off_screen?
    super
  end

end

class Yagi < Enemy
  attr_accessor :x, :y, :attack_bullets, :image_height, :image_width

  def initialize
    super
    @animation = Gosu::Image::load_tiles("img/nekomeme/yagi.png", 600, 344)        
    @x = 1020  
    @y = 640
    @image_width = 0 
    @image_height = 0
    @color = Gosu::Color::WHITE
    @animation_speed = 80  
    @start_time = Gosu.milliseconds
    @bomb = Bomb.new(@x,@y)
    @attack_bullets = []
    @bomb_num = rand(5..8)
  end

  def update
    if @attack_bullets.size < @bomb_num
      @attack_bullets << Bomb.new(@x,@y)
    end
    @attack_bullets.each(&:update)
    @attack_bullets.reject! { |bomb| !bomb.bomb_remain? }
  end

  def draw
    super       
  end

  def off_screen?
    super
  end

end

class Paku < Enemy
  attr_accessor :x, :y, :attack_bullets, :image_height, :image_width

  def initialize
    super
    @animation = Gosu::Image::load_tiles("img/nekomeme/paku.png", 550, 540)        
    @x = Gosu.screen_width 
    @y = 580
    @image_height = 0
    @image_width = 0
    @bullet = Reflection_Bullet.new(@x,@y-100)
    @color = Gosu::Color::WHITE
    @animation_speed = 80 
    @start_time = Gosu.milliseconds
    @attack_timer = 20
    @cnt = 0
    @attack_bullets = []
  end

  def update
    @cnt += 1
    if @attack_timer < @cnt
      @attack_bullets << Reflection_Bullet.new(@x,@y-100)
      @cnt = 0
    end
    @attack_bullets.each(&:update)
    @attack_bullets.reject!(&:out_of_bounds?)
  end

  def draw
    super
  end

  def off_screen?
    super
  end

  def hit?(bullet_x,bullet_y)
    super
  end
  
end