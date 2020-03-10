require_relative "../game"

describe "Game" do

  ## 1
  it "creates player" do
    player = Player::Core.new("Toivo", "X")

    expect(player.name).to eq("Toivo")
    expect(player.symbol).to eq("X")
  end

  ## 2
  let(:toivo) { Player::Core.new("Toivo", "X") }
  let(:simon) { Player::Core.new("Simon", "O") }

  it "works to create a initial game and add user to it" do
    init = GameInitiative.new
    init.add_player toivo
    init.add_player simon
    game = init.start_game

    expect(game).to be_a(Game)
  end

  ## 3
  context "game between Toivo and Simon" do
    let(:game) {
      init = GameInitiative.new
      init.add_player toivo
      init.add_player simon
      init.start_game
    }

    it "breaks when a player tries take piece which is already taken" do
      game.play_turn toivo, 0, 0
      expect {
        game.play_turn simon, 0, 0
      }.to raise_error("piece is taken")
    end

    it "breaks when a player tries to play two turns in a row" do
      game.play_turn toivo, 0, 0
      expect {
        game.play_turn toivo, 0, 1
      }.to raise_error("not your turn")
    end

    it "breaks if a player plays off the grid" do
      expect {
        game.play_turn toivo, 0, 3
      }.to raise_error("off the grid")
    end

    ## 4
    it "can out put in ascii" do
      expect(game.to_terminal).to eq(<<~TEXT)
          0   1   2
        2   |   |   2
          - + - + -
        1   |   |   1
          - + - + -
        0   |   |   0
          0   1   2
      TEXT
    end

    ## 5
    it "draws one played move into the game" do
      game.play_turn toivo, 1, 1

      expect(game.to_terminal).to eq(<<~TEXT)
          0   1   2
        2   |   |   2
          - + - + -
        1   | X |   1
          - + - + -
        0   |   |   0
          0   1   2
      TEXT
    end

    ## 6
    it "draws multiple played move into the game" do
      game.play_turn toivo, 0, 0
      game.play_turn simon, 0, 1
      game.play_turn toivo, 1, 1
      game.play_turn simon, 1, 0

      expect(game.to_terminal).to eq(<<~TEXT)
          0   1   2
        2   |   |   2
          - + - + -
        1 O | X |   1
          - + - + -
        0 X | O |   0
          0   1   2
      TEXT
    end

    ## 7
    it "determines a winner when thats the case" do
      game.play_turn toivo, 0, 0
      game.play_turn simon, 0, 1
      game.play_turn toivo, 1, 1
      game.play_turn simon, 1, 0
      game.play_turn toivo, 2, 2

      expect(game.winner).to eq(toivo)
    end

    ## 8
    it "determines a winner when thats the case #2" do
      game.play_turn toivo, 0, 0
      game.play_turn simon, 0, 1
      game.play_turn toivo, 2, 2
      game.play_turn simon, 1, 0
      game.play_turn toivo, 1, 1

      expect(game.winner).to eq(toivo)
    end

    ## 9
    it "starts a new game then the table is full and not winner yet" do
      game.play_turn toivo, 0, 0
      game.play_turn simon, 0, 1
      game.play_turn toivo, 1, 1
      game.play_turn simon, 1, 0
      game.play_turn toivo, 0, 2
      game.play_turn simon, 1, 2
      game.play_turn toivo, 2, 2
      game.play_turn simon, 2, 0
      game.play_turn toivo, 2, 1

      game.play_turn simon, 1, 1


      expect(game.to_terminal).to eq(<<~TEXT)
          0   1   2
        2   |   |   2
          - + - + -
        1   | O |   1
          - + - + -
        0   |   |   0
          0   1   2
      TEXT
    end
  end # of context "game between Toivo and Simon"

  ## 10
  describe "table size 5 x 5" do
    let(:game) {
      init = GameInitiative.new
      init.add_player toivo
      init.add_player simon
      init.dimension = 5
      init.start_game
    }

    it "draws the 4 x 4 board" do
      expect(game.to_terminal).to eq(<<~TEXT)
          0   1   2   3   4
        4   |   |   |   |   4
          - + - + - + - + -
        3   |   |   |   |   3
          - + - + - + - + -
        2   |   |   |   |   2
          - + - + - + - + -
        1   |   |   |   |   1
          - + - + - + - + -
        0   |   |   |   |   0
          0   1   2   3   4
      TEXT
    end

    it "lets me fill the board" do
      game.play_turn toivo, 4, 4
      game.play_turn simon, 3, 4
      game.play_turn toivo, 4, 3
      game.play_turn simon, 0, 1
      game.play_turn toivo, 3, 1
      game.play_turn simon, 1, 0
      game.play_turn toivo, 0, 2
      game.play_turn simon, 1, 2
      game.play_turn toivo, 2, 2
      game.play_turn simon, 2, 0
      game.play_turn toivo, 2, 1
      game.play_turn simon, 1, 3

      expect(game.to_terminal).to eq(<<~TEXT)
          0   1   2   3   4
        4   |   |   | O | X 4
          - + - + - + - + -
        3   | O |   |   | X 3
          - + - + - + - + -
        2 X | O | X |   |   2
          - + - + - + - + -
        1 O |   | X | X |   1
          - + - + - + - + -
        0   | O | O |   |   0
          0   1   2   3   4
      TEXT
    end

    it "still wins by 3 in a row" do
      game.play_turn toivo, 4, 4
      game.play_turn simon, 3, 4
      game.play_turn toivo, 4, 3
      game.play_turn simon, 0, 1
      game.play_turn toivo, 3, 1
      game.play_turn simon, 1, 0
      game.play_turn toivo, 0, 2
      game.play_turn simon, 1, 2
      game.play_turn toivo, 2, 2
      game.play_turn simon, 2, 0
      game.play_turn toivo, 2, 1
      game.play_turn simon, 1, 3
      game.play_turn toivo, 4, 1

      expect(game.winner).to eq(toivo)
    end
  end

  ## 11
  describe "table size 10 x 10" do
    let(:game) {
      init = GameInitiative.new
      init.add_player toivo
      init.add_player simon
      init.dimension = 10
      init.streak_to_win = 5
      init.start_game
    }

    it "requires 5 in a row to win when streak_to_win is set" do
      game.play_turn toivo, 4, 4
      game.play_turn simon, 3, 4
      game.play_turn toivo, 3, 3
      game.play_turn simon, 0, 1
      game.play_turn toivo, 2, 2
      game.play_turn simon, 1, 0
      game.play_turn toivo, 5, 5
      game.play_turn simon, 1, 2
      expect(game.winner).to eq(nil)
      game.play_turn toivo, 6, 6


      expect(game.to_terminal).to eq(<<~TEXT)
          0   1   2   3   4   5   6   7   8   9
        9   |   |   |   |   |   |   |   |   |   9
          - + - + - + - + - + - + - + - + - + -
        8   |   |   |   |   |   |   |   |   |   8
          - + - + - + - + - + - + - + - + - + -
        7   |   |   |   |   |   |   |   |   |   7
          - + - + - + - + - + - + - + - + - + -
        6   |   |   |   |   |   | X |   |   |   6
          - + - + - + - + - + - + - + - + - + -
        5   |   |   |   |   | X |   |   |   |   5
          - + - + - + - + - + - + - + - + - + -
        4   |   |   | O | X |   |   |   |   |   4
          - + - + - + - + - + - + - + - + - + -
        3   |   |   | X |   |   |   |   |   |   3
          - + - + - + - + - + - + - + - + - + -
        2   | O | X |   |   |   |   |   |   |   2
          - + - + - + - + - + - + - + - + - + -
        1 O |   |   |   |   |   |   |   |   |   1
          - + - + - + - + - + - + - + - + - + -
        0   | O |   |   |   |   |   |   |   |   0
          0   1   2   3   4   5   6   7   8   9
      TEXT
      expect(game.winner).to eq(toivo)
    end
  end

  # 12
  it "let multiple user play the game together" do
    init = GameInitiative.new
    telhaug = Player::Core.new("Telhaug", "👪")
    init.add_player telhaug
    init.add_player toivo
    init.add_player simon
    init.dimension = 4
    game = init.start_game
    game.play_turn telhaug, 3, 2
    game.play_turn toivo, 3, 3
    game.play_turn simon, 2, 3
    game.play_turn telhaug, 3, 1
    game.play_turn toivo, 2, 2
    game.play_turn simon, 1, 3
    game.play_turn telhaug, 3, 0

    expect(game.winner).to eq(telhaug)
    expect(game.to_terminal).to eq(<<~TEXT)
          0   1   2   3
        3   | O | O | X 3
          - + - + - + -
        2   |   | X | 👪 2
          - + - + - + -
        1   |   |   | 👪 1
          - + - + - + -
        0   |   |   | 👪 0
          0   1   2   3
    TEXT
  end

  # 13
  describe "AI" do
    describe "Random AI" do
      let(:ai_handler) { DumAi.new() }
      let(:ai) { Player::Core.new("DumAi", "A") }
      let(:game) {
        init = GameInitiative.new
        init.add_player ai
        game = init.start_game
      }

      it "return array with with coordinates" do
        x, y = ai_handler.call game

        expect(x).to be_a(Integer)
        expect(y).to be_a(Integer)
      end

      it "return different moves" do
        expect(
          10.times.map { ai_handler.call game }.uniq.length
        ).to be > 1
      end

      it "play on available places" do
        8.times {
          x, y = ai_handler.call(game)
          game.play_turn ai, x, y
        }
        expect(game.board.length).to eq(8)
      end
    end
  end

  ## 99
end

