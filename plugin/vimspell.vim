"$Id: vimspell.vim,v 1.40 2003/03/06 10:00:30 clabaut Exp $
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Name:		    vimspell
" Description:	    Use ispell to highlight spelling errors on the fly, or on
"		    demand. 
" Author:	    Mathieu Clabaut <mathieu.clabaut@free.fr>
" Original Author:  Claudio Fleiner <claudio@fleiner.com>
" Url:		    http://www.vim.org/scripts/script.php?script_id=465
"
" Last Change:	    06-Mar-2003.
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
"		    Markus Braun <Markus.Braun@krawel.de> for several bug
"		      report and patches :-).
"		    Tim Allen <firstlight@redneck.gacracker.org> for showing
"		      me a way to autogenerate help file in his 'posting'
"		      script.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Section: Documentation {{{1
"---------------------------- 
"
" Documentation should be available by ":help vimspell" command, once the
" script has been copied in you .vim/plugin directory.
"
"*vimspell.txt*   For Vim version 6.1.                                #version#
"
"
"                        VIMSPELL REFERENCE MANUAL
"
"
"Spelling text with the plugin "Vimspell" 
"
"
"==============================================================================
"1. Contents                                                *vimspell-contents*
"
"    Installation        : |vimspell-install|
"    Vimspell intro      : |vimspell|
"    Requirements        : |vimspell-requirements|
"    Vimspell commands   : |vimspell-commands|
"    Customization       : |vimspell-customize|
"    Bugs                : |vimspell-bugs|
"    Todo list           : |vimspell-todo|
"
"==============================================================================
"1. vimspell Installation {{{2                               *vimspell-install*
"
"    In order to install the plugin, place the vimspell.vim file into a plugin'
"    directory in your runtime path (please see |add-global-plugin| and
"    |'runtimepath'|).
"
"    By default, on-the-fly spell checking is disable. In order to activate it
"    for a filetype, either redefine the |spell_auto_type| variable (see below)
"    or put the following lines in the associated |ftplugin| file (for example in
"    ~/.vim/ftplugin/tex.vim or ~/.vim/after/ftplugin/tex.vim). 
" 
"        if exists("loaded_vimspell")
"            :SpellAutoEnable
"        endif
" 
"    Be sure that the filetype is defined (See |new-filetype| if it doesn't
"    work).
"    
"    |vimspell| may be customized by setting variables, creating maps, and
"    specifying event handlers.  Please see |vimspell-customize| for more
"    details.
"
"                                                          *vimspell-auto-help*
"    This help file is automagically generated when the |vimspell| script is
"    loaded for the first time.
"
"==============================================================================
"1.1. vimspell requirements                             *vimspell-requirements*
"
"    Vimspell needs the following external tools :
"     - 'ispell' or 'aspell' spell checkers,
"     - 'awk', 'sort' and 'sed' unix filters.
"
"    It has been tested with vim 6.1, but should also work with vim 6.0.
"
"==============================================================================
"2. vimspell intro {{{2                                              *vimspell*
"                                                              *vimspell-intro*
"
"   vimspell script provides functions and mappings to check spelling ; either
"   on demand on the whole buffer, or for the current visible window whenever
"   the cursor is idle for a certain time.
"
"   The default mappings are defined as follow (By default, <Leader> stands
"   for '\'. See |Leader| for more info) :
"
"   <Leader>ss - write file, spellcheck file & highlight spelling mistakes.
"   <Leader>sA - start autospell mode.
"   <Leader>sq - return to normal syntax coloring and disable auto spell
"		 checking.
"   <Leader>sl - switch between languages.
"   <Leader>sn - go to next error.
"   <Leader>sp - go to previous error.
"   <Leader>si - insert word under cursor into directory.
"   <Leader>su - insert word under cursor as lowercase into directory.
"   <Leader>sa - accept word for this session only.
"   <Leader>s? - check for alternatives.
"
"   See |vimspell-mappings-override| and |vimspell-options| to learn how to
"   override those default mappings.
"
"==============================================================================
"3. vimspell commands	{{{2                               *vimspell-commands*
"
"    See |vimspell-intro| for default mapping. Vimspell defines the following
"    commands:
"
"    :SpellCheck                                                  *:SpellCheck*
"      Spell check the text after _writing_ the buffer. Define highlighting and
"      mapping for correction and navigation.
"
"    :SpellAutoEnable                                        *:SpellAutoEnable*
"      Enable on-the-fly spell checking.
" 
"    :SpellAutoDisable                                      *:SpellAutoDisable*
"      Disable on-the-fly spell checking.
" 
"    :SpellChangeLanguage                                *:SpellChangeLanguage*
"      Select the next language available.
" 
"    :SpellSetLanguage                                      *:SpellSetLanguage*
"      Set the language to the one given as a parameter.
" 
"    :SpellSetSpellchecker                              *:SpellSetSpellchecker*
"      Set the spell checker to the string given as a parameter (currently,
"      aspell or ispell are supported).
"
"    :SpellProposeAlternatives                      *:SpellProposeAlternatives*
"      Propose alternative for keyword under cursor. Define mapping used to
"      correct the word under the cursor.
"
"    :SpellExit                                                    *:SpellExit*
"      Remove syntax highlighting and mapping defined for spell checking.
"
"    :SpellReload                                                *:SpellReload*
"      Reload vimspell script.
"
"==============================================================================
"4. Vimspell customization  {{{2                           *vimspell-customize*
"
"4.1. General configuration {{{3
"--------------------------
"                                          *loaded_vimspell* *vimspell-disable*
"    You can disable this script by putting the following line in your |vimrc|
"      let loaded_vimspell = 1
" 
"    You can define your own color scheme for error highlighting, by setting
"    |highlight| on SpellErrors group. For example:
"      highlight SpellErrors  guibg=Red guifg=Black
" 
"    If no words appear to be highlighted after a spell check, try to put the
"    following lines in your |vimrc|:
"      highlight SpellErrors ctermfg=Red guifg=Red \
" 	cterm=underline gui=underline term=reverse
"
"
"4.2. Mapping documentation: {{{3
"---------------------------
"                                                  *vimspell-mappings-override*
"    By default, a global mapping is defined for some commands.  User-provided
"    mappings can be used instead by mapping to <Plug>CommandName. This is
"    especially useful when these mappings collide with other existing mappings
"    (vim will warn of this during plugin initialization, but will not clobber
"    the existing mappings).
"
"    For instance, to override the default mapping for :SpellCheck to set it to
"    \sc, add the following to the |vimrc|.
" 
"    nnoremap \sc <Plug>SpellCheck
" 
"    The default global mappings are as follow:
"    
"        <Leader>ss  SpellCheck
"        <Leader>sA  SpellAutoEnable
"        <Leader>s?  SpellProposeAlternatives
"        <Leader>sl  SpellChangeLanguage
"
"    Other mapping are defined according to the context of utilisation, and can
"    be redefined by mean of buffer-wise variables. See |vimspell-options| here
"    after.
"
"4.3. Options documentation: {{{3
"--------------------------- 
"                                                            *vimspell-options*
"    Several variables are checked by the script to customize vimspell
"    behaviour. Note that variables are looked for in the following order :
"    window dependent variables first, buffer dependent variables next and
"    global ones last (See |internal-variables|, |buffer-variable|,
"    |window-variable| and |global-variable|).
" 
"    spell_case_accept_map                              *spell_case_accept_map*
"      This variable, if set, determines the mapping used to accept the word
"      under the cursor, taking case into account. Defaults to:
" 	  let spell_case_accept_map = "<Leader>si"
" 
"      When using 'ispell' the accepted words are put in the
"      ./.ispell_<language> file if it exists or in the
"      $HOME/.ispell_<language> file.
" 
"      
"    spell_accept_map                                        *spell_accept_map*
"      This variable, if set, determines the mapping used to accept a lowercase
"      version of the word under the cursor. Defaults to:
" 	  let spell_accept_map = "<Leader>su"
" 
" 
"    spell_ignore_map                                        *spell_ignore_map*
"      This variable, if set, determines the mapping used to ignore the
"      spelling error for the current session. Defaults to:
" 	  let spell_ignore_map = "<Leader>sa"
" 
" 
"    spell_next_error_map                                *spell_next_error_map*
"      This variable, if set, determines the mapping used to jump to the next
"      spelling error. Defaults to:
" 	  let spell_next_error_map = "<Leader>sn"
" 
" 
"    spell_previous_error_map                        *spell_previous_error_map*
"      This variable, if set, determines the mapping used to jump to the
"      previous spelling error. Defaults to:
" 	  let spell_previous_error_map = "<Leader>sp"
" 
" 
"    spell_exit_map                                            *spell_exit_map*
"      This variable, if set, determines the mapping used to exit from
"      spelling-checker mode. Defaults to:
" 	  let spell_exit_map = "<Leader>sq"
" 
" 
"    spell_executable                                        *spell_executable*
"      This variable, if set, defines the name of the spell-checker. Defaults :
" 	  let spell_executable = "ispell"
" 
"    spell_filter                                                *spell_filter*
"      This variable, if set, defines the name of a script (followed by |)
"      designed to filter out certain words from the input. Defaults to:
" 	  let spell_filter = ""
"      For example : 
" 	let spell_filter="grep -v '^#' |"
"      would prevent line beginning by # to be spell checked.
" 
" 
"    spell_update_time                                      *spell_update_time*
"      This variable, if set, defines the duration (in ms) between the last
"      cursor movement and the on-the-fly spell check. Defaults to:
" 	  let spell_update_time = 2000
" 
"    spell_language_list      *vimspell_default_language* *spell_language_list*
"      This variable, if set, defines the languages available for spelling. The
"      language names are the ones passed as an option to the spell checker.
"      Defaults to the languages for which a dictionary is present, or if none
"      can be found in the standard location, to: 
" 	  let spell_language_list = "english,francais"
"      Note: The first language of this list is the one selected by default.
" 
"    spell_options                                              *spell_options*
"      This variable, if set, defines additional options passed to the spell
"      checker executable. Defaults for ispell to:
" 	  let spell_options = "-S"
"      and for aspell to:
" 	  let spell_options = ""
" 
"    spell_auto_type                                          *spell_auto_type*
"      This variable, if set, defines a list of filetype for which spell check
"      is done on the fly by default. Set it to "all" if you want on-the-fly
"      spell check for every filetype. Defaults to:
" 	  let spell_auto_type = "tex,mail,text,html,sgml,otl"
" 
"    spell_no_readonly                                      *spell_no_readonly*
"      This variable, if set, defines if read-only files are spell checked or
"      not. Defaults to: 
" 	  let spell_no_readonly = 1  "no spell check for read only files.
" 
"    spell_{spellchecker}_{filetype}_args
"                               *spell_spellchecker_args* *spell_filetype_args*
"      Those variables, if set, define the options passed to the "spellchecker"
"      executable for the files of type "filetype". By default, they are set
"      to options known by ispell and aspell for tex, html, sgml, email
"      filetype.
"      For example:
" 	  let spell_aspell_tex_args = "-t"
" 
"    spell_root_menu                                          *spell_root_menu*
"      This variable, if set, give the name of the menu in which the vimspell
"      menu will be put. Defaults to:
" 	  let spell_root_menu = "Plugin."
"      Note the termination dot.
"      spell_root_menu_priority must be set accordingly. Set them both to "" if
"      you want vimspell menu in the main menu bar.
" 
"    spell_root_menu_priority                        *spell_root_menu_priority*
"      This variable, if set, give the priority of the menu containing the
"      vimspell menu. Defaults to: 
" 	  let spell_root_menu_priority = "500."
"      which is quite on the right of the menu bar.
"      Note the termination dot.
" 
"    spell_menu_priority                                  *spell_menu_priority*
"      This variable, if set, give the priority of the vimspell menu. Defaults
"      to:
" 	  let spell_menu_priority = "10."
"      Note the termination dot.
"      
"
"==============================================================================
"5. Vimspell bugs  {{{2                                         *vimspell-bugs*
"
"    - BUG reported by Fabio Stumbo <f.stumbo@unife.it>:
"      Textual navigation in Plugin submenus doesn't work when pressing <F4>
"      with the following .vimrc settings:
" 	   source $VIMRUNTIME/menu.vim
" 	   set wildmenu
" 	   set cpo-=<
" 	   set wcm=<C-Z>
" 	   map <F4> :emenu <C-Z>
"    - BUG with aspell (aspell-0.33.7.1-7mdk) on HTML files where aspell seems
"      to loop infinitely (Fabio Stumbo <f.stumbo@unife.it>).
"    - BUG - _sa does not work when autospell is set (to be confirmed)
"    - BUG - ispell add many words in a local .ispell_francais when using _si
"    - BUG - autospell seems to not work every time.... Investigation needed.
"    - BUG - spell check is not done in insert mode : this is apparently a
"      feature of VIM. There will perhaps be a hook which will allow this in
"      vim 6.2, but Bram seems quite reluctant in implementing it (because
"      autocomands are dangerous and difficult to test thoroughly).
"
"==============================================================================
"5. Vimspell TODO list  {{{2                                    *vimspell-todo*
"
"    - <Leader>sl should update or suppress mispelling information when auto
"      spellcheck was previously done.
"    - Add options to prevent some words to be checked (like TODO). If not,
"      their highlighting is overwritten by spellcheck's one.
"    - Errors did not get highlighted in all other highlight groups (some work
"      done in comments see SpellTuneCommentSyntax function). Need
"      documentation. 
"    - selection of syntax group for which spelling is done (for example, only
"      string and comments are of interest in a C source code..) - Partly done.
"    - When only some syntax group get highlighted for spell errors, <Leader>sn
"      and <Leader>sp don't work as expected.
"    - reduce the number of external tools used. 
"    - Ideally, errors resulting from on the fly spell checking should be added
"      to a list of all errors (b:spellerrors and SpellErrors highlighting).
"      The problem is to keep a list of unique word, else the list will grown
"      too fast... What is the quickest way to do that ?
"    - display a statusline like "Spellcheck in progress..." and perhaps
"      "Spellcheck done: NNN words seem to be misspelled" (Peter Valach
"      <pvalach@gmx.net>).
"    - add popup menu for suggestion and replacement.
"    - add a engspchk like driver ? (The way of using the whole dictionary in
"      syntax match seems usable, and provides a nicer on-the-fly spell
"      checking).
"    - ...
"    - reduce this TODO list (I didn't think it would have grown so quickly).
"
"==============================================================================
" vim:tw=78:ts=8:ft=help:norl:
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""END_DOC

