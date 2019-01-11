# Connor Cates
# ruby 2.4.3p205
# 2/16/2018

class Pair
  # Simple data structure to hold two objects in a pair

  attr_accessor :first, :second

  def initialize first, second
    @first = first
    @second = second
  end

  def to_s
    return "#{@first} #{@second}"
  end
  
end

class MarkovChainTextGenerator
  # Markov Chain class - generates text using trigrams from a given text file"
  include Enumerable

  # instance variable declarations
  attr_reader :file, :words_array, :word_triples, :text_title
  
  def initialize text
    # Initializes the class object
    
    @text_title = text
    
    # open the file
    @file = File.open(text, 'r')

    # generate the coupled words for the trigrams
    @words_array = File.read(@file).split
    @file.close

    # go through each pair of words and use the pair as a key to an array
    # of all words that follow that pair
    @word_triples = Hash.new
    i = 0
    while i < @words_array.length-1
      
      # get the initial two words
      initial_two_words = Pair.new(@words_array[i], @words_array[i+1]).to_s

      # if they have not been encountered, make a new array for the values
      # that follow
      if @word_triples[initial_two_words] == nil
        arr = Array.new
        @word_triples[Pair.new(@words_array[i], @words_array[i+1]).to_s] =
          arr.push(@words_array[i+2])

      # else they are already a key in the Hash and thus add the next 
      # word to the array
      else
        @word_triples[Pair.new(@words_array[i], @words_array[i+1]).to_s].push(
          @words_array[i+2])
      end

      i = i+1
    end
  end

  def to_s
    # returns a string representation of the object
    
    "Markov Chain Text Generator based on the text '#{@text_title}'"
  end

  def inspect
    # returns a more computer friendly string representation of the object

    self.to_s + "; Trigram Hash: #{@word_triples}"
  end

  def parse_two_words string_of_two_words
    # takes a string containing two words and returns a Pair of the two

    words = string_of_two_words.split(' ')
    Pair.new(words[0], words[1])
  end

  def sentence_starters
    # find all sentence starting words in the text

    # insert the first two words of the text file as starters as they must
    # start a sentence
    potential_starters = @word_triples.keys
    sentence_starters = []
    text_starters = text_starter
    sentence_starters.push(text_starter.first + " " + text_starter.second)
    
    # for each key in the has, if the first word has a period at the end the 
    # second has to be a start of a sentence
    potential_starters.each do |words|
      word_pair = parse_two_words(words)
      
      if word_pair.first[word_pair.first.length-1] == '.'
        next_words = @word_triples[word_pair.to_s]
        next_word = next_words[rand(0..next_words.length-1)]

        sentence_starters.push(word_pair.second + " " + next_word)
                              
      end
    end

    sentence_starters
  end

  def text_starter
    # return a string of two words to start a text with

    Pair.new(@words_array[0], @words_array[1])
  end

  def random_value arr
    # returns a random value stored in an array

    arr[rand(0..arr.length-1)]
  end

  def previous_pair text
    # gets the last two words in the  string text and returns them as a Pair

    words = text.split(' ')
    word1 = words[words.length-1]
    word2 = words[words.length-2]
    
     # return the new pair
     Pair.new(word2, word1)
  end
  
  def generate_text text_length
    # generate and return a string of text with text_length number of words

    generated_text = ""
    num_words = 0

    while num_words < text_length

      # if it is the start of the text
      if generated_text.length == 0
        generated_text += random_value(sentence_starters)
        num_words += 2

      # else it is in the middle and thus caluclate the trigram for the
      # Markov Chain
      else
        possible_words = @word_triples[previous_pair(generated_text).to_s]
        next_word = random_value(possible_words).to_s
        generated_text = generated_text + " " + next_word
        num_words += 1
      end 

    end

    generated_text
  end 

  def generate_sentence
    # generate and returns a string that is starts with a typical first
    # word of a sentence and ends with end of sentence punctuation

    # start the sentence
    generated_sentence = random_value(sentence_starters).to_s

    while true

      # if the generated text has an end-of-sentence punctuation, return the
      # generated sentence and end the method
      if generated_sentence[generated_sentence.length-1] == '.' ||
          generated_sentence[generated_sentence.length-1] == '!' ||
          generated_sentence[generated_sentence.length-1] == '?'
        return generated_sentence
        
      end

      possible_words = @word_triples[previous_pair(generated_sentence).to_s]
      next_word = random_value(possible_words).to_s
      generated_sentence = generated_sentence + " " + next_word
      
    end

    generated_sentence
  end

  def each
    # Yields each word in a randomly generated sentence to a given code block
    
    sentence = generate_sentence
    sentence.split(' ').each {|word| yield word}
    sentence
  end

end
