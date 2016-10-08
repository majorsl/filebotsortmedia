#!/bin/sh
# version 2.5 *REQUIREMENTS BELOW*
#
# 1. Working Homebrew installed.
# 2. Homebrew: brew tap caskroom/cask
# 3. Homebrew: brew install terminal-notifier
# 4. Homebrew: brew cask install filebot
# 5. Homebrew: brew install osxutils
# 6. Java SDK version 8 or greater.
#
# Note: you may have to symlink /usr/local/Cellar/terminal-notifier/1.6.3/terminal-notifier.app
# to /Applications/terminal-notifier.app
#
# This script will do several things in this order:
# 1. it will look for any file/folder with "sample" in the name and move it to trash, pre-
# pending the date/time to the file. While not likely an file will include a name AND
# also have "sample" as an name, it's safer to put it in the trash than to out-right
# rm it.
# 2. Next, it runs Filebot and sorts the file into the proper dir.
# 3. It cleans-up common "extra files" left behind, as well as any empty directories. You
# still may have to clean up a few things now and then, but it is better than a full rm of
# everything.
# 4. Updates Emby when new media is added.
# 5. Displays a Notification Center item when it has finished, you can comment this out in
# the script if you do not want it to show.
# 6. Set a Finder Label to Green for x265 files if file is properly tagged.
# 
# It shouldn't be a problem to have both your unsorted TV Shows and Movies in the same
# directory, but you run the risk mis-matching names. If your torrent client has options
# for rules, you can set it so that your TV Show names are moved to a separate directory
# for processing, leaving the default download location for movies.

# *** SET YOUR OPTIONS HERE ***
# path to Filebot binary (usually /Applications/ for the app and possibly ~/Applications if using
# homebrew cask. If in ~/Applications you can move it to /Applications if you like.)
FILEBOT="/Applications/FileBot_4.7.2-brew.app/"

# path to your unsorted TV Shows
TVSHOWS="/Volumes/Drobo/Media Center/Unsorted-TV Shows/"

# path to your sorted TV Shows
TVSHOWSSORT="/Volumes/Drobo/Media Center/TV Shows/"

# format for your TV show Season/Episode prefex & what database to use.
TVFORMAT="{n}/Season {s.pad(2)}/{S00E00} {t}"
TVDB="thetvdb"
#TVDB="TVmaze"

# path to your unsorted Movies
MOVIES="/Volumes/Drobo/Media Center/Unsorted-Movies/"

# path to your sorted Movies
MOVIESSORT="/Volumes/Drobo/Media Center/Movies/"

# format for your Movies title/year & what database to use.
MOVIEFORMAT="{n} ({y})"
MOVIEDB="themoviedb"

# path to your Volume's Trash ("501" is my UUID, yours may be different!) Find with:
# dscl . -read /Users/YOURUSERNAME/ UniqueID
VOLTRASH="/Volumes/Drobo/.Trashes/501/"

# IP or Hostname to Emby & your api key generated within Emby. Set to 0 to not use.
EMBYHOST="127.0.0.1"
# path to a plain text file with your emby api key.
EMBYAPI="/Volumes/Drobo/Media Center/embyapi.txt"
#EMBY="0"

# *****************************

# start loop 0 for TV Shows then 1 for Movies.
xloop=0
EMBYUPDATE=""

# update Emby?
if [ "$EMBY" != "0" ]; then
    IFS=$'\n'
	API=$(cat "$EMBYAPI")
	unset IFS
	EMBYUPDATE="$EMBYHOST:$API"
fi

while [ $xloop -lt 2 ]
do

# 1st loop sets for TV shows.
if [ "$xloop" -eq "0" ]; then
	/Applications/terminal-notifier.app/Contents/MacOS/terminal-notifier -title 'FileBot' -message "Running filebotsortmedia script, searching for TV Shows..." -appIcon "$FILEBOT"FileBot.app/Contents/Resources/filebot.icns
	STARTDIR=$TVSHOWS
	ENDDIR=$TVSHOWSSORT
	FORMAT="seriesFormat="$TVFORMAT
	DB=$TVDB
	FNAMC="seriesFormat"
fi

# 2nd loop sets for movies.
if [ "$xloop" -eq "1" ]; then
	/Applications/terminal-notifier.app/Contents/MacOS/terminal-notifier -title 'FileBot' -message "Running filebotsortmedia script, searching for Movies..." -appIcon "$FILEBOT"FileBot.app/Contents/Resources/filebot.icns
	STARTDIR=$MOVIES
	ENDDIR=$MOVIESSORT
	FORMAT="seriesFormat"$MOVIEFORMAT
	DB=$MOVIEDB
	FNAMC="movieFormat"
fi

let xloop=$xloop+1

# current date/time for file stamping.
DATETIME=`date +%m%d-%H%M%S`

# here we set BASHs internal IFS variable so directories/filenames are not broken into new
# lines when a space is found.
IFS=$'\n'

# looks for "sample" directories first.
for X in `find $STARTDIR -type d -iname "*sample*"`
do
        echo "Processing $X..."
        mv $X $VOLTRASH/$DATETIME/
done

sleep 1

# looks for "sample" files.
for X in `find $STARTDIR -iname "*sample*"`
do
        echo "Processing $X..."
        mv $X $VOLTRASH/$DATETIME/
done

# sets finder label to Green for x265 items
for X in `find $STARTDIR -iname "*x265*"`
do
        echo "Processing $X..."
        /usr/local/bin/setlabel Green $X
done

# clean up files so they don't get moved to the show directories.
find $STARTDIR -iname "*.nfo" -delete
find $STARTDIR -iname ".DS_Store" -delete
find $STARTDIR -iname "*.srt" -delete
find $STARTDIR -iname "*.sfv" -delete
find $STARTDIR -iname "*.jpg" -delete
find $STARTDIR -iname "*.idx" -delete
find $STARTDIR -iname "*.md5" -delete
find $STARTDIR -iname "*.url" -delete
find $STARTDIR -iname "*.mta" -delete
find $STARTDIR -iname "*.txt" -delete
find $STARTDIR -iname "*.png" -delete
find $STARTDIR -iname "*.ico" -delete
find $STARTDIR -iname "*.xml" -delete
find $STARTDIR -iname "*.htm" -delete
find $STARTDIR -iname "*.website" -delete
find $STARTDIR -iname "*.torrent" -delete
find $STARTDIR -iname "*.sqlite" -delete
find $STARTDIR -iname "Thumbs.db" -delete
# delete files smaller than xMB since these are often un-named sample files.
find $STARTDIR -type f -maxdepth 2 -size -15M -iname "*.mp4" -delete
find $STARTDIR -type f -maxdepth 2 -size -9M -iname "*.mkv" -delete

# path to Filebot binary
#cd $FILEBOT"Contents/MacOS/"

# rename and move.
"$FILEBOT"Contents/MacOS/./filebot.sh -script fn:amc --def $FNAMC=$ENDDIR"$FORMAT" -r -extract -rename $STARTDIR --db $DB -non-strict --def emby=$EMBYUPDATE

# cleanup remaining files.
find $STARTDIR -iname "*.txt" -delete
find $STARTDIR -iname "*.r*" -delete

sleep 2

# remove empty directories.
find $STARTDIR -empty -type d -delete
unset IFS

# done both TV Shows and Movies for this run.
done

# display Notification Center update.
/Applications/terminal-notifier.app/Contents/MacOS/terminal-notifier -title 'FileBot' -message "Completed, any found media has been organized." -appIcon "$FILEBOT"FileBot.app/Contents/Resources/filebot.icns
