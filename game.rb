class DumAi
  def call game
    (0...game.dimension)
      .to_a
      .permutation(2)
      .to_a
      .concat((0...game.dimension).zip(0...game.dimension))
      .select{|pos| game.board[pos].nil?}
      .sample
  end
end

module Player
  class Core
    attr_reader :symbol
    attr_reader :name

    def initialize(name, symbol)
      @symbol = symbol
      @name = name
    end
  end
end

class GameInitiative
  attr_accessor :dimension
  attr_accessor :streak_to_win

  def initialize()
    @players = []
    @dimension = 3
    @streak_to_win = 3
  end

  def add_player player
    @players << player
  end

  def start_game
    raise "need at least two players" if @players.length < 1

    Game.new(@players, dimension: @dimension, streak_to_win: streak_to_win)
  end
end

class Game
  attr_accessor :game
  attr_reader :winner
  attr_reader :board
  attr_reader :dimension

  def initialize(players, dimension:, streak_to_win:)
    @players = players.cycle
    @board = {}
    @dimension = dimension
    @streak_to_win = streak_to_win
  end
  def next_player; @players.peek end

  def check_for_winner player
    winning_possitions = [
      @streak_to_win.times.map{|i|[ 0, i]}, # N
      @streak_to_win.times.map{|i|[ i, i]}, # NE
      @streak_to_win.times.map{|i|[ i, 0]}, # E
      @streak_to_win.times.map{|i|[ i,-i]}, # SE
      @streak_to_win.times.map{|i|[ 0,-i]}, # S
      @streak_to_win.times.map{|i|[-i,-i]}, # SW
      @streak_to_win.times.map{|i|[-i, 0]}, # W
      @streak_to_win.times.map{|i|[-i, i]}, # NW
    ]

    @board
      .select{ |k, v| v == player }
      .find do |(x,y),_|
        winning_possitions.any? do |strike|
          strike.all? { |(x_extra, y_extra)|
            @board[[x,y]] == @board[[x + x_extra ,y + y_extra]]
          }
        end
      end
      &.last
  end
  def free_slots
    @board.length - @dimension**2
  end

  def play_turn player, x, y
    raise "not your turn"if @players.peek != player
    raise "piece is taken" if @board[[x,y]]
    raise "off the grid" if !(0...@dimension).include?(x) || !(0...@dimension).include?(y)
    @players.next # just to continue the cycle

    @board[[x,y]] = player
    @winner ||= check_for_winner player
    @board = {} if free_slots.zero?
  end

  def print_status
    puts to_terminal
    if winner
      puts "We have a winner, #{winner.name}!🎉"
    end
  end

  def to_terminal
    x_ruler = @dimension.times.map { |e| " #{e} " }.join(" ").strip
    x_spacer = @dimension.times.map { |e| " - " }.join("+").strip

    table = @dimension.times.reverse_each.map do |y|
      "#{y}#{@dimension.times.map { |x| " #{@board[[x,y]]&.symbol || " "} " }.join("|")}#{y}"
    end
      .join("\n  #{x_spacer}\n")

    <<~BOARD
          #{x_ruler}
        #{table}
          #{x_ruler}
    BOARD
  end
end

