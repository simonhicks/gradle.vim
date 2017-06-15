# Gradle.vim

`Gradle.vim` is a tiny vim plugin for the using Gradle in vim. It provides the `:Gradle` command,
which dynamically sets the buffer local makeprg to the requested gradle task (executed using
`./gradlew`), runs that make command (loading any errors into the quickfix list) and then restores
the makeprg to whatever it was before.

## Usage

Assuming you have a `./gradlew` script in your current directory, you can run `:Gradle <taskName>`
to run that task and load the errors into the quickfix list. So, `:Gradle build` will run `./gradlew
build`.

That's it.

Obviously, this only works on *nix systems.
