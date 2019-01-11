# Connor Cates
# Ruby 2.4.3p205

# CITE: http://www.rubyguides.com/2016/04/twitter-api-from-ruby-tutorial/
# Learned how to use and install the twitter API and different 
# functionality of it.

require 'twitter'
require './MarkovChainTextGenerator'

class MarkovKeywordGenerator
  # Class to use the Markov Chain Generator from Part 1 and add the
  # functionality to give the generate_sentence function a keyword to base
  # the text off of

  attr_accessor :markov_chain

  def initialize markov_gen

    @markov_chain = markov_gen
  end

  def get_first_word str_words
    # takes in a string and returns the first word of the string
    if str_words[0] == ' '
      return ''
    end

    str_words[0] + get_first_word(str_words[1..str_words.length])
  end

  def find_pair keyword
    # finds the first word pair that starts with the given keyword

    keys = @markov_chain.word_triples.keys
    keys.each do |words|

      first_word = get_first_word(words)

      if first_word == keyword
        return words
      end
    end

    return nil
    
  end

  def generate_sentence keyword
    # Generates a sentence which starts with a given keyword
    
    end_of_sentence = find_pair(keyword)

    while true
      if end_of_sentence == nil
        puts "The corpus does not contain this word."
        return nil
      end

      length = end_of_sentence.length
      if end_of_sentence[length-1] == '.' ||
         end_of_sentence[length-1] == '?' ||
         end_of_sentence[length-1] == '!'
        return end_of_sentence
      end

      possible_words = @markov_chain.word_triples[
        @markov_chain.previous_pair(end_of_sentence).to_s]
      next_word = @markov_chain.random_value(possible_words).to_s
      end_of_sentence = end_of_sentence + " " + next_word
    
    end

    end_of_sentence
  end
  
end


class TwitterBot
  #Cclass to generate and post tweets based on a given users last posted
  # tweets. Posted to the twitter handle @HammyTrump

  attr_accessor :client, :corpus, :markov_gen

  def initialize twitter_user_handle
    @corpus = ""
 
    # create the twitter client
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key = "BAfUjv9estlB1jpnO39mmu0cp"
      config.consumer_secret = "BzKzfeQYecGwCQNyBDWNtPyerUxmt51MwvJe0ERB25NeJGDp8Q"
      config.access_token = "965772013414551553-C6fcdE1LIpxId1U0kUfMmuyzph5CLiV"
      config.access_token_secret = "VOFNYIpEoTOemvH3jZlSWMsW01b9iPhoEMwbxeiVkL8ib"
    end

    # gathers tweets from the given twitter handle to base the tweets on
    tweets = client.user_timeline(twitter_user_handle, count: 200, include_retweets: 1)
    tweets.each {|tweet| @corpus += " " +  tweet.full_text }

    # create a text file for the MarkocChainTextGenerator to base itself off of
    corpus_file = File.new('corpus_file.txt', 'w+')
    corpus_file.puts(@corpus)
    corpus_file.close

    @markov_gen = MarkovChainTextGenerator.new(corpus_file)
  end

  def generate_tweet keyword = nil
    # Calls the generate sentence method to generate a short tweet
    # May pass keyword to base the sentence off of 
    if keyword == nil
      return @markov_gen.generate_sentence
    end

    keyword_markov = MarkovKeywordGenerator.new(@markov_gen)
    keyword_markov.generate_sentence(keyword)
  end

  def tweet keyword = nil
    # Tweets to the affiliated account of the @client
    # May pass a keyword to be the subject of the tweet
    if keyword == nil
      return @client.update(generate_tweet)
    end

    @client.update(generate_tweet(keyword))
    
  end

  def tweet_periodically_x_times x
    # Tweets to the affiliated account x times, 10 minutes apart
    one_minute = 60
    
    i = 0
    while i < x
      tweet
      sleep(10 * one_minute)
    end
  end
end
                            
