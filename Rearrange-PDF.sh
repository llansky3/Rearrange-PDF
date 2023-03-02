#! /bin/bash

# Input checks
if [ $# -eq 0 ]
then
    echo "Error: No arguments supplied! You must provide a PDF file to process!"
    exit 1
fi
INPUTFILE=$1
echo "REARRANGE-PDF" 
echo "Processing file:" $INPUTFILE
echo "┏━━━━━"
if [ ! -f $INPUTFILE ]
then
    echo "┣ Error: Provided PDF file doesn't exist!"
    echo "┻"
    exit 1    
fi

# Main
NPAGES=$(pdftk "$INPUTFILE" dump_data | grep NumberOfPages | sed 's/[^0-9]*//')
echo "┣ number of pages:" $NPAGES

echo -ne "┣ adding blank pages ... "
BLANKPAGES=""
for (( i=0; i<(($NPAGES%4)); i++ ))
do
    BLANKPAGES+=" blank.pdf"
done
pdftk $INPUTFILE $BLANKPAGES cat output merged.pdf
echo "done"

OUTPUTFILE="rearranged-"
OUTPUTFILE+=$(basename "$INPUTFILE" .pdf)
OUTPUTFILE+=".pdf"

echo -ne "┣ rearranging and exporting $OUTPUTFILE ... "
NPAGES=$(pdftk merged.pdf dump_data | grep NumberOfPages | sed 's/[^0-9]*//')
NLOOPS=$(($NPAGES/2))
NEWORDER=""
for (( i=0; i<$NLOOPS; i++ ))
do
    N1=$(($i*2+1))
    N2=$(($i*2+2))
    N3=$(($NPAGES-$i*2-1))
    N4=$(($NPAGES-$i*2))
    if (( $N1 > $N3 )); then
        # Stop here - all pages covered
        break;
    fi
    NEWORDER+="$N4 $N1 $N2 $N3 "
done

pdftk merged.pdf cat $NEWORDER output merged2.pdf
pdfjam merged2.pdf --nup 2x1 --suffix 2up --landscape --paper a4paper --quiet --outfile $OUTPUTFILE

echo "done"
# Clean up
rm merged.pdf
rm merged2.pdf
echo "┻" 