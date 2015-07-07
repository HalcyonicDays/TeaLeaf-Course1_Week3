require 'sinatra'

use Rack::Session::Cookie,  :key => 'rack.session',
                            :path => '/',
                            :secret => 'this_is_a_secret'

set :sessions, true

helpers do
  VALUES = %w(2 3 4 5 6 7 8 9 10 jack queen king ace) 
  SUITS = %w(clubs hearts diamonds spades)
  BLACKJACK = 21
  DEALER_STAYS = 17
  IMAGE_PATH = "/images/cards/"
  IMG_EXTENSION = ".jpg"
  Card = Struct.new(:value, :suit)
  
  def reset_game
    session[:deck] = prepare_deck
    session[:players_hand] = []
    session[:dealers_hand] = []
    session[:current_bet] = 0
  end

  def starting_money
    starting_money = 500
  end

  def prepare_deck
    cards = VALUES.product(SUITS)
    deck = cards.collect do |card|
      Card.new(card[0], card[1])
    end
    deck.shuffle!
  end
  
  def deal_card(hand)
    new_card = session[:deck].pop
    hand << new_card
  end

  def calculate_score(hand)
    total_score = 0
    ace_count = 0
    hand.each do |card|
      total_score += card.value.to_i unless card.value.to_i == 0
      total_score += 10 if %w(jack queen king).include?(card.value)
      ace_count += 1 if card.value == 'ace'
    end
    total_score += ace_count
    ace_count.times {total_score += 10 if total_score <= 11}
    total_score
  end

  def determine_winner
    players_score = calculate_score(session[:players_hand])
    dealers_score = calculate_score(session[:dealers_hand])
    if players_score <= BLACKJACK && dealers_score < BLACKJACK then
      case calculate_score(session[:players_hand]) <=> calculate_score(session[:dealers_hand])
      when 1
        player_wins
      when -1
        dealer_wins
      when 0
        draw_game
      end
    else
      dealer_wins 
    end
  end

  def player_wins
    session[:money] += session[:current_bet]*2
  end

  def dealer_wins
  end

  def draw_game
    session[:money] += session[:current_bet]
  end

end

get '/' do
  redirect '/welcome'
end

get '/welcome' do 
  erb :welcome_screen
end

post '/game_start' do
  session[:player_name] = (params[:player_name] != "") ? params[:player_name] : "lorum ipsum"
  session[:money] = starting_money
  redirect '/place_bet'
end  

get '/place_bet' do
  reset_game
  erb :game_start
end

post '/post_bet' do 
  case
  when (1..session[:money].to_i).include?(params[:bet_amount].to_i)
    session[:current_bet] = params[:bet_amount].to_i
    session[:money] -= session[:current_bet]
    2.times {deal_card(session[:players_hand])}
    1.times {deal_card(session[:dealers_hand])}
    redirect '/deal_cards'  
  when (params[:bet_amount].to_i) < 0
    session[:current_bet] = params[:bet_amount].to_i
    redirect '/deal_blackjack'
  else 
    redirect '/place_bet'
  end
end

get '/deal_cards' do
  erb :deal_cards
end

get '/player_hit' do
  deal_card(session[:players_hand])
  erb :deal_cards
end

get '/dealer_hit' do
  deal_card(session[:dealers_hand])
  erb :dealers_turn
end

get '/conclusion' do
  determine_winner
  (session[:money] > 0) ? (redirect '/play_again') : (redirect '/welcome')
end

get '/play_again' do
  erb :play_again
end

get '/deal_blackjack' do
  "Oh, you've bet -$#{session[:current_bet]*-1} of your $#{session[:money]}?  Interesting."
end


not_found do 
  redirect '/custom_404'
end

get '/custom_404' do 
  "Path not found.  Not at all."
end