#!/usr/bin/env ruby

require "colorize"

p = `git branch`

key_word = $*[0]

branches = p.split("\n")

current_branch = branches.select{|branch| branch.start_with?("*")}[0].gsub("* ", "")

unless key_word.nil?
  branches = branches.select{|branch| branch.include?(key_word)}
end  

def list_branches(branches, current_branch)
  branches.each_with_index do |branch, index|
    if branch == current_branch
      branch = branch.green
    end
    puts "[#{index}] #{branch}"
  end

  print "[which?] "
  option = $stdin.gets.chomp

  abort if option == "q"
  
  unless /[^0-9]/.match(option).nil?
    list_branches(branches.select{|b| b.include?(option)}, current_branch)
  else
    system "git co #{branches[option.to_i]}"
  end
end    

case key_word 
when "-h", "--help", "help", "--h"
  puts
  puts "gco [keyword]    ... go to another branch"
  puts "gco pull [merge] ... pull and update the develop branch"
  puts "                     if merge option added, the update will be merged."
  puts
when "pull"
  result = system "git co develop"
  if result
    puts "pulling in develop ...".green
    system "git pull"
    puts "checking out onto the #{current_branch}".green
    system "git co #{current_branch}"
  end  
  if ARGV.include?("merge")
    system "git merge develop"
  elsif ARGV.include?("rebase")
    system "git pull --rebase origin develop"
  end
else
  list_branches branches, current_branch
end  
