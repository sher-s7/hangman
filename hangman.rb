require 'colorize'
require 'json'

class Hangman
  @@WORDBANK = File.open("5desk.txt", "r")
  @@WORDS = @@WORDBANK.readlines
  attr_reader :tries, :WORDBANK, :incorrect_letters, :word, :word_arr
  attr_accessor :guess_arr

  def initialize(tries=8,incorrect_letters=[],word=get_word.downcase,guess_arr=[])
    @tries = tries
    @incorrect_letters = incorrect_letters
    @word = word
    @word_arr = word.split('')
    @guess_arr = guess_arr
    if guess_arr==[]
      word_arr.length.times do
        guess_arr.push(' _ ')
      end
    end
  end

  def play
    

    while guess_arr.join != word
      if tries == 0
        puts "0 tries left. You lose".red
        puts
        puts "Correct word: #{word.upcase.green}"
        return
      end

      puts
      puts "Word: #{guess_arr.join}    Tries: #{tries}"
      puts
      puts "Incorrect letters: #{incorrect_letters}"
      puts
      puts "Enter a letter, or enter 'ss' to save the game:"
      begin
        letter = gets.chomp.downcase
        if letter.length != 1
          if letter == 'ss'
            File.open('save.json','w').write(to_json)
            return
          else
            raise "Error: Only enter one letter"
          end
        end
      rescue Exception=>e
        puts e
        retry
      end
      if !word_arr.include?(letter) && !incorrect_letters.include?(letter)
        countdown
        add_bad_letter(letter)
      elsif !guess_arr.include?(letter)
        word_arr.each_with_index do |l, index|
          if letter == l
            guess_arr[index] = letter
          end
        end
      else
        puts 'Letter already guessed. Choose another one: '
      end
      puts '- - - - - - - - - - - -'.green
      
    end
    puts 'you won congrats'
    puts word.upcase.green

  end
  
  def get_word
    word = @@WORDS.sample.strip
    while !word.length.between?(5, 12)
      word = @@WORDS.sample.strip
    end
    return word
  end

  def to_json
    JSON.dump ({
      :tries => @tries,
      :incorrect_letters => @incorrect_letters,
      :word => @word,
      :guess_arr => @guess_arr
    })
  end

  def self.from_json(string)
    data = JSON.load string
    self.new(data['tries'], data['incorrect_letters'], data['word'], data['guess_arr'])
  end

  protected

  def countdown
    @tries -= 1
  end

  def add_bad_letter(letter)
    @incorrect_letters.push(letter)
  end

end

puts 'Would you like to load a saved game? (y/n)'
begin
  ans = gets.chomp.downcase
  if !(ans.downcase == 'y' || ans.downcase=='n')
    raise 'Error: Enter "y" or "n" (yes/no)'
  end
rescue Exception=>e
  puts e
  retry
end
if(ans == 'y' && File.exist?('save.json'))
  game = Hangman.from_json(File.read('save.json'))
  game.play
else
  puts 'No save file found'.red if !File.exist?('save.json')
  puts
  game = Hangman.new
  game.play
end



