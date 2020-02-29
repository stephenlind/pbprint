#!/bin/bash -e

# Requirements
# 1. pngpaste (brew install pngpaste)
# 2. sips (preinstalled on macOS)
# 3. lp (preinstalled on macOS, configured to use your default printer)

# Constants: A4 page at 300 dpi
# LONG_EDGE=3508
# SHORT_EDGE=2480
# MARGIN=300 # 0.5 inches (0.5 inches on each side, safe for all printers)
PRINTABLE_LONG_EDGE=3208 
PRINTABLE_SHORT_EDGE=2180

# copy the pasteboard to a png using pngpaste
TEMP_PNG="pbprint.pbpaste.png"
pngpaste ${TEMP_PNG}
ORIG_HEIGHT=`identify -format '%h' ${TEMP_PNG}`
ORIG_WIDTH=`identify -format '%w' ${TEMP_PNG}`

# determine portrait/landscape
if [[ ${ORIG_HEIGHT} -ge ${ORIG_WIDTH} ]]; then
	ORIENTATION="portrait"
	WIDTH=${PRINTABLE_SHORT_EDGE}
	HEIGHT=${PRINTABLE_LONG_EDGE}
	EDGE_RATIO=`bc -l <<< "${ORIG_HEIGHT} / ${ORIG_WIDTH}"`
else
	ORIENTATION="landscape"
	HEIGHT=${PRINTABLE_SHORT_EDGE}
	WIDTH=${PRINTABLE_LONG_EDGE}
	EDGE_RATIO=`bc -l <<< "${ORIG_WIDTH} / ${ORIG_HEIGHT}"`
fi

# determine proper maximum resample size for this image
MAX_EDGE_RATIO=`bc -l <<< "${PRINTABLE_LONG_EDGE} / ${PRINTABLE_SHORT_EDGE}"`
SQUARISH=`bc -l <<< "${EDGE_RATIO} < ${MAX_EDGE_RATIO}"`
if [[ ${SQUARISH} ]]; then
	# image is close enough to square that we need to use the short edge as limit
	# to maximize, multiply the short edge by the edge ratio
	ADJUSTED_EDGE=`bc -l <<< "${EDGE_RATIO} * ${PRINTABLE_SHORT_EDGE}"`
	RESAMPLE_MAX=${ADJUSTED_EDGE%.*}
else
	# more asymetric than A4, can be resampled to the long edge
	RESAMPLE_MAX=${PRINTABLE_SHORT_EDGE}	
fi	

# use sips to resize keeping aspect ratio 
echo "Using orientation: ${ORIENTATION}, resizing image to ${RESAMPLE_MAX} pixels on the longest side"
sips -Z ${RESAMPLE_MAX} -p ${HEIGHT} ${WIDTH} --padColor FFFFFF "${TEMP_PNG}"

# convert png to pdf format
TEMP_PDF="pbprint.output.pdf"
sips -s dpiWidth 300 -s dpiHeight 300 -s format pdf "${TEMP_PNG}" --out "${TEMP_PDF}" 
rm "${TEMP_PNG}"

if [[ "${1}" == "--pdf" ]]; then
	# do not print, rename
	PDF_OUT=$(uuidgen).pbprint.pdf
	mv ${TEMP_PDF} ${PDF_OUT}
	open ${PDF_OUT}
else
	echo "Printing in orientation ${ORIENTATION}"
	lp -o ${ORIENTATION} "${TEMP_PDF}"	
	rm "${TEMP_PDF}"
fi


