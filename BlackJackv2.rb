require 'rubygems'
require 'pry'

class Card

  attr_accessor :suit, :value

  def initialize(s, v)
    @suit = s
    @value = v
  end

  def pretty_output
    "The #{value} of #{find_suit}"
  end

  def to_s
    pretty_output
  end

  def find_suit
  
    pretty_suit = case suit
      when 'H' then 'Hearts'
      when 'D' then 'Diamonds'
      when 'S' then 'Spades'
      when 'C' then 'Clubs'
    end
    
    return pretty_suit 
  
  end

end

class Deck
  attr_accessor :cards

  def initialize (num_decks = 1)

    @cards = []
    ['H', 'D', 'S', 'C'].each do |suit|
      ['2', '3', '3', '4', '5', '6', '7', '8', '9', '10','J','Q','K','A'].each do |value|
        @cards << Card.new(suit, value)
      end
    end

    #duplicate the cards for multiple decks
    @cards = @cards * num_decks

    #shuffle the deck of cards
    scramble!

  end

  # shuffle the deck of cards
  def scramble!
    cards.shuffle!
  end

  # deal a Card
  def deal_one
    cards.pop
  end
  
  def size
    cards.size
  end

  # returns a string containing all the cards currently in the deck
  def to_s

    puts "\nHere are the current cards in the deck"
    @cards.each do |card|
      "#{card} + \n"
    end

  end

end

class Player
  
  attr_accessor :name, :cards

  def initialize (n = "Dealer")
    @name = n
    @cards = []
  end
  
  def show_flop
    show_hand
  end
  
  def to_s
    name
  end

  def show_hand
    puts "---- #{name}'s Hand ----"
    cards.each do |card|
      puts card.to_s
    end
    puts "=> Total: #{total}"
  end

  def total

    face_values = cards.map{ |card| card.value }
    total = 0

    face_values.each do |val|
      if val == "A"
        total += 11
      else
        total += (val.to_i == 0? 10 : val.to_i)
      end
    end

    #correct for aces
    face_values.select {|val| val == "A"}.count.times do
      break if total <= BlackJack::BLACKJACK_AMOUNT
      total -= 10
    end

    return total

  end

  def add_card(card)
    cards << card
  end

  def is_busted?
    total > BlackJack::BLACKJACK_AMOUNT
  end

end

class Dealer < Player
  
  attr_accessor :name, :cards

  def initialize
    @name = "Dealer"
    @cards = []
  end

  def show_flop
    puts "---- #{name}'s Hand ----"
    puts "=> First card is hidden"
    puts "=> Second cards is #{cards[cards.length-1]}"
  end

  
end

# game engine
class BlackJack

  attr_accessor :player, :dealer, :deck

  BLACKJACK_AMOUNT = 21
  DEALER_HIT_MIN = 17

  def initialize num_decks = 1
    @deck = Deck.new(num_decks)
    @player = Player.new("player")
    @dealer = Dealer.new
    
  end

  def set_player_name
    puts "What's your name?"
    player.name = gets.chomp.capitalize
  end

  def deal_cards
    2.times do
      player.add_card(deck.deal_one)
      dealer.add_card(deck.deal_one)
    end
    
  end

  def show_hands
    player.show_hand
    dealer.show_hand
  end

  def show_flop
    player.show_flop
    dealer.show_flop
  end

  def blackjack_or_bust?(player_or_dealer) 
    
    if player_or_dealer.total == BLACKJACK_AMOUNT
      if player_or_dealer.is_a?(Dealer)
        puts "Sorry, dealer hit blackjack. #{player.name} loses"
      else
        puts "Congratulations, you hit blackjack! #{player.name} win!"
      end
      play_again?
    elsif player_or_dealer.is_busted?
      if player_or_dealer.is_a?(Dealer)
        puts "Congratulations, dealer busted. #{player.name} win!"
      else
        puts "Sorry, #{player.name} busted. #{player.name} loses"
      end
      play_again?
    end
    
  end

  def player_turn
    puts #{player.name}'s turn.'

    blackjack_or_bust?(player)
    while !player.is_busted?
      
      puts "\nWhat would you like to do? 1) [H]it 2) [S]tay"
      response = gets.chomp.downcase.strip
      
      if !['h','s'].include?(response)
        puts "Error: you must enter H or S"
        next # stop current execution of loop and go to the next iteration
      end

      if response == "s"
        puts "#{player.name} chose to stay."
        break # breaking out ot the loop, continue from line with #end while
      end
      
    #hit
    player.add_card(deck.deal_one)
    #binding pry
    puts "Dealing card to #{player.name}: #{player.cards[player.cards.size-1]}"
    puts "#{player.name}'s total is now : #{player.total}"

    blackjack_or_bust?(player)

    end #end while
    
    puts "#{player.name} stays at #{player.total}"

  end

  def dealer_turn

    puts "Dealer's turn."

    blackjack_or_bust?(dealer)
    
    while dealer.total < DEALER_HIT_MIN
      dealer.add_card(deck.deal_one)
      #binding pry
      puts "Dealing card to Dealer: #{dealer.cards[dealer.cards.size-1]}"
      puts "Dealer's total is now : #{dealer.total}"
      blackjack_or_bust?(dealer)
    end

    puts "Dealer stays at #{dealer.total}"

  end

  def who_won? player, dealer
    if player.total > dealer.total
      puts "Congratulations #{player.name} wins!"
    elsif dealer.total > player.total
      puts "Sorry, #{player.name} looses!"
    else
      puts "Draw Game"
    end
    play_again?
  end
  
  def play_again?
    puts "\nWould you like to play agains? [Y]es, [N]o"
    if gets.chomp.downcase == 'y'
      puts "Starting new game..."
      puts ""
      deck = Deck.new()
      player.cards.clear
      dealer.cards.clear
      start
    else
      puts "Goodbye!"
      exit
    end
  end
  
  def start
    # This is the procedural side
    # This is the game engine
    set_player_name
    deal_cards
    show_flop
    player_turn
    dealer_turn
    who_won?(player, dealer)
  
  end
  
end

game = BlackJack.new
game.start