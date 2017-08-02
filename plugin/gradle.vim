if exists("g:hasLoadedGradleVim")
  finish
endif
let g:hasLoadedGradleVim = 1

let g:gradleVimTaskDefaults = {}
if !exists("g:gradleVimInitialDefaultTask")
  let g:gradleVimInitialDefaultTask = 'assemble'
endif

let g:gradleVimHome = expand("<sfile>:p:h:h")
let g:gradleVimBin = g:gradleVimHome . "/bin"
let g:gradleVimResources = g:gradleVimHome . "/resources"
let g:gradleVimBrowser = $HOME . "/local-scripts/browser"

command! -nargs=* Gradle call gradle#gradlew("<args>")
command! -nargs=0 -bang GenerateTags call gradle#generateTags(<q-bang>)
command! -nargs=1 -complete=customlist,gradle#classComplete Javadoc call gradle#showJavadoc("<args>")
