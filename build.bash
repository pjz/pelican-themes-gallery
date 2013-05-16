

# install a fresh instance of pelican
PELICAN=/tmp/pelican-base.$$
virtualenv $PELICAN
. ${PELICAN}/bin/activate
pip install pelican

DESTDIR=/tmp/dest.$$

# check out the current themes repo
THEMES=/tmp/pelican-themes.$$
THEMELINKBASE=http://github.com/getpelican/pelican-themes/tree/master/
git clone git://github.com/getpelican/pelican-themes.git "$THEMES"
( cd $THEMES ; git submodule update --recursive )

INDEX="${DESTDIR}/index.html"
mkdir $DESTDIR

for theme in $THEMES/* ; do
    if [ -d "$theme" ]; then
	name=`basename "$theme"`
	themedest="${DESTDIR}/$name"
	mkdir "$themedest"
	themeconf="/tmp/pelican-theme-${name}.py"
	cp ipsumconf.py "$themeconf"
	echo "SITEURL=\"${SITEURL}\"" >> "$themeconf"
	${PELICAN}/bin/pelican -t $theme -o "$themedest" -s "$themeconf" content
	echo "<h1><a href=\"${name}\">${name}</a> - <a href=\"${THEMELINKBASE}${name}\">source</a></h1>" >>${INDEX}
        echo "<hr />" >>${INDEX}
        rm $themeconf
    fi
done

