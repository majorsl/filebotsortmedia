REQUIREMENTS BELOW

1. Working Homebrew installed.
2. Homebrew: brew tap caskroom/cask
3. Homebrew: brew install terminal-notifier
4. Homebrew: brew cask install filebot
5. Homebrew: brew install osxutils
6. Java SDK version 8 or greater.

This script will do several things in this order:
1. It will clean-up extra files downloaded that are not needed, removing them first so that they do not end up in your sorted directories.
2. Next, it runs Filebot and sorts the file into the proper dir.
3. It cleans-up common "extra files" left behind, as well as any empty directories. You still may have to clean up a few things now and then, but it is better than a full rm of everything. I add items I discover to successive versions.
4. Displays a Notification Center item when it has finished.
5. Set a Finder Label to Green for x265, Red for x264, or Blue for xvid to files if the downloaded file is properly tagged.

It shouldn't be a problem to have both your unsorted TV Shows and Movies in the same
directory, but you run the risk mis-matching names. If your torrent client has options
for rules, you can set it so that your TV Show names are moved to a separate directory
for processing, leaving the default download location for movies.
