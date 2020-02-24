#!/bin/bash -ex

# A4 page at 300 dpi
LONG_EDGE=3508
SHORT_EDGE=2480
MARGIN=150 # 0.5 inches (0.25 on each side, safe for most printers)

# copy the pasteboard to a png
TEMP_PNG="pbprint.pbpaste.png"
pngpaste ${TEMP_PNG}
ORIG_HEIGHT=`identify -format '%h' ${TEMP_PNG}`
ORIG_WIDTH=`identify -format '%w' ${TEMP_PNG}`

# determine portrait/landscape
if [[ ${ORIG_HEIGHT} > ${ORIG_WIDTH} ]]; then
	ORIENTATION="portrait"
	WIDTH=${SHORT_EDGE}
	HEIGHT=${LONG_EDGE}
	EDGE_RATIO=`bc -l <<< "${ORIG_HEIGHT} / ${ORIG_WIDTH}"`
else
	ORIENTATION="landscape"
	HEIGHT=${SHORT_EDGE}
	WIDTH=${LONG_EDGE}
	EDGE_RATIO=`bc -l <<< "${ORIG_WIDTH} / ${ORIG_HEIGHT}"`
fi

# determine proper resample
MAX_EDGE_RATIO=`bc -l <<< "${LONG_EDGE} / ${SHORT_EDGE}"`
SQUARISH=`bc -l <<< "${EDGE_RATIO} < ${MAX_EDGE_RATIO}"`
if [[ ${SQUARISH} ]]; then
	# image is close enough to square that we need to use the short edge as limit
	# to maximize 
	ADJUSTED_EDGE=`bc -l <<< "${EDGE_RATIO} * ${SHORT_EDGE} - ${MARGIN}"`
	RESAMPLE_MAX=${ADJUSTED_EDGE%.*}
else
	RESAMPLE_MAX=$(expr ${LONG_EDGE} - ${MARGIN})	
fi	

echo "Using orientation: ${ORIENTATION}"
sips -Z ${RESAMPLE_MAX} \
-p ${HEIGHT} ${WIDTH} \
--padColor FFFFFF \
"${TEMP_PNG}"

# output to pdf
TEMP_PDF="pbprint.output.pdf"
sips -s dpiWidth 300 -s dpiHeight 300 -s format pdf "${TEMP_PNG}" --out "${TEMP_PDF}" 
rm "${TEMP_PNG}"

if [[ "${1}" == "--pdf" ]]; then
	# do not print, rename
	PDF_OUT=$(uuidgen).pbprint.pdf
	mv ${TEMP_PDF} ${PDF_OUT}
	open ${PDF_OUT}
else
	echo "printing"
	lp -o ${ORIENTATION} -o fit-to-page "${TEMP_PDF}"	
	rm "${TEMP_PDF}"
fi


