require 'gosu'

# 定数の定義
WINDOW_WIDTH = 800
WINDOW_HEIGHT = 600

class Bullet
  attr_reader :x, :y, :speed, :angle, :radius

  def initialize(x, y, angle = 180, speed = 25) # デフォルトの角度は左方向（180度）
    @x = x
    @y = y
    @angle = angle
    @speed = speed
    @image = Gosu::Image.new("bullet.png") rescue nil # 画像がない場合はnil
    @power = 45
    @radius = 5
    @color = Gosu::Color::YELLOW
  end

  def update
    # 角度に基づいて位置を更新
    @x += Gosu.offset_x(@angle, @speed)
    @y += Gosu.offset_y(@angle, @speed)
  end

  def draw
    if @image
      @image.draw(@x, @y, 1)
    else
      # 画像がない場合は簡単な円で代用
      draw_circle(@x, @y, @radius, @color)
    end
  end

  def out_of_bounds?
    @x < 0 || @x > WINDOW_WIDTH || @y < 0 || @y > WINDOW_HEIGHT
  end

  private

  # 円を描画するヘルパーメソッド
  def draw_circle(x, y, radius, color, segments = 16)
    angle_step = 360.0 / segments
    points = []

    (0..segments).each do |i|
      angle = angle_step * i
      radian = Gosu.degrees_to_radians(angle)
      points << [x + radius * Math.cos(radian), y + radius * Math.sin(radian)]
    end

    points.each_cons(2) do |p1, p2|
      Gosu.draw_line(p1[0], p1[1], color, p2[0], p2[1], color, z = 0)
    end
  end
end

class Reflection_Bullet < Bullet
  def initialize(x, y, angle = 180, speed = rand(30..40))
    super(x, y, angle, speed)
    @color = Gosu::Color::CYAN
  end

  def update
    super
    # 反射処理: X軸の壁に当たった場合に反射
    if @x <= @radius || @x >= WINDOW_WIDTH - @radius
      @angle = 180 - @angle
      # 角度を0-360度に正規化
      @angle %= 360
      # 速度を再設定（30～40のランダム）
      @speed = rand(30..40)
    end
    # Y軸の壁には反射させず、画面外に出るまで移動し続ける
  end

  def draw
    if @image
      @image.draw(@x, @y, 1)
    else
      # 画像がない場合は反射弾特有の色で描画
      draw_circle(@x, @y, @radius, @color)
    end
  end
end

class Enemy
  attr_reader :x, :y

  def initialize(x, y)
    @x = x
    @y = y
    @fire_interval = 60 # 弾を発射する間隔（フレーム数）
    @timer = 0
    @bullets = []
  end

  def update
    @timer += 1
    if @timer % @fire_interval == 0
      fire_bullet
      fire_reflection_bullet
    end

    # 弾の更新
    @bullets.each(&:update)
    # 画面外の弾を削除
    @bullets.reject! { |bullet| bullet.out_of_bounds? }
  end

  def draw
    # 敵を四角形で描画
    Gosu.draw_rect(@x - 20, @y - 20, 40, 40, Gosu::Color::RED)
    # 弾の描画
    @bullets.each(&:draw)
  end

  private

  def fire_bullet
    # 初期の弾を左斜めに発射（ランダムな角度を設定）
    angle = rand(150..210) # 左斜めの角度範囲
    speed = rand(25..30)
    @bullets << Bullet.new(@x, @y + 20, angle, speed)
  end

  def fire_reflection_bullet
    # Reflection_Bulletをランダムな角度で発射
    angle = rand(150..210) # 左斜めの角度範囲
    @bullets << Reflection_Bullet.new(@x, @y + 20, angle)
  end
end

class GameWindow < Gosu::Window
  def initialize
    super(WINDOW_WIDTH, WINDOW_HEIGHT)
    self.caption = "Reflection Bullet Example"

    @bullets = []
    @reflection_bullets = []
    @enemy = Enemy.new(WINDOW_WIDTH / 2, WINDOW_HEIGHT - 50)
  end

  def update
    @enemy.update

    # 弾の更新と管理はEnemyクラス内で行っているため、ここでは不要
    # @bullets.each(&:update)
    # @bullets.reject! { |bullet| bullet.out_of_bounds? }
  end

  def draw
    @enemy.draw
  end
end

# ゲームの実行
GameWindow.new.show
