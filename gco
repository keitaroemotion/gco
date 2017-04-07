#!/usr/bin/env ruby

require "colorize"

p = `git branch`

key_word = $*[0]

branches = p.split("\n")

unless key_word.nil?
  branches = branches.select{|branch| branch.include?(key_word)}
end  

current_branch = branches.select{|branch| branch.start_with?("*")}[0]

def list_branches(branches, current_branch)
  branches.each_with_index do |branch, index|
    if branch == current_branch
      branch = branch.green
    end
    puts "[#{index}] #{branch}"
  end

  print "[which?] "
  option = $stdin.gets.chomp

  abort if option == "q" || option.empty?
  if /^[0-9]/.match(option).present?
    list_branches(branches.select{|b| b.include?(option)}, current_branch)
  else
    system "git co #{branches[option.to_i]}"
  end
end    

list_branches branches, current_branch
