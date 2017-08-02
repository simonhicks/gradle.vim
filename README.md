# Gradle.vim

`Gradle.vim` is a vim plugin which provides a bunch of useful stuff for gradlew based java projects
in vim. It provides:

- A way to run gradle commands from vim, loading errors into the quickfix list so you can quickly
  jump between compile/checkstyle errors
- Simplified tag management for all the classes on the classpath
- Quick javadoc lookup for all the classes on the classpath
- An import-specific auto-complete function, so you can do your import statements without having to
  remember where every single class lives.

## `:Gradle`

Assuming you're editing a buffer that's in a gradlew managed project, you can run `:Gradle <taskName>`
to run that task and load the errors into the quickfix list.

So, `:Gradle build` does the following:

1. find the first parent directory with a `gradlew` file
2. run `./gradlew build` in that directory
3. load any errors into the quickfix list

It's basically just a wrapper around the builtin `:make` command, which adds some redirects and
directory shuffling to make it work in a way that feels natural for gradle.

After running `:Gradle <taskname>` once, you can run the same command without giving it a task and
it will default to using the same task as the last one you ran in that project.

## `:GenerateTags`

Running `:GenerateTags` will use the `./gradlew` script at the root of your gradle project to
calculate the classpath, fetch all the relevant source and javadocs, and index the source (both
your project source and the downloaded dependency source) using ctags (depends on exuberant ctags).
It will store all this in `<project-root>/.vimproject`.

## `:Javadoc`

Once you've run `:GenerateTags`, you can run `:Javadoc <fully-qualified-class-name>` to open the
relevant javadoc file in a browser. This has tab completion set up so it'll tab complete based on
a regex match, so `:Javadoc ^j.*ArrayL` will tab complete to `:Javadoc java.util.ArrayList`. 

By default, it will use the command `open` to load the javadoc in a browser, however you can
customise this by setting `g:gradleVimBrowser`.

The javadoc that is loaded comes from a cached version on disk, so `:Javadoc` works fine offline as
long as you've run `:GenerateTags` at some point previously.

## imports

This plugin will also add an insert mode mapping which will autocomplete from a class name to an
import statement. You can configure this by setting `g:gradleVimImportCompleteMapping` (defaults to
`"<C-f>"`.

Note, this autocomplete will try to match the **full line** against the fully qualified class name.
So this:

```
j.*u.*ArrayL
```

will autocomplete to

```
import java.util.ArrayList;
```

however the same thing starting with an import statement:

```
import j.*u.*ArrayL
```

will fail to match (because the class name doesn't include the word "import").

## WARNING: Your mileage may vary!

This plugin is based on an unspeakably hacky hack which allows it to inject a custom gradle task
without modifying anything in the gradle project itself (check out `bin/gradleww` if you like that
sort of thing). It works for me on all the gradle based projects I've tried at my employer (which is
the only place I use gradle), but there may well be some assumptions about the conventions we use
that I've baked in without realising they're there. I'm not a gradle expert by any stretch of the
imagination.

## Known limitations

Obviously, this only works on *nix systems. Aside from that, there are a couple of assumptions:

- It depends on real ctags (aka. exuberant-ctags). If you're using a mac, and haven't explicitly
  installed that version, you have a very limited mac specific version of ctags which doesn't have
the necessary features to work with this plugin. You can install exuberant-ctags using `brew`

- It depends on an `unzip` command. I'm not sure if that's installed by default on a mac, because I
  don't have a mac to test with.

