"$Id: vimspell.vim,v 1.12 2002/10/30 09:00:10 clabaut Exp $
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use ispell to highlight spellig errors
" Author: Claudio Fleiner <claudio@fleiner.com>
" F6         - write file, spell file & highlight spelling mistakes
" <SHIFT>F6  - switch between francais and american spelling
" <ALT>F6    - return to normal syntax coloring
" <ALT>I     - insert word under cursor into directory
" <ALT>U     - insert word under cursor as lowercase into directory
" <ALT>A     - accept word for this session only
" <ESC>/     - check for alternatives
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

:function! ProposeAlternatives()
:  let @_=CheckSpellLanguage()
:  let alter=system("echo ".expand("<cword>")." | ispell -a -d ".b:language." | sed -e '/^$/d' -e '/^[@*#]/d' -e 's/.*: //' -e 's/,//g' | awk '{ for(i=1;i<=NF;i++) if(i<10) printf \"map <silent> <buffer> %d :let r=SpellReplace(\\\"%s\\\")<CR> | map <silent> <buffer> *%d :let r=SpellReplaceEverywhere(\\\"%s\\\")<CR> | echo \\\"%d: %s\\\" | \",i,$i,i,$i,i,$i; }'")
:  if alter !=? ""
:    echo "Checking ".expand("<cword>").": Type 0 for no change, r to replace, *<number> to replace all or"
:    exe alter
:    map <silent> <buffer> 0 <cr>:let r=SpellRemoveMappings()<cr>
:    map <silent> <buffer> r 0gewcw
:  else
:    echo "no alternatives"
:  endif
:endfunction

:function! SpellRemoveMappings()
:  let counter=0
:  while counter<10
:    exe "map <silent> <buffer> ".counter." x"
:    exe "unmap <silent> <buffer> ".counter
:    let counter=counter+1
:  endwhile
:  unmap <silent> <buffer> r
:endfunction


:function! SpellReplace(s)
:  exe "normal gewcw".a:s."\<esc>"
:  let r=SpellRemoveMappings()
endfunction

function! SpellReplaceEverywhere(s)
  exe ":%s/".expand("<cword>")."/".a:s."/g"
  normal 
  let r=SpellRemoveMappings()
endfunction

:function! ExitSpell()
:  unmap <silent> <buffer> <esc>i
:  unmap <silent> <buffer> <esc>u
:  unmap <silent> <buffer> <esc>a
:  unmap <silent> <buffer> <esc>n
:  unmap <silent> <buffer> <esc>p
:  unmap <silent> <buffer> <esc><f6>
:  syn match SpellErrors "xxxxx"
:  syn match SpellCorrected "xxxxx"
:  syn clear SpellErrors
:  syn clear SpellCorrected
:endfunction

