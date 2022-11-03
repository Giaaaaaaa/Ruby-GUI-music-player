require 'rubygems'
require 'gosu'

TOP_COLOR = Gosu::Color::CYAN
BOTTOM_COLOR = Gosu::Color.new(0xFF1EB1FA)

SCREEN_SIZE = 800
TrackLeftX = 320
COVER_SIZE = 120

module ZOrder
  BACKGROUND, PLAYER, UI = *0..2
end

module Genre
  POP, CLASSIC, JAZZ, ROCK = *1..4
end

GENRE_NAMES = ['Null', 'Pop', 'Classic', 'Jazz', 'Rock']

class ArtWork
	attr_accessor :bmp

	def initialize (file)
		@bmp = Gosu::Image.new(file)
	end
end

# Put your record definitions here

class Album
	attr_accessor :album_title, :artist, :img_file, :tracks

	def initialize(album_title, artist, img_file, tracks)
		@album_title = album_title
		@artist = artist
		@img_file = img_file
		@tracks = tracks
	end
end

class Track
	attr_accessor :track_name, :location, :track_number
	
	def initialize(track_name, location, track_number)
		@track_name = track_name
		@location = location
		@track_number = track_number
	end
end

def read_albums(music_file)
    number_of_albums = music_file.gets().to_i
    albums = Array.new()
    i = 0   
    while i < number_of_albums
        album = read_album(music_file)
        albums << album
        i += 1
         
    end
    return albums
end

def read_album(music_file)
	album_title = music_file.gets().to_s
	artist = music_file.gets().to_s
	img_file = music_file.gets().chomp.to_s
	tracks = read_tracks(music_file)
	album = Album.new(album_title, artist, img_file, tracks)
	return album
end

def read_tracks(music_file)
	number_of_tracks = music_file.gets().to_i
	tracks = Array.new()
	i = 0
	while i < number_of_tracks
        track = read_track(music_file)
		tracks << track
        track_number = i + 1
		i += 1
	end
	return tracks
end

def read_track(music_file)
	track_name = music_file.gets().to_s
	location = music_file.gets().chomp.to_s
	track_number = 0
	track = Track.new(track_name, location, track_number)
	return track
end

