#!/usr/bin/env bash
# version 2.8.3 *REQUIREMENTS BELOW*
#
# 1. Working Homebrew installed.
# 2. Homebrew: brew tap caskroom/cask
# 3. Homebrew: brew install terminal-notifier
# 4. Homebrew: brew cask install filebot --force --appdir=/Applications
# 5. Homebrew: brew install tag
# 6. Homebrew: brew install detox
# 7. Java JRE or SDK version 8 or greater.
#
# Note: you may have to symlink /usr/local/Cellar/terminal-notifier/1.6.3/terminal-notifier.app
# to /Applications/terminal-notifier.app
#
# Most app path options below can be left as is since they are the default install locations for
# homebrew. Modify only if you installed in a custom location or didn't use homebrew.
#
# This script will do several things in this order:
# 1. It will clean-up extra files downloaded that are not needed, removing them first so
# that they do not end up in your sorted directories.
# 2. Next, it runs Filebot and sorts the file into the proper dir.
# 3. It cleans-up common "extra files" left behind, as well as any empty directories. You
# still may have to clean up a few things now and then, but it is better than a full rm of
# everything. I add items I discover to successive versions.
# 4. Displays a Notification Center item when it has finished.
# 5. Set a Finder Label to Green for x265, Red for x264, or Orange for xvid to files if the
# downloaded file is properly tagged.
# 
# It shouldn't be a problem to have both your unsorted TV Shows and Movies in the same
# directory, but you run the risk mis-matching names. If your torrent client has options
# for rules, you can set it so that your TV Show names are moved to a separate directory
# for processing, leaving the default download location for movies.

# SET YOUR OPTIONS HERE -------------------------------------------------------------------------
# path to Filebot binary, usually /Applications/ for the app and possibly ~/Applications if using
# homebrew cask. If in ~/Applications you can move it to /Applications if you like or link
# directly to the install location eg: /usr/local/Caskroom/filebot/4.7.8/ )
FILEBOT="/Applications/"

# path to terminal-notifier
TERMINALNOTIFIER="/usr/local/bin/"

# path to your unsorted TV Shows
TVSHOWS="/Volumes/Drobo/Media Center/Unsorted-TV Shows/"

# path to your sorted TV Shows
TVSHOWSSORT="/Volumes/Drobo/Media Center/TV Shows/"

# format for your TV show Season/Episode prefex & what database to use. Only use one database.
TVFORMAT="{n}/Season {s.pad(2)}/{S00E00} {t}" #default sorts: Series Name/Season #/S##E## Title
TVDB="thetvdb"
#TVDB="TVmaze"

# path to your unsorted Movies
MOVIES="/Volumes/Drobo/Media Center/Unsorted-Movies/"

# path to your sorted Movies
MOVIESSORT="/Volumes/Drobo/Media Center/Movies/"

# format for your Movies title/year & what database to use. Only use one database.
MOVIEFORMAT="{n} ({y})" #default sorts: Movie Name (year)
MOVIEDB="themoviedb"

# path to detox
DETOX="/usr/local/opt/detox/bin/"

#path to tag
TAG="/usr/local/bin/"

# pre-script path. Execute a script before filebotsortmedia & wait for it to complete. Leave as "" if none.
PRESCRIPT="/Users/majorsl/Scripts/GitHub/convertac3/convertac3.sh"

# -----------------------------------------------------------------------------------------------

# Execute pre-script.
if [ "$PRESCRIPT" != "" ]; then
	/bin/bash "$PRESCRIPT"
	wait
fi

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
		"$TERMINALNOTIFIER"terminal-notifier -title 'FileBot' -message "Running filebotsortmedia script, searching for $NOTIFYCENT in $COUNTTV folder(s)/file(s)..." -sender net.filebot.FileBot.Command -activate -timeout 10
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
		"$TERMINALNOTIFIER"terminal-notifier -title 'FileBot' -message "Running filebotsortmedia script, searching for $NOTIFYCENT in $COUNTMOV folder(s)/file(s)..." -sender net.filebot.FileBot.Command -activate -timeout 10
	fi
fi

let xloop=$xloop+1

# here we set BASHs internal IFS variable so directories/filenames are not broken into new lines when a space is found.
IFS=$'\n'

# use detox to get rid of non-standard ascii characters and extra spaces to help out FileBot.
"$DETOX"detox -r $STARTDIR

# sets finder label to Green for x265 items, red for x264, blue for XviD.
for X in $(find $STARTDIR -iname "*hevc*")
do
    "$TAG"tag -a Green $X
done
for X in $(find $STARTDIR -iname "*x265*")
do
    "$TAG"tag -a Green $X
done
for X in $(find $STARTDIR -iname "*x264*")
do
    "$TAG"tag -a Red $X
done
for X in $(find $STARTDIR -iname "*xvid*")
do
    "$TAG"tag -a Orange $X
done

# clean up these files so they don't get moved to the show directories.
filearray=( '*.nfo' '.DS_Store' '*.srt' '*.sfv' '*.jpg' '*.idx' '*.md5' '*.url' '*.mta' '*.txt' '*.png' '*.ico' '*.xml' '*.htm' '.html' '*.web' '*.lnk' '*.website' '*.torrent' '*.sql' '*.sql-lite' '*.sqlite' 'Thumbs.db' '*.json' )

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
"$FILEBOT"Filebot.app/Contents/MacOS/./filebot.sh -script fn:amc --def $FNAMC=$ENDDIR"$FORMAT" --conflict auto -r -extract -rename $STARTDIR --db $DB -non-strict

# cleanup any remaining files after the run, such as txt and expanded rar files.
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

"$TERMINALNOTIFIER"terminal-notifier -title 'FileBot' -message "Completed, $COUNT media $HAVEHAS been organized." -sender net.filebot.FileBot.Command -activate -timeout 10
