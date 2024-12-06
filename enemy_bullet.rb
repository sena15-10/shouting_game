class Bullet #初期クラス
    attr_accessor :x, :y, :angle, :speed, :image, :speed
    def initialize(x,y,angle,speed,image)
        @x = x
        @y = y
        @angle =  angle 
        @speed = speed
        @image = image
        @speed = speed
    end

    def update
        @x += Gosu.offset_x(@angle, @speed)
        @y += Gosu.offset_y(@angle, @speed)
    end

    def draw
        @image.draw_rot(@x, @y, 1, @angle)
    end

    def out_of_bounds?
        @x < 0 || @x > WINDOW_WIDTH || @y < 0 || @y > WINDOW_HEIGHT
    end
end

class Reflection_Bullet < Bullet #パクパク猫の攻撃
    def initialize(x,y)
        super(power,image)
        @angle = 180
        @speed = rand(30..40)
    end

    def update
        @x += Gosu.offset_x(@angle, @speed)
        @y += Gosu.offset_y(@angle, @speed)
        if @x <= 0 || @x >= Gosu.screen_width
            @angle = 180 - @angle
            @speed = rand(30..40)
        end
    end

    def draw
        super
    end
end

class ChipChapa_Bullet < Bullet #ちぴちゃぱ猫の攻撃
    def initialize(chipchapa)
        @chipchapa = chipchapa
        @image = Gosu::Image.new('img/purple_blt.png')
        @angle = 90
        @speed = 20
        @power = 10
        @timer = 0
        @fire_interval = 8
        @start_angle=at_pos(y)
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
    def at_pos(y) ##敵の位置に応じて上向きか下向きか考える
        if (Gosu.screen_height / 2) > @chipchapa.y
            rand(180..360)
        else 
            rand(0..180)
        end
    end

    def fire
        bullet = Bullet.new(@chipchapa.x + 150, @chipchapa.y + 40, @current_angle, @speed, @image)
        @bullets << bullet
        @current_angle += @step
        if @current_angle > @end_angle
          @current_angle = @start_angle
        end
      end
    

    def out_of_bounds?
        super
    end
    
end
