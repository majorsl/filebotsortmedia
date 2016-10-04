#!/bin/sh
# version 2.4.4 *REQUIREMENTS BELOW*
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
# 4. The final lines (see end of script) will update your Kodi video library, and then
# clean it. You can comment out the two lines if you don't want this done.
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

# path to your unsorted Movies
MOVIES="/Volumes/Drobo/Media Center/Unsorted-Movies/"

# path to your sorted Movies
MOVIESSORT="/Volumes/Drobo/Media Center/Movies/"

# path to your Volume's Trash ("501" is my UUID, yours may be different!) Find with:
# dscl . -read /Users/YOURUSERNAME/ UniqueID
VOLTRASH="/Volumes/Drobo/.Trashes/501/"

# *****************************

/Applications/terminal-notifier.app/Contents/MacOS/terminal-notifier -title 'FileBot' -message "Running filebotsortmedia script, searching for media..." -appIcon "$FILEBOT"FileBot.app/Contents/Resources/filebot.icns

# start loop 0 for TV Shows then 1 for Movies.
xloop=0
STARTDIR=$TVSHOWS
ENDDIR=$TVSHOWSSORT
FORMAT="{n}/Season {s.pad(2)}/{S00E00} {t}"
DB="thetvdb"
#DB="TVmaze"

while [ $xloop -lt 2 ]
do

# 2nd loop sets for movies.
if [ "$xloop" -eq "1" ]; then
	STARTDIR=$MOVIES
	ENDDIR=$MOVIESSORT
	FORMAT="{n} ({y})"
	DB="themoviedb"
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
cd $FILEBOT"Contents/MacOS/"

# rename and move.
./filebot.sh -r -extract -rename $STARTDIR --format $ENDDIR"$FORMAT" --db $DB -non-strict

# cleanup remaining files.
find $STARTDIR -iname "*.txt" -delete
find $STARTDIR -iname "*.r*" -delete

sleep 2

# remove empty directories.
find $STARTDIR -empty -type d -delete
unset IFS

# done both TV Shows and Movies for this run.
done

# update Kodi library. Adjust the IP and Port for your Kodi installation. You can
# duplicate the two curl statements for multiple Kodi installs.
# /Applications/terminal-notifier.app/Contents/MacOS/terminal-notifier -title 'FileBot' -message "Updating Kodi media library..." -appIcon "$FILEBOT"FileBot.app/Contents/Resources/filebot.icns

# curl --data-binary '{ "jsonrpc": "2.0", "method": "VideoLibrary.Scan", "id": "mybash"}' -H 'content-type: application/json;' http://10.0.1.201:81/jsonrpc
# curl --data-binary '{ "jsonrpc": "2.0", "method": "VideoLibrary.Clean", "id": "mybash"}' -H 'content-type: application/json;' http://10.0.1.201:81/jsonrpc

# display Notification Center update.
/Applications/terminal-notifier.app/Contents/MacOS/terminal-notifier -title 'FileBot' -message "Completed, any found media has been organized." -appIcon "$FILEBOT"FileBot.app/Contents/Resources/filebot.icns -timeout 10
