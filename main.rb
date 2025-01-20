require 'gosu'
require_relative 'player' #プレイヤーファイルを参照
require_relative 'enemy'
DEBUG_FONT = Gosu::Font.new(40)
class GameWindow < Gosu::Window
  def initialize
    super Gosu.screen_width, Gosu.screen_height, true
    self.caption = "My Gosu Game"
    @player = Player.new  
    $game_window = self
    @phases = [:chipchapa, :huh, :yagi, :paku]  # フェーズ名を格納する配列
    @phase = :yagi
    @spawn_enemies = []
    @phase_timer = Gosu.milliseconds
    @phase_duration = 50000  # フェーズの持続時間を60秒に設定
    @enemy_spawn_timer = Gosu.milliseconds  # タイマーの初期化
    change_enemy  # 初期フェーズの敵を生成
    @enemy_hit = 0
    @enemy_distance = 0
    @game_state = :playing  # :playing, :win, :lose のいずれか
    @result_text_scale = 0.0
    @result_text_color = Gosu::Color.new(255, 255, 255, 255)
  end
  
  def update
    return unless @game_state == :playing
    @player.update
    update_phase
    current_update 
    hit_judgment
    @spawn_enemies.each(&:update)
    @spawn_enemies.reject!(&:off_screen?)
    check_game_end
  end

  def draw
    @spawn_enemies.each(&:draw)
    @player.draw  
    draw_game_end
    # 結果表示のアニメーション

  end

  def button_down(id) #ボタンを押したときの処理
    case id          
      when Gosu::KB_ESCAPE 
        close         
      when Gosu::KB_W
        @player.player_bullet_change("w")
      when Gosu::KB_A
        @player.player_bullet_change("a")
      when Gosu::KB_S
        @player.player_bullet_change("s")
      when Gosu::KB_D
        @player.player_bullet_change("d")
      when Gosu::KB_SPACE
        @player.attack
      end
    if @player.player_bullet != :laser
      @player.stop_laser
    end
  end

  def button_up(id)
    case id
    when Gosu::KB_SPACE
      if @player.player_bullet == :charge_bullet
        @player.release_charge
      elsif @player.player_bullet == :laser
        @player.stop_laser  # レーザーの発射停止
      end
    end
  end

  def current_update
    if @phase == :chipchapa # ChipChapaフェーズだけ敵を再生成
      current_hp = @spawn_enemies.first&.hp || Enemy::MAX_HP
      current_time = Gosu.milliseconds
      interval_time = current_time - @enemy_spawn_timer
      if interval_time > 2000  # 50秒ごとにスポーン
        @enemy_spawn_timer = current_time  # タイマーをリセット
        new_enemy = ChipChapa.new
        new_enemy.inherit_hp(current_hp)
        @spawn_enemies << new_enemy
      end
    end
  end

  def update_phase #時間経過でフェーズ切り替え
    current_time = Gosu.milliseconds
    if current_time - @phase_timer > @phase_duration
      @phase = @phases.sample  # ランダムに次のフェーズを選択
      @spawn_enemies = []
      change_enemy
      @phase_timer = current_time
      puts "Current Phase: #{@phase}"
    end
  end   
  
  def change_enemy
    current_hp = @spawn_enemies.first&.hp || Enemy::MAX_HP
    case @phase #敵のフェーズの変更
      when :huh
        new_enemy = Huh.new
      when :yagi
        new_enemy = Yagi.new
      when :paku
        new_enemy = Paku.new
      when :chipchapa
        new_enemy = ChipChapa.new
    end
    new_enemy.inherit_hp(current_hp)
    @spawn_enemies << new_enemy
  end

  def hit_judgment
    # プレイヤー ← 敵弾の判定
    @spawn_enemies.each do |enemy|
      enemy.attack_bullets.each do |bullet|
        if Gosu.distance(bullet.x, bullet.y, @player.x, @player.y) <= 50
          @player.damage(bullet.power)
          bullet.remove
        end
        @enemy_distance = Gosu.distance(enemy.x, enemy.y, @player.x, @player.y).to_i

        if Gosu.distance(enemy.x, enemy.y, @player.x, @player.y) < 70
          @player.damage(1)
        end
      end

      if enemy.is_a?(Yagi) # ヤギのときだけ
        enemy.attack_bullets.each do |bomb|
          if bomb.explosion && bomb.hit?(@player.x, @player.y, @player.width, @player.height)
            @player.damage(bomb.bomb_effect_power)
          end
        end
      end

      # 敵 ← プレイヤー弾の判定
      @player.bullets.each do |bullet|
        if enemy.hit?(bullet.x,bullet.y)
          enemy.damage(bullet.power)
          bullet.remove # 弾を削除
        elsif bullet.is_a?(Laser) && bullet.hit?(enemy)
            enemy.damage(bullet.power)
        end
      end
    end

  end

  def check_game_end
    if @player.hp <= 0
      @game_state = :lose
      @spawn_enemies.each do |e|
        puts "ENEMY_HP:#{e.hp}"
      end
      @result_text_scale = 0.0
    elsif @spawn_enemies.all? { |enemy| enemy.hp <= 0 }
      @game_state = :win
      @result_text_scale = 0.0
    end
  end

  def draw_game_end
    if @game_state != :playing
      text = @game_state == :win ? "YOUR WIN!" : "YOUR LOSE..."
      scale = @result_text_scale
      color = @result_text_color
      
      # テキストを画面中央に表示
      text_width = DEBUG_FONT.text_width(text, scale)
      x = Gosu.screen_width / 2 - text_width / 2
      y = Gosu.screen_height / 2 - (DEBUG_FONT.height * scale) / 2
      
      DEBUG_FONT.draw_text(text, x, y, 10, scale, scale, color)
      
      # アニメーション更新
      @result_text_scale = [@result_text_scale + 0.02, 2.0].min
      @result_text_color.alpha = (Math.sin(Gosu.milliseconds / 500.0) * 127 + 127).to_i
    end
  end

end



window = GameWindow.new
window.show
