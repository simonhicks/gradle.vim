if exists("g:has_loaded_gradle_vim")
  finish
endif
let g:has_loaded_gradle_vim = 1
let g:gradle_vim_task_defaults = {}

if !exists("g:gradle_vim_initial_default_task")
  let g:gradle_vim_initial_default_task = 'assemble'
endif

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

function! s:get_cmd(cmd, dir)
  if a:cmd != ''
    let g:gradle_vim_task_defaults[a:dir] = a:cmd
    return a:cmd
  elseif has_key(g:gradle_vim_task_defaults, a:dir)
    return g:gradle_vim_task_defaults(a:dir)
  else
    return g:gradle_vim_initial_default_task
  endif
endfunction

function! s:gradlew(cmd)
  let l:gradlew_dir = s:find_root()
  if l:gradlew_dir != -1
    let l:cmd = s:get_cmd(a:cmd, l:gradlew_dir)
    let l:oldmakeprg = &makeprg
    let &makeprg="((cd " . l:gradlew_dir . " && ./gradlew " . l:cmd . " 3>&2 2>&1 1>&3-) 2>/dev/tty)" 
    make
    let &makeprg = l:oldmakeprg
  else
    echoerr "Couldn't find Gradle project root!"
  endif
endfunction

command! -nargs=* Gradle call <SID>gradlew("<args>")
