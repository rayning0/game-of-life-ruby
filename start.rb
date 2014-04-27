require_relative 'lib/gol'
require_relative 'lib/gol_gosu'

loop do
  puts "\nRaymond Gan's Game of Life\n\n"
  puts "In both versions, hit SPACE to restart game or ESC to exit game.\n\n"
  puts 'Do you want to see/hear pretty color graphics version (g)'
  print "or see text version (t)? ('q' to QUIT) "

  input = ''

  loop do
    input = gets.chomp[0].downcase
    break if %w(g t q).include?(input)
  end

  if input == 'g'
    GameWindow.new(600, 400).show
  elsif input == 't'
    Window.new(40, 30).run
  end

  break if input == 'q'
end
