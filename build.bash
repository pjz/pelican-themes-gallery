
SITEURL="http://pelican-themes.place.org/"

# install a fresh instance of pelican
PELICAN=/tmp/pelican-base
if [ ! -d $PELICAN ]; then
virtualenv $PELICAN
. ${PELICAN}/bin/activate
pip install pelican
fi

DESTDIR=/tmp/dest.$$

# check out the current themes repo
THEMES=/tmp/pelican-themes.$$
THEMELINKBASE=http://github.com/getpelican/pelican-themes/tree/master/
git clone git://github.com/getpelican/pelican-themes.git "$THEMES"
( cd $THEMES ; git submodule update --init --recursive )

INDEX="${DESTDIR}/index.html"
mkdir $DESTDIR

for theme in $THEMES/* ; do
    if [ -d "$theme" ]; then
	name=`basename "$theme"`
	themedest="${DESTDIR}/$name"
	mkdir "$themedest"
	themeconf="/tmp/pelican-theme-${name}.py"
	cp ipsumconf.py "$themeconf"
	echo "SITEURL=\"${SITEURL}${name}\"" >> "$themeconf"
	echo "# end of conf" >>"$themeconf"
	${PELICAN}/bin/pelican -t $theme -o "$themedest" -s "$themeconf" content
	echo "<h1><a href=\"${name}\">${name}</a> - <a href=\"${THEMELINKBASE}${name}\">source</a></h1>" >>${INDEX}
        echo "<hr />" >>${INDEX}
        #rm $themeconf
    fi
done

