[![Gem Version](https://badge.fury.io/rb/notenote.svg)](https://badge.fury.io/rb/notenote)

# Note :pencil:

`notenote` is a gem for keeping a daily log of everything.

## Setup

Install a Ruby gem:

`gem install notenote`

Initialize a folder for your daily notes:

`note init %FOLDER_NAME%`

:warning: Note that although the name of the gem is **notenote** (**note** is already taken), the CLI command is `note` for simplicity.

I also highly encourage using aliases to save time typing. If you're using [Zsh](https://github.com/ohmyzsh/ohmyzsh), I'd recommend going 1 letter:

```
alias n="note"
alias non="note on"
alias np="note push!"
alias na="note all"
```

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

### `note`

`note` create today's note file

```bash
// 05-11-2022/today.md
```

### `note on tax return`

`note on` creates a custom note file:

```bash
// It will create a new note file in today's folder:
// 05-11-2022/tax_return.md
```

Special characters break `note on` command. If you see an error like `No matches found` in the terminal, try using quotation marks for note's name:

`note on 'How Are You Doing?'`

Push new notes to Github with a default commit message from the `.notenote` config:

### `note push`

By default, `note push` will commit and push only if there were no changes or deletions in your notes.

### `note push!`

`note push!` doesn't do any checks, it commits and pushes all your changes.

### `note pull`

`note pull` simply does `git pull --ff-only` to safely pull new notes from Github.

### `note all`

Opens note folder in your editor.

### `note version`

Prints out the current `notenote` version.

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
