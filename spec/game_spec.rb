require_relative "../game"

describe "Game" do
  it "creates player" do
    player = Player::Core.new("Toivo", "X")

    expect(player.name).to eq("Toivo")
    expect(player.symbol).to eq("X")
  end

  let(:toivo) { Player::Core.new("Toivo", "X") }
  let(:simon) { Player::Core.new("Simon", "O") }

  it "works to create a initial game and add user to it" do
    init = GameInitiative.new
    init.add_player toivo
    init.add_player simon
    game = init.start_game

    expect(game).to be_a(Game)
  end

  it "after adding two players it lets the games begins" do
    init = GameInitiative.new
    init.add_player toivo
    init.add_player simon
    game = init.start_game

    expect(game).to be_a(Game)
  end

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
        game.play_turn toivo, 0, -100
      }.to raise_error("off the grid")
    end

    it "can out put in ascii" do
      expect(game.to_terminal).to eq(<<~TEXT)
          0   1   2
        2   |   |   2
          – + – + –
        1   |   |   1
          – + – + –
        0   |   |   0
          0   1   2
      TEXT
    end

    it "draws one played move into the game" do
      game.play_turn toivo, 1, 1

      expect(game.to_terminal).to eq(<<~TEXT)
          0   1   2
        2   |   |   2
          – + – + –
        1   | X |   1
          – + – + –
        0   |   |   0
          0   1   2
      TEXT
    end

    it "draws multiple played move into the game" do
      game.play_turn toivo, 0, 0
      game.play_turn simon, 0, 1
      game.play_turn toivo, 1, 1
      game.play_turn simon, 1, 0

      expect(game.to_terminal).to eq(<<~TEXT)
          0   1   2
        2   |   |   2
          – + – + –
        1 O | X |   1
          – + – + –
        0 X | O |   0
          0   1   2
      TEXT
    end

    it "determines a winner when thats the case" do
      game.play_turn toivo, 0, 0
      game.play_turn simon, 0, 1
      game.play_turn toivo, 1, 1
      game.play_turn simon, 1, 0
      game.play_turn toivo, 2, 2

      expect(game.winner).to eq(toivo)
    end


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
          – + – + –
        1   | O |   1
          – + – + –
        0   |   |   0
          0   1   2
      TEXT
    end

  end
end

