"$Id: vimspell.vim,v 1.26 2002/12/11 14:01:35 clabaut Exp $
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Name:		    vimspell
" Description:	    Use ispell to highlight spelling errors on the fly, or on
"		    demand. 
" Author:	    Mathieu Clabaut <mathieu.clabaut@free.fr>
" Original Author:  Claudio Fleiner <claudio@fleiner.com>
" Last Change:	    11-Dec-2002.
"
" Licence:	    This program is free software; you can redistribute it
"                   and/or modify it under the terms of the GNU General Public
"                   License.  See http://www.gnu.org/copyleft/gpl.txt
"
" Credits:	    Claudio Fleiner <claudio@fleiner.com> for the original
"		      script,
"		    Matthias Veit <matthias_veit@yahoo.de> for implementation
"		      idea of fly spelling.
"		    Bob Hiestand <bob@hiestandfamily.org> for his
"		      cvscommand.vim script, which was a reference for
"		      documentation, vim usage, some ideas and functions.
"		    Peter Valach <pvalach@gmx.net> for suggestions, bug
"		      corrections, and vim conformance tip.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Section: Documentation {{{1
"---------------------------- 
"
"   Provides functions and mappings to check spelling ; either on demand on
"   the whole buffer, or for the current visible window whenever the cursor is
"   idle for a certain time.
"
"   Needs 'ispell', 'awk', 'sort' and 'sed' in order to work properly.
"
"   The default mappings are defined as follow (By default, <Leader> stands
"   for '\'. Type :help leader for more info) :
"
"   <Leader>ss - write file, spellcheck file & highlight spelling mistakes
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
" Installation: {{{2
"---------------------------- 
"   Just copy this script in your ~/.vim/plugin/ directory.
"
"   By default, on-the-fly spell checking is disable. In order to activate it
"   for a filetype, either redefine the spell_auto_type variable (see below)
"   or put the following lines in the associated ftplugin file (for example in
"   ~/.vim/ftplugin/tex.vim or ~/.vim/after/ftplugin/tex.vim). 
"
"    if exists("loaded_vimspell")
"      :SpellAutoEnable
"    endif
"
"   Be sure that the filetype is defined (type ":help new-filetype" if it
"   doesn't work).
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
"   If no words appear to be highlighted after a spell check, try to put the
"   following lines in your .vimrc :
"     highlight SpellErrors ctermfg=Red guifg=Red \
"	cterm=underline gui=underline term=reverse
"     
"
" Mapping documentation: {{{2
"---------------------------- 
" By default, a mapping is defined for some commands.  User-provided mappings
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
"
" Options documentation: {{{2
"---------------------------- 
"  Several variables are checked by the script to determine behavior as
"  follow:
"
"   spell_case_accept_map	
"     This variable, if set, determines the mapping used to accept the word
"     under the cursor, taking case into account. Defaults to "<Leader>si".
"     With ispell the accepted words are put in the ./.ispell_<language> file
"     if it exists or in the  $HOME/.ispell_<language> file.
"     
"   spell_accept_map
"     This variable, if set, determines the mapping used to accept a lowercase
"     version of the word under the cursor. Defaults to "<Leader>su".
"
"   spell_ignore_map
"     This variable, if set, determines the mapping used to ignore the
"     spelling error for the current session. Defaults to "<Leader>sa".
"
"   spell_next_error_map
"     This variable, if set, determines the mapping used to jump to the next
"     spelling error. Defaults to "<Leader>sn".
"
"   spell_previous_error_map
"     This variable, if set, determines the mapping used to jump to the
"     previous spelling error. Defaults to "<Leader>sp".
"
"   spell_exit_map
"     This variable, if set, determines the mapping used to exit from
"     spelling-checker mode. Defaults to "<Leader>sq".
"
"   spell_executable
"     This variable, if set, defines the name of the spell-checker. Defaults
"     to "ispell".
"
"   spell_filter
"     This variable, if set, defines the name of a script (followed by |)
"     designed to filter out certain words from the input. Defaults to "".
"     For example : 
"	set spell_filter="grep -v '^#' |"
"     would prevent line beginning by # to be spell checked.
"
"   spell_update_time
"     This variable, if set, defines the duration (in ms) between the last
"     cursor movement and the on-the-fly spell check. Defaults to 2000.
"
"   spell_language_list
"     This variable, if set, defines the languages available for spelling. The
"     language names are the ones passed as an option to the spell checker.
"     Defaults to the languages for which a dictionary is present, or if none
"     can be found in the standard location, to  "english,francais"
"
"   spell_options
"     This variable, if set, defines additional options passed to the spell
"     checker executable.
"
"   spell_auto_type
"     This variable, if set, defines a list of filetype for which spell check
"     is done on the fly by default. Set it to "all" if you want on-the-fly
"     spell check for every filetype. Defaults to "tex,mail,text,html,sgml".
"
"   spell_no_readonly
"     This variable, if set, defines if read-only files are spell checked or
"     not. Defaults to 1 (no spell check for read only files).
"
"   spell_{spellchecker}_{filetype}_args
"     Those variables, if set, define the options passed to the "spellchecker"
"     executable for the files of type "filetype". By default, theu are set
"     to options known by ispell and aspell for tex, html, sgml, email
"     filetype.
"     For example:
"      let spell_aspell_tex_args = "-t"
"
"   Note: variables are looked for in the following order : window dependant
"   variables first, buffer dependant variables next and global ones last.
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
"     Set the language to the one given as a parameter.
"
"   SpellSetSpellchecker
"     Set the spell checker to the string given as a parameter (currently,
"     aspell or ispell are supported).
"
"
" TODO list: {{{2
"---------------- 
"
"   - BUG - errors did not get highlighted in other highlight groups (in
"     comments for example). Need documentation, and/or overwriting of
"     existings rules with addition of "contains SpellErrors".
"   - selection of syntax group for which spelling is done (for example, only
"     string and comments are of interest in a C source code..)
"   - reduce the number of external tools used. 
"   - Ideally, errors resulting from on the fly spell checking should be added
"     to a list of all errors (b:spellerrors and SpellErrors highlighting).
"     The problem is to keep a list of unique word, else the list will grown
"     too fast... What is the quickiest way to do that ?
"   - display a statusline like "Spellcheck in progress..." and perhaps
"     "Spellcheck done: NNN words seem to be misspelled" (Peter Valach
"     <pvalach@gmx.net>).
"   - add popup menu for suggestion and replacement.
"   - ...
"   - reduce this TODO list (I didn't think it would have grown so quickly).
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Section: Plugin header {{{1
" loaded_vimspell is set to 1 when the initialization begins, and 2 when it
" completes.  This allows various actions to only be taken by functions after
" system initialization.
if exists("loaded_vimspell")
   finish
endif
let loaded_vimspell = 1

" Filetype dependants default options {{{2

let s:spell_ispell_tex_args   = "-t" 
let s:spell_ispell_html_args  = "-H"
let s:spell_ispell_sgml_args  = "-H"  
let s:spell_ispell_nroff_args = "-n"  

let s:spell_aspell_tex_args   = "--mode=tex" 
let s:spell_aspell_html_args  = "--mode=sgml" 
let s:spell_aspell_sgml_args  = "--mode=sgml" 
let s:spell_aspell_mail_args  = "--mode=email" 

let s:known_spellchecker = "aspell,ispell"


" Section: Utility functions {{{1
"
" Function: s:SpellProposeAlternatives() {{{2
" Propose alternative for keyword under cursor. Define mapping used to correct
" the word under the cursor.
function! s:SpellProposeAlternatives()
  let @_=s:SpellCheckLanguage()
  let alter=system("echo ".expand("<cword>")." | ". b:spell_executable . b:spell_options . " -a -d ".b:spell_language." | sed -e '/^$/d' -e '/^[@*#]/d' -e 's/.*: //' -e 's/,//g' | awk '{ for(i=1;i<=NF;i++) if(i<10) printf \"map <silent> <buffer> %d :let r=<SID>SpellReplace(\\\"%s\\\")<CR> | map <silent> <buffer> *%d :let r=<SID>SpellReplaceEverywhere(\\\"%s\\\")<CR> | echo \\\"%d: %s\\\" | \",i,$i,i,$i,i,$i; }'")
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
  syn match SpellFlyErrors "xxxxx"
  syn match SpellCorrected "xxxxx"
  syn clear SpellErrors
  syn clear SpellFlyErrors
  syn clear SpellCorrected
endfunction

" Function: s:SpellContextMapping() {{{2
" Define mapping defined for spell checking.
function! s:SpellContextMapping()
  execute "map <silent> <buffer> " . s:SpellGetOption("spell_case_accept_map","<Leader>si") . " :call <SID>SpellCaseAccept()<cr><c-l>"
  execute "map <silent> <buffer> " . s:SpellGetOption("spell_accept_map","<Leader>su") . ":call <SID>SpellAccept()<cr><c-l>"
  execute "map <silent> <buffer> " . s:SpellGetOption("spell_ignore_map","<Leader>sa") . " :call <SID>SpellIgnore()<cr><c-l>"
  execute "map <silent> <buffer> " . s:SpellGetOption("spell_exit_map","<Leader>sq") . " :let @_=<SID>SpellExit()<CR>"
  execute "map <silent> <buffer> " . s:SpellGetOption("spell_next_error_map","<Leader>sn") . ' /\<\(' . b:spellerrors . '\|' . b:spell_fly_errors . '\)\><cr>:nohl<cr>'
  execute "map <silent> <buffer> " . s:SpellGetOption("spell_previous_error_map","<Leader>sp") . ' ?\<\(' . b:spellerrors . '\|' . b:spell_fly_errors . '\)\><cr>:nohl<cr>'
endfunction                                        
                                                   
" Function: s:SpellCheck() {{{2
" Spell check the text after *writing* the buffer. Define highlighting and
" mapping for correction and navigation.
function! s:SpellCheck() 
  "TODO : how to display several informative messages, without a prompt for
  "pressing <ENTER> ?
  echo "Spell check in progress..."
  syn case match
  let @_=s:SpellCheckLanguage()
  silent update
  syn match SpellErrors "xxxxx"
  syn clear SpellErrors
  let b:spellerrors="nonexisitingwordinthisdociumnt"
  if !exists("b:spell_fly_errors")
    let b:spell_fly_errors="nonexisitingwordinthisdociumnt"
  endif
  let b:mappings=system(b:spell_filter . b:spell_executable . b:spell_options . " -l -d ".b:spell_language." < ".expand("%")." | sort -u | sed 's/\\(.*\\)/syntax match SpellErrors \"\\\\<\\1\\\\>\" ".b:spell_no_spelled."| let b:spellerrors=b:spellerrors.\"\\\\\\\\\\\\\\\\|\\1\"/'")
  exe b:mappings
  call s:SpellContextMapping()
  syn cluster Spell contains=SpellErrors,SpellCorrected,SpellFlyErrors
  " TODO : show stats about spell check ?
  echo "Spell check done."
  " Trick to avoid the "Press RETURN ..." prompt -- not perfect...
  exe "0 append"
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
  syn match SpellFlyErrors "xxxxx"
  syn clear SpellFlyErrors
  let b:spell_fly_errors="nonexisitingwordinthisdociumnt"
  if !exists("b:spellerrors")
    let b:spellerrors="nonexisitingwordinthisdociumnt"
  endif

  let b:mappings=system(b:spell_filter . b:spell_executable . b:spell_options . " -l -d ".b:spell_language." < ".w:tempname." | sort -u | sed 's/\\(.*\\)/syntax match SpellFlyErrors \"\\\\<\\1\\\\>\" ".b:spell_no_spelled."| let b:spell_fly_errors=b:spell_fly_errors.\"\\\\\\\\\\\\\\\\|\\1\"/'")

  exe b:mappings
  call s:SpellContextMapping()

  syntax cluster Spell contains=SpellErrors,SpellCorrected,SpellFlyErrors
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


" Function: s:SpellCaseAccept() {{{2
" add keyword under cursor to local dictionnary, keeping case.
function! s:SpellCaseAccept() 
  call s:SpellSaveIskeyword()
  let @_=system('(echo "*'.substitute(expand("<cword>"),"'","\\\\\'","").'"; echo "#") | '. b:spell_executable . b:spell_options . " -a -d ".b:spell_language)
  syntax case match
  execute "syntax match SpellCorrected \"\\<".escape(expand("<cword>"),"'")."\\>\" transparent contains=NONE ".b:spell_no_spelled
  call s:SpellLoadIskeyword()
endfunction

" Function: s:SpellAccept() {{{2
" add lowercased keyword under cursor to local dictionnary
function! s:SpellAccept() 
  call s:SpellSaveIskeyword()
  let @_=system('(echo "&'.substitute(expand("<cword>"),"'","\\\\\'","").'";echo "#") | '. b:spell_executable . b:spell_options . " -a -d ".b:spell_language)
  syntax case ignore
  execute "syntax match SpellCorrected \"\\<".escape(expand("<cword>"),"'")."\\>\" transparent contains=NONE ".b:spell_no_spelled
  call s:SpellLoadIskeyword()
endfunction

" Function: s:SpellIgnore() {{{2
" ignbore keyword under cursor for current vim session.
function! s:SpellIgnore() 
  call s:SpellSaveIskeyword()
  syntax case match
  execute "syntax match SpellCorrected \"\\<".expand("<cword>")."\\>\" transparent contains=NONE ".b:spell_no_spelled
  call s:SpellLoadIskeyword()
endfunction

" Function: s:SpellCheckLanguage() {{{2
function! s:SpellCheckLanguage() 
  if !exists("b:spell_no_spelled") 
    let b:spell_no_spelled=""
  endif
  if !exists("b:spell_language")
    " take first language
    let b:spell_language=substitute(b:spell_internal_language_list,",.*","","")
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

" Function: s:SpellSetSpellchecker(a:spellchecker) {{{2
" Select a spell checker executable
function! s:SpellSetSpellchecker(prog)
  if matchstr(s:known_spellchecker,a:prog) == ""
    echo "No driver for '".a:prog."' spell checker."
    return
  endif
  if exists("b:spell_executable")
    exec "amenu <silent> enable Plugin.Spell.".b:spell_executable
  endif
  let b:spell_executable=a:prog
  exec "amenu <silent> disable Plugin.Spell.".b:spell_executable
  "get language list (spell checker dependant)
  let b:spell_internal_language_list=s:SpellGetDicoList().","
    " Init language menu
  aunmenu <silent> Plugin.Spell.Language
  let l:mlang=substitute(b:spell_internal_language_list,",.*","","")
  while matchstr(l:mlang,",") == "" 
    exec "amenu <silent> 10.10.50 &Plugin.Spell.&Language.".l:mlang."  :SpellSetLanguage ".l:mlang."<cr>"
    " take next one
    let l:mlang=substitute(b:spell_internal_language_list,".*\\C" . l:mlang . ",\\([^,]\\+\\),.*","\\1","")
  endwhile
  "force spell check
  let b:my_changedtick=0
endfunction

" Function: s:SpellChangeLanguage() {{{2
" Select next available language
function! s:SpellChangeLanguage()
  if !exists("b:spell_language")
    " take first language
    let b:spell_language=substitute(b:spell_internal_language_list,",.*","","")
  else
    exec "amenu <silent> enable Plugin.Spell.Language.".b:spell_language
    " take next one
    let l:res=substitute(b:spell_internal_language_list,".*\\C" . b:spell_language . ",\\([^,]\\+\\),.*","\\1","")
    if matchstr(l:res,",") != "" 
      " if no next, take the first
      let l:res=substitute(b:spell_internal_language_list,",.*","","")
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
  let l:opt=s:SpellGetOption("spell_language_list", 0)
  if l:opt != 0
    " return user defined language list, if exists
    return l:opt
  endif

  let l:dirfiles=""
  if b:spell_executable == "ispell"
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
  elseif b:spell_executable == "aspell"
    " Thanks to Alexandre Beneteau <alexandre.beneteau@wanadoo.fr> for showing
    " me a way to get aspell directory for dictionnaries.
    let l:dirs = system("aspell config | grep 'dict-dir current'") 
    let l:dirs = substitute(l:dirs,'^.*dict-dir current: \(\/.*\)','\1',"")
    "don't know, why there is a <NUL> char at the end of line ? Get rid of it.
    let l:dirs = substitute(l:dirs,".$","","")

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


" Function: s:SpellSetupBuffer() {{{2
" Initialize buffer dependants variables.

function! s:SpellSetupBuffer()
  call s:SpellSetSpellchecker(s:SpellGetOption("spell_executable","ispell"))

  let b:spell_filter=s:SpellGetOption("spell_filter","")

    " get filetype and speller dependant options.
  let l:options="spell_".b:spell_executable."_".&filetype."_args"
  if exists("s:".l:options)
    let l:ft_options=s:SpellGetOption(l:options,s:{l:options})
  else
    let l:ft_options=s:SpellGetOption(l:options,"")
  endif

  if b:spell_executable == "ispell"
    " -S : sort by probability option.
    let b:spell_options=s:SpellGetOption("spell_options","-S") 
  elseif b:spell_executable == "aspell"
    let b:spell_options=s:SpellGetOption("spell_options","") 
  endif
  let b:spell_options = " " . b:spell_options ." " .l:ft_options ." "
  if match(s:SpellGetOption("spell_auto_type","tex,mail,text,html,sgml"),&filetype) >= 0
    call s:SpellAutoEnable()
  endif

endfunction

" Section: Spelling functions {{{1

" Function: s:SpellAutoEnable() {{{2
" Enable auto spelling.
function! s:SpellAutoEnable()
  if exists("b:spell_auto_enable")&& b:spell_auto_enable 
    return
  endif
  if s:SpellGetOption("spell_no_readonly",1) && &readonly
    return
  endif
  let b:spell_auto_enable = 1
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
  if !exists("b:spell_auto_enable") || b:spell_auto_enable == 0
    return
  endif
  let b:spell_auto_enable = 0
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
com! -nargs=1 SpellSetSpellchecker call s:SpellSetSpellchecker(<f-args>)<Bar> echo "Spell checker: ".<f-args>


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


" Section: Menu items {{{1
amenu <silent> 10.10.10 &Plugin.Spell.&Spell       <Plug>SpellCheck
amenu <silent> 10.10.15 &Plugin.Spell.&Off         <Plug>SpellExit
amenu <silent> 10.10.20 &Plugin.Spell.&Alternative <Plug>SpellProposeAlternatives"
amenu <silent> 10.10.30 &Plugin.Spell.&Language.Next\ one <Plug>SpellChangeLanguage
amenu <silent>		&Plugin.Spell.&Language.-Sep-   :
amenu <silent> 10.10.40 &Plugin.Spell.-Sep-		:
amenu <silent> 10.10.45 &Plugin.Spell.A&utomatic <Plug>SpellAutoEnable
amenu <silent> 10.10.50 &Plugin.Spell.&No\ auto  <Plug>SpellAutoDisable  
amenu <silent> 10.10.100 &Plugin.Spell.-Sep2-	    :
amenu <silent> 10.10.101 &Plugin.Spell.aspell :SpellSetSpellchecker aspell<CR>
amenu <silent> 10.10.102 &Plugin.Spell.ispell :SpellSetSpellchecker ispell<CR>

" Section: Plugin init {{{1
"
  highlight default SpellErrors ctermfg=Red guifg=Red cterm=underline gui=underline term=reverse
  highlight default link SpellFlyErrors  SpellErrors
    " empty augroup spellchecker
  augroup spellchecker  
    au!
  augroup END
  let g:spell_old_update_time=&updatetime
  let &updatetime=s:SpellGetOption("spell_update_time",2000)
  augroup SpellCommandPlugin
    au!
    au BufEnter * call s:SpellSetupBuffer()
  augroup END


" Section: Plugin completion {{{1
let loaded_vimspell=2
"}}}1
" vim600: set foldmethod=marker ts=8 sw=2 sts=2 si sta :
