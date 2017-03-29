#!/usr/bin/env ruby

p = `git branch`

key_word = $*[0]

branches = p.split("\n")

unless key_word.nil?
  branches = branches.select{|branch| branch.include?(key_word)}
end  

branches.each_with_index do |branch, index|
  puts "[#{index}] #{branch}"
end

print "[which?] "
option = $stdin.gets.chomp

abort if option == "q"

system "git co #{branches[option.to_i]}"
