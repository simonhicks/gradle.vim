if exists("g:has_loaded_gradle_vim")
  finish
endif
let g:has_loaded_gradle_vim = 1

function! s:gradlew(cmd)
  let l:oldmakeprg = &makeprg
  let &makeprg="((./gradlew " . a:cmd . " 3>&2 2>&1 1>&3-) 2>/dev/tty)" 
  make
  let &makeprg = l:oldmakeprg
endfunction

command! -nargs=1 Gradle call <SID>gradlew("<args>")
