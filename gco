#!/usr/bin/env ruby

require "colorize"


$key_word = $*[0]

def branch(show: false)
  #
  # these keyword filter has to be multiple later
  #
  if show
    $key_word = $*[1]
  end

  p = `git branch`
  branches = p.split("\n")
  current_branch = branches.select{|branch| branch.start_with?("*")}[0].gsub("* ", "")
  unless $key_word.nil?
    branches = branches.select{|branch| branch.include?($key_word)}
  end  
  [branches, current_branch]
end  

def get_branch(branches, current_branch)
  branches.each_with_index do |branch, index|
    if branch == current_branch
      branch = branch.green
    end
    puts "[#{index.to_s.green}] #{branch}"
  end
  print "[branch?] "
  input = $stdin.gets.chomp
  abort if input == "q"
  if num?(input)
    branches[input.to_i]
  else
    get_branch(branches.select{|branch| branch.include?(input)}, current_branch)
  end
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

def include?(file, key_words)
  key_words.select do |key_word|
    file.downcase.include?(key_word.downcase)
  end.size == key_words.size
end

def num?(i)
  /[^0-9]/.match(i).nil?
end

def get_file(key_words, files=[])
  if files.size == 0
    files = Dir["./**/*"]
  end
  matches = files.select do |file|
    include? file, key_words
  end

  matches.each_with_index do |file, i|
    puts "[#{i.to_s.cyan}] #{file}" 
  end
  
  abort "\n0 matches\n\n" if matches.size == 0
  print "which file? "
  input = $stdin.gets.chomp
  if num?(input)
    return matches[input.to_i]
  else
    return get_file(input.split(" "))
  end
end

def show(branches, current_branch, key_words)
  target_branch = get_branch(branches, current_branch)
  command = "git show #{target_branch}:#{get_file(key_words)}"
  puts command.green
  system command
end

case $key_word 
when "-h", "--help", "help", "--h"
  puts
  puts "gco [keyword]    ... go to another branch"
  puts "gco pull [merge] ... pull and update the develop branch"
  puts "                     if merge option added, the update will be merged."
  puts "gco #{"pm".green}           ... same as 'gco pull merge'"
  puts "gco retreat      ... kill the last commit"
  puts "gco show         ... look into the file in another branch"
  puts
when "show"
  branches, current_branch = branch(show: true)
  print "File: key_words: ".green
  show branches, current_branch, $stdin.gets.chomp.strip.split(" ")
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
