REQUIREMENTS BELOW

1. Working Homebrew installed.
2. Homebrew: brew tap caskroom/cask
3. Homebrew: brew install terminal-notifier
4. Homebrew: brew cask install filebot
5. Homebrew: brew install osxutils
6. Java SDK version 8 or greater.

# This script will do several things in this order:
# 1. it will look for any file/folder with "sample" in the name and move it to trash, pre-
# pending the date/time to the file. While not likely an file will include a name AND
# also have "sample" as an name, it's safer to put it in the trash than to out-right
# rm it.
# 2. Next, it runs Filebot and sorts the file into the proper dir.
# 3. It cleans-up common "extra files" left behind, as well as any empty directories. You
# still may have to clean up a few things now and then, but it is better than a full rm of
# everything.
# 4. Displays a Notification Center item when it has finished, you can comment this out in
# the script if you do not want it to show.
# 5. Set a Finder Label to Green for x265 or Red for x264 files if file is properly tagged.
# 
# It shouldn't be a problem to have both your unsorted TV Shows and Movies in the same
# directory, but you run the risk mis-matching names. If your torrent client has options
# for rules, you can set it so that your TV Show names are moved to a separate directory
# for processing, leaving the default download location for movies.

It shouldn't be a problem to have both your unsorted TV Shows and Movies in the same
directory, but you run the risk mis-matching names. If your torrent client has options
for rules, you can set it so that your TV Show names are moved to a separate directory
for processing, leaving the default download location for movies.