" Section: Plugin header {{{1
" loaded_vimspell is set to 1 when the initialization begins, and 2 when it
" completes.  This allows various actions to only be taken by functions after
" system initialization.
if exists("loaded_vimspell")
   finish
endif
let loaded_vimspell = 1

" Filetype dependents default options {{{2

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
  silent "unmap <silent> <buffer> " . s:SpellGetOption("spell_case_accept_map","<Leader>si")
  silent "unmap <silent> <buffer> " . s:SpellGetOption("spell_accept_map","<Leader>su")
  silent "unmap <silent> <buffer> " . s:SpellGetOption("spell_ignore_map","<Leader>sa")
  silent "unmap <silent> <buffer> " . s:SpellGetOption("spell_next_error_map","<Leader>sn")
  silent "unmap <silent> <buffer> " . s:SpellGetOption("spell_previous_error_map","<Leader>sp")
  silent "unmap <silent> <buffer> " . s:SpellGetOption("spell_exit_map","<Leader>sq")
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
  execute "map <silent> <buffer> " . s:SpellGetOption("spell_exit_map","<Leader>sq") . " :let @_=<SID>SpellAutoDisable()<CR>"
  execute "map <silent> <buffer> " . s:SpellGetOption("spell_next_error_map","<Leader>sn") . ' /\<\(' . b:spellerrors . '\\|' . b:spell_fly_errors . '\)\><cr>:nohl<cr>'
  execute "map <silent> <buffer> " . s:SpellGetOption("spell_previous_error_map","<Leader>sp") . ' ?\<\(' . b:spellerrors . '\\|' . b:spell_fly_errors . '\)\><cr>:nohl<cr>'
