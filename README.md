# pbprint
`pbprint` uses the image in your clipboard (pasteboard), resizes it to be as large as possible on an A4 page, and then prints it using your default printer.

## Requirements

Requires `pngpaste` and `identify` (imagemagick)

`pngpaste` is a tool for creating a png file out of the current copied item in your clipboard. 

`imagemagick` is a tool for manipulating images from the command line. 

The easist wayto install these is using [Homebrew](https://brew.sh/).

`brew install pngpaste`

`brew install imagemagick`

Make sure `pngpaste` is in your `PATH`

## Usage

1. Copy an image to your clipboard
2. Run `pbprint.sh`

Without any arguments, this will resize the image to the clipboard to maximize it on an a4 page, and then print it using your default printer (via `lp`).

`pbprint.sh --pdf` allows you to perform a dry-run by creating and open a pdf of the output so you can examine it before printing.

## Motivation

This script was written to automate the printing of coloring pages for kids. If you perform a [google image search](https://www.google.com/search?tbm=isch&q=coloring+pages+butterfly) for "coloring pages something_kid_likes", you will get lots of great pictures, which can be copied to the clipboard. `pbprint.sh` makes the re-sizing and printing part much faster.


