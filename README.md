Chrome Pack 1.0.1
===========

Chrome Pack is a little Ruby script which allows you minify JS and CSS
in your chrome extension and then build this extension into *.crx file.

## Preparation

First you need to make `chrome_pack.rb` to be executable:

```
$ sudo chmod -x chrome_pack.rb
$ sudo chmod 777 chrome_pack.rb
```

Unless you do this you'll be not allowed to run Chrome Pack.
Next, when you were done, you need to configure Chrome Pack

Open `chrome_pack.rb` and find this rows:

```ruby
@ext_names = [".js", ".css"]
@needed_dirs = ["js", "css"]
```

The `@ext_names` variable consists of file extensions to be minified.
The `@needed_dirs` variable consists of dir names (in the root of your extension) where files are stored.

Change those variables as your own.
Dirs which are in `@needed_dirs` will be passed recursively.

Next you need specify path to your chrome browser:

```ruby
chrome 	= "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
```

When you're done you may run chrome_pack.rb from commandline.
I recommend you to create alias command for this

Paste this code into your `~/.bach_profile` (for Zsh users `~/.zshrc`):
```bash
alias chromepack="~/chrome_pack.rb"
```

## Usage
From your terminal run:

```bash
$ cd ~/Sites/my_extension
$ chrome_pack -n my_extension
```

You'll see base parameters (working directory, chrome version, path to extension *.pem key etc.)
then you'll see process of minification (original files will be overriden) and next Chrome Pack will
run Google Chrome extensions compiler.

If you want skip minification and just pack your extension set last attribute to true

```bash
$ chrome_pack -n my_extension -nm true
```

You can specify type of package: `*.crx` or `*.zip`

```bash
$ chrome_pack -n my_package -t zip
```

## Arguments

* `-p`  `--path`         - _(string, optional, default: current directory)_ path to extension..
* `-n`  `--name`         - _(string, required, default: nil)_ name of extension. needed for choosing right pem file and folder
* `-nm` `--not_minimize` - _(boolean, optional, default: false)_ skip minification of js/css
* `-t`  `--type`         - _(string, optional, default: "crx")_ type of packed extension

