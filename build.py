#!/usr/bin/python

import os
import shutil
import contextlib
from fabricate import run, shell, autoclean, main

SITEURL="http://pelican-themes-gallery.place.org/"
PEL_BASE='pelican-base'
THEMES="themes"
THEMES_URL="git://github.com/getpelican/pelican-themes.git"
THEMELINKBASE="http://github.com/getpelican/pelican-themes/tree/master/"
DESTDIR="meta-out"

def debug_noop(*args):
    pass

def debug_stdout(arg):
    print arg()

debug = debug_stdout

# random utility
@contextlib.contextmanager  
def chdir(dirname=None):  
    curdir = os.getcwd()  
    try:  
        if dirname is not None:  
            os.chdir(dirname)  
        yield  
    finally:  
        os.chdir(curdir)

# real work starts here

def _pelcmd(cmd):
    return os.path.join(PEL_BASE, "bin", cmd)

def pelican():
    debug(lambda: "Installing pelican")
    if os.path.exists(PEL_BASE): return
    run('virtualenv', PEL_BASE)
    for package in [ 'Jinja2==2.6', 'pelican', 'webassets', 'cssmin' ]:
        run(_pelcmd('pip'), 'install', package)

def clean_pelican():
    debug(lambda: "Cleaning pelican")
    shell("rm", "-rf", PEL_BASE)

def _sub_repo(name, url):
    debug(lambda: "Updating themes")
    if not os.path.exists(name):
        run("git", "clone", url, name)
    with chdir(name):
        shell("git", "pull")
        shell("git", "submodule", "update", "--init", "--recursive")

def _clean_sub_repo(name):
    debug(lambda: "Cleaning " + name)
    shell("rm", "-rf", name)

def themes():
    _sub_repo(THEMES, THEMES_URL)

def clean_themes():
    _clean_sub_repo(THEMES)

def plugins():
    _sub_repo('plugins', 'git://github.com/getpelican/pelican-plugins.git')

def clean_plugins():
    _clean_sub_repo('plugins')


def build():
    pelican()
    themes()
    plugins()
    debug(lambda: "Building index and blogs")
    if not os.path.isdir(DESTDIR): os.mkdir(DESTDIR)
    indexfilename = os.path.join(DESTDIR, "index.html")
    with open(indexfilename, "w") as indexfile:
        for name in os.listdir(THEMES):
            if name in [ ".git" ]: continue
            path = os.path.join(THEMES, name)
            if os.path.isdir(path):
                dest_theme = os.path.join(DESTDIR, name)
                if os.path.isdir(dest_theme): continue
                conf_file = os.path.join(THEMES, "configure-theme-" + name + ".py")
                shutil.copyfile("ipsumconf.py", conf_file)
                with open(conf_file, "a") as conf:
                    conf.write('SITEURL="' + SITEURL + name + '"\n')
                    if name == 'syte':
                        conf.write('PLUGIN_PATH="plugins"\n')
                        conf.write('PLUGINS=["assets"]\n')
                os.mkdir(dest_theme)
                run(_pelcmd('pelican'), '-t', path, '-o', dest_theme, '-s', conf_file, 'content')
                indexfile.write('<h1><a href="' + name + '">' + name + '</a>')
                indexfile.write(' - <a href="' + THEMELINKBASE + name + '">source</a></h1>\n')
		theme_screenshot = os.path.join(THEMES, name, "screenshot.png")
                if os.path.exists(theme_screenshot):
                    indexfile.write('<img src="' + name + '/screenshot.png">\n')
		    run('cp', theme_screenshot, dest_theme)
                indexfile.write('<hr />\n')


def clean_build():
    debug(lambda: "Cleaning index and blogs")
    shell("rm", "-rf", DESTDIR)


def clean():
    autoclean()
    clean_build()
    clean_themes()
    clean_pelican()


main()

