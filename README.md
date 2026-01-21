# Introduction

This plugin allows a library to specify an automatic search and replacement to scanned barcodes for either patrons, or items, or both using regular expressions.

#Setup

From the plugins page click 'Actions->Configure' to acces the configuration page.

The plugin takes a block of YAML with two (optional) sections - one for patrons and one for items. You specify any number of three options: search, match, and replace
Match defines a regex string that the plugin looks for to decide if the current barcode should be altered
Search defines the regex string that will be replaced
Replace defines the new regex string that will replace the above match

If a barcode does not match the 'match' expression it will not be altered

Example:
```YAML
item:
  -
    match: "^000"
    search: "^000"
    replace: ""
  -
    match: "^123"
    search: "^123"
    replace:
      BR1: "ABC"
      BR2: "DEF"
      _default: "GHI"
```

The above will find a barcode starting with three zero's and replace them with nothing, i.e. remove them from the barcode

So a scanned barcode like '0001234' would be scanned as '1234'

# Introduction to plugins

Koha’s Plugin System (available in Koha 3.12+) allows for you to add additional tools and reports to [Koha](http://koha-community.org) that are specific to your library. Plugins are installed by uploading KPZ ( Koha Plugin Zip ) packages. A KPZ file is just a zip file containing the perl files, template files, and any other files necessary to make the plugin work. Learn more about the Koha Plugin System in the [Koha 3.22 Manual](http://manual.koha-community.org/3.22/en/pluginsystem.html) or watch [Kyle’s tutorial video](http://bywatersolutions.com/2013/01/23/koha-plugin-system-coming-soon/).

# Downloading

From the [release page](https://github.com/bywatersolutions/koha-plugin-barcode-transformer/releases) you can download the relevant *.kpz file

# Installing

Koha's Plugin System allows for you to add additional tools and reports to Koha that are specific to your library. Plugins are installed by uploading KPZ ( Koha Plugin Zip ) packages. A KPZ file is just a zip file containing the perl files, template files, and any other files necessary to make the plugin work.

The plugin system needs to be turned on by a system administrator.

To set up the Koha plugin system you must first make some changes to your install.

* Change `<enable_plugins>0<enable_plugins>` to `<enable_plugins>1</enable_plugins>` in your koha-conf.xml file
* Confirm that the path to `<pluginsdir>` exists, is correct, and is writable by the web server
* Restart your webserver

Once set up is complete you will need to alter your UseKohaPlugins system preference. On the Administration page you will see the header, Plugins- choose Manage Plugins. This is where you will upload the plugin and configure it. 
