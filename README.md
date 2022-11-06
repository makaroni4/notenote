[![Gem Version](https://badge.fury.io/rb/notenote.svg)](https://badge.fury.io/rb/notenote)

# Note :pencil:

`notenote` is a gem for keeping a daily log of everything.

## Setup

Install a Ruby gem:

`gem install notenote`

Initialize a folder for your follows (it'll also create a `.note` config file):

`note init %FOLDER_NAME%`

Create today's note file:

`note`

Create a custom file, it'll be automatically linked to today's note file:

`note %FILE_NAME%`

Generate a website based on all follows:

`note web`

## Development

To test changes locally run:

~~~
Y | gem uninstall notenote && gem build note.gemspec && bundle && rake build && rake install
~~~

To release a new version run:

~~~
Y | gem uninstall notenote && gem build note.gemspec && bundle && rake build && rake release
~~~

## License

This project is released under the [MIT License](https://github.com/makaroni4/notenote/blob/main/LICENSE.txt).
