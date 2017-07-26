# Gradle.vim

`Gradle.vim` is a tiny vim plugin for the using Gradle in vim. It provides the `:Gradle` command,
which dynamically sets the buffer local makeprg to the requested gradle task (executed using
`./gradlew`), runs that make command (loading any errors into the quickfix list) and then restores
the makeprg to whatever it was before.

## Usage

Assuming you're editing a buffer that's in a gradlew managed project, you can run `:Gradle <taskName>`
to run that task and load the errors into the quickfix list.

So, `:Gradle build` does the following:

1. find the first parent directory with a `gradlew` file
2. run `./gradlew build` in that directory
3. load any errors into the quickfix list

That's it.

Obviously, this only works on *nix systems.
