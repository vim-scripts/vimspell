"$Id: vimspell.vim,v 1.17 2002/11/27 16:22:31 clabaut Exp $
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Name:		    vimspell
" Description:	    Use ispell to highlight spelling errors on the fly, or on
"		    demand. 
" Author:	    Mathieu Clabaut <mathieu.clabaut@free.fr>
" Original Author:  Claudio Fleiner <claudio@fleiner.com>
" Last Change:	    27-Nov-2002.
"
" Licence:	    This program is free software; you can redistribute it
"                   and/or modify it under the terms of the GNU General Public
"                   License.  See http://www.gnu.org/copyleft/gpl.txt
"
" Credits:	    Claudio Fleiner <claudio@fleiner.com> for  the original
"		      script,
"		    Matthias Veit <matthias_veit@yahoo.de> for implementation
"		      idea of fly spelling.
"		    Peter Valach <pvalach@gmx.net> for suggestions, bug
"		      corrections, and vim conformance tip.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Section: Documentation {{{1
"---------------------------- 
"
"   Provides function and mapping to check spelling ; either on demand on the
"   whole  buffer, or for the current visible window whenever the cursor is hold
"   for a certain time.
"
"   Need 'ispell', 'awk', 'sort' and 'sed' in order to work properly.
"
"   The default mappings are defined as follow:
"   <Leader>ss - write file, spell file & highlight spelling mistakes
"   <Leader>sl - switch between languages
"   <Leader>sq - return to normal syntax coloring
"   <Leader>sn - go to next error.
"   <Leader>sp - go to previous error.
"   <Leader>si - insert word under cursor into directory
"   <Leader>su - insert word under cursor as lowercase into directory
"   <Leader>sa - accept word for this session only
"   <Leader>s? - check for alternatives
"
"   See below for changing them.
"
"
"
" General configuration: {{{2
"---------------------------- 
"   Disable this script by putting the following line in your .vimrc
"     let loaded_vimspell = 1
"
"   You can define your own color scheme for error highlighting, by setting
"   highlight on SpellErrors group (:help highlight). For example :
"     highlight SpellErrors  guibg=Red guifg=Black
"
"     
" Function documentation: {{{2
"----------------------------- 
"   SpellAutoEnable
"     Enable on-the-fly spell checking.
"
"   SpellAutoDisable
"     Disable on-the-fly spell checking.
"
"   SpellChangeLanguage
"     Select the next language available.
"
"   SpellSetLanguage
"     Set the language to the one given as parameter.
"
"
" Mapping documentation: {{{2
"---------------------------- 
" By default, a mapping is defined for some command.  User-provided mappings
" can be used instead by mapping to <Plug>CommandName, for instance:
"
"   nnoremap <Leader>sc <Plug>SpellCheck
"
" The default global mappings are as follow:
"
"   <Leader>ss  SpellCheck
"   <Leader>s?  SpellProposeAlternatives
"   <Leader>sl	SpellChangeLanguage
"
" Options documentation: {{{2
"---------------------------- 
"  Several variables are checked by the script to determine behavior as follow:
"
"   spell_case_accept_map	
"     This variable, if set, determines the mapping use to accept word under
"     cursor, taking case into account. Defaults to "<Leader>si".
"     With ispell the accepted words are put in the ./.ispell_<language> file
"     if exists or in the  $HOME/.ispell_<language> file.
"     
"   spell_accept_map
"     This variable, if set, determines the mapping use to accept lowercased
"     word under cursor. Defaults to "<Leader>su".
"
"   spell_ignore_map
"     This variable, if set, determines the mapping use to ignore the spelling
"     error for the current session. Defaults to "<Leader>sa".
"
"   spell_next_error_map
"     This variable, if set, determines the mapping use to jump to the next
"     spelling error. Defaults to "<Leader>sn".
"
"   spell_previous_error_map
"     This variable, if set, determines the mapping use to jump to the
"     previous spelling error. Defaults to "<Leader>sp".
"
"   spell_exit_map
"     This variable, if set, determines the mapping use to exit from
"     spelling-checker mode. Defaults to "<Leader>sq".
"
"   spell_executable
"     This variable if set defines the name of the spell-checker. Defaults to
"     "ispell".
"
"   spell_update_time
"     This variable if set defines the duration (in ms) between the last
"     cursor movement and the on-the-fly spell check. Defaults to 2000.
"
"   spell_language_list
"     This variable if set defines the language availables for spelling. The
"     language names is the one passed as an option to the spell checker.
"     Defaults to the languages for which a dictionary is present, or if none
"     can be found on the standard location, to  "english,francais"
"
" TODO list: {{{2
"---------------- 
"
"   - BUG - correct the current behaviour where AutoSpell lose SPellCheck
"     errors...
"   - selection of syntax group for which spelling is done (for example, only
"     string and comments are of interest in a C source code..)
"   - documentation in a better english :-/
"   - reduce the number of external tools used. 
"   - add popup menu for suggestion and replacement.
"   - more speller parametrization
"   - ...
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Section: Plugin header {{{1
if exists("loaded_vimspell")
   finish
endif
let loaded_vimspell = 1


" Section: Utility functions {{{1
"
" Function: s:SpellProposeAlternatives() {{{2
" Propose alternative for keyword under cursor. Define mapping used to correct
" the word under the cursor.
function! s:SpellProposeAlternatives()
  let @_=s:SpellCheckLanguage()
  let alter=system("echo ".expand("<cword>")." | ". s:spell_executable ." -a -d ".b:spell_language." | sed -e '/^$/d' -e '/^[@*#]/d' -e 's/.*: //' -e 's/,//g' | awk '{ for(i=1;i<=NF;i++) if(i<10) printf \"map <silent> <buffer> %d :let r=<SID>SpellReplace(\\\"%s\\\")<CR> | map <silent> <buffer> *%d :let r=<SID>SpellReplaceEverywhere(\\\"%s\\\")<CR> | echo \\\"%d: %s\\\" | \",i,$i,i,$i,i,$i; }'")
  if alter !=? ""
    echo "Checking ".expand("<cword>").": Type 0 for no change, r to replace, *<number> to replace all or"
    exe alter
    map <silent> <buffer> 0 <cr>:let r=<SID>SpellRemoveMappings()<cr>
    map <silent> <buffer> r 0gewcw
  else
    echo "no alternatives"
  endif
endfunction

" Function: s:SpellRemoveMappings() {{{2
" Remove mappings defined by SpellProposeAlternatives function.
function! s:SpellRemoveMappings()
  let counter=0
  while counter<10
    exe "map <silent> <buffer> ".counter." x"
    exe "map <silent> <buffer> *".counter." x"
    exe "unmap <silent> <buffer> ".counter
    exe "unmap <silent> <buffer> *".counter
    let counter=counter+1
  endwhile
  unmap <silent> <buffer> r
endfunction


" Function: s:SpellReplace() {{{2
" Replace word under cursor by the string given in parameter
function! s:SpellReplace(s)
  exe "normal ciw".a:s."\<esc>"
  let r=s:SpellRemoveMappings()
endfunction

" Function: s:SpellReplaceEverywhere() {{{2
" Replace word under cursor by the string given in parameter, in the whole
" text.
function! s:SpellReplaceEverywhere(s)
  exe ":%s/".expand("<cword>")."/".a:s."/g"
  normal 
  let r=s:SpellRemoveMappings()
endfunction

" Function: s:SpellExit() {{{2
" remove syntax highlighting and mapping defined for spell checking.
function! s:SpellExit()
  silent "unmap <silent> <buffer> " . s:SpellGetOption("spell_case_accept_map","<esc>i")
  silent "unmap <silent> <buffer> " . s:SpellGetOption("spell_accept_map","<esc>u")
  silent "unmap <silent> <buffer> " . s:SpellGetOption("spell_ignore_map","<esc>a")
  silent "unmap <silent> <buffer> " . s:SpellGetOption("spell_next_error_map","<esc>n")
  silent "unmap <silent> <buffer> " . s:SpellGetOption("spell_previous_error_map","<esc>p")
  silent "unmap <silent> <buffer> " . s:SpellGetOption("spell_exit_map","<esc><f6>")
  syn match SpellErrors "xxxxx"
  syn match SpellCorrected "xxxxx"
  syn clear SpellErrors
  syn clear SpellCorrected
endfunction

" Function: s:SpellContextMapping() {{{2
" Define mapping defined for spell checking.
function! s:SpellContextMapping()
  execute "map <silent> <buffer> " . s:SpellGetOption("spell_case_accept_map","<Leader>si") . " :call <SID>SpellCaseAccept()<cr><c-l>"
  execute "map <silent> <buffer> " . s:SpellGetOption("spell_accept_map","<Leader>su") . ":call <SID>SpellAccept()<cr><c-l>"
  execute "map <silent> <buffer> " . s:SpellGetOption("spell_ignore_map","<Leader>sa") . " :call <SID>SpellIgnore()<cr><c-l>"
  execute "map <silent> <buffer> " . s:SpellGetOption("spell_exit_map","<Leader>sq") . " :let @_=<SID>SpellExit()<CR>"
  execute "map <silent> <buffer> " . s:SpellGetOption("spell_next_error_map","<Leader>sn") . " /" . b:spellerrors . "<cr>:nohl<cr>"
  execute "map <silent> <buffer> " . s:SpellGetOption("spell_previous_error_map","<Leader>sp") . " ?" . b:spellerrors . "<cr>:nohl<cr>"
endfunction                                        
                                                   
" Function: s:SpellCheck() {{{2
" Spell check the text after *writing* the buffer. Define highlighting and
" mapping for correction and navigation.
function! s:SpellCheck() 
  syn case match
  let @_=s:SpellCheckLanguage()
  update
  syn match SpellErrors "xxxxx"
  syn clear SpellErrors
  let b:spellerrors="\\<\\(nonexisitingwordinthisdociumnt"
  let b:mappings=system(s:spell_executable ." -l -d ".b:spell_language." < ".expand("%")." | sort -u | sed 's/\\(.*\\)/syntax match SpellErrors \"\\\\<\\1\\\\>\" ".b:spell_options."| let b:spellerrors=b:spellerrors.\"\\\\\\\\\\\\\\\\|\\1\"/'")
  exe b:mappings
  let b:spellerrors=b:spellerrors."\\)\\>"
  call s:SpellContextMapping()
  syn cluster Spell contains=SpellErrors,SpellCorrected
endfunction


" Function: s:SpellSaveIskeyword() {{{2
" save keyword definition, and add ' to it if the selected language needs it.
" In french for example, "l'objet" is a word recognized by ispell.
function! s:SpellSaveIskeyword()
  let w:iskeyword=&iskeyword
  if b:spell_language == "francais "
    let &iskeyword=w:iskeyword.",39"
  endif
endfunction

" Function: s:SpellLoadIskeyword() {{{2
" set keyword definition to its previous value.
function! s:SpellLoadIskeyword()
  let &iskeyword=w:iskeyword
endfunction


" Function: s:SpellCreateTemp() {{{2
" Create temp file use for fly spell checking. Define various window dependant
" variables.
function! s:SpellCreateTemp()
  if !exists("w:tempname")
    let w:tempname = tempname()
  endif
  let w:wtop=0
  let w:wbottom=0
  let b:my_changedtick=b:changedtick
endfunction

" Function: s:SpellDeleteTemp() {{{2
function! s:SpellDeleteTemp()
  if exists("w:tempname")
    call delete(w:tempname)
  endif
endfunction


" Function: s:SpellCheckWindow() {{{2
" Spell check the text display on the window (+ some lines before and after)
" *without* writing the buffer. Define highlighting and mapping for correction
" and navigation.
function! s:SpellCheckWindow() 
  " SpellCreateTemp must have been called.
  if !exists("w:wtop")
	  return
  endif
  " initialisation
  let wh=winheight(0)
  let wtop=line(".") - &scrolloff - wh
  let wbottom=line(".") + &scrolloff + wh
  if wtop < 1
    let wtop = 1
  endif
  if wbottom > line("$")
    let wbottom = line("$")
  endif
  " has something changed (buffer content or window position) ?
  if wtop == w:wtop && wbottom == w:wbottom && b:my_changedtick == b:changedtick
    return
  endif
  let b:my_changedtick = b:changedtick
  let w:wtop = wtop
  let w:wbottom = wbottom
  " save portion of buffer we are interested in .
  silent execute  ":".wtop .",".wbottom."w!".w:tempname

  " define mappings and syntax hilights for spelling errors
  syn case match
  let @_=s:SpellCheckLanguage()
  syn match SpellErrors "xxxxx"
  syn clear SpellErrors
  let b:spellerrors="\\<\\(nonexisitingwordinthisdociumnt"

  let b:mappings=system(s:spell_executable ." -l -d ".b:spell_language." < ".w:tempname." | sort -u | sed 's/\\(.*\\)/syntax match SpellErrors \"\\\\<\\1\\\\>\" ".b:spell_options."| let b:spellerrors=b:spellerrors.\"\\\\\\\\\\\\\\\\|\\1\"/'")

  exe b:mappings
  let b:spellerrors=b:spellerrors."\\)\\>"
  call s:SpellContextMapping()

  syntax cluster Spell contains=SpellErrors,SpellCorrected
endfunction

" Function: s:SpellCaseAccept() {{{2
" add keyword under cursor to local dictionnary, keeping case.
function! s:SpellCaseAccept() 
  call s:SpellSaveIskeyword()
  let @_=system("echo \\\*".substitute(expand("<cword>"),"'","\\\\\'","")." \| ". s:spell_executable ." -a -d ".b:spell_language)
  syntax case match
  execute "syntax match SpellCorrected \"\\<".escape(expand("<cword>"),"'")."\\>\" transparent contains=NONE ".b:spell_options
  call s:SpellLoadIskeyword()
endfunction

" Function: s:SpellAccept() {{{2
" add lowercased keyword under cursor to local dictionnary
function! s:SpellAccept() 
  call s:SpellSaveIskeyword()
  let @_=system("echo \\\&".substitute(expand("<cword>"),"'","\\\\\'","")." \| ". s:spell_executable ." -a -d ".b:spell_language)
  syntax case ignore
  execute "syntax match SpellCorrected \"\\<".escape(expand("<cword>"),"'")."\\>\" transparent contains=NONE ".b:spell_options
  call s:SpellLoadIskeyword()
endfunction

" Function: s:SpellIgnore() {{{2
" ignbore keyword under cursor for current vim session.
function! s:SpellIgnore() 
  call s:SpellSaveIskeyword()
  syntax case match
  execute "syntax match SpellCorrected \"\\<".expand("<cword>")."\\>\" transparent contains=NONE ".b:spell_options
  call s:SpellLoadIskeyword()
endfunction

" Function: s:SpellCheckLanguage() {{{2
function! s:SpellCheckLanguage() 
  if !exists("b:spell_options") 
    let b:spell_options=""
  endif
  if !exists("b:spell_language")
    " take first language
    let b:spell_language=substitute(g:spell_language_list,",.*","","")
    exec "amenu <silent> disable Plugin.Spell.Language.".b:spell_language
  endif
endfunction

" Function: s:SpellSetLanguage(a:language) {{{2
" Select a language
function! s:SpellSetLanguage(language)
  exec "amenu <silent> enable Plugin.Spell.Language.".b:spell_language
  let b:spell_language=a:language
  exec "amenu <silent> disable Plugin.Spell.Language.".b:spell_language
  "TODO : some verification about arguments ?
  "force spell check
  let b:my_changedtick=0
  echo "Language: ".b:spell_language
endfunction

" Function: s:SpellChangeLanguage() {{{2
" Select next available language
function! s:SpellChangeLanguage()
  if !exists("b:spell_language")
    " take first language
    let b:spell_language=substitute(g:spell_language_list,",.*","","")
  else
    exec "amenu <silent> enable Plugin.Spell.Language.".b:spell_language
    " take next one
    let l:res=substitute(g:spell_language_list,".*" . b:spell_language . ",\\([^,]*\\),.*","\\1","")
    if l:res == g:spell_language_list
      " if no next, take the first
      let l:res=substitute(g:spell_language_list,",.*","","")
    endif
    let b:spell_language=l:res
  endif
  exec "amenu <silent> disable Plugin.Spell.Language.".b:spell_language
  "force spell check
  let b:my_changedtick=0
  echo "Language: ".b:spell_language
endfunction

" Function: s:SpellGetDicoList() {{{2
" try to find a list of install dictionnaries
function! s:SpellGetDicoList()
  let l:default = "english,francais"
  let l:dirfiles=""
  if s:spell_executable == "ispell"
    if isdirectory("/usr/lib/ispell/")
      let l:dirs =  "/usr/lib/ispell/"
    elseif isdirectory("/usr/local/lib/ispell/")
      let l:dirs =  "/usr/local/lib/ispell/"
    else
      let l:dirs =  "/usr/local/lib"
    endif

    let l:dirfiles = glob("`find ". l:dirs ." -name '*.hash' -print -type f`")
    let l:dirfiles = substitute(l:dirfiles,"\/[^\n]*\/","","g")
    let l:dirfiles = substitute(l:dirfiles,"[^\n]*-[^\n]*\n","","g")
    let l:dirfiles = substitute(l:dirfiles,"\.hash","","g")
    let l:dirfiles = substitute(l:dirfiles,"\n",",","g")
  elseif s:spell_executable == "aspell"
    " TODO better selection ? I don't know aspell enough...
    if isdirectory("/usr/lib/aspell/")
      let l:dirs =  "/usr/lib/aspell/"
    elseif isdirectory("/usr/local/lib/aspell/")
      let l:dirs =  "/usr/local/lib/aspell/"
    else
      let l:dirs =  "/usr/lib/ /usr/local/lib"
    endif
    let l:dirfiles = glob("`find ". l:dirs ." -name '*.multi' -print -type f`")
    let l:dirfiles = substitute(l:dirfiles,"\/[^\n]*\/","","g")
    let l:dirfiles = substitute(l:dirfiles,"[^\n]*-[^\n]*\n","","g")
    let l:dirfiles = substitute(l:dirfiles,"\.multi","","g")
    let l:dirfiles = substitute(l:dirfiles,"\n",",","g")
  endif
  if l:dirfiles != ""
      return l:dirfiles
  else
      return l:default
  endif
endfunction

" Function: s:SpellGetOption(name, default) {{{2
" Grab a user-specified option to override the default provided.  Options are
" searched in the window, buffer, then global spaces.
"
" Function taken from Bob Hiestand <bob@hiestandfamily.org> cvscommand script.

function! s:SpellGetOption(name, default)
  if exists("w:" . a:name)
    execute "return w:".a:name
  elseif exists("b:" . a:name)
    execute "return b:".a:name
  elseif exists("g:" . a:name)
    execute "return g:".a:name
  else
    return a:default
  endif
endfunction


" Section: Spelling functions {{{1

" Function: s:SpellAutoEnable() {{{2
" Enable auto spelling.
function! s:SpellAutoEnable()
  let filename=bufname(winbufnr(0))
  augroup spellchecker
    execute "autocmd! CursorHold ". filename ." call s:SpellCheckWindow()"
    execute "autocmd! BufWinEnter ". filename ." call s:SpellCreateTemp()"
    execute "autocmd! BufWinLeave ". filename ." call s:SpellDeleteTemp()"
  augroup END
  call s:SpellCreateTemp()
  amenu <silent> disable Plugin.Spell.Automatic
  amenu <silent> enable Plugin.Spell.No\ auto
endfunction

" Function: s:SpellAutoDisable() {{{2
" Disable auto spelling
function! s:SpellAutoDisable()
  augroup spellchecker
    silent "autocmd! CursorHold ". filename 
    silent "autocmd! BufWinEnter ". filename 
    silent "autocmd! BufWinLeave ". filename 
  augroup END
  let  &updatetime=g:spell_old_update_time
  unlet! w:wtop
  call s:SpellExit()
  amenu <silent> enable Plugin.Spell.Automatic
  amenu <silent> disable Plugin.Spell.No\ auto
endfunction

" Section: Command definitions {{{1
com! SpellAutoEnable call s:SpellAutoEnable()
com! SpellAutoDisable call s:SpellAutoDisable()
com! SpellCheck call s:SpellCheck()
com! SpellExit call s:SpellExit()
com! SpellProposeAlternatives call s:SpellProposeAlternatives()
com! SpellChangeLanguage call s:SpellChangeLanguage()
com! -nargs=1 SpellSetLanguage call s:SpellSetLanguage(<f-args>)


" Section: Plugin  mappings {{{1
nnoremap <silent> <unique> <Plug>SpellCheck       :SpellCheck<cr>
nnoremap <silent> <unique> <Plug>SpellExit       :SpellExit<cr>
nnoremap <silent> <unique> <Plug>SpellChangeLanguage    :SpellChangeLanguage<cr>
nnoremap <silent> <unique> <Plug>SpellAutoEnable  :SpellAutoEnable<cr>
nnoremap <silent> <unique> <Plug>SpellAutoDisable :SpellAutoDisable<cr>  
nnoremap <silent> <unique> <Plug>SpellProposeAlternatives  :SpellProposeAlternatives<CR>

" Section: Default mappings {{{1
if !hasmapto('<Plug>SpellCheck')
  nmap <silent> <unique> <Leader>ss <Plug>SpellCheck
endif

if !hasmapto('<Plug>SpellProposeAlternatives')
  nmap <silent> <unique> <Leader>s? <Plug>SpellProposeAlternatives
endif

if !hasmapto('<Plug>SpellChangeLanguage')
  nmap <silent> <unique> <Leader>sl <Plug>SpellChangeLanguage
endif


" Section: Plugin init {{{1
"
  highlight default SpellErrors ctermfg=Red guifg=Red cterm=underline gui=underline term=reverse
    " empty augroup spellchecker
  augroup spellchecker  
    au!
  augroup END
  let g:spell_old_update_time=&updatetime
  let s:spell_executable=s:SpellGetOption("spell_executable","ispell")
  let &updatetime=s:SpellGetOption("spell_update_time",2000)
  let g:spell_language_list=s:SpellGetOption("spell_language_list", s:SpellGetDicoList()).","


" Section: Menu items {{{1
amenu <silent> &Plugin.Spell.&Spell              <Plug>SpellCheck
amenu <silent> &Plugin.Spell.&Off                <Plug>SpellExit
amenu <silent> &Plugin.Spell.&Alternative        <Plug>SpellProposeAlternatives"
amenu <silent> &Plugin.Spell.&Language.Next\ one <Plug>SpellChangeLanguage
amenu <silent> &Plugin.Spell.&Language.-Sep-	    :
amenu <silent> &Plugin.Spell.-Sep-	    :
amenu <silent> &Plugin.Spell.A&utomatic <Plug>SpellAutoEnable
amenu <silent> &Plugin.Spell.&No\ auto  <Plug>SpellAutoDisable  

let s:mlang=substitute(g:spell_language_list,",.*","","")
while s:mlang != g:spell_language_list
  exec "amenu <silent> &Plugin.Spell.&Language.".s:mlang."  :SpellSetLanguage ".s:mlang."<cr>"
  " take next one
  let s:mlang=substitute(g:spell_language_list,".*" . s:mlang . ",\\([^,]*\\),.*","\\1","")
endwhile

"}}}1
" vim600: set foldmethod=marker ts=8 sw=2 sts=2 si sta :
