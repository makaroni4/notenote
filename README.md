[![Gem Version](https://badge.fury.io/rb/notenote.svg)](https://badge.fury.io/rb/notenote)

# Note :pencil:

`notenote` is a gem for keeping a daily log of everything.

## Setup

Install a Ruby gem:

`gem install notenote`

Initialize a folder for your daily notes:

`note init %FOLDER_NAME%`

## Config

`note init` command also generates a `.notenote` config file in your home folder:

```
{
  "notes_folder": "%FOLDER_NAME%",
  "date_format": "%d-%m-%Y",
  "editor_command": "code",
  "commit_message": "Added new notes"
}

```

## Using

Create today's note file:

`note`

You can create custom note files:

```bash
note on tax return

// will create a new note file in today's folder:
// 05-11-2022/tax_return.md
```

Push new notes to Github with a default:

`note push`

Open editor with all notes:

`note all`

## Markdown

All notes are created as Markdown files. I personally like the Kramdown version:

https://kramdown.gettalong.org/quickref.html

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
