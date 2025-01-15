require_relative 'enemy_bullet'
DEBUG_FONT = Gosu::Font.new(40)
MAX_HP = 4000 
class ChipChapa
    attr_accessor :x, :y, :attack_bullets
  
    def initialize
      # アニメーションフレームを読み込む
      @animation = Gosu::Image::load_tiles("img/chipchap.png", 500, 281)
      @x = Gosu.screen_width - 500
      @y = rand(0..Gosu.screen_height)
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
      # 現在のフレームを計算
      current_time = Gosu.milliseconds - @start_time
      frame = (current_time / @animation_speed) % @animation.size
      img = @animation[frame]
      img.draw(@x, @y, 2, 1, 1, @color, :add)
      @attack_bullet.draw
    end
  
    def off_screen?
      @x < -@animation.first.width
    end

    def read_attack_bullets
        @attack_bullets = @attack_bullet.bullets
    end
end

class Huh
    attr_accessor :x, :y, :attack_bullets
    def initialize
        @animation = Gosu::Image::load_tiles("img/nekomeme/huh.png", 600, 346)        
        @x = Gosu.screen_width  - 100
        @y = 640
        @color = Gosu::Color::WHITE
        @animation_speed = 100
        @start_time = Gosu.milliseconds
        @fire_interval = 50
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
        # 現在のフレームを計算
        current_time = Gosu.milliseconds - @start_time
        frame = (current_time / @animation_speed) % @animation.size
        img = @animation[frame]

        # 画像を描画
        img.draw(@x - img.width / 2.0, @y - img.height / 2.0,
                 2, 1, 1, @color, :add)
        @attack_bullets.each(&:draw)
    end
end

class Yagi
    attr_accessor :x, :y, :attack_bullets
    def initialize
        @animation = Gosu::Image::load_tiles("img/nekomeme/yagi.png", 600, 344)        
        # 初期位置を設定（ウィンドウサイズに応じて調整）
        @x = 1020  
        @y = 640
        # 色を設定（必要に応じて）
        @color = Gosu::Color::WHITE
        # アニメーションのフレーム速度（ミリ秒単位）
        @animation_speed = 80  # フレーム切り替え間隔
        # アニメーションの開始時間
        @start_time = Gosu.milliseconds
        @bomb = Bomb.new(@x,@y)
        @attack_bullets = []
        @bomb_num = rand(5..8)
        @huh = Huh.new
    end

    def update
        if @attack_bullets.size < @bomb_num
            @attack_bullets << Bomb.new(@x,@y)
        end
        @attack_bullets.each(&:update)
        @attack_bullets.reject! { |bomb| !bomb.bomb_remain? }
    end

    def draw
        # 現在のフレームを計算
        current_time = Gosu.milliseconds - @start_time
        frame = (current_time / @animation_speed) % @animation.size
        img = @animation[frame]
        @huh.draw
        # 画像を描画
        img.draw(@x - img.width / 2.0, @y - img.height / 2.0,
                 2, 1, 1, @color, :add)
        @attack_bullets.each(&:draw)
        
    end

end

class Paku 
    attr_accessor :x, :y, :attack_bullets
    def initialize
        @animation = Gosu::Image::load_tiles("img/nekomeme/paku.png", 550, 540)        
        @x = Gosu.screen_width 
        @y = 580
        @bullet = Reflection_Bullet.new(@x,@y-100)
        @color = Gosu::Color::WHITE
        @animation_speed = 80 
        @start_time = Gosu.milliseconds
        @attack_timer = 20
        @cnt = 0
        @attack_bullets = []
    end

    def update # 攻撃Refection_bulletで攻撃する
        @cnt += 1
        if @attack_timer < @cnt
            @attack_bullets << Reflection_Bullet.new(@x,@y-100)
            @cnt = 0
        end
        @attack_bullets.each(&:update)
        @attack_bullets.reject!(&:out_of_bounds?) # 画面外の弾丸を削除
    end

    def draw
        # 現在のフレームを計算
        current_time = Gosu.milliseconds - @start_time
        frame = (current_time / @animation_speed) % @animation.size
        img = @animation[frame]

        # 画像を描画
        img.draw(@x - img.width / 2.0, @y - img.height / 2.0,
                 2, 1, 1, @color, :add)
        @attack_bullets.each(&:draw)
    end
end