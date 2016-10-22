#!/bin/sh
# version 2.5.6 *REQUIREMENTS BELOW*
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
TVFORMAT="{n}/Season {s.pad(2)}/{S00E00} {t}" #default sorts: Series Name/Season #/S##E## Title
TVDB="thetvdb"
#TVDB="TVmaze"

# path to your unsorted Movies
MOVIES="/Volumes/Drobo/Media Center/Unsorted-Movies/"

# path to your sorted Movies
MOVIESSORT="/Volumes/Drobo/Media Center/Movies/"

# format for your Movies title/year & what database to use.
MOVIEFORMAT="{n} ({y})" #default sorts: Movie Name (year)
MOVIEDB="themoviedb"

# path to your Volume's Trash ("501" is my UUID, yours may be different!) Find with:
# dscl . -read /Users/YOURUSERNAME/ UniqueID
VOLTRASH="/Volumes/Drobo/.Trashes/501/"

# IP or Hostname to Emby & your api key generated within Emby. Set to 0 to not use.
EMBYHOST="127.0.0.1"
# path to a plain text file with your emby api key.
EMBYAPI="/Volumes/Drobo/Media Center/embyapi.txt"

# *****************************

# start loop 0 for TV Shows then 1 for Movies.
xloop=0
EMBYUPDATE=""

# update Emby?
if [ "$EMBYHOST" != "0" ]; then
    IFS=$'\n'
	API=$(cat "$EMBYAPI")
	unset IFS
	EMBYUPDATE="$EMBYHOST:$API"
fi

while [ $xloop -lt 2 ]
do

# 1st loop sets for TV shows. Count files in our unsorted directory, if 0 skip & check for movies.

if [ "$xloop" -eq "0" ]; then
	IFS=$'\n'
	COUNT=`ls -1 $TVSHOWS | wc -l | tr -d ' '`
	unset IFS
	if [ "$COUNT" -eq "0" ]; then
		let xloop=$xloop+1
	else
		STARTDIR=$TVSHOWS
		ENDDIR=$TVSHOWSSORT
		FORMAT=$TVFORMAT
		DB=$TVDB
		FNAMC="seriesFormat"
		NOTIFYCENT="TV Shows"
		/Applications/terminal-notifier.app/Contents/MacOS/terminal-notifier -title 'FileBot' -message "Running filebotsortmedia script, searching for $NOTIFYCENT in $COUNT folder(s)/file(s)..." -appIcon "$FILEBOT"FileBot.app/Contents/Resources/filebot.icns
	fi
fi

# 2nd loop sets for movies. Count the files in our unsorted directory, if 0 this is the 2nd run. We can exit the script now.
if [ "$xloop" -eq "1" ]; then
	IFS=$'\n'
	COUNT=`ls -1 $MOVIES | wc -l | tr -d ' '`
	unset IFS
	if [ "$COUNT" -eq "0" ]; then
		exit 0
	else
		STARTDIR=$MOVIES
		ENDDIR=$MOVIESSORT
		FORMAT=$MOVIEFORMAT
		DB=$MOVIEDB
		FNAMC="movieFormat"
		NOTIFYCENT="Movies"
		/Applications/terminal-notifier.app/Contents/MacOS/terminal-notifier -title 'FileBot' -message "Running filebotsortmedia script, searching for $NOTIFYCENT in $COUNT folder(s)/file(s)..." -appIcon "$FILEBOT"FileBot.app/Contents/Resources/filebot.icns
	fi
fi

let xloop=$xloop+1

# current date/time for file stamping.
DATETIME=`date +%m%d-%H%M%S`

# here we set BASHs internal IFS variable so directories/filenames are not broken into new
# lines when a space is found.
IFS=$'\n'

# clean up "sample" directories, but don't delete, just move to trash to be safe.
for X in `find $STARTDIR -type d -iname "*sample*"`
do
    mv $X $VOLTRASH/$DATETIME/
done

sleep 1

# clean up "sample" files, but don't delete, just move them to trash to be safe.
for X in `find $STARTDIR -iname "*sample*"`
do
    mv $X $VOLTRASH/$DATETIME/
done

# sets finder label to Green for x265 items, red for x264
for X in `find $STARTDIR -iname "*x265*"`
do
    /usr/local/bin/setlabel Green $X
done

for X in `find $STARTDIR -iname "*x264*"`
do
    /usr/local/bin/setlabel Red $X
done

# clean up these files so they don't get moved to the show directories.
filearray=( '*.nfo' '.DS_Store' '*.srt' '*.sfv' '*.jpg' '*.idx' '*.md5' '*.url' '*.mta' '*.txt' '*.png' '*.ico' '*.xml' '*.htm' '.html' '*.web' '*.website' '*.torrent' '*.sql' '*.sql-lite' 'Thumbs.db' )

for delfile in "${filearray[@]}"
do
	find $STARTDIR -iname "$delfile" -delete
done

# delete files smaller than xMB since these are often un-named sample files.
find $STARTDIR -type f -maxdepth 2 -size -15M -iname "*.mp4" -delete
find $STARTDIR -type f -maxdepth 2 -size -9M -iname "*.mkv" -delete

# rename and move.
"$FILEBOT"Contents/MacOS/./filebot.sh -script fn:amc --def $FNAMC=$ENDDIR"$FORMAT" -r -extract -rename $STARTDIR --db $DB -non-strict --def emby=$EMBYUPDATE

# cleanup any remaining files after the run, such as rar and expanded txt files.
filearray2=( '*.txt' '*.r*' '*.part' )

for delfile in "${filearray2[@]}"
do
	find $STARTDIR -iname "$delfile" -delete
done

sleep 2

# remove empty directories.
find $STARTDIR -empty -type d -delete
unset IFS

# display Notification Center update.
/Applications/terminal-notifier.app/Contents/MacOS/terminal-notifier -title 'FileBot' -message "Completed, any found $NOTIFYCENT media has been organized." -appIcon "$FILEBOT"FileBot.app/Contents/Resources/filebot.icns

# done both TV Shows and Movies for this run.
done