*Requirements:*

1. Working Homebrew installed.
2. Homebrew: brew tap caskroom/cask
3. Homebrew: brew install terminal-notifier
4. Homebrew: brew cask install filebot --force --appdir=/Applications
5. Homebrew: brew install tag
6. Homebrew: brew install detox
7. Homebrew: brew install ffmpeg
8. Java JRE or SDK version 8 or greater.

Note: you may have to symlink /usr/local/Cellar/terminal-notifier/1.6.3/terminal-notifier.app
to /Applications/terminal-notifier.app

Geared towards OS X, but could easily be adapted for most *nix distros.

*This script will do several things in this order:*

1. Optionally run a script before execution. Useful to act on media first, perhaps a remux.
2. It will clean-up extra files downloaded that are not needed, removing them first so
that they do not end up in your sorted directories.
3. Next, it runs Filebot and sorts the file into the proper dir.
4. It cleans-up common "extra files" left behind, as well as any empty directories. You
still may have to clean up a few things now and then, but it is better than a full rm of
everything. I add items I discover to successive versions.
5. Displays a Notification Center item when it has finished.
6. Set a Finder Label to Green x265, Red x264, Yellow x262, Orange mpeg4, Purple all others/
legacy formats eg. xvid, wmv, etc.

It shouldn't be a problem to have both your unsorted TV Shows and Movies in the same
directory, but you run the risk mis-matching names. Best use is to have a separate location
for movies and tv shows.
