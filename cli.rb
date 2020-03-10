require_relative "game"

@handlers = {}
def regiser_player player, handler:
  @handlers[player] = handler
  player
end

init = GameInitiative.new
game = nil
loop do
  puts <<~HELP
    commands
      add  <name> <symbol>  adds a terminal player to the game
      add_ai_1 <symbol>     adds a dum AI player to the game
      start                 start the game
      dimension <int>       sets the dimension
      streak_to_win <int>   sets the streak_to_win
  HELP
  cmd = gets.split
  case cmd.first
  when "start"
    game = init.start_game
    break
  when "add"
    init.add_player regiser_player(Player::Core.new(cmd[1], cmd[2]), handler: ->(game) {
      print "enter your coordinats, x y: "
      gets.split(" ", 2).map(&:to_i)
    })
  when "add_ai_1"
    init.add_player regiser_player(Player::Core.new("DumCI", cmd[1]), handler: DumAi.new)
  when "dimension"
    init.dimension = cmd[1]
  when "streak_to_win"
    init.streak_to_win = cmd[1]
  end
end

game.print_status
while game.winner.nil?
  active_player = game.next_player
  puts "#{active_player.name}, it's your turn"
  x, y = @handlers[active_player].call game
  game.play_turn active_player, x, y

  game.print_status
end
