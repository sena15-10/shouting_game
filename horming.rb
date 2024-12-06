require 'gosu'

# 定数の定義
WINDOW_WIDTH = 800
WINDOW_HEIGHT = 600
PLAYER_SPEED = 5
ENEMY_FIRE_INTERVAL = 10 # 弾を発射する間隔（フレーム数）
BULLET_SPEED = 3
BULLET_RADIUS = 5

# プレイヤークラス
class Player
  attr_reader :x, :y

  def initialize
    @x = WINDOW_WIDTH / 2
    @y = WINDOW_HEIGHT - 50
    @speed = PLAYER_SPEED
    @color = Gosu::Color::GREEN
    @radius = 15
  end

  def update
    @x -= @speed if Gosu.button_down?(Gosu::KB_LEFT) || Gosu.button_down?(Gosu::GP_LEFT)
    @x += @speed if Gosu.button_down?(Gosu::KB_RIGHT) || Gosu.button_down?(Gosu::GP_RIGHT)
    @y -= @speed if Gosu.button_down?(Gosu::KB_UP) || Gosu.button_down?(Gosu::GP_BUTTON_0)
    @y += @speed if Gosu.button_down?(Gosu::KB_DOWN) || Gosu.button_down?(Gosu::GP_BUTTON_1)

    # 画面内にプレイヤーを制限
    @x = [[@x, @radius].max, WINDOW_WIDTH - @radius].min
    @y = [[@y, @radius].max, WINDOW_HEIGHT - @radius].min
  end

  def draw
    draw_circle(@x, @y, @radius, @color)
  end

  private

  # 円を描画するヘルパーメソッド
  def draw_circle(x, y, radius, color, segments = 32)
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

# ホーミング弾クラス
class HomingBullet
  attr_reader :x, :y

  def initialize(x, y, target)
    @x = x
    @y = y
    @target = target
    @speed = BULLET_SPEED
    @color = Gosu::Color::FUCHSIA
    @radius = BULLET_RADIUS
  end

  def update
    # プレイヤーへの方向ベクトルを計算
    dx = @target.x - @x
    dy = @target.y - @y
    distance = Math.sqrt(dx**2 + dy**2)
    current_time = Gosu.milliseconds
    unless distance == 0
      # 単位ベクトルを計算し、速度を掛けて位置を更新
      @x += (dx / distance) * @speed
      @y += (dy / distance) * @speed
    end
  end

  def draw
    draw_circle(@x, @y, @radius, @color)
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

# 敵クラス
class Enemy
  attr_reader :x, :y

  def initialize(x, y)
    @x = x
    @y = y
    @fire_interval = ENEMY_FIRE_INTERVAL
    @timer = 0
    @bullets = []
    @color = Gosu::Color::RED
    @size = 40
  end

  def update(player)
    @timer += 1
    if @timer % @fire_interval == 0
      fire_homing_bullet(player)
    end

    # 弾の更新
    @bullets.each(&:update)
    # 画面外の弾を削除
    @bullets.reject! { |bullet| off_screen?(bullet) }
  end

  def draw
    # 敵を四角形で描画
    Gosu.draw_rect(@x - @size / 2, @y - @size / 2, @size, @size, @color)
    # 弾の描画
    @bullets.each(&:draw)
  end

  private

  def fire_homing_bullet(player)
    @bullets << HomingBullet.new(@x, @y + @size / 2, player)
  end

  def off_screen?(bullet)
    bullet.x < -50 || bullet.x > WINDOW_WIDTH + 50 || bullet.y < -50 || bullet.y > WINDOW_HEIGHT + 50
  end
end

# ゲームウィンドウクラス
class GameWindow < Gosu::Window
  def initialize
    super WINDOW_WIDTH, WINDOW_HEIGHT
    self.caption = "ホーミング弾（追尾弾）の例"

    @player = Player.new
    @enemy = Enemy.new(WINDOW_WIDTH / 2, 100)
  end

  def update
    @player.update
    @enemy.update(@player)
  end

  def draw
    @player.draw
    @enemy.draw
  end
end

# ゲームの実行
GameWindow.new.show
