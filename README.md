# atokplugin

atokplugin helps you to development ATOK Direct Plugin.

## Limitation

atokplugin only tested on OSX Mavericks, ATOK 2013, Ruby 2.0+.

## Installation

atokplugin requires ATOK Direct Plugin module.
Please download from http://www.atok.com/useful/developer/api/
and set its path to ATOK_TOOLS_ROOT environement variable.

    # example
    $ export ATOK_TOOLS_ROOT=/path/to/adsapi26

And install atokplugin by git

    $ git clone https://github.com/labocho/atokplugin.git
    $ cd atokplugin
    $ rake install

## Tutorial

`atokplugin new PLUGIN_NAME` makes plugin project directory named `PLUGIN_NAME`
Optional `--lang` flag with `ruby`, `python`, or `perl` copies sample written by specified language.

    $ atokplugin new foo --lang python
    Create plugin directory: foo
    Copy plugin template: foo/foo.py
    Create: foo/LICENSE.TXT
    Create: foo/atokplugin.yml
    Create: foo/.gitignore
    $ cd foo
    $ tree -a
    .
    ├── .gitignore
    ├── LICENSE.TXT
    ├── atokplugin.yml
    └── foo.py

`atokplugin debug` on project directory launches debugger.

    $ atokplugin debug
    Create temporary directory: /path/to/tmpdir
    Launch debugger

`atokplugin build` on project directory builds plugin to `./pkg`.

    $ atokplugin build
    Remove directory: pkg
    Create directory: pkg
    Build succeeded
    $ tree pkg
    pkg
    ├── DATA
    │   ├── foo.py
    │   └── foo.xml
    ├── LICENSE.TXT
    ├── SETUPINFO.XML
    └── atok_plugin_installer.app
    ...

`atokplugin install` on project directory builds plugin and launches installer.

    $ atokplugin install
    Remove directory: pkg
    Create directory: pkg
    Build succeeded
    Launch installer

## Contributing

1. Fork it ( http://github.com/<my-github-username>/atokplugin/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
