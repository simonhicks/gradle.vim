if exists("g:hasAutoLoadedGradleVim")
  finish
endif
let g:hasAutoLoadedGradleVim = 1

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
    endif
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
  elseif has_key(g:gradleVimTaskDefaults, a:dir)
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

function! gradle#gradlew(cmd)
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
  call system("rm -r " . s:gradleRoot() . "/.vimproject/tmp")
endfunction

function! s:downloadSourcesAndJavadoc()
  let l:oldState = s:setupTempState()
  try
    let $PATH = g:gradleVimBin . ":" . $PATH
    echom "Fetching sources and javadocs"
    call system("gradleww --rerun-tasks vim")
    call s:unpackJdkDocs()
    let l:classFile = s:gradleRoot() . "/.vimproject/classes.txt"
    call system("touch " . l:classFile)
    let it = readfile(g:gradleVimResources . "/java8_classes.txt")
    call writefile(it, l:classFile, "a")
  finally
    call s:cleanupTempState(l:oldState)
  endtry
endfunction

function! gradle#generateTags(bang)
  if (a:bang != '!')
    call system("rm -rf " . s:gradleRoot() . "/.vimproject")
    call s:downloadSourcesAndJavadoc()
  endif
  echom "Generating tag file"
  call system("ctags --exclude='*.class' --exclude='*.html' -f " . s:gradleRoot() . "/.tags -R " . s:gradleRoot())
endfunction

function! gradle#showJavadoc(qualifiedClassName)
  let path = s:gradleRoot() . "/.vimproject/javadocs/" . substitute(a:qualifiedClassName, '\.', "/", "g") . ".html"
  call system(g:gradleVimBrowser . " " . path)
  call feedkeys("<CR>")
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

function gradle#classComplete(argLead, cmdLine, cursorPos)
  return s:classesMatching(a:argLead)
endfunction

function gradle#importCompletion()
  let l:options = []
  let l:line = substitute(getline('.'), '\(^\s*\|\s*$\)', '', 'g') 
  for l:class in s:classesMatching(l:line)
    call add(l:options, "import " . l:class . ";")
  endfor
  call complete(1, l:options)
  return ''
endfunction