endfunction                                        
                                                   
" Function: s:SpellCheck() {{{2
" Spell check the text after *writing* the buffer. Define highlighting and
" mapping for correction and navigation.
function! s:SpellCheck() 
  echo "Spell check in progress..."
  " save position
  let CursorPosition = line(".") . "normal!" . virtcol(".") . "|"
  syn case match
  let @_=s:SpellCheckLanguage()
  silent update
  syn match SpellErrors "xxxxx"
  syn clear SpellErrors
  let b:spellerrors="nonexisitingwordinthisdociumnt"
  if !exists("b:spell_fly_errors")
    let b:spell_fly_errors="nonexisitingwordinthisdociumnt"
  endif
  let b:mappings=system(b:spell_filter . b:spell_executable . b:spell_options . " -l -d ".b:spell_language." < ".expand("%")." | sort -u | sed 's/\\(.*\\)/syntax match SpellErrors \"\\\\<\\1\\\\>\" ".b:spell_syntax_options."| let b:spellerrors=b:spellerrors.\"\\\\\\\\\\\\\\\\|\\1\"/'")
  exe b:mappings
  call s:SpellContextMapping()
  " TODO : show stats about spell check ?
  exe CursorPosition
  echo "Spell check done."
  redraw
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
  let b:save_mod = &modified
  " save portion of buffer we are interested in .
  silent execute  ":".wtop .",".wbottom."w!".w:tempname
  let &modified = b:save_mod

  " define mappings and syntax hilights for spelling errors
  syn case match
  let @_=s:SpellCheckLanguage()
  syn match SpellFlyErrors "xxxxx"
  syn clear SpellFlyErrors
  let b:spell_fly_errors="nonexisitingwordinthisdociumnt"
  if !exists("b:spellerrors")
    let b:spellerrors="nonexisitingwordinthisdociumnt"
  endif

  let b:mappings=system(b:spell_filter . b:spell_executable . b:spell_options . " -l -d ".b:spell_language." < ".w:tempname." | sort -u | sed 's/\\(.*\\)/syntax match SpellFlyErrors \"\\\\<\\1\\\\>\" ".b:spell_syntax_options."| let b:spell_fly_errors=b:spell_fly_errors.\"\\\\\\\\\\\\\\\\|\\1\"/'")

  exe b:mappings
  call s:SpellContextMapping()

  "syntax cluster Spell contains=SpellErrors,SpellCorrected,SpellFlyErrors
