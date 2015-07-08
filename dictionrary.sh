#!/bin/bash

#idea borrowed and modified from here:
#https://synacl.wordpress.com/2012/02/10/using-john-the-ripper-to-crack-a-password-protected-rar-archive/

echo "DictionRARy v0.0.1 by @ericrallen";

#check for correct options
if [ $# -ne 2 ]; then
	echo -e "\nUsage:  $0 <rarfile> <wordlist>";
	exit;
fi

#default status code for rar error
STATUS=3

#display rar info
unrar l $1

#iterate over dictionary
while read line

do
	#if we haven't found the right password yet, keep going
	if [ $STATUS -ne 0 ]; then

		#if this line isn't a comment (format taken from John the Ripper WordList comments which start with #!comment:)
		if [[ ! $line =~ \#\!comment\:.* ]]; then

			#if this line is a string of some length
			if [ ! -z $line ]; then

				#clear our the text from our previous try (this is a hack that could be done better)
				printf "\rtrying:                           "

				#print the current try to the screen
				printf "\rtrying: \"%-${COLUMNS}s\"" "$line"

				#check the password by testing the integrity of the rar, which will require the password
				#this means we won't continually be trying to extract the information and the user can decide how they want to unrar the file
				unrar t -y -p$line -inul $1 > /dev/null;

				#check the status of the unrar
				STATUS=$?

				#if we have the right password, STATUS should be 0
				if [ $STATUS -eq 0 ]; then
					#display correct password
					echo -e "\rArchive password is: \"$line\""

					#exit loop
					break;

				fi

			fi

		fi

	#if we have already found the password, exit the loop
	else
		exit;
	fi

done < $2

if [ ! $STATUS -eq 0 ]; then
	echo -e "\rArchive password not found in word list.";
fi
