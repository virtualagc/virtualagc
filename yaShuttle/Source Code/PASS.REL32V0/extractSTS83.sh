#!/bin/bash
# This is a one-off script to extract all of the display-screen templates from
# the PDFs 'sts83-0020v1-34 - Displays and Controls', volumes 1-3, to create a 
# bunch of files v1_NNNN.pdf, v2_NNNN.pdf, v3_NNNN.pdf.  Run it in an empty
# directory containing only those three PDFs
#
# It turns out that volume 3 has no display screens in it.

# Burst the PDFs into individual pages
docDir="$HOME/Desktop/sandroid.org/public_html/apollo/Shuttle"
vol1='sts83-0020v1-34 - Displays and Controls - GNC.pdf'
vol2='STS83-0020V2-34 - Displays and Controls - SM.pdf'
#vol3='sts83-0020v3-34 - Displays and Controls Appendices.pdf'
echo Bursting Volume 1 ...
pdftk "$docDir/$vol1" burst output v1_%04d.pdf
echo Bursting Volume 2 ...
pdftk "$docDir/$vol2" burst output v2_%04d.pdf
echo Skipping Volume 3.
#pdftdk "$docDir/$vol3"" burst output v3_%04d.pdf

# Process volume 1
v1="0159 0160 0173 0191 0203 0213 0224 0225 0243 0259 0260 0279 0280 0291"
v1=" $v1 0292 0303 0304 0315 0316 0335 0336 0353 0354 0369 0424 0425 0426"
v1=" $v1 0427 0428 0485 0533 0534 0557 0576 0577 0607 0631 0649 0661 0675"
v1=" $v1 0703 0721 0745 0783 0805 0829 0859 0883 0907 0957 0995 1013 1037"
v1=" $v1 1063 1084 1085 1086 1087 1128 1129"
for page in $v1
do
        base=v1_$page
        echo "Extracting $base.pdf -> $base.txt"
        crop=
        # Some exceptions where autocrop doesn't work right for some reason.
        if [[ $page == 0203 ]]
        then
                crop="--crop=368,1709,333,1254,2112,1632"
        elif [[ $page == 0424 ]]
        then
                crop="--crop=327,1738,284,1251,2112,1632"
        elif [[ $page == 0428 ]]
        then
                crop="--crop=327,1738,236,1206,2112,1632"
        fi
        extractSTS83.py $base.pdf $crop >$base.txt
done

# Process volume 2
v2="0039 0057 0075 0097 0113 0129 0141 0153 0167 0179 0191 0203 0213 0231"
v2=" $v2 0249 0283 0310 0311 0329 0345 0361 0369 0388 0404 0405 0417 0427"
v2=" $v2 0445 0465 0495 0511 0519 0537"
for page in $v2
do
        base=v2_$page
        echo "Extracting $base.pdf -> $base.txt"
        crop=
        # Some exceptions where autocrop doesn't work right for some reason.
        if [[ $page == 0283 ]]
        then
                crop="--crop=382,1762,338,1287,2112,1632"
        fi
        extractSTS83.py $base.pdf $crop >$base.txt
done


