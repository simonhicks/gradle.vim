if exists("g:hasLoadedGradleVim")
  finish
endif
let g:hasLoadedGradleVim = 1
let g:gradleVimTaskDefaults = {}

if !exists("g:gradleVimInitialDefaultTask")
  let g:gradleVimInitialDefaultTask = 'assemble'
endif

" TODO
" - check for show#show() and throw if missing
" - set gradle_root once in an initializeBuffer function
" - move all of this crap into autoload
" - move java specific things into ftplugin
" - maybe don't do all the long running crap if it's already there?

let g:gradleVimHome = expand("<sfile>:p:h:h")
let g:gradleVimBin = g:gradleVimHome . "/bin"
let g:gradleVimResources = g:gradleVimHome . "/resources"
let g:gradleVimBrowser = $HOME . "/local-scripts/browser"

function! s:isRootDirectory(path)
  return isdirectory(a:path) && filereadable(a:path . "/gradlew")
endfunction

function! s:findRoot()
  let l:path = expand("%:p")
  while l:path != "/"
    if s:isRootDirectory(l:path)
      return l:path
    else
      let l:path = fnamemodify(l:path, ":h")
    end
  endwhile
  throw "Couldn't find Gradle project root!"
endfunction

function! s:gradleRoot()
  if !exists("b:gradleRoot")
    let b:gradleRoot = s:findRoot()
  endif
  return b:gradleRoot
endfunction

function! s:getCmd(cmd, dir)
  if a:cmd != ''
    let g:gradleVimTaskDefaults[a:dir] = a:cmd
    return a:cmd
  elseif hasKey(g:gradleVimTaskDefaults, a:dir)
    return g:gradleVimTaskDefaults[a:dir]
  else
    return g:gradleVimInitialDefaultTask
  endif
endfunction

function! s:setupTempState()
  let l:oldPath = $PATH
  let l:oldMakePrg = &makeprg
  return {'path': l:oldPath, 'makeprg': l:oldMakePrg}
endfunction

function! s:cleanupTempState(state)
  let $PATH = a:state['path']
  let &makeprg = a:state['makeprg']
endfunction

function! s:gradlew(cmd)
  let l:oldState = s:setupTempState()
  try
    let $PATH = g:gradleVimBin . ":" . $PATH
    let l:cmd = s:getCmd(a:cmd, s:gradleRoot())
    let &makeprg="((cd " . s:gradleRoot() . " && ./gradlew " . l:cmd . " 3>&2 2>&1 1>&3-) 2>/dev/tty)" 
    make
  finally
    call s:cleanupTempState(l:oldState)
  endtry
endfunction

function! s:unpackJdkDocs()
  echom "Unpacking javadocs"
  call system("unzip -d " . s:gradleRoot() . "/.vimproject/tmp " . g:gradleVimResources . "/jdk-8u144-docs-all.zip docs/api/*")
  call system("mv " . s:gradleRoot() . "/.vimproject/tmp/docs/api/* " . s:gradleRoot() . "/.vimproject/javadocs/")
  call system("rmdir -r " . s:gradleRoot() . "/.vimproject/tmp")
endfunction

function! s:downloadSourcesAndJavadoc()
  let l:oldState = s:setupTempState()
  try
    let $PATH = g:gradleVimBin . ":" . $PATH
    echom "Fetching sources and javadocs"
    call system("gradleww --rerun-tasks vim")
    call s:unpackJdkDocs()
    call writefile(readfile(g:gradleVimResources . "/java8_classes.txt"), s:gradleRoot() . "/.vimproject/classes.txt", "a")
  finally
    call s:cleanupTempState(l:oldState)
  endtry
endfunction

function! s:generateTags(bang)
  if (a:bang != '!')
    call system("rm -rf " . s:gradleRoot() . "/.vimproject")
    call s:downloadSourcesAndJavadoc()
  endif
  echom "Generating tag file"
  call system("ctags -h .java -f " . s:gradleRoot() . "/.tags -R " . s:gradleRoot())
endfunction

function! s:showJavadoc(qualifiedClassName, bang)
  let path = s:gradleRoot() . "/.vimproject/javadocs/" . substitute(a:qualifiedClassName, '\.', "/", "g") . ".html"
  if (a:bang != "!")
    call show#show("__JAVADOC__", split(system("w3m -dump " . path), "\n"))
  else
    call system(g:gradleVimBrowser . " " . path)
    call feedkeys("<CR>")
  end
endfunction

function! s:getClasses()
  return readfile(s:gradleRoot() . "/.vimproject/classes.txt")
endfunction

function! s:classesMatching(str)
  let l:matching = []
  for l:class in s:getClasses()
    if match(l:class, a:str) != -1
      call add(l:matching, l:class)
    endif
  endfor
  return l:matching
endfunction

function s:classComplete(argLead, cmdLine, cursorPos)
  return s:classesMatching(a:argLead)
endfunction

function s:importCompletion()
  let l:options = []
  for l:class in s:classesMatching(getline('.'))
    call add(l:options, "import " . l:class . ";")
  endfor
  call complete(1, l:options)
  return ''
endfunction

command! -nargs=* Gradle call <SID>gradlew("<args>")
command! -nargs=0 -bang GenerateTags call <SID>generateTags(<q-bang>)
command! -nargs=1 -bang -complete=customlist,<SID>classComplete Javadoc call <SID>showJavadoc("<args>", <q-bang>)

imap <C-i> <C-R>=<SID>importCompletion()<CR>
