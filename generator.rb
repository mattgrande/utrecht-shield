require 'csv';
require 'yaml'

@current_holder = 'France'  # First team to win was France
@streak_started = '1982-06-13'
@defenses = 0
@info = Hash.new

def update_holder(new_holder, date)
    if new_holder != @current_holder
        @info[@streak_started][:changed_hands] = true
        @info[@streak_started][:held_for] = @defenses
        @info[@streak_started][:held_by] = @current_holder

        puts "NEW HOLDER! #{new_holder}"
        puts "#{@current_holder} defended #{@defenses} times"
        @current_holder = new_holder
        @defenses = 1
        @streak_started = date
    else
        @defenses += 1
    end
end

CSV.foreach("./matches.csv") do |row|
    game = Hash.new
    game[:home] = row[0]
    game[:home_score] = row[1].to_i
    game[:away_score] = row[2].to_i
    game[:away] = row[3]
    game[:date] = row[4]
    game[:filename] = "#{row[4]}-#{row[0]}-v-#{row[3]}.md"
    @info[game[:date]] = game
    if (game[:home_score] > game[:away_score])
        puts "HOME: #{game[:home]} #{game[:home_score]}-#{game[:away_score]} #{game[:away]}"
        update_holder(row[0], game[:date])
    elsif (game[:away_score] > game[:home_score])
        puts "AWAY: #{game[:home]} #{game[:home_score]}-#{game[:away_score]} #{game[:away]}"
        update_holder(row[3], game[:date])
    else
        puts "DRAW: #{game[:home]} #{game[:home_score]}-#{game[:away_score]} #{game[:away]}"
        update_holder(@current_holder, game[:date])
    end
end

update_holder(nil, nil)

@info.each do |key, value|
    File.open("_posts/#{value[:filename]}", 'w') do |f|
        f.puts('---')
        f.puts('layout: event')
        f.puts('location: Utrecht')
        f.puts("home: #{value[:home]}")
        f.puts("away: #{value[:away]}")
        f.puts("home_score: #{value[:home_score]}")
        f.puts("away_score: #{value[:away_score]}")
        if (value[:changed_hands])
            f.puts("changed_hands: true")
            f.puts("held_for: #{value[:held_for]}")
            f.puts("held_by: #{value[:held_by]}")
        end
        f.puts('---')
    end
end