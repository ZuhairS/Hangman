class Hangman

  attr_reader :guesser, :referee, :board

  def initialize(players)
    @guesser = players[:guesser]
    @referee = players[:referee]
    @board = []
  end

  def setup
    secret_word_length = referee.pick_secret_word
    @guesser.register_secret_length(secret_word_length)
    @board = Array.new(secret_word_length)
  end

  def take_turn
    guess = @guesser.guess
    indices = @referee.check_guess(guess)
    update_board(indices)
    @guesser.handle_response
  end

  def update_board(indices)
    indices.each { |idx| @board[idx] = @referee.secret_word }
  end

end

class HumanPlayer

  attr_reader :dictionary, :secret_word

  def initialize(dictionary)
    @dictionary = dictionary
    @secret_word = ""
  end

  def pick_secret_word
    print "Please enter your secret word: "
    @secret_word = gets.chomp
    until dictionary.include?(@secret_word)
      puts "\nPlease enter a word from the dictionary!\n"
      pick_secret_word
    end
    @secret_word.length
  end

  def register_secret_length(secret_word_length)
    puts "The secret word has #{secret_word_length} letters.\n"
  end

  def check_guess(char)
    alphabets = ("a".."z").to_a
    raise "Not a valid character!" if !alphabets.include?(char.downcase)
    (0...@secret_word.length).select do |index|
      @secret_word[index] == char.downcase
    end
  end

  def guess(board)
    print "\nPlease enter your guess letter: "
    gets.chomp
  end

  def handle_response(guess, indices_arr)
    
  end

  def candidate_words
    @dictionary
  end

end

class ComputerPlayer

  attr_reader :dictionary, :secret_word

  def initialize(dictionary)
    @dictionary = dictionary
    @secret_word = ""
  end

  def pick_secret_word
    @secret_word = dictionary.sample
    @secret_word.length
  end

  def register_secret_length(secret_word_length)
    @dictionary = candidate_words.select { |word| word.length == secret_word_length }
  end

  def check_guess(char)
    alphabets = ("a".."z").to_a
    raise "Not a valid character!" if !alphabets.include?(char.downcase)
    (0...@secret_word.length).select do |index|
      @secret_word[index] == char.downcase
    end
  end

  def guess(board)
    counter = Hash.new(0)
    @dictionary.join.each_char { |ch| counter[ch] += 1 unless board.include?(ch) }
    counter.max_by { |_, v| v }.first
  end

  def handle_response(guess, indices_arr)
    if indices_arr == []
      @dictionary = candidate_words.reject { |word| word.include?(guess) }
    else
      @dictionary = candidate_words.select do |word|
        indices_arr.all? do |idx|
          word[idx] == guess && word.count(guess) == indices_arr.count
        end
      end
    end
  end

  def candidate_words
    @dictionary
  end

end