endfunction


" Function: s:SpellSaveIskeyword() {{{2
" save keyword definition, and add ' to it if the selected language needs it.
" In french for example, "l'objet" is a word recognized by ispell.
function! s:SpellSaveIskeyword()
  let w:iskeyword=&iskeyword
  if b:spell_language == "francais "
    let &iskeyword=w:iskeyword.",39,½,æ"
  endif
endfunction

" Function: s:SpellLoadIskeyword() {{{2
" set keyword definition to its previous value.
function! s:SpellLoadIskeyword()
  let &iskeyword=w:iskeyword
endfunction


" Function: s:SpellCreateTemp() {{{2
" Create temp file use for fly spell checking. Define various window dependent
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
" add keyword under cursor to local dictionary, keeping case.
function! s:SpellCaseAccept() 
  call s:SpellSaveIskeyword()
  let @_=system('(echo "*'.substitute(expand("<cword>"),"'","\\\\\'","").'"; echo "#") | '. b:spell_executable . b:spell_options . " -a -d ".b:spell_language)
  syntax case match
  execute "syntax match SpellCorrected \"\\<".escape(expand("<cword>"),"'")."\\>\" transparent contains=NONE ".b:spell_syntax_options
  call s:SpellLoadIskeyword()
endfunction

" Function: s:SpellAccept() {{{2
" add lowercased keyword under cursor to local dictionary
function! s:SpellAccept() 
  call s:SpellSaveIskeyword()
  let @_=system('(echo "&'.substitute(expand("<cword>"),"'","\\\\\'","").'";echo "#") | '. b:spell_executable . b:spell_options . " -a -d ".b:spell_language)
  syntax case ignore
  execute "syntax match SpellCorrected \"\\<".escape(expand("<cword>"),"'")."\\>\" transparent contains=NONE ".b:spell_syntax_options
  call s:SpellLoadIskeyword()
