#!/usr/bin/env ruby

require "colorize"

p = `git branch`

key_word = $*[0]

branches = p.split("\n")

unless key_word.nil?
  branches = branches.select{|branch| branch.include?(key_word)}
end  

current_branch = branches.select{|branch| branch.start_with?("*")}[0]

branches.each_with_index do |branch, index|
  if branch == current_branch
    branch = branch.green
  end
  puts "[#{index}] #{branch}"
end

print "[which?] "
option = $stdin.gets.chomp

abort if option == "q" || option.empty?

system "git co #{branches[option.to_i]}"
