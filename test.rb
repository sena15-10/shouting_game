require 'gosu'

class GameWindow < Gosu::Window
  TILE_SIZE = 32
  SCREEN_WIDTH = 640
  SCREEN_HEIGHT = 480

  def initialize
    super SCREEN_WIDTH, SCREEN_HEIGHT
    self.caption = "Bomb Test Game"

    # プレイヤーと爆弾、障害物の管理
    @player_x = TILE_SIZE * 5
    @player_y = TILE_SIZE * 5
    @bombs = []
    @obstacles = [[TILE_SIZE * 7, TILE_SIZE * 5], [TILE_SIZE * 5, TILE_SIZE * 7]]
    
    # 画像読み込み
    @player_image = Gosu::Image.new("img/starfighter.png")
    @bomb_image = Gosu::Image.new("img/bullet.png")
    @explosion_image = Gosu::Image.new("img/laser.png")
  end

  def update
    # プレイヤーの移動
    if Gosu.button_down?(Gosu::KB_UP)
      @player_y -= TILE_SIZE unless obstacle?(@player_x, @player_y - TILE_SIZE)
    elsif Gosu.button_down?(Gosu::KB_DOWN)
      @player_y += TILE_SIZE unless obstacle?(@player_x, @player_y + TILE_SIZE)
    elsif Gosu.button_down?(Gosu::KB_LEFT)
      @player_x -= TILE_SIZE unless obstacle?(@player_x - TILE_SIZE, @player_y)
    elsif Gosu.button_down?(Gosu::KB_RIGHT)
      @player_x += TILE_SIZE unless obstacle?(@player_x + TILE_SIZE, @player_y)
    end

    # スペースキーで爆弾を設置
    if Gosu.button_down?(Gosu::KB_SPACE)
      place_bomb
    end

    # 爆弾の更新
    @bombs.each(&:update)
    @bombs.reject!(&:finished?) # 爆発が終わった爆弾を削除
  end

  def draw
    # プレイヤーを描画
    @player_image.draw(@player_x, @player_y, 1)

    # 障害物を描画
    @obstacles.each do |obstacle|
      Gosu.draw_rect(obstacle[0], obstacle[1], TILE_SIZE, TILE_SIZE, Gosu::Color::GRAY, 1)
    end

    # 爆弾と爆発を描画
    @bombs.each(&:draw)
  end

  private

  def place_bomb
    # プレイヤー位置に爆弾を設置（重複を防ぐ）
    unless @bombs.any? { |bomb| bomb.x == @player_x && bomb.y == @player_y }
      @bombs << Bomb.new(@player_x, @player_y, 3, @bomb_image, @explosion_image, @obstacles)
    end
  end

  def obstacle?(x, y)
    @obstacles.include?([x, y])
  end
end

class Bomb
  attr_reader :x, :y
  TILE_SIZE = 32
  def initialize(x, y, explosion_range, bomb_image, explosion_image, obstacles)
    @x = x
    @y = y
    @explosion_range = explosion_range
    @bomb_image = bomb_image
    @explosion_image = explosion_image
    @obstacles = obstacles
    @timer = 60 # 爆発までの時間（60フレーム = 1秒）
    @exploding = false
    @explosion_timer = 30 # 爆発エフェクトを描画する時間（30フレーム）
  end

  def update
    if @timer > 0
      @timer -= 1
    elsif !@exploding
      @exploding = true # 爆発開始
    elsif @explosion_timer > 0
      @explosion_timer -= 1
    end
  end

  def draw
    if @exploding && @explosion_timer > 0
      draw_explosion
    elsif !@exploding
      @bomb_image.draw(@x, @y, 1)
    end
  end

  def finished?
    @exploding && @explosion_timer <= 0
  end

  private

  def draw_explosion
    # 爆心地を描画
    @explosion_image.draw(@x, @y, 1)

    # 十字方向に描画
    (1..@explosion_range).each do |i|
      # 上方向
      draw_explosion_tile(@x, @y - i * TILE_SIZE)
      # 下方向
      draw_explosion_tile(@x, @y + i * TILE_SIZE)
      # 左方向
      draw_explosion_tile(@x - i * TILE_SIZE, @y)
      # 右方向
      draw_explosion_tile(@x + i * TILE_SIZE, @y)
    end
  end

  def draw_explosion_tile(x, y)
    # 障害物がない場合にのみ描画
    unless @obstacles.include?([x, y])
      @explosion_image.draw(x, y, 1)
    end
  end
end

# ゲームの実行
window = GameWindow.new
window.show
