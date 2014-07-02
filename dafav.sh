#!/bin/sh

# GPLv3
# script to dowload favourite images from deviantart.com
# nail{@}nodomain{.}sk
#
# usage:
# ./dafav.sh username password download_folder
# defaults:
# script ask for username and password and download folder is set to ~/Pictures/DeviantArt/Favourites
#

cookie=`mktemp`
if [ $3 ]
then
outputdir=$3
else
outputdir=~/Pictures/DeviantArt/Favourites
fi

mkdir -p $outputdir

if [ $1 ]
then
username=$1
else
read -p "DA Username: " username
fi

if [ $2 ]
then
password=$2
else
stty -echo 
read -p "Password for user $user: " password;echo
stty echo
fi

curl -s -c $cookie -d password=$password -d username=$username -d reusetoken=1 https://www.deviantart.com/users/login
favs=`curl -s -b $cookie http://$username.deviantart.com/|grep \<\/strong\>Favourites|sed 's/.*<strong>\([0-9 ]*\)<\/strong>.*/\1/'|sed 's/\ //g'`
for i in `seq 0 24 $favs`
do
arts=`curl -s -b $cookie "http://backend.deviantart.com/rss.xml?q=favby%3A$username&type=deviation&offset=$i"|grep \<link\>|sed 's/.*<link>\(.*\)<\/link>.*/\1/'|grep \/art\/`

for art in $arts
do
picurl=`curl -s -b $cookie $art |grep class=\"fullview|sed 's/.*src="\(.*\)".*/\1/'|cut -d\" -f1`
filename=`echo $picurl|sed 's/.*\/\(.*\)\..../\1/'`
echo $filename
ext=`echo $picurl|sed 's/.*\.\([jpng]*\)/\1/'`
file=$outputdir/$filename.$ext
if [ ! -e $file ]
then
wget -v $picurl -P $outputdir
fi
done
done

rm $cookie