endfunction

" Function: s:SpellIgnore() {{{2
" ignore keyword under cursor for current vim session.
function! s:SpellIgnore() 
  call s:SpellSaveIskeyword()
  syntax case match
  execute "syntax match SpellCorrected \"\\<".expand("<cword>")."\\>\" transparent contains=NONE ".b:spell_syntax_options
  call s:SpellLoadIskeyword()
endfunction

" Function: s:SpellCheckLanguage() {{{2
function! s:SpellCheckLanguage() 
  if !exists("b:spell_syntax_options") 
    let b:spell_syntax_options=""
  endif
  if !exists("b:spell_language")
    " take first language
    let b:spell_language=substitute(b:spell_internal_language_list,",.*","","")
    exec "amenu <silent> disable ".s:menu."Spell.Language.".b:spell_language
  endif
endfunction

" Function: s:SpellSetLanguage(a:language) {{{2
" Select a language
function! s:SpellSetLanguage(language)
  exec "amenu <silent> enable ".s:menu."Spell.Language.".b:spell_language
  let b:spell_language=a:language
  exec "amenu <silent> disable ".s:menu."Spell.Language.".b:spell_language
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
    exec "amenu <silent> enable ".s:menu."Spell.".b:spell_executable
  endif
  let b:spell_executable=a:prog
  exec "amenu <silent> disable ".s:menu."Spell.".b:spell_executable
  "get language list (spell checker dependent)
  let b:spell_internal_language_list=s:SpellGetDicoList().","
    " Init language menu
  exe "aunmenu <silent> ".s:menu."Spell.Language"
  let l:mlang=substitute(b:spell_internal_language_list,",.*","","")
  while matchstr(l:mlang,",") == "" 
    exec "amenu <silent> ".s:prio."50 ".s:menu."Spell.&Language.".l:mlang."  :SpellSetLanguage ".l:mlang."<cr>"
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
    exec "amenu <silent> enable ".s:menu."Spell.Language.".b:spell_language
    " take next one
    let l:res=substitute(b:spell_internal_language_list,".*\\C" . b:spell_language . ",\\([^,]\\+\\),.*","\\1","")
    if matchstr(l:res,",") != "" 
      " if no next, take the first
      let l:res=substitute(b:spell_internal_language_list,",.*","","")
    endif
    let b:spell_language=l:res
  endif
  exec "amenu <silent> disable ".s:menu."Spell.Language.".b:spell_language
  "force spell check
  let b:my_changedtick=0
  echo "Language: ".b:spell_language
