DEBUG_FONT = Gosu::Font.new(40)



class Enemy_Bullet #初期クラス
    attr_accessor :x, :y, :angle, :speed, :image, :speed, :power
    def initialize(x,y,angle,speed,image)
        @x = x
        @y = y
        @angle =  angle 
        @speed = speed
        @image = image
        @speed = speed
        @power = 20
    end

    def update
        @x += Gosu.offset_x(@angle, @speed)
        @y += Gosu.offset_y(@angle, @speed)
    end

    def draw
        @image.draw_rot(@x, @y, 1, @angle)
    end

    def out_of_bounds?
        @x < 0 || @x > Gosu.screen_width || @y < 0 || @y >Gosu.screen_height
    end

    def remove
        @x = -1000
        @y = -1000
    end
end

class Reflection_Bullet #パクパク猫の攻撃
    attr_reader :x, :y, :speed, :velocity_x, :velocity_y, :power# speed属性を追加
    def initialize(x,y)
        @x = x
        @y = y
        @image = Gosu::Image.new('img/purple_blt.png') 
        @angle = rand(200..340)
        @speed = rand(15..20)
        @power = 20
        @velocity_x = Gosu.offset_x(@angle, @speed)
        @velocity_y = Gosu.offset_y(@angle, @speed)
    end

    def update
        @x += @velocity_x
        @y += @velocity_y 
        if @y <= 10 || @y >= Gosu.screen_height
            @speed = rand(20..30)
            @velocity_y *= -1
            # 角度を変えずに速度のみを変更
            @velocity_x = Gosu.offset_x(@angle, @speed)
        end
    end

    def draw
        @image.draw_rot(@x, @y, 1, @angle)
       
    end

    def out_of_bounds?
        @x < 0 || @x > Gosu.screen_width
    end

    def remove
        @x = -1000
        @y = -1000
    end
end

class ChipChapa_Bullet < Enemy_Bullet #ちぴちゃぱ猫の攻撃
    attr_accessor :x, :y, :angle, :speed, :image, :speed, :power
    def initialize(chipchapa)
        @chipchapa = chipchapa
        @image = Gosu::Image.new('img/purple_blt.png')
        @angle = 90
        @speed = 20
        @power = 10
        @timer = 0
        @fire_interval = 5
        @start_angle=at_pos
        @step = 10       
        @end_angle = @start_angle + @angle
        @bullets = []
        @current_angle = @start_angle
    end

    def update
        @timer += 1
        if @timer % @fire_interval == 0
            fire
        end
        @bullets.each(&:update)
        @bullets.reject!
    end

    def draw
        @bullets.each(&:draw)
      
    end

    def at_pos ##敵の位置に応じて上向きか下向きか考える
        if (Gosu.screen_height / 2) > @chipchapa.y
            rand(0..180)
        else 
            rand(180..360)
        end
    end

    def fire
        bullet = Enemy_Bullet.new(@chipchapa.x + 250, @chipchapa.y + 200, @current_angle, @speed, @image)
        @bullets << bullet
        @current_angle += @step
        if @current_angle > @end_angle
          @current_angle = @start_angle
        end
    end
    

    def out_of_bounds?
        puts "out_of_bounds"
        super
    end

    def remove
        @x = -1000
        @y = -1000
    end
end

class Bomb
    attr_accessor :x, :y, :bomb_explosion, :explosion_remain, :explosion, :bomb_power, :bomb_effect_power
    MAX_WIDTH = Gosu.screen_width
    MAX_HEIGHT = Gosu.screen_height
    def initialize(x,y)
        @x = x
        @y = y
        @bomb_effect = Gosu::Image.new('img/bomb_effect.png')
        @bomb_width = 50
        @bomb_height = 50
        @effect_width = 0
        @max_width = MAX_WIDTH + 500
        @max_height = MAX_HEIGHT
        @move_timer = rand(200..300)  # 爆弾が動く時間
        @bomb_explosion = 350 # 爆発するまでの時間
        @explosion_remain = 500
        @explosion = false
        @bomb_power = 30 
        @bomb_effect_power = 25 
        @move_y = rand(-5..3) # どれくらい上下に動くか
        @move_x = rand(-5..3) # どれくらい左右に動くか
    end

    def update
        bomb_move if @move_timer > 0 # 爆弾の動き
        @bomb_explosion -= 1
        if @bomb_explosion <= 0
            @explosion = true
        elsif bomb_remain? # 爆発が終わったら消す
            @explosion = false
        end
        @explosion_remain -= 1 if @explosion 
    end

    def draw
        if @explosion
            center_x = @x + @bomb_width / 2
            center_y = @y + @bomb_height / 2
            # 左方向
            @bomb_effect.draw_rot(center_x, center_y, 2, 180, 0.5, 0.5,add_width, 1)
            # 右方向
            @bomb_effect.draw_rot(center_x, center_y, 2, 0, 0.5, 0.5, add_width, 1)
            # 上方向
            @bomb_effect.draw_rot(center_x, center_y, 2, 270, 0.5, 0.5, add_width, 1)
            # 下方向
            @bomb_effect.draw_rot(center_x, center_y, 2, 90, 0.5, 0.5, add_width, 1)
        end
        Gosu.draw_rect(@x, @y, @bomb_width, @bomb_height, Gosu::Color::RED, 2)
    end

    def bomb_remain?
        @explosion_remain > 0
    end

    private 
    def bomb_move
        @move_timer -= 1
        @x += @move_x
        @y += @move_y

        # 画面外に出ないようにする
        if @x < 0
            @x = 0
            @move_x = -@move_x
        elsif @x > @max_width - @bomb_width
            @x = @max_width - @bomb_width
            @move_x = -@move_x
        end

        if @y < 0
            @y = 0
            @move_y = -@move_y
        elsif @y > @max_height - @bomb_height
            @y = @max_height - @bomb_height
            @move_y = -@move_y
        end
    end

    def add_width
        @effect_width = [@effect_width + 200, @max_width].min
        return @effect_width
    end
end

class Hidden_bullet
    attr_accessor :x, :y, :speed, :image, :image_width, :z_index, :hidden_timer, :hidden, :power
    def initialize(x,y,speed)
        @x = x
        @y = y
        @speed = speed * rand(1..2)
        @image = Gosu::Image.new('img/kao_moji.jpg')
        @image_width = @image.width
        @z_index = -1
        @center_width = Gosu.screen_width / 2
        @hidden_timer = 200
        @append_timer = 100
        @hidden = false
        @power = 20
    end

    def update
        @x -= @speed
        hide_bullet
        center_view #真ん中に来たら少し表示
    end

    def draw
        unless @hidden
            @image.draw(@x, @y, 1)
        end
    end

    def hide_bullet
        if @hidden
            @hidden_timer -= 1
            if @hidden_timer <= 0
                @hidden = false
                @hidden_timer = 300
            end
        else
            @append_timer -= 1
            if @append_timer <= 0
                @hidden = true
                @append_timer = 100
            end
        end
    end

    def center_view
        if @x < @center_width + 100 && @x > @center_width - 100
            @hidden = false
        end
    end

    def out_of_bounds?
        @x < -@image_width || @x > Gosu.screen_width
    end

    def remove
        @x = -1000
        @y = -1000
    end
end