:function! SpellCheck() 
:  syn case match
:  let @_=CheckSpellLanguage()
:  w
:  syn match SpellErrors "xxxxx"
:  syn clear SpellErrors
:  let b:spellerrors="\\<\\(nonexisitingwordinthisdociumnt"
:  let b:mappings=system("ispell -l -d ".b:language." < ".expand("%")." | sort -u | sed 's/\\(.*\\)/syntax match SpellErrors \"\\\\<\\1\\\\>\" ".b:spell_options."| let b:spellerrors=b:spellerrors.\"\\\\\\\\\\\\\\\\|\\1\"/'")
:  exe b:mappings
:  let b:spellerrors=b:spellerrors."\\)\\>"
:  map <silent> <buffer> <ESC>i :call SaveIskeyword()<cr>:let @_=system("echo \\\*".substitute(expand("<cword>"),"'","\\\\\'","")." \| ispell -a -d ".b:language)<CR>:syn case match<cr>:exe "syn match SpellCorrected \"\\<".escape(expand("<cword>"),"'")."\\>\" transparent contains=NONE ".b:spell_options<cr><cr>:call LoadIskeyword()<cr><c-l>
:  map <silent> <buffer> <ESC>u :call SaveIskeyword()<cr>:let @_=system("echo \\\&".substitute(expand("<cword>"),"'","\\\\\'","")." \| ispell -a -d ".b:language)<CR>:syn case ignore<cr>:exe "syn match SpellCorrected \"\\<".escape(expand("<cword>"),"'")."\\>\" transparent contains=NONE ".b:spell_options<cr><cr>:call LoadIskeyword()<cr><c-l>
:  map <silent> <buffer> <ESC>a :call SaveIskeyword()<cr>:syn case match<cr>:exe "syn match SpellCorrected \"\\<".expand("<cword>")."\\>\" transparent contains=NONE ".b:spell_options<cr>:call LoadIskeyword()<cr><c-l>
":  map <silent> <buffer> <ESC>i :call SaveIskeyword()<cr>:let @_=system("echo \\\*".escape(escape(expand("<cword>"),"'"),'\')." \| ispell -a -d ".b:language)<CR>:syn case match<cr>:exe "syn match SpellCorrected \"\\<".expand("<cword>")."\\>\" transparent contains=NONE ".b:spell_options<cr>:call LoadIskeyword()<cr><c-l>
":  map <silent> <buffer> <ESC>u :call SaveIskeyword()<cr>:let @_=system("echo \\\&".expand("<cword>")." \| ispell -a -d ".b:language)<CR>:syn case ignore<cr>:exe "syn match SpellCorrected \"\\<".expand("<cword>")."\\>\" transparent contains=NONE ".b:spell_options<cr><cr>:call LoadIskeyword()<cr><c-l>
":  map <silent> <buffer> <ESC>a :call SaveIskeyword()<cr>:syn case match<cr>:exe "syn match SpellCorrected \"\\<".expand("<cword>")."\\>\" transparent contains=NONE ".b:spell_options<cr>:call LoadIskeyword()<cr><c-l>
:  map <silent> <buffer> <ESC><F6> :let @_=ExitSpell()<CR>
:  exe "map <silent> <buffer> <esc>n /".b:spellerrors."<cr>:nohl<cr>"
:  exe "map <silent> <buffer> <esc>p ?".b:spellerrors."<cr>:nohl<cr>"
:  syn cluster Spell contains=SpellErrors,SpellCorrected
":  hi link SpellErrors Error
:  exe "normal \<cr>"
:endfunction


function! SaveIskeyword()
	let w:iskeyword=&iskeyword
	if b:language == "francais "
		let &iskeyword=w:iskeyword.",39"
	endif
endfunction

function! LoadIskeyword()
	let &iskeyword=w:iskeyword
endfunction

function! CreateTemp()
	if !exists("w:tempname")
		let w:tempname = tempname()
	endif
	let w:wtop=0
	let w:wbottom=0
endfunction

function! DeleteTemp()
	if exists("w:tempname")
		silent exe ":!/bin/rm -f ".w:tempname
	endif
endfunction

function! SpellCheckWindow() 
	
	" Once autocommand is set, it is activated for all windows. We do not spell
	" check other window.
	if !exists("w:wtop")
		return
	endif
	"init
	let wh=winheight(0)
	let wtop=line(".") - &scrolloff - wh
	let wbottom=line(".") + &scrolloff + wh
	if wtop < 1
		let wtop = 1
	endif
	if wbottom > line("$")
		let wbottom = line("$")
	endif
	"has something changed?
	if wtop == w:wtop && wbottom == w:wbottom && b:my_changedtick == b:changedtick
		return
	endif
	let b:my_changedtick = b:changedtick
	let w:wtop = wtop
	let w:wbottom = wbottom
	silent execute  ":".wtop .",".wbottom."w!".w:tempname

	syn case match
	let @_=CheckSpellLanguage()
	syn match SpellErrors "xxxxx"
	syn clear SpellErrors
	let b:spellerrors="\\<\\(nonexisitingwordinthisdociumnt"

	let b:mappings=system("ispell -l -d ".b:language." < ".w:tempname." | sort -u | sed 's/\\(.*\\)/syntax match SpellErrors \"\\\\<\\1\\\\>\" ".b:spell_options."| let b:spellerrors=b:spellerrors.\"\\\\\\\\\\\\\\\\|\\1\"/'")

	exe b:mappings
	let b:spellerrors=b:spellerrors."\\)\\>"
