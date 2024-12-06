require_relative 'enemy_bullet'
class ChipChapa

    MAX_HP = 4000
    attr_accessor :x, :y
  
    def initialize
      # アニメーションフレームを読み込む
      @animation = Gosu::Image::load_tiles("img/chipchap.png", 500, 281)
      @x = Gosu.screen_width - 500
      @y = rand(0..Gosu.screen_height - 281)
      @color = Gosu::Color::WHITE
      @animation_speed = 100  
      @start_time = Gosu.milliseconds
      @attack_bullet = ChipChapa_Bullet.new(self)
    end
  
    def update
      @x -= 5
      #攻撃パターン追加
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
end

class Huh
    attr_accessor :x, :y
    def initialize
        @animation = Gosu::Image::load_tiles("img/nekomeme/huh.png", 600, 346)        
        @x = 320  
        @y = 640
        @color = Gosu::Color::WHITE
        @animation_speed = 100
        @start_time = Gosu.milliseconds
    end

    def update
        @x += 1
        @y += 0.5
    end

    def draw
        # 現在のフレームを計算
        current_time = Gosu.milliseconds - @start_time
        frame = (current_time / @animation_speed) % @animation.size
        img = @animation[frame]

        # 画像を描画
        img.draw(@x - img.width / 2.0, @y - img.height / 2.0,
                 2, 1, 1, @color, :add)
    end
end

class Yagi
    attr_accessor :x, :y
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
    end

    def update
        @x += 1
        @y += 0.5
    end

    def draw
        # 現在のフレームを計算
        current_time = Gosu.milliseconds - @start_time
        frame = (current_time / @animation_speed) % @animation.size
        img = @animation[frame]

        # 画像を描画
        img.draw(@x - img.width / 2.0, @y - img.height / 2.0,
                 2, 1, 1, @color, :add)
    end
end

class Paku 
    attr_accessor :x, :y
    def initialize
        @animation = Gosu::Image::load_tiles("img/nekomeme/paku.png", 550, 540)        
        # 初期位置を設定（ウィンドウサイズに応じて調整）
        @x = Gosu.screen_width - 550 
        @y = 580
        # 色を設定（必要に応じて）
        @color = Gosu::Color::WHITE
        # アニメーションのフレーム速度（ミリ秒単位）
        @animation_speed = 80  # フレーム切り替え間隔
        # アニメーションの開始時間
        @start_time = Gosu.milliseconds
    end

    def update # 攻撃Refection_bulletで攻撃する

    end

    def draw
        # 現在のフレームを計算
        current_time = Gosu.milliseconds - @start_time
        frame = (current_time / @animation_speed) % @animation.size
        img = @animation[frame]

        # 画像を描画
        img.draw(@x - img.width / 2.0, @y - img.height / 2.0,
                 2, 1, 1, @color, :add)
    end
end