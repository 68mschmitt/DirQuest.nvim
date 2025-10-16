if exists('g:loaded_dirquest')
  finish
endif
let g:loaded_dirquest = 1

command! -nargs=? -complete=dir DirQuest lua require('dirquest').start(<f-args>)
command! -nargs=0 DirQuestQuit lua require('dirquest').close()
