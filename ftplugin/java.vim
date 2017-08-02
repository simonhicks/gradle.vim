if exists("b:hasLoadedGradleVimJava")
  finish
endif
let g:hasLoadedGradleVimJava = 1

if !exists("g:gradleVimImportCompleteMapping")
  let g:gradleVimImportCompleteMapping = "<C-f>"
endif

execute "inoremap <buffer> " . g:gradleVimImportCompleteMapping . " <C-R>=gradle#importCompletion()<CR>"
