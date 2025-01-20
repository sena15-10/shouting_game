class Enemy_Bullet #初期クラス
    attr_accessor :x, :y, :angle, :speed, :image, :speed, :power, :out_of_bounds
    def initialize(x,y,angle,speed,image)
        @x = x
        @y = y
        @angle =  angle 
        @speed = speed
        @image = image
        @speed = speed
        @power = 50
        @out_of_bounds = false
    end

    def update
        @x += Gosu.offset_x(@angle, @speed)
        @y += Gosu.offset_y(@angle, @speed)
        @out_of_bounds = true if out_of_bounds?
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

class Reflection_Bullet < Enemy_Bullet #パクパク猫の攻撃
    attr_reader :x, :y, :speed, :velocity_x, :velocity_y, :power# speed属性を追加

    def initialize(x,y)
        @x = x
        @y = y
        @image = Gosu::Image.new('img/purple_blt.png') 
        @angle = rand(190..350)
        @speed = rand(15..20)
        @power = 50
        @velocity_x = Gosu.offset_x(@angle, @speed)
        @velocity_y = Gosu.offset_y(@angle, @speed)
    end

    def update
        @x += @velocity_x
        @y += @velocity_y 
        if @y <= 10 || @y >= Gosu.screen_height
            @speed = rand(20..30)
            @velocity_y *= -1
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
        super
    end
end

class ChipChapa_Bullet < Enemy_Bullet #ちぴちゃぱ猫の攻撃
    attr_accessor :x, :y, :angle, :speed, :image, :speed, :power,:bullets
    def initialize(chipchapa)
        @chipchapa = chipchapa
        @image = Gosu::Image.new('img/purple_blt.png')
        @angle = 90
        @speed = 10
        @power = 30
        @timer = 0
        @fire_interval = 15
        @start_angle = at_pos
        @step = 10       
        @end_angle = @start_angle + 90
        @bullets = []
        @current_angle = @start_angle
    end

    def update
        @timer += 1
        if @timer % @fire_interval == 0
            fire
        end
        @bullets.each(&:update)
        @bullets.reject!(&:out_of_bounds?)
    end

    def draw
        @bullets.each(&:draw)
    end

    def at_pos
        if @chipchapa.y < (Gosu.screen_height / 2)
            rand(180..220) # 下方向に発射
        else
            rand(-90..0) # 上方向に発射
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
        super
    end

    def remove
        super
    end
end

class Bomb
    attr_accessor :x, :y, :bomb_explosion, :explosion_remain, :explosion, :power, :bomb_effect_power,:bomb_height,:bomb_width

    MAX_WIDTH = Gosu.screen_width
    MAX_HEIGHT = Gosu.screen_height
    def initialize(x,y)
        @x = x
        @y = y
        @bomb_effect = Gosu::Image.new('img/bomb_effect.png')
        @bomb_width = 50
        @bomb_height = 50
        @effect_width = 0
        @effect_height = 0
        @max_width = MAX_WIDTH
        @max_height = MAX_HEIGHT
        @move_timer = rand(200..300)  # 爆弾が動く時間
        @bomb_explosion = 350 # 爆発するまでの時間
        @explosion_remain = 500
        @explosion = false
        @power = 50
        @bomb_effect_power = 1 
        @move_y = rand(-5..3) # どれくらい上下に動くか
        @move_x = rand(-5..3) # どれくらい左右に動くか
    end

    def update
        bomb_move if @move_timer > 0 # 爆弾の動き
        @bomb_explosion -= 1
        if @bomb_explosion <= 0
            @explosion = true
            @move_timer = 0
        elsif bomb_remain? # 爆発が終わったら消す
            @explosion = false
        end
        @explosion_remain -= 1 if @explosion 
    end

    def draw
        if @explosion
            @bomb_timer = 0
            center_x = @x + @bomb_width / 2
            center_y = @y + @bomb_height / 2
            # 左方向
            @bomb_effect.draw_rot(center_x, center_y, 2, 180, 0.5, 0.5, add_width, 1)
            # 右方向
            @bomb_effect.draw_rot(center_x, center_y, 2, 0, 0.5, 0.5, add_width, 1)
            # 上方向
            @bomb_effect.draw_rot(center_x, center_y, 2, 270, 0.5, 0.5, add_width, 1)
            # 下方向
            @bomb_effect.draw_rot(center_x, center_y, 2, 90, 0.5, 0.5, add_width, 1)
            @effect_pos = [@x + @bomb_width / 2, @y + @bomb_height / 2, @x - @bomb_width / 2, @y - @bomb_height / 2]
          
        end
        unless @explosion
            Gosu.draw_rect(@x, @y, @bomb_width, @bomb_height, Gosu::Color::RED, 2)
        end
    end

    def bomb_remain?
        @explosion_remain > 0
    end

    def remove
        @bomb_explosion = 0
        
    end

    def hit?(player_x, player_y, player_width, player_height)
        center_x = @x + @bomb_width / 2
        center_y = @y + @bomb_height / 2
    
        # 左方向
        left_effect_x = center_x - add_width
        if player_x + player_width > left_effect_x && player_x < center_x &&
           player_y + player_height > center_y - @bomb_height / 2 && player_y < center_y + @bomb_height / 2
          return true
        end
    
        # 右方向
        right_effect_x = center_x + add_width
        if player_x < right_effect_x && player_x + player_width > center_x &&
           player_y + player_height > center_y - @bomb_height / 2 && player_y < center_y + @bomb_height / 2
          return true
        end
    
        # 上方向
        top_effect_y = center_y - add_width
        if player_y + player_height > top_effect_y && player_y < center_y &&
           player_x + player_width > center_x - @bomb_width / 2 && player_x < center_x + @bomb_width / 2
          return true
        end
    
        # 下方向
        bottom_effect_y = center_y + add_width
        if player_y < bottom_effect_y && player_y + player_height > center_y &&
           player_x + player_width > center_x - @bomb_width / 2 && player_x < center_x + @bomb_width / 2
          return true
        end
    
        false
    end

    # def explode_if_hit(player_x, player_y)
    #     if Gosu.distance(@x, @y, player_x, player_y) < 50
    #         @bomb_explosion = 0
    #     end
    # end
    def add_width
        @effect_width = [@effect_width + 200, @max_width].min
        return @effect_width
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

end

class Hidden_bullet < Enemy_Bullet
    attr_accessor :x, :y, :speed, :image, :image_width, :z_index, :hidden_timer, :hidden, :power
    def initialize(x,y,speed)
        @x = x
        @y = y
        @speed = speed * rand(1..2)
        @image = Gosu::Image.new('img/kao_moji.jpg')
        @image_width = @image.width
        @center_width = Gosu.screen_width / 2
        @hidden_timer = 200
        @append_timer = 50
        @hidden = false
        @power = 100
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
                @hidden_timer = 200
            end
        else
            @append_timer -= 1
            if @append_timer <= 0
                @hidden = true
                @append_timer = 50
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
        super
    end
end