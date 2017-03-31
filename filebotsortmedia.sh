#!/bin/sh
# version 2.7.3 *REQUIREMENTS BELOW*
#
# 1. Working Homebrew installed.
# 2. Homebrew: brew tap caskroom/cask
# 3. Homebrew: brew install terminal-notifier
# 4. Homebrew: brew cask install filebot --force --appdir=/Applications
# 5. Homebrew: brew install osxutils
# 6. Java JRE or SDK version 8 or greater.
#
# Note: you may have to symlink /usr/local/Cellar/terminal-notifier/1.6.3/terminal-notifier.app
# to /Applications/terminal-notifier.app
#
# This script will do several things in this order:
# 1. It will clean-up extra files downloaded that are not needed, removing them first so
# that they do not end up in your sorted directories.
# 2. Next, it runs Filebot and sorts the file into the proper dir.
# 3. It cleans-up common "extra files" left behind, as well as any empty directories. You
# still may have to clean up a few things now and then, but it is better than a full rm of
# everything. I add items I discover to successive versions.
# 4. Displays a Notification Center item when it has finished, you can comment this out in
# the script if you do not want it to show.
# 5. Set a Finder Label to Green for x265 or Red for x264 files if file is properly tagged.
# 
# It shouldn't be a problem to have both your unsorted TV Shows and Movies in the same
# directory, but you run the risk mis-matching names. If your torrent client has options
# for rules, you can set it so that your TV Show names are moved to a separate directory
# for processing, leaving the default download location for movies.

# *** SET YOUR OPTIONS HERE ***
# path to Filebot binary (usually /Applications/ for the app and possibly ~/Applications if using
# homebrew cask. If in ~/Applications you can move it to /Applications if you like or link
# directly to the install location eg: /usr/local/Caskroom/filebot/4.7.8/FileBot.app/ )
FILEBOT="/Applications/FileBot.app/"

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

# *****************************

# start loop 0 for TV Shows then 1 for Movies.
xloop=0

while [ $xloop -lt 2 ]
do

# 1st loop sets for TV shows. Count files in our unsorted directory, if 0 skip & check for movies.

if [ "$xloop" -eq "0" ]; then
	IFS=$'\n'
	COUNTTV=$(ls -1 $TVSHOWS | wc -l | tr -d ' ')
	unset IFS
	if [ "$COUNTTV" -eq "0" ]; then
		let xloop=$xloop+1
	else
		STARTDIR=$TVSHOWS
		ENDDIR=$TVSHOWSSORT
		FORMAT=$TVFORMAT
		DB=$TVDB
		FNAMC="seriesFormat"
		NOTIFYCENT="TV Shows"
		/Applications/terminal-notifier.app/Contents/MacOS/terminal-notifier -title 'FileBot' -message "Running filebotsortmedia script, searching for $NOTIFYCENT in $COUNTTV folder(s)/file(s)..." -appIcon "$FILEBOT"Contents/Resources/filebot.icns
	fi
fi

# 2nd loop sets for movies. Count the files in our unsorted directory, if 0 this is the 2nd run. We can exit the script now.
if [ "$xloop" -eq "1" ]; then
	IFS=$'\n'
	COUNTMOV=$(ls -1 $MOVIES | wc -l | tr -d ' ')
	unset IFS
	if [ "$COUNTMOV" -eq "0" ]; then
		exit 0
	else
		STARTDIR=$MOVIES
		ENDDIR=$MOVIESSORT
		FORMAT=$MOVIEFORMAT
		DB=$MOVIEDB
		FNAMC="movieFormat"
		NOTIFYCENT="Movies"
		/Applications/terminal-notifier.app/Contents/MacOS/terminal-notifier -title 'FileBot' -message "Running filebotsortmedia script, searching for $NOTIFYCENT in $COUNTMOV folder(s)/file(s)..." -appIcon "$FILEBOT"Contents/Resources/filebot.icns
	fi
fi

let xloop=$xloop+1

# here we set BASHs internal IFS variable so directories/filenames are not broken into new
# lines when a space is found.
IFS=$'\n'

# sets finder label to Green for x265 items, red for x264
for X in $(find $STARTDIR -iname "*x265*")
do
    /usr/local/bin/setlabel Green $X
done

for X in $(find $STARTDIR -iname "*x264*")
do
    /usr/local/bin/setlabel Red $X
done

# clean up these files so they don't get moved to the show directories.
filearray=( '*.nfo' '.DS_Store' '*.srt' '*.sfv' '*.jpg' '*.idx' '*.md5' '*.url' '*.mta' '*.txt' '*.png' '*.ico' '*.xml' '*.htm' '.html' '*.web' '*.lnk' '*.website' '*.torrent' '*.sql' '*.sql-lite' 'Thumbs.db' '*.json' )

for delfile in "${filearray[@]}"
do
	find $STARTDIR -iname "$delfile" -delete
done

# delete files smaller than xMB since these are often un-named sample files.
filearray3=( '*.mp4' '*.mkv' '*.avi' )

for delfile in "${filearray3[@]}"
do
	find $STARTDIR -type f -maxdepth 4 -size -15M -iname "$delfile" -delete
done

# rename and move.
"$FILEBOT"Contents/MacOS/./filebot.sh -script fn:amc --def $FNAMC=$ENDDIR"$FORMAT" --conflict auto -r -extract -rename $STARTDIR --db $DB -non-strict

# cleanup any remaining files after the run, such as rar and expanded txt files.
filearray2=( '*.txt' '*.r*' '*.part' '*.ass' )

for delfile in "${filearray2[@]}"
do
	find $STARTDIR -iname "$delfile" -delete
done

sleep 2

# remove empty directories.
cd $STARTDIR
find . -empty -type d -delete
# featurettes clean up.
find . -name "Featurettes" -type d -exec rm -r {} +
unset IFS

# done both TV Shows and Movies for this run.
done

# display Notification Center update.
let COUNT=$COUNTTV+COUNTMOV
HAVEHAS="items have"

if [ "$xloop" -eq "1" ]; then
	HAVEHAS="item has"
fi

/Applications/terminal-notifier.app/Contents/MacOS/terminal-notifier -title 'FileBot' -message "Completed, $COUNT media $HAVEHAS been organized." -appIcon "$FILEBOT"Contents/Resources/filebot.icns
