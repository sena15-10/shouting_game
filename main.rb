require 'gosu'
require_relative 'player' #プレイヤーファイルを参照
require_relative 'enemy'
DEBUG_FONT = Gosu::Font.new(40)
class GameWindow < Gosu::Window
  def initialize
    super Gosu.screen_width, Gosu.screen_height, true
    self.caption = "My Gosu Game"
    @player = Player.new  
    @phases = [:chipchapa, :huh, :yagi, :paku]  # フェーズ名を格納する配列
    @phase = :chipchapa
    @spawn_enemies = []
    @phase_timer = Gosu.milliseconds
    @phase_duration = 50000  # フェーズの持続時間を60秒に設定
    @enemy_spawn_timer = Gosu.milliseconds  # タイマーの初期化
    @bullet_power = 0
    @cnt = 0

    @hit = false
    change_enemy  # 初期フェーズの敵を生成
  end

  def update
    @player.update
    update_phase
    current_update 
    hit_judgment
    @spawn_enemies.each(&:update)
  end

  def draw
    @spawn_enemies.each(&:draw)
    @player.draw 
    DEBUG_FONT.draw("Bullet_power: #{@bullet_power}", 0, 0, 10)
    DEBUG_FONT.draw("HP: #{@player.hp}", 0, 40, 10)
    if @hit
      DEBUG_FONT.draw("Hit!", 100, 40,10)
      @cnt += 1 if @cnt < 100
      @hit = false if @cnt == 100
    end
    
      
    
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
      current_time = Gosu.milliseconds
      interval_time = current_time - @enemy_spawn_timer
      if interval_time > 1000  # 50秒ごとにスポーン
        @enemy_spawn_timer = current_time  # タイマーをリセット
        @spawn_enemies << ChipChapa.new   
      end
      puts "Enemy_spawn_timer:#{@enemy_spawn_timer}\n interval_time:#{interval_time}"
    end
  end

  def update_phase
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
    case @phase # ChipChapaのときだけ再生成するので
      when :huh
        @spawn_enemies << Huh.new
      when :yagi
        @spawn_enemies << Yagi.new
      when :paku
        @spawn_enemies << Paku.new
      when :chipchapa
        @spawn_enemies << ChipChapa.new
      end
  end

  def hit_judgment
    @spawn_enemies.each do |enemy|
      enemy.attack_bullets.each do |bullet|
        @bullet_power = bullet.power
        puts "Bullet_power: #{@bullet_power}"
        if Gosu.distance(bullet.x, bullet.y, @player.x, @player.y) < 100
          @player.damage(bullet.power)
          @hit = true
          bullet.remove
        end
      end
    end

    # @player.attacks.each do |attack|
    #   @spawn_enemies.each do |enemy|
    #     if Gosu.distance(attack.x, attack.y, enemy.x, enemy.y) < 50
    #       enemy.damage(attack.power)
    #       attack.remove
    #     end
    #   end
    # end
  end
end

window = GameWindow.new
window.show