class MusicPlayerMain < Gosu::Window

	def initialize
	    super SCREEN_SIZE, SCREEN_SIZE
	    self.caption = "Music Player"

		# Reads in an array of albums from a file and then prints all the albums in the
		# array to the terminal
		music_file = File.new("albums.txt","r") #changed to local
		@albums = read_albums(music_file)
		@track_font = Gosu::Font.new(20)
		@album_info_font = Gosu::Font.new(22)
		@artist_font = Gosu::Font.new(22)
		#@is_clicked = false #do not need
		@my_album = Album.new(nil, nil, nil, nil)
		@my_track = Track.new(nil, nil, nil)
		@album_index = 0
		@track_index = 0
		@album_clicked = false
		#@track_clicked = false #changed to local
		#@another_album_clicked = false #do not need
        @song = Gosu::Song.new(@albums[0].tracks[0].location)
		music_file.close
		
	end

  # Put in your code here to load albums and tracks

  # Draws the artwork on the screen for all the albums

  def draw_album(leftX, topY, album)
		cover = Gosu::Image.new(album.img_file)
		cover.draw( leftX, topY, ZOrder::PLAYER)
  end


  def draw_albums(albums)
    # complete this code
		i = 0
		while i < albums.length
			leftX = 30 + (150 * (i/5))
			topY = 50 + (150 * (i%5))
			draw_album( leftX, topY, albums[i])
			i += 1
		end
		mouse_over_albums(albums)
  end

  # Detects if a 'mouse sensitive' area has been clicked on
  # i.e either an album or a track. returns true or false

  def draw_indicator(leftX, topY, rightX, bottomY)
    draw_quad(leftX + 7, topY + 7, BOTTOM_COLOR, leftX + 7, bottomY + 7, BOTTOM_COLOR, rightX + 7, topY + 7, BOTTOM_COLOR, rightX + 7, bottomY + 7, BOTTOM_COLOR, ZOrder::BACKGROUND, mode=:default)
  end

  def mouse_over_area(leftX, topY, rightX, bottomY)
	if (mouse_x - leftX) > 0 && (mouse_x - rightX) < 0
		if (mouse_y - topY) > 0 && (mouse_y - bottomY) < 0
			true
			#draw_indicator(leftX, topY, rightX, bottomY)
		else
			false
		end
	end
  end

  def mouse_over_albums(albums)
    i = 0
    while i < albums.length
        leftX = 30 + (150 * (i/5))
        topY = 50 + (150 * (i%5))
        rightX = leftX + COVER_SIZE
        bottomY = topY + COVER_SIZE
        if mouse_over_area(leftX, topY, rightX, bottomY)
			draw_indicator(leftX, topY, rightX, bottomY)
			#display_tracks(albums[i])
			if button_down?(Gosu::MsLeft)
				@my_album = albums[i]
				@album_index = i
			end	
		end
		
        i += 1
    end

  end



  def mouse_over_tracks(album)
    i = 0
    while i < album.tracks.length
        leftX = TrackLeftX - 10
        topY = 100 + (30 * i) - 7
        rightX = 780 - 5
        bottomY = topY + 20 - 3
        if mouse_over_area(leftX, topY, rightX, bottomY)
			draw_indicator(leftX, topY, rightX, bottomY)
			if button_down?(Gosu::MsLeft)
                @my_track = album.tracks[i]
				@track_index = i
				
            end
		end
        i += 1
    end
  end


  # Takes a String title and an Integer ypos
  # You may want to use the following:
  def display_track(track_name, ypos)
		@track_font.draw_text(track_name, TrackLeftX, ypos, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
  end

  def display_tracks(album)
		i = 0
		while i < album.tracks.length
			ypos = 100 + (30 * i)
			display_track(album.tracks[i].track_name, ypos)
			i += 1
		end
		@album_info_font.draw_text(album.album_title , TrackLeftX, 30, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
		@artist_font.draw_text(album.artist , TrackLeftX, 55, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
        mouse_over_tracks(album)
  end

  



  # Takes a track index and an Album and plays the Track from the Album

 

# Draw a coloured background using TOP_COLOR and BOTTOM_COLOR

	def draw_background
		draw_quad( 0, 0, BOTTOM_COLOR, 0, SCREEN_SIZE, BOTTOM_COLOR, SCREEN_SIZE, 0, BOTTOM_COLOR, 
        SCREEN_SIZE, SCREEN_SIZE, BOTTOM_COLOR, ZOrder::BACKGROUND)
        
        draw_quad( 10, 10, TOP_COLOR, 10, SCREEN_SIZE - 10, TOP_COLOR, SCREEN_SIZE - 10, 10, TOP_COLOR, 
        SCREEN_SIZE - 10, SCREEN_SIZE - 10, TOP_COLOR, ZOrder::BACKGROUND)

	end

	def draw_clicked_album
		if button_down?(Gosu::MsLeft)
			@album_clicked = true
		end
		if @album_clicked
			display_tracks(@my_album)
			leftX = 30 + (150 * (@album_index/5))
       		topY = 50 + (150 * (@album_index%5))
        	rightX = leftX + COVER_SIZE
        	bottomY = topY + COVER_SIZE
			draw_indicator(leftX, topY, rightX, bottomY)
		end
	end

	def draw_and_play_clicked_track
        track_clicked = false
		leftX = TrackLeftX - 10
        topY = 100 + (30 * @track_index) - 7
        rightX = 780 - 5
        bottomY = topY + 20 - 3
		if mouse_over_area(leftX, topY, rightX, bottomY) && button_down?(Gosu::MsLeft)
			track_clicked = true
            play_track(@my_track)
		end
		if track_clicked && @my_album.tracks[@track_index] == @my_track
			draw_indicator(leftX, topY, rightX, bottomY)
            
            #elsif @song.playing? == true && @song.paused? == true
            #    @song.stop
            
		end
        
	end

    def play_track(track)
        # complete the missing code
        
        if @song.playing? == true || @song.paused? == true   
            @song.stop
            @song = Gosu::Song.new(track.location)
            @song.play(false)
        elsif @song.playing? ==false && @song.paused? == false
            @song = Gosu::Song.new(track.location)
            @song.play(false)
        end
         
     # Uncomment the following and indent correctly:
       #	end
       # end
   end


# Not used? Everything depends on mouse actions.

	def update
        
	end

 # Draws the album images and the track list for the selected album

	def draw
		# Complete the missing code
		draw_background
		draw_albums(@albums)
		draw_clicked_album
		draw_and_play_clicked_track

		#@music_file.close
	end

 	def needs_cursor?; true; end

	# If the button area (rectangle) has been clicked on change the background color
	# also store the mouse_x and mouse_y attributes that we 'inherit' from Gosu
	# you will learn about inheritance in the OOP unit - for now just accept that
	# these are available and filled with the latest x and y locations of the mouse click.

	def button_down(id)
		case id
	    when Gosu::MsLeft
	    	# What should happen here?
          
        end
	end

end

# Show is a method that loops through update and draw

MusicPlayerMain.new.show if __FILE__ == $0
