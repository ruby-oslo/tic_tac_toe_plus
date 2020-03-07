module Player
  class Core
    attr_reader :symbol
    attr_reader :name

    def initialize(name, symbol)
      @symbol = symbol
      @name = name
    end

    def play_turn game; raise "Not implemented" end
  end

  class Terminal < Core
    def play_turn game
      print "#{name}, it's your turn, enter your coordinates x y: "
      return gets.split(" ", 2).map(&:to_i)
    end
  end
end

class GameInitiative
  def initialize()
    @players = []
  end

  def add_player player
    @players << player
  end

  def start_game
    raise "need two players" if @players.length != 2

    Game.new(@players)
  end
end

class Game
  attr_accessor :game
  attr_reader :winner
  GAME_SIZE = 3

  def initialize(players)
    @players = players.cycle
    @board = {}
  end
  def next_player; @players.peek end

  def check_for_winner x, y
    winning_possitions = [
      [[0,0], [ 0, 1], [ 0, 2]], # N
      [[0,0], [ 1, 1], [ 2, 2]], # NE
      [[0,0], [ 1, 0], [ 2, 0]], # E
      [[0,0], [-1, 1], [-2, 2]], # SE
      [[0,0], [-1, 0], [-2, 0]], # S
      [[0,0], [-1,-1], [-2,-2]], # SW
      [[0,0], [ 0,-1], [ 0,-2]], # W
      [[0,0], [ 1,-1], [ 2,-2]], # NW
    ]
    won = winning_possitions.any? do |strike|
      strike.all? { |(x_extra, y_extra)|
        @board[[x,y]] == @board[[x + x_extra ,y + y_extra]]
      }
    end

    if won
      @board[[x,y]]
    else
      nil
    end
  end
  def free_slots
    @board.length - 9
  end

  def play_turn player, x, y
    raise "not your turn"if @players.peek != player
    raise "piece is taken" if @board[[x,y]]
    raise "off the grid" if !(0..3).include?(x) || !(0..3).include?(y)
    @players.next # just to continue the cycle

    @board[[x,y]] = player
    @winner = check_for_winner x,y
    @board = {} if free_slots.zero?
  end

  def start_game_loop
    while winner.nil?
      active_player = @players.next
      x, y = active_player.play_turn self
      raise "piece is taken" if @board[[x,y]]
      @board[[x,y]] = active_player
      @winner = check_for_winner x,y

      print_status
    end
  end

  def print_status
    puts to_terminal
    if winner
      puts "We have a winner, #{winner.name}!🎉"
    end
  end
  def to_terminal
    <<~BOARD
        0   1   2
      2 #{@board[[0,2]]&.symbol || " "} | #{@board[[1,2]]&.symbol || " "} | #{@board[[2,2]]&.symbol || " "} 2
        – + – + –
      1 #{@board[[0,1]]&.symbol || " "} | #{@board[[1,1]]&.symbol || " "} | #{@board[[2,1]]&.symbol || " "} 1
        – + – + –
      0 #{@board[[0,0]]&.symbol || " "} | #{@board[[1,0]]&.symbol || " "} | #{@board[[2,0]]&.symbol || " "} 0
        0   1   2
    BOARD
  end
end

