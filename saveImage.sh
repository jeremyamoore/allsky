#!/bin/bash
source /home/pi/allsky/config.sh

# Make a directory to store current night images
mkdir -p images/current;

# Subtract dark frame
convert "$FULL_FILENAME" "$DARK_FRAME" -compose minus_src -composite "$FILENAME-clean.$EXTENSION";

# Save image in "current" directory
cp "$FILENAME-clean.$EXTENSION" "images/current/$FILENAME-$(date +'%Y%m%d%H%M%S').$EXTENSION";

echo -e "Saving $FILENAME-$(date +'%Y%m%d%H%M%S').$EXTENSION\n" >> log.txt

# If upload is true, create a smaller version of the image and upload it
if [ "$UPLOAD_IMG" = true ] ; then
	echo -e "Resizing\n"
	echo -e "Resizing $FULL_FILENAME\n" >> log.txt

	# Create a thumbnail for live view
	# Here's what I use with my ASI224MC
	convert "$FILENAME-clean.$EXTENSION" -resize 962x720 -gravity East -chop 2x0 "$FILENAME-resize.$EXTENSION";
	# Here's what I use with my ASI185MC (larger sensor so I crop the black around the image)
	#convert "$FILENAME-clean.$EXTENSION" -resize 962x720 -gravity Center -crop 680x720+40+0 +repage "$FILENAME-resize.$EXTENSION";

	echo -e "Uploading\n"
	echo -e "Uploading $FILENAME-resize.$EXTENSION\n" >> log.txt
	lftp "$PROTOCOL"://"$USER":"$PASSWORD"@"$HOST":"$IMGDIR" -e "set net:max-retries 1; set net:timeout 20; put $FILENAME-resize.$EXTENSION; bye" &
fi

