if exists("b:hasLoadedGradleVimJava")
  finish
endif
let g:hasLoadedGradleVimJava = 1

inoremap <buffer> <C-f> <C-R>=gradle#importCompletion()<CR>
