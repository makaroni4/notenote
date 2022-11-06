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

You can create custom note files. They'll be added to today's folder:

`note on tax return`

Sync new notes to Github:

`note sync`

Generate a website based on all notes:

`note web`

Open editor with notes folder:

`note edit`

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