endfunction

" Function: s:SpellGetDicoList() {{{2
" try to find a list of install dictionaries
function! s:SpellGetDicoList()
  let l:default = "english,francais"
  let l:opt=s:SpellGetOption("spell_language_list", "")
  if l:opt != ""
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
    " me a way to get aspell directory for dictionaries.
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
      let l:dirfiles = substitute(l:dirfiles, '[~]', '\\~','')
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


" Function: s:SpellTuneCommentSyntax() {{{2
" Add support to do spell checking inside comment. Idea from engspchk.vim from
" Dr. Charles E. Campbell, Jr. <Charles.Campbell.1@gsfc.nasa.gov>.
" This can be done only for those syntax files' comment blocks that
" contains=@cluster.
function! s:SpellTuneCommentSyntax()
  let b:spell_syntax_options = ""
  if     &ft == "amiga"
    syn cluster amiCommentGroup		add=SpellErrors,SpellFlyErrors,SpellCorrected
    " highlight only in comments.
    let b:spell_syntax_options = "contained"
  elseif &ft == "bib"
    syn cluster bibVarContents     	contains=SpellErrors,SpellFlyErrors,SpellCorrected
    syn cluster bibCommentContents 	contains=SpellErrors,SpellFlyErrors,SpellCorrected
    let b:spell_syntax_options = "contained"
  elseif &ft == "c" || &ft == "cpp"
    syn cluster cCommentGroup		add=SpellErrors,SpellFlyErrors,SpellCorrected
    let b:spell_syntax_options = "contained"
  elseif &ft == "csh"
    syn cluster cshCommentGroup		add=SpellErrors,SpellFlyErrors,SpellCorrected
    let b:spell_syntax_options = "contained"
  elseif &ft == "dcl"
    syn cluster dclCommentGroup		add=SpellErrors,SpellFlyErrors,SpellCorrected
    let b:spell_syntax_options = "contained"
  elseif &ft == "fortran"
    syn cluster fortranCommentGroup	add=SpellErrors,SpellFlyErrors,SpellCorrected
    syn match   fortranGoodWord contained	"^[Cc]\>"
    syn cluster fortranCommentGroup	add=fortranGoodWord
    hi link fortranGoodWord fortranComment
    let b:spell_syntax_options = "contained"
  elseif &ft == "sh" || &ft == "ksh" || &ft == "bash"
    syn cluster shCommentGroup		add=SpellErrors,SpellFlyErrors,SpellCorrected
  elseif &ft == "b" 
    syn cluster bCommentGroup		add=SpellErrors,SpellFlyErrors,SpellCorrected
    let b:spell_syntax_options = "contained"
  elseif &ft == "xml"
    syn cluster xmlText		add=SpellErrors,SpellFlyErrors,SpellCorrected
    syn cluster xmlRegionHook	add=SpellErrors,SpellFlyErrors,SpellCorrected

    let b:spell_syntax_options = "contained"
  elseif &ft == "tex"
    syn cluster texCommentGroup		add=SpellErrors,SpellFlyErrors,SpellCorrected

    syn cluster texMatchGroup		add=SpellErrors,SpellFlyErrors,SpellCorrected

  elseif &ft == "vim"
    syn cluster vimCommentGroup		add=SpellErrors,SpellFlyErrors,SpellCorrected

    let b:spell_syntax_options = "contained"
  elseif &ft == "otl"
    syn cluster otlGroup		add=SpellErrors,SpellFlyErrors,SpellCorrected
    let b:spell_syntax_options = "contained"
  endif
