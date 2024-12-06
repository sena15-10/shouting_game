require 'gosu'

class SplittingBullet
  attr_reader :x, :y

  def initialize(x, y, angle, generation = 0)
    @x = x
    @y = y
    @angle = angle
    @speed = 5
    @lifetime = 20 # 弾が分裂するまでのフレーム数
    @generation = generation # 分裂の世代
    @max_generations = 2 # 最大分裂回数
    @split_angle = 90# 分裂時の弾の角度差
    @split_count = 5 # 分裂時に生成される弾の数
    @color = Gosu::Color::YELLOW
  end

  def update(bullets)
    # 弾の移動
    @x += Gosu.offset_x(@angle, @speed)
    @y += Gosu.offset_y(@angle, @speed)
    @lifetime -= 1

    # 分裂条件のチェック
    if @lifetime <= 0 && @generation < @max_generations
      split(bullets)
    end
  end

  def draw
    # 弾を円として描画
    draw_circle(@x, @y, 5, @color)
  end

  private

  def split(bullets)
    # 分裂時に新しい弾を生成
    (-@split_angle..@split_angle).step(@split_angle * 2 / (@split_count - 1)) do |angle_offset|
      new_angle = @angle + angle_offset
      bullets << SplittingBullet.new(@x, @y, new_angle, @generation + 1)
    end
    # 元の弾を削除
    bullets.delete(self)
  end

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
      Gosu.draw_line(p1[0], p1[1], color, p2[0], p2[1], color)
    end
  end
end

class Enemy
  attr_reader :x, :y

  def initialize(x, y)
    @x = x
    @y = y
    @fire_interval = 120 # 弾を発射する間隔（フレーム数）
    @timer = 0
    @bullets = []
  end

  def update
    @timer += 1
    if @timer % @fire_interval == 0
      fire_splitting_bullet
    end

    # 弾の更新
    @bullets.each do |bullet|
      bullet.update(@bullets)
    end
    # 画面外の弾を削除
    @bullets.reject! { |bullet| off_screen?(bullet) }
  end

  def draw
    # 敵の描画（四角形で表現）
    Gosu.draw_rect(@x - 20, @y - 20, 40, 40, Gosu::Color::RED)
    # 弾の描画
    @bullets.each(&:draw)
  end

  private

  def fire_splitting_bullet
    initial_angle = 90 # 初期の弾の角度（下方向）
    @bullets << SplittingBullet.new(@x, @y + 20, initial_angle)
  end

  def off_screen?(bullet)
    bullet.x < -50 || bullet.x > 850 || bullet.y < -50 || bullet.y > 650
  end
end

class GameWindow < Gosu::Window
  def initialize
    super 800, 600
    self.caption = "分裂する弾の例"

    @enemy = Enemy.new(400, 100)
  end

  def update
    @enemy.update
  end

  def draw
    @enemy.draw
  end
end

GameWindow.new.show
