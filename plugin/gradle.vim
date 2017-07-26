if exists("g:has_loaded_gradle_vim")
  finish
endif
let g:has_loaded_gradle_vim = 1

function! s:is_root_directory(path)
  return isdirectory(a:path) && filereadable(a:path . "/gradlew")
endfunction

function! s:find_root()
  let l:path = expand("%:p")
  while l:path != "/"
    if s:is_root_directory(l:path)
      return l:path
    else
      let l:path = fnamemodify(l:path, ":h")
    end
  endwhile
  return -1
endfunction

function! s:get_cmd(cmd)
  if a:cmd != ''
    return a:cmd
  elseif exists("b:cmd")
    return b:cmd
  else
    return 'tasks'
  endif
endfunction

function! s:gradlew(cmd)
  let b:cmd = s:get_cmd(a:cmd)
  let l:gradlew_dir = s:find_root()
  if l:gradlew_dir != -1
    let l:oldmakeprg = &makeprg
    let &makeprg="((cd " . l:gradlew_dir . " && ./gradlew " . b:cmd . " 3>&2 2>&1 1>&3-) 2>/dev/tty)" 
    make
    let &makeprg = l:oldmakeprg
  else
    echoerr "Couldn't find Gradle project root!"
  endif
endfunction

command! -nargs=* Gradle call <SID>gradlew("<args>")