endfunction


" Function: s:SpellSetupBuffer() {{{2
" Initialize buffer dependents variables.

function! s:SpellSetupBuffer()
  call s:SpellSetSpellchecker(s:SpellGetOption("spell_executable","ispell"))

  let b:spell_filter=s:SpellGetOption("spell_filter","")

    " get filetype and speller dependent options.
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
  " set on-the-fly spell check, if filetype is set to a type in
  " spell_auto_type variable, and if nothing is known about
  " b:spell_auto_enable (we do not want to re-enable spell checking on a
  " buffer where it was previously disabled.
  if !exists("b:spell_auto_enable") &&  strlen(&filetype) && match(s:SpellGetOption("spell_auto_type","tex,mail,text,html,sgml,otl"),&filetype) >= 0 
    call s:SpellAutoEnable()
  endif

  call s:SpellTuneCommentSyntax()

endfunction

" Function: s:SpellInstallDocumentation() {{{2
" Install vimspell help documentation
function! s:SpellInstallDocumentation(rev)
  silent! unlet s:help_doc
  if !exists("s:vim_doc_path")
    let s:vim_doc_path = s:vim_doc_path_def
  endif
  if !isdirectory(s:vim_plugin_path) || !isdirectory(s:vim_doc_path) || filewritable(s:vim_doc_path) != 2
    return
  endif
  let l:plugin_file = s:vim_plugin_path . '/vimspell.vim'
  let l:doc_file    = s:vim_doc_path . '/vimspell.txt'
  if bufnr(substitute(l:plugin_file, '[\/]', '*', 'g')) != -1
    return
  endif
  if filereadable(s:vim_plugin_path . '/.vimspell.vim.swp')
    "return
  endif
  if filereadable(l:doc_file) && getftime(l:plugin_file) < getftime(l:doc_file)
    return
  endif

  function! s:Make_doc(rev)
    norm zR
    norm gg
    1,/^"\*vimspell.txt\*/-1 d
    /"""""""""""""END_DOC/,$ d 
    % s/^"//
    % s/{{{[1-3]/    /
    exe "normal :1s/#version#/ v" . a:rev . "/"
  endfunction

  if strlen(@%)
    let go_back = 'b ' . bufnr("%")
  else
    let go_back = 'enew!'
  endif
  setl nomodeline
  exe 'enew!'
  exe 'r ' . l:plugin_file
  "exe 'edit! ' . l:plugin_file
  setl modeline
  let buf = bufnr("%")
  setl noswapfile modifiable
  call s:Make_doc(a:rev)
  exe 'w! ' . l:doc_file
  let s:help_doc = 1
  exe go_back
  exe 'bw ' . buf
  exe 'helptags ' . s:vim_doc_path
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
    execute "autocmd! FocusLost ". filename ." call s:SpellCheckWindow()"
    execute "autocmd! BufWinEnter ". filename ." call s:SpellCreateTemp()"
    execute "autocmd! BufWinLeave ". filename ." call s:SpellDeleteTemp()"
  augroup END
  call s:SpellCreateTemp()
  exe "amenu <silent> disable ".s:menu."Spell.Auto"
  exe "amenu <silent> enable ".s:menu."Spell.No\\ auto"
endfunction

" Function: s:SpellAutoDisable() {{{2
" Disable auto spelling
function! s:SpellAutoDisable()
  call s:SpellExit()
  if !exists("b:spell_auto_enable") || b:spell_auto_enable == 0
    return
  endif
  let b:spell_auto_enable = 0
  augroup spellchecker
    silent "autocmd! CursorHold ". filename 
    silent "autocmd! FocusLost ". filename 
    silent "autocmd! BufWinEnter ". filename 
    silent "autocmd! BufWinLeave ". filename 
  augroup END
  let  &updatetime=g:spell_old_update_time
  unlet! w:wtop
  exe "amenu <silent> enable ".s:menu."Spell.Auto"
  exe "amenu <silent> disable ".s:menu."Spell.No\\ auto"
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

" Allow reloading vimspell.vim
com! SpellReload unlet! loaded_vimspell | SpellAutoDisable | runtime plugin/vimspell.vim

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

if !hasmapto('<Plug>SpellAutoEnable')
  nmap <silent> <unique> <Leader>sA <Plug>SpellAutoEnable
endif

if !hasmapto('<Plug>SpellProposeAlternatives')
  nmap <silent> <unique> <Leader>s? <Plug>SpellProposeAlternatives
endif

if !hasmapto('<Plug>SpellChangeLanguage')
  nmap <silent> <unique> <Leader>sl <Plug>SpellChangeLanguage
endif


" Section: Menu items {{{1
"
let s:menu=s:SpellGetOption("spell_root_menu","Plugin.")
let s:prio=s:SpellGetOption("spell_root_menu_priority","500.") . s:SpellGetOption("spell_menu_priority","10.")

exe "amenu <silent> ".s:prio."10  ".s:menu."Spell.&Spell       <Plug>SpellCheck"
exe "amenu <silent> ".s:prio."15  ".s:menu."Spell.&Off         <Plug>SpellExit"
exe "amenu <silent> ".s:prio."20  ".s:menu."Spell.&Alternative <Plug>SpellProposeAlternatives"
exe "amenu <silent> ".s:prio."30  ".s:menu."Spell.&Language.Next\ one <Plug>SpellChangeLanguage"
exe "amenu <silent> ".s:prio."    ".s:menu."Spell.&Language.-Sep-   :"
exe "amenu <silent> ".s:prio."40  ".s:menu."Spell.-Sep-		:"
exe "amenu <silent> ".s:prio."45  ".s:menu."Spell.A&uto <Plug>SpellAutoEnable"
exe "amenu <silent> ".s:prio."50  ".s:menu."Spell.&No\\ auto  <Plug>SpellAutoDisable  "
exe "amenu <silent> ".s:prio."100 ".s:menu."Spell.-Sep2-	    :"
exe "amenu <silent> ".s:prio."101 ".s:menu."Spell.aspell :SpellSetSpellchecker aspell<CR>"
exe "amenu <silent> ".s:prio."102 ".s:menu."Spell.ispell :SpellSetSpellchecker ispell<CR>"

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

" Section: Doc installation {{{1
" 
  let s:vim_plugin_path  = expand("<sfile>:p:h")
  let s:vim_doc_path_def = expand("<sfile>:p:h:h") . '/doc'
  let s:revision=substitute("$Revision: 1.40 $",'\$\S*: \([.0-9]\+\) \$','\1','')
  silent! call s:SpellInstallDocumentation(s:revision)
  if exists("s:help_doc")
    echo "vimspell v" . s:revision . ": Installed help-documentation."
  endif


" Section: Plugin completion {{{1
let loaded_vimspell=2
"}}}1
" vim600: set foldmethod=marker ts=8 sw=2 sts=2 si sta  :
