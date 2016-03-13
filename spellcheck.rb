#!/usr/bin/env ruby
require 'pry'

def words(text)
  text.downcase.scan(/[a-z]+/)
end

def train(features)
  model = Hash.new(1)
  features.each { |f| model[f] += 1 }
  model
end

DICTIONARY = train(words(File.new('lotsowords.txt').read))

LETTERS = ("a".."z").to_a

def num_letters(word)
  word.length
end

def deletion(word)
  (0...num_letters(word)).collect do |i|
    word[0...i] + word[i + 1..-1]
  end
end

def transpose(word)
  (0...num_letters(word) - 1).collect do |i|
    word[0...i] + word[i + 1, 1] + word[i, 1] + word[i + 2..-1]
  end
end

def alteration(word)
  alteration = []
  num_letters(word).times do |i|
    LETTERS.each do |letter|
      alteration << word[0...i] + letter + word[i + 1..-1]
    end
  end
  alteration
end

def insertion(word)
  insertion = []
  (num_letters(word) + 1).times do |i|
    LETTERS.each do |letter|
      insertion << word[0...i] + letter + word[i..-1]
    end
  end
  insertion
end

def edits1(word)
  result = deletion(word) + transpose(word) + alteration(word) + insertion(word)
  result.empty? ? nil : result
end

def known_edits2(word)
  results = []
  edits1(word).each do |edit|
    edits1(edit).each do |edit2|
      if DICTIONARY.has_key?(edit2)
        results << edit2
      end
    end
  end
  results.empty? ? nil : results
end

def known(words)
  result = words.find_all { |word| DICTIONARY.has_key?(word) }
  result.empty? ? nil : result
end

def correct(sentence)
  words = sentence.downcase.split(" ")
  new_sentence = ""
  words.each do |word|
    candidates = (known([word]) || known(edits1(word)) || known_edits2(word) || [word])
    new_word = candidates.max { |a, b| DICTIONARY[a] <=> DICTIONARY[b] }
    new_sentence += new_word + " "
  end
  new_sentence
end

input = ARGV.join(" ")
puts correct(input)