:  map <silent> <buffer> <ESC>i :call SaveIskeyword()<cr>:let @_=system("echo \\\*".substitute(expand("<cword>"),"'","\\\\\'","")." \| ispell -a -d ".b:language)<CR>:syn case match<cr>:exe "syn match SpellCorrected \"\\<".escape(expand("<cword>"),"'")."\\>\" transparent contains=NONE ".b:spell_options<cr>:call LoadIskeyword()<cr><c-l>
:  map <silent> <buffer> <ESC>u :call SaveIskeyword()<cr>:let @_=system("echo \\\&".substitute(expand("<cword>"),"'","\\\\\'","")." \| ispell -a -d ".b:language)<CR>:syn case ignore<cr>:exe "syn match SpellCorrected \"\\<".escape(expand("<cword>"),"'")."\\>\" transparent contains=NONE ".b:spell_options<cr>:call LoadIskeyword()<cr><c-l>
:  map <silent> <buffer> <ESC>a :call SaveIskeyword()<cr>:syn case match<cr>:exe "syn match SpellCorrected \"\\<".expand("<cword>")."\\>\" transparent contains=NONE ".b:spell_options<cr>:call LoadIskeyword()<cr><c-l>
	map <silent> <buffer> <ESC><F6> :let @_=ExitSpell()<CR>
:  exe "map <silent> <buffer> <esc>n /".b:spellerrors."<cr>:nohl<cr>"
:  exe "map <silent> <buffer> <esc>p ?".b:spellerrors."<cr>:nohl<cr>"
	syn cluster Spell contains=SpellErrors,SpellCorrected
	"hi link SpellErrors Error
	"exe "normal \<cr>"
endfunction

:function! CheckSpellLanguage() 
:  if !exists("b:spell_options") 
:    let b:spell_options=""
:  endif
:  if !exists("b:language")
:    let b:language="francais "
:  elseif b:language !=? "english"
:    let b:language="francais "
:  endif
:endfunction

:function! SpellLanguage()
:  if !exists("b:language")
:    let b:language="francais "
:  elseif b:language ==? "english"
:    let b:language="francais "
:  else
:    let b:language="english"
:  endif
:  echo "Language: ".b:language
:endfunction

function! SpellAutoEnable()
	let filename=bufname(winbufnr(0))
	augroup spellchecker
		au!
		execute "autocmd! CursorHold ". filename ." call SpellCheckWindow()"
		execute "autocmd! BufWinEnter ". filename ." call CreateTemp()"
		execute "autocmd! BufWinLeave ". filename ." call DeleteTemp()"
	augroup END
	set updatetime=1000
	call CreateTemp()
	"call SpellCheckWindow()
endfunction

function! SpellAutoDisable()
	augroup spellchecker
		autocmd! CursorHold * 
		autocmd! BufWinEnter * 
		autocmd! BufWinLeave * 
	augroup END
	set updatetime=4000
	unlet! w:wtop
	call ExitSpell()
endfunction

let b:my_changedtick=b:changedtick

highlight SpellErrors ctermfg=Red guifg=Red cterm=underline gui=underline term=reverse

map <silent> <buffer> <F6> :let @_=SpellCheck()<cr>
map <silent> <buffer> <ESC>/ :let @_=ProposeAlternatives()<CR>
map <silent> <buffer> <ESC><F7> :let @_=SpellLanguage()<cr>


"vim : ts=2 sw=2 : 
