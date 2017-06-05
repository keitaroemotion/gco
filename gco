#!/usr/bin/env ruby

require "colorize"


def key_word 
  $*[0]
end  

def branch
  p = `git branch`

  branches = p.split("\n")

  current_branch = branches.select{|branch| branch.start_with?("*")}[0].gsub("* ", "")

  unless key_word.nil?
    branches = branches.select{|branch| branch.include?(key_word)}
  end  
  [branches, current_branch]
end  

def get_branch(branches, current_branch)
  branches.each_with_index do |branch, index|
    if branch == current_branch
      branch = branch.green
    end
    puts "[#{index}] #{branch}"
  end
  print "[which?] "
  $stdin.gets.chomp
end

def list_branches(branches, current_branch)
  option = get_branch(branches, current_branch)

  abort if option == "q"
  
  unless /[^0-9]/.match(option).nil?
    list_branches(branches.select{|b| b.include?(option)}, current_branch)
  else
    system "git co #{branches[option.to_i]}"
  end
end    

def get_file(key_words)
  matches = Dir["./**/*"].select do |file|
    key_words.select do |key_word|
      file.downcase.include?(key_word.downcase)
    end.size == key_words
  end
  matches.each_with_index do |file, i|
    puts "#{i} #{file}" 
  end
  print "which? "
  input = $stdin.gets.chomp
  matches[input.to_i]
end

def show(branches, current_branch, key_words)
  target_branch = get_branch(branches, current_branch)
  "git show #{target_branch}:#{get_file(key_words)}"
end

case key_word 
when "-h", "--help", "help", "--h"
  puts
  puts "gco [keyword]    ... go to another branch"
  puts "gco pull [merge] ... pull and update the develop branch"
  puts "                     if merge option added, the update will be merged."
  puts "gco #{"pm".green}           ... same as 'gco pull merge'"
  puts "gco retreat      ... kill the last commit"
  puts
when "show"
  show branches, current_branch, ARGV[1..-1]
when "pull", "pm"
  branches, current_branch = branch
  result = system "git co develop"
  if result
    puts "pulling in develop ...".green
    system "git pull"
    puts "checking out onto the #{current_branch}".green
    system "git co #{current_branch}"
  end  
  if ARGV.include?("merge") || ARGV.include?("pm")
    system "git merge develop"
  elsif ARGV.include?("rebase")
    system "git pull --rebase origin develop"
  end
when "retreat"
  system "git reset HEAD~"
  system "git reset --hard"
else
  branches, current_branch = branch
  list_branches branches, current_branch
end  
