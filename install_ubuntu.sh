#!/bin/bash

INSTALL_DIR="/usr/share/lua/5.1"
WIKI_DIR="/var/www/wiki-data"
CGI_DIR="/usr/lib/cgi-bin/"
USER="www-data"

# First, install all dependencies
if [ $# -gt 1 ] && [ $1 == "dep" ]; then
	apt-get install liblua5.1-cosmo0 liblua5.1-cospcall0 liblua5.1-filesystem0 \
		liblua5.1-logging liblua5.1-lpeg2 liblua5.1-markdown0 \
		liblua5.1-md5-0 liblua5.1-socket2 liblua5.1-sql-sqlite3-2 liblua5.1-wsapi1

	cd /tmp/
	git clone https://github.com/yuri/lua-diff lua-diff
	git clone https://github.com/yuri/lua-xssfilter lua-xssfilter
	git clone https://github.com/yuri/lua-colors lua-colors

	echo "Installing diff..."
	cp -r /tmp/lua-diff/lua/* $INSTALL_DIR
	echo "Installing xssfilter..."
	cp -r /tmp/lua-xssfilter/lua/* $INSTALL_DIR
	echo "Installing colors..."
	cp -r /tmp/lua-colors/lua/* $INSTALL_DIR
fi

# Install sputnik code
echo "Installing sputnik..."
cp -r ./sputnik/lua/* $INSTALL_DIR
echo "Installing saci..."
cp -r ./saci/lua/* $INSTALL_DIR
echo "Installing versium..."
cp -r ./versium/lua/* $INSTALL_DIR
echo "Installing versium-git..."
cp -r ./versium-git/lua/* $INSTALL_DIR

## Setup the wiki data directory
#echo "Creating wiki data directory $WIKI_DIR"
#mkdir $WIKI_DIR
#chmod u+rw $WIKI_DIR
#chown $USER:$USER $WIKI_DIR
#
## Generate the cgi file and move it to cgi-bin folder
#./sputnik/sputnik/bin/sputnik.lua make-cgi
#rm sputnik.ws
#mv sputnik.cgi $CGI_DIR/
#chown www-data:www-data $CGI_DIR/sputnik.cgi
#chmod ug+x $CGI_DIR/sputnik.cgi

echo "------------------------------------------------"
echo "To enable git modify sputnik.cgi adding:"
echo "    VERSIUM_STORAGE_MODULE = \"versium.git\","
echo "    ..."
echo "    require\"lfs\""
echo "    lfs.chdir(\"$WIKI_DIR\")"
