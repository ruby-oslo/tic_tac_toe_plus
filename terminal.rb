require_relative "game"

init = GameInitiative.new
init.add_player Player::Terminal.new("Hildegunn", "X")
init.add_player Player::Terminal.new("Simon", "O")
game = init.start_game

puts "a ne game"

game.print_status
puts game.start_game_loop
# game.play_turn game.next_player, 0, 0
# game.play_turn game.next_player, 0, 1
# game.play_turn game.next_player, 1, 1
# game.play_turn game.next_player, 1, 0
# game.play_turn game.next_player, 2, 2

game.print_status
