"$Id: vimspell.vim,v 1.13 2002/11/07 10:23:22 clabaut Exp $
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use ispell to highlight spellig errors
" Author: Mathieu Clabaut <mathieu.clabaut@free.fr>
" Original Author:  Claudio Fleiner <claudio@fleiner.com>
" Last Change: $Date: 2002/11/07 10:23:22 $
" License:
" Credits:  Claudio Fleiner <claudio@fleiner.com> for  the original script,
"	    Matthias Veit <matthias_veit@yahoo.de> for implementation of fly
"	       spelling.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Section: Documentation {{{1
"   Provides function and mapping to check spelling ; either on demand on all
"   the buffer, or whenever the user old the cursor for a certain time
"   (default 1s).
"
"   Need 'ispell', 'awk' and 'sed' in order to work properly.
"
" Function documentation: {{{2
"   TODO
"
" Mapping documentation: {{{2
"   The default mappings are as follow:
"   <F6>      - write file, spell file & highlight spelling mistakes
"   <F7>      - switch between francais and american spelling
"   <ESC><F6> - return to normal syntax coloring
"   <ESC>n    - go to next error.
"   <ESC>p    - go to previous error.
"   <ESC>I    - insert word under cursor into directory
"   <ESC>U    - insert word under cursor as lowercase into directory
"   <ESC>A    - accept word for this session only
"   <ESC>/    - check for alternatives
"
" Options documentation: {{{2
"
" TODO: {{{2
"   - More parameters
"   - mapping redefinition
"   - highlight redefinition
"   - ...
"
"
" Options documentation: {{{2
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Section: Plugin header {{{1
if exists("loaded_vimspell")
   finish
endif
let loaded_vimspell = 1

" Section: Plugin init {{{1
highlight SpellErrors ctermfg=Red guifg=Red cterm=underline gui=underline term=reverse
let b:my_changedtick=b:changedtick

" Section: Utility functions {{{1
"
" Function: s:ProposeAlternatives() {{{2
" Propose alternative for keyword under cursor. Define mapping used to correct
" the word under the cursor.
function! s:ProposeAlternatives()
  let @_=s:CheckSpellLanguage()
  let alter=system("echo ".expand("<cword>")." | ispell -a -d ".b:language." | sed -e '/^$/d' -e '/^[@*#]/d' -e 's/.*: //' -e 's/,//g' | awk '{ for(i=1;i<=NF;i++) if(i<10) printf \"map <silent> <buffer> %d :let r=<SID>SpellReplace(\\\"%s\\\")<CR> | map <silent> <buffer> *%d :let r=<SID>SpellReplaceEverywhere(\\\"%s\\\")<CR> | echo \\\"%d: %s\\\" | \",i,$i,i,$i,i,$i; }'")
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
" Remove mappings defined by ProposeAlternatives function.
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
  exe "normal gewcw".a:s."\<esc>"
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

" Function: s:ExitSpell() {{{2
" remove syntax highlighting and mapping defined for spell checking.
function! ExitSpell()
  unmap <silent> <buffer> <esc>i
  unmap <silent> <buffer> <esc>u
  unmap <silent> <buffer> <esc>a
  unmap <silent> <buffer> <esc>n
  unmap <silent> <buffer> <esc>p
  unmap <silent> <buffer> <esc><f6>
  syn match SpellErrors "xxxxx"
  syn match SpellCorrected "xxxxx"
  syn clear SpellErrors
  syn clear SpellCorrected
endfunction

" Function: s:SpellCheck() {{{2
" Spell check the text after *writing* the buffer. Define highlighting and
" mapping for correction and navigation.
function! s:SpellCheck() 
  syn case match
  let @_=s:CheckSpellLanguage()
  w
  syn match SpellErrors "xxxxx"
  syn clear SpellErrors
  let b:spellerrors="\\<\\(nonexisitingwordinthisdociumnt"
  let b:mappings=system("ispell -l -d ".b:language." < ".expand("%")." | sort -u | sed 's/\\(.*\\)/syntax match SpellErrors \"\\\\<\\1\\\\>\" ".b:spell_options."| let b:spellerrors=b:spellerrors.\"\\\\\\\\\\\\\\\\|\\1\"/'")
  exe b:mappings
  let b:spellerrors=b:spellerrors."\\)\\>"
  map <silent> <buffer> <ESC>i :call <SID>SaveIskeyword()<cr>:let @_=system("echo \\\*".substitute(expand("<cword>"),"'","\\\\\'","")." \| ispell -a -d ".b:language)<CR>:syn case match<cr>:exe "syn match SpellCorrected \"\\<".escape(expand("<cword>"),"'")."\\>\" transparent contains=NONE ".b:spell_options<cr><cr>:call <SID>LoadIskeyword()<cr><c-l>
  map <silent> <buffer> <ESC>u :call <SID>SaveIskeyword()<cr>:let @_=system("echo \\\&".substitute(expand("<cword>"),"'","\\\\\'","")." \| ispell -a -d ".b:language)<CR>:syn case ignore<cr>:exe "syn match SpellCorrected \"\\<".escape(expand("<cword>"),"'")."\\>\" transparent contains=NONE ".b:spell_options<cr><cr>:call <SID>LoadIskeyword()<cr><c-l>
  map <silent> <buffer> <ESC>a :call <SID>SaveIskeyword()<cr>:syn case match<cr>:exe "syn match SpellCorrected \"\\<".expand("<cword>")."\\>\" transparent contains=NONE ".b:spell_options<cr>:call <SID>LoadIskeyword()<cr><c-l>
  map <silent> <buffer> <ESC><F6> :let @_=ExitSpell()<CR>
  exe "map <silent> <buffer> <esc>n /".b:spellerrors."<cr>:nohl<cr>"
  exe "map <silent> <buffer> <esc>p ?".b:spellerrors."<cr>:nohl<cr>"
  syn cluster Spell contains=SpellErrors,SpellCorrected
  exe "normal \<cr>"
endfunction


" Function: s:SaveIskeyword() {{{2
" save keyword definition, and add ' to it if the selected language needs it.
function! s:SaveIskeyword()
	let w:iskeyword=&iskeyword
	if b:language == "francais "
		let &iskeyword=w:iskeyword.",39"
	endif
endfunction

" Function: s:LoadIskeyword() {{{2
" set keyword definition to its previous value.
function! s:LoadIskeyword()
	let &iskeyword=w:iskeyword
endfunction


" Function: s:CreateTemp() {{{2
" Create temp file use for fly spell checking. Define various window dependant
" variables.
function! s:CreateTemp()
	if !exists("w:tempname")
		let w:tempname = tempname()
	endif
	let w:wtop=0
	let w:wbottom=0
endfunction

" Function: s:DeleteTemp() {{{2
function! s:DeleteTemp()
	if exists("w:tempname")
	       silent exe ":!/bin/rm -f ".w:tempname
	endif
endfunction

" Function: s:SpellCheckWindow() {{{2
" Spell check the text display on the window (+ some lines before and after)
" without writing the buffer. Define highlighting and mapping for correction
" and navigation.
function! s:SpellCheckWindow() 
  " CreateTemp must have been called.
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
  " has something changed?
  if wtop == w:wtop && wbottom == w:wbottom && b:my_changedtick == b:changedtick
	  return
  endif
  let b:my_changedtick = b:changedtick
  let w:wtop = wtop
  let w:wbottom = wbottom
  " save portion of buffer we are interested in.
  silent execute  ":".wtop .",".wbottom."w!".w:tempname

  syn case match
  let @_=s:CheckSpellLanguage()
  syn match SpellErrors "xxxxx"
  syn clear SpellErrors
  let b:spellerrors="\\<\\(nonexisitingwordinthisdociumnt"

  let b:mappings=system("ispell -l -d ".b:language." < ".w:tempname." | sort -u | sed 's/\\(.*\\)/syntax match SpellErrors \"\\\\<\\1\\\\>\" ".b:spell_options."| let b:spellerrors=b:spellerrors.\"\\\\\\\\\\\\\\\\|\\1\"/'")

  exe b:mappings
  let b:spellerrors=b:spellerrors."\\)\\>"
  map <silent> <buffer> <ESC>i :call <SID>SaveIskeyword()<cr>:let @_=system("echo \\\*".substitute(expand("<cword>"),"'","\\\\\'","")." \| ispell -a -d ".b:language)<CR>:syn case match<cr>:exe "syn match SpellCorrected \"\\<".escape(expand("<cword>"),"'")."\\>\" transparent contains=NONE ".b:spell_options<cr>:call <SID>LoadIskeyword()<cr><c-l>
  map <silent> <buffer> <ESC>u :call <SID>SaveIskeyword()<cr>:let @_=system("echo \\\&".substitute(expand("<cword>"),"'","\\\\\'","")." \| ispell -a -d ".b:language)<CR>:syn case ignore<cr>:exe "syn match SpellCorrected \"\\<".escape(expand("<cword>"),"'")."\\>\" transparent contains=NONE ".b:spell_options<cr>:call <SID>LoadIskeyword()<cr><c-l>
  map <silent> <buffer> <ESC>a :call <SID>SaveIskeyword()<cr>:syn case match<cr>:exe "syn match SpellCorrected \"\\<".expand("<cword>")."\\>\" transparent contains=NONE ".b:spell_options<cr>:call <SID>LoadIskeyword()<cr><c-l>
  map <silent> <buffer> <ESC><F6> :let @_=ExitSpell()<CR>
  exe "map <silent> <buffer> <esc>n /".b:spellerrors."<cr>:nohl<cr>"
  exe "map <silent> <buffer> <esc>p ?".b:spellerrors."<cr>:nohl<cr>"
  syn cluster Spell contains=SpellErrors,SpellCorrected
endfunction

" Function: s:CheckSpellLanguage() {{{2
function! s:CheckSpellLanguage() 
  if !exists("b:spell_options") 
    let b:spell_options=""
  endif
  if !exists("b:language")
    let b:language="francais "
  elseif b:language !=? "english"
    let b:language="francais "
  endif
endfunction

" Function: s:SpellLanguage() {{{2
" Swith language
function! s:SpellLanguage()
  if !exists("b:language")
    let b:language="francais "
  elseif b:language ==? "english"
    let b:language="francais "
  else
    let b:language="english"
  endif
  echo "Language: ".b:language
endfunction


" Section: Spelling functions {{{1

" Function: s:SpellAutoEnable() {{{2
" Enable auto spelling.
function! s:SpellAutoEnable()
  let filename=bufname(winbufnr(0))
  augroup spellchecker
    au!
    execute "autocmd! CursorHold ". filename ." call s:SpellCheckWindow()"
    execute "autocmd! BufWinEnter ". filename ." call s:CreateTemp()"
    execute "autocmd! BufWinLeave ". filename ." call s:DeleteTemp()"
  augroup END
  set updatetime=2000
  call s:CreateTemp()
endfunction

" Function: s:SpellAutoEnable() {{{2
" Disable auto spelling
function! s:SpellAutoDisable()
  augroup spellchecker
    autocmd! CursorHold * 
    autocmd! BufWinEnter * 
    autocmd! BufWinLeave * 
  augroup END
  set updatetime=4000
  unlet! w:wtop
  call ExitSpell()
endfunction

" Section: Command definitions {{{1
com! SpellAutoEnable call s:SpellAutoEnable()
com! SpellAutoDisable call s:SpellAutoDisable()
com! SpellCheck call s:SpellCheck()
com! ProposeAlternatives call s:ProposeAlternatives()
com! SpellLanguage call s:SpellLanguage()


" Section: Plugin  mappings {{{1
nnoremap <silent> <unique> <Plug>SpellCheck :SpellCheck<cr>
nnoremap <silent> <unique> <Plug>ProposeAlternatives  :ProposeAlternatives<CR>
nnoremap <silent> <unique> <Plug>SpellLanguage  :SpellLanguage<cr>
nnoremap <silent> <unique> <Plug>SpellAutoEnable  :SpellAutoEnable<cr>
nnoremap <silent> <unique> <Plug>SpellAutoDisable  :SpellAutoDisable<cr>

" Section: Default mappings {{{1
if !hasmapto('<Plug>SpellCheck')
  nmap <silent> <unique> <F6> :SpellCheck<cr>
endif

if !hasmapto('<Plug>ProposeAlternatives')
  nmap <silent> <unique> <ESC>/ :ProposeAlternatives<CR>
endif

if !hasmapto('<Plug>SpellLanguage')
  nmap <silent> <unique> <ESC><F7> :SpellLanguage<cr>
endif

" Section: Menu items {{{1
amenu <silent> &Plugin.Spell.&Spell         <Plug>SpellCheck
amenu <silent> &Plugin.Spell.&Language      <Plug>SpellLanguage
amenu <silent> &Plugin.Spell.&Alternative   <Plug>ProposeAlternatives
amenu <silent> &Plugin.Spell.-Sep-	    :
amenu <silent> &Plugin.Spell.A&utomatic   <Plug>SpellAutoEnable
amenu <silent> &Plugin.Spell.&No\ auto   <Plug>SpellAutoDisable


" vim600: set foldmethod=marker ts=8 sw=2 sts=2 si sta :
