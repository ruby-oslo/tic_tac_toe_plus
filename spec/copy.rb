require 'open3'

block = ARGV[0]
is_inside = false
lines = []

Open3.popen2("cd #{__dir__} && git show HEAD:./game_spec.rb")[1].each do |line|
# File.open(__dir__ + '/game_spec.rb').each do |line|
  line.rstrip!

  if line =~ /^\s*##(.*)$/
    is_inside = (block == $1.strip)
  else
    lines << line if is_inside
  end
end

deindent = lines
  .reject(&:empty?)
  .map { |line| line[/^\s*/].size }
  .min

Open3.popen2('pbcopy') do |stdin, stdout|
  lines.each do |line|
    stdin.puts line[deindent..-1]
  end
end

puts "Copied #{lines.size} lines."

puts ""
lines.each do |line|
  puts line[deindent..-1]
end
