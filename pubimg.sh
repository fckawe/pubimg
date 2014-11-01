#!/bin/bash

# -----------------------------------------------------------------------------
# pubimg.sh (version 0.1)
# Copyright (C) 2014 Gerald Backmeister (http://mamu.backmeister.name)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
# -----------------------------------------------------------------------------
# TO RUN THIS SCRIPT...
# ... you will need to have ImageMagick installed (e.g. package imagemagick
#     on systems running ubuntu os)
# ... you will need to have ExifTool installed (e.g. package
#     libimage-exiftool-perl on systems running ubuntu os)
# ... you will need standard programs: bc and awk
# -----------------------------------------------------------------------------

TARGET_DIR=pubimg.out
TARGET_QUALITY=80
DEFAULT_TARGET_SIZE=900
TARGET_SIZE[100]=800
WATERMARK="tribe_ul.svg"
WATERMARK_SIZE=50
WATERMARK_OPACITY=30
WATERMARK_MARGIN=10
WATERMARK_POS=southeast

# get aspect ratio (multiplied with 100) of given image
# $1 = input file
# return = aspect ratio
get_aspect_ratio() {
	export img_width=$(expr $(convert "$1" -format "%[fx:w]" info:))
	export img_height=$(expr $(convert "$1" -format "%[fx:h]" info:))
	if [ "$img_width" -eq "$img_height" ]; then
		echo 100
	elif [ "$img_width" -gt "$img_height" ]; then
		awk 'BEGIN {r=sprintf("%.0f", ENVIRON["img_width"]/ENVIRON["img_height"]*100); print r}'
	else
		awk 'BEGIN {r=sprintf("%.0f", ENVIRON["img_height"]/ENVIRON["img_width"]*100); print r}'
	fi
}

# create resized copy of given image file in target directory
# $1 = input file
# $2 = target file
# return = return code of resize command
resize_image() {
	echo "  resizing image..."
	aspect_ratio=$(get_aspect_ratio "$1")
	target_size=${TARGET_SIZE[$aspect_ratio]}
	if [ -z "$target_size" ]; then
		target_size="$DEFAULT_TARGET_SIZE"
	fi
	convert "$1" -quality "$TARGET_QUALITY" -resize "$target_size" "$2" >/dev/null
}

# insert (in place) watermark in given image
# $1 = input file
# return = return code of composite command
insert_watermark() {
	echo "  adding watermark..."
	if [ -f "$WATERMARK" ]; then
		percent_size=$(echo "$WATERMARK_SIZE * 100 / $aspect_ratio" | bc -l)
		percent_size=$(echo "$percent_size + 6*(($WATERMARK_SIZE - $percent_size)*.1)" | bc -l)
		size=$(identify -format %[fx:w*$percent_size/100] "$1")
		composite -blend "$WATERMARK_OPACITY" -bordercolor transparent -border "$WATERMARK_MARGIN" -gravity "$WATERMARK_POS" -background none \( "$WATERMARK" -geometry "$size" \) "$1" "$1"
	else
		echo "  watermark file '$WATERMARK' not found!" >&2
		return 1
	fi
}

# remove (in place) all exif data of given image file
# $1 = input file
# return = return code of remove command
remove_exif_data() {
	echo "  removing exif data..."
	exiftool -overwrite_original_in_place -all= "$1" >/dev/null
}

for input in $*; do
	if [ -d "$input" ]; then
		echo "skipping directory '$input'"
	elif [ ! -f "$input" ]; then
		echo "file not found: '$input'"
	elif [[ ! $(file -ib "$input") == image/jpeg* ]]; then
		echo "skipping non-jpeg file '$input'"
	else
		echo "processing input file '$input'"

		# ensure that target directory exists
		if [ ! -d "$TARGET_DIR" ]; then
			if ! mkdir -p $TARGET_DIR; then
				echo "error creating target directory '$TARGET_DIR'" >&2
				exit 1
			fi
		fi

		target_file="$TARGET_DIR"/$(basename "$input")

		# resize image
		if ! resize_image "$input" "$target_file"; then
			echo "error while resizing image! (file: '$input')" >&2
		fi

		# insert watermark
		if ! insert_watermark "$target_file"; then
			echo "error while inserting watermark! (file: '$target_file')" >&2
		fi

		# remove exif data
		if ! remove_exif_data "$target_file"; then
			echo "error while removing exif data! (file: '$target_file')" >&2
		fi
	fi
done
