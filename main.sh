#!/bin/bash

# Current date
C_DATE=`date +%Y%m%d_%H%M%S`
# Work dir
DIR='/tmp/'$C_DATE'/'
# File which will store results
FILE=$PWD'/'$C_DATE'.lst'
touch $FILE ; 

if [ "$1" = "" ]; then
    echo "I need a URI";
    exit 1;
elif [ ! `echo $1 | egrep '(\w+\.)+[a-z]{2,4}(\/.*)*'` ]; then # TODO: Add support for IP addresses
    echo 'Malformed URI';
fi

echo "Jumping to working directory: $DIR"

mkdir $DIR && cd $DIR ;

if [ $? -ne 0 ]; then
    echo "Unable to create my working directory. Exiting.";
    exit 2;
fi

echo 'Searching for matches ...';
wget --recursive --mirror --random-wait \
    -R gif,jpg,pdf,mp3,m4a,doc,css,png,js,zip -A html,htm  $1 \
    > /dev/null 2>&1

for F in `find . -name "*.htm?"`
do
    for L in `cat $F | egrep -o '\w+\@\w+\.[a-z]{2,4}'`
    do
        grep -Fxq $L $FILE ;
        if [ $? -ne 0 ]; then echo $L >> $FILE ; fi
    done
done

echo 'Done';

echo "Returning to previous folder ... "
cd -

echo "Cleaning files ..."
rm -r $DIR;

LINES=`cat $FILE | wc -l`;
 
if [ $LINES -gt 0 ]; then
    echo "Check your results here: $FILE .";
    more $FILE;
else
    echo "No mails found."
    rm $FILE;
fi
