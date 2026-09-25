# WordNet.app

This application provides a graphical interface for the WordNet lexical database of English and is very similar to the X Window System client that is part of the WordNet distribution; except it looks much nicer on Mac OS X! Note that it does not query any of the online versions of WordNet but uses a local copy of the dictionary files.

For latest news, updates, and other information visit [www.mulle-kybernetik.com/software/WordNet/](https://www.mulle-kybernetik.com/software/WordNet)

## Build

On macOS with the Xcode Command Line Tools installed, run `./build-app.sh`.
The self-contained `build/WordNet.app` bundle includes the local WordNet
database. Open it with `open build/WordNet.app`.

## Install

Run `./build-installer-app.sh` to create the clickable
`build/WordNet Installer.app`. Open it and select **Install WordNet** to install
the bundled app in `~/Applications`; use **Open WordNet** when installation
finishes. This does not require administrator privileges. The existing
`./install-app.sh` script remains available for command-line installation.

Have fun,

  Marcus & Erik
