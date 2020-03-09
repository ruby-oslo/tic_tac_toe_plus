require_relative "game"

init = GameInitiative.new
init.add_player Player::Terminal.new("Simon", "O")
init.add_player Player::DumAi.new("A")
game = init.start_game

game.print_status

while game.winner.nil?
  active_player = game.next_player
  x, y = active_player.play_turn game
  game.play_turn active_player, x, y

  puts "game.winner: #{game.winner.inspect}"
  game.print_status
end

puts "Thanks for playing"
