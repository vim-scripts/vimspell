"$Id: vimspell.vim,v 1.48 2003/04/29 12:20:56 clabaut Exp $
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Name:		    vimspell
" Description:	    Use ispell to highlight spelling errors on the fly, or on
"		    demand. 
" Author:	    Mathieu Clabaut <mathieu.clabaut@free.fr>
" Original Author:  Claudio Fleiner <claudio@fleiner.com>
" Url:		    http://www.vim.org/scripts/script.php?script_id=465
"
" Last Change:	    29-Apr-2003.
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
"		      report and patches :-). He helped me in reducing the
"		      TODO list and in doing early testing before each
"		      release.
"		    Tim Allen <firstlight@redneck.gacracker.org> for showing
"		      me a way to autogenerate help file in his 'posting'
"		      script.
"		    Mikolaj Machowski <mikmach@wp.pl> for implementation of on
"		      the fly spell checking in insert mode.
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
"    Faq                 : |vimspell-tips|
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
"     - 'ispell' or 'aspell' spell checkers
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
"      highlight SpellErrors ctermfg=Red guifg=Red 
" 	   \ cterm=underline gui=underline term=reverse
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
"    behavior. Note that variables are looked for in the following order :
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
"
"    spell_language_list      *vimspell_default_language* *spell_language_list*
"      This variable, if set, defines the languages available for spelling. The
"      language names are the ones passed as an option to the spell checker.
"      Defaults to the languages for which a dictionary is present, or if none
"      can be found in the standard location, to: 
" 	  let spell_language_list = "english,francais"
"      Note: The first language of this list is the one selected by default.
"
"
"    spell_options                                              *spell_options*
"      This variable, if set, defines additional options passed to the spell
"      checker executable. Defaults for ispell to:
" 	  let spell_options = "-S"
"      and for aspell to:
" 	  let spell_options = ""
"
"
"    spell_auto_type                                          *spell_auto_type*
"      This variable, if set, defines a list of filetype for which spell check
"      is done on the fly by default. Set it to "all" if you want on-the-fly
"      spell check for every filetype. You can use the token "none" if you
"      want on-the-fly spell check for file which do not have a filetype.
"      Defaults to:
" 	  let spell_auto_type = "tex,mail,text,html,sgml,otl,none"
"      Note: the "text" and "otl" filetypes are not defined by vim. Look at
"      |new-filetype| to see how you could yourself define a new filetype.
"
"
"    spell_insert_mode                                      *spell_insert_mode*
"      This variable if set, set up a hack to allow spell checking in insert
"      mode. This is normally not possible by mean of autocommands, but is
"      done with a map to the <Space> key. Each time that <Space> is hitted,
"      the current line is spell checked. This feature can slow down vim
"      enough but is otherwise very nice.
"      Note that the mapping is defined only when spell check is done on the
"      fly (see |spell_auto_type|).
"      Defaults to:
" 	  let spell_insert_mode = 1
"
"
"    spell_no_readonly                                      *spell_no_readonly*
"      This variable, if set, defines if read-only files are spell checked or
"      not. Defaults to: 
" 	  let spell_no_readonly = 1  "no spell check for read only files.
"
"
"    spell_{spellchecker}_{filetype}_args
"                               *spell_spellchecker_args* *spell_filetype_args*
"      Those variables, if set, define the options passed to the "spellchecker"
"      executable for the files of type "filetype". By default, they are set
"      to options known by ispell and aspell for tex, html, sgml, email
"      filetype. See also |vimspell-ispell-dont-work| below.
"      For example:
" 	  let spell_aspell_tex_args = "-t"
"
"
"    spell_{language}_iskeyword                               *spell_iskeyword*
"      Those variables if set define the characters which are part of a word
"      in the selected language. See |iskeyword| for more informations.
"      The following is defined:
"	   let spell_francais_iskeyword  =  ",39,�,�,�,�,-"
"      which say that the quote, the hyphen and dome other digraphs must be
"      considered as being part of words.
"
"
"    spell_root_menu                                          *spell_root_menu*
"      This variable, if set, give the name of the menu in which the vimspell
"      menu will be put. Defaults to:
" 	  let spell_root_menu = "Plugin."
"      Note the termination dot.
"      spell_root_menu_priority must be set accordingly. Set them both to "" if
"      you want vimspell menu in the main menu bar.
"
"
"    spell_root_menu_priority                        *spell_root_menu_priority*
"      This variable, if set, give the priority of the menu containing the
"      vimspell menu. Defaults to: 
" 	  let spell_root_menu_priority = "500."
"      which is quite on the right of the menu bar.
"      Note the termination dot.
"
"
"    spell_menu_priority                                  *spell_menu_priority*
"      This variable, if set, give the priority of the vimspell menu. Defaults
"      to:
" 	  let spell_menu_priority = "10."
"      Note the termination dot.
"      
"
"==============================================================================
"5. Vimspell faq  {{{2                                           *vimspell-faq*
"
"				  		    *vimspell-ispell-dont-work*
"   When I try to spell check an HTML file using ispell, I got an error like  
"   "Not an editor command:  -pfile | -wchars | ..."
"
"	By default, vimspell pass the "-H" option to tell ispell that the file
"	in which he is looking for errors is an HTML file. This option changed
"	accross ispell versions. You should adjust the
"	'spell_ispell_html_args' and 'spell_ispell_sgml_args' variables
"	appropriately. For example, with ispell 3.1.20, you should set the
"	following lines in your .vimrc :
"	  let spell_ispell_html_args  = "-h"
"	  let spell_ispell_sgml_args  = "-h"  
"
"
"==============================================================================
"6. Vimspell bugs  {{{2                                         *vimspell-bugs*
"
"    - BUG <leader>sl move cursor.
"    - BUG for help installation when the script is not installed in a
"      directory hierarchy which is not user writable. Thanks to Peter Kaagman
"      <bilbo@nedlinux.nl> for pinpointing the problem.
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
"    - BUG - ispell add many words in a local .ispell_francais when using _si
"    - BUG - spell check is not done in insert mode : this is apparently a
"      feature of VIM. There will perhaps be a hook which will allow this in
"      vim 6.2, but Bram seems quite reluctant in implementing it (because
"      autocomands are dangerous and difficult to test thoroughly).
"
"==============================================================================
"7. Vimspell TODO list  {{{2                                    *vimspell-todo*
"
"    - Add an optional feature which would allow spell checking in insert
"      mode, by mean of space and ponctuation mapping (suggestion of Mikolaj
"      Machowski <mikmach@wp.pl>).
"    - Add documentation about older ispell (3.1.20), which needs a -h
"      parameter for HTML files -partly done : FAQ.
"    - Add options to prevent some words to be checked (like TODO). If not,
"      their highlighting is overwritten by spellcheck's one (depends of TODO
"      highlighting definition... To be investigated).
"    - Add actual (potentially user defined) shorcuts in menu (with <Leader>
"      replaced by its value).
"    - Errors did not get highlighted in all other highlight groups (some work
"      done in comments see SpellTuneCommentSyntax function). Need
"      documentation. 
"    - selection of syntax group for which spelling is done (for example, only
"      string and comments are of interest in a C source code..) - Partly done.
"    - When only some syntax group get highlighted for spell errors, <Leader>sn
"      and <Leader>sp don't work as expected.
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

" Exit quickly when already loaded or when 'compatible' is set.
if exists("loaded_vimspell") || &compatible
   finish
endif
let loaded_vimspell = 1
scriptencoding iso-8859-15

" Filetype, spell checker and/or language dependents default options {{{2

let s:spell_ispell_tex_args   = "-t" 
let s:spell_ispell_html_args  = "-H"
let s:spell_ispell_sgml_args  = "-H"  
let s:spell_ispell_nroff_args = "-n"  

let s:spell_aspell_tex_args   = "--mode=tex" 
let s:spell_aspell_html_args  = "--mode=sgml" 
let s:spell_aspell_sgml_args  = "--mode=sgml" 
let s:spell_aspell_mail_args  = "--mode=email" 

" In french for example, "l'objet" or "�uvre" are words recognized by ispell.
" add "'", "e in o" and "e in a"  to 'iskeyword'
" 'there should probably be some encoding consideration here... ? )
"
let s:spell_francais_iskeyword  =  ",39,�,�,�,�,-"

let s:known_spellchecker = "aspell,ispell"


" Section: Utility functions {{{1
"
" Function: s:SpellProposeAlternatives() {{{2
" Propose alternative for keyword under cursor. Define mapping used to correct
" the word under the cursor.
function! s:SpellProposeAlternatives()
  call s:SpellCheckLanguage()

  let l:alternatives=system("echo ".expand("<cword>")." | "
	\ . b:spell_executable . b:spell_options . " -a -d ".b:spell_language)
    " add \n, that the next substitute works
  let l:alternatives=substitute(l:alternatives, "^", "\n", "g")               
    " delete all irrelevant lines
  let l:alternatives=substitute(l:alternatives, "\n[@*#][^\n]*", "", "g")     
    " join lines
  let l:alternatives=substitute(l:alternatives, "\n", "", "g")                
    " delete irrelevant begin of alternatives
  let l:alternatives=substitute(l:alternatives, "^.*: \\(.*\\)", "\\1, ", "")

  let l:alterNr=1
  let l:alter=""
  let l:index=stridx(l:alternatives, ", ")

  while (l:index > 0 && l:alterNr <= 9)
    let l:oneAlter=strpart(l:alternatives, 0, l:index)
    let l:alternatives=strpart(l:alternatives, l:index+2)
    let l:index=stridx(l:alternatives, ", ")

    let alter=alter."map <silent> <buffer> ".l:alterNr
	  \ . " :let r=<SID>SpellReplace(\"".l:oneAlter
	  \ . "\")<CR> | map <silent> <buffer> *"
	  \ . l:alterNr." :let r=<SID>SpellReplaceEverywhere(\"".l:oneAlter
	  \ . "\")<CR> | echo \"".l:alterNr.": ".l:oneAlter."\" | "

    let l:alterNr=l:alterNr+1
  endwhile

  if l:alter !=? ""
    echo "Checking ".expand("<cword>")
	  \.": Type 0 for no change, r to replace, *<number> to replace all or"
    exe l:alter
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

" Function: s:SpellContextMapping() {{{2
" Define mapping defined for spell checking.
function! s:SpellContextMapping()
  execute "map <silent> <buffer> " 
	\ . s:SpellGetOption("spell_case_accept_map","<Leader>si") 
	\ . " :call <SID>SpellCaseAccept()<cr><c-l>"
  execute "map <silent> <buffer> " 
	\ . s:SpellGetOption("spell_accept_map","<Leader>su") 
	\ . ":call <SID>SpellAccept()<cr><c-l>"
  execute "map <silent> <buffer> " 
	\ . s:SpellGetOption("spell_ignore_map","<Leader>sa") 
	\ . " :call <SID>SpellIgnore()<cr><c-l>"
  execute "map <silent> <buffer> " 
	\ . s:SpellGetOption("spell_exit_map","<Leader>sq") 
	\ . " :let @_=<SID>SpellAutoDisable()<CR>"
  execute "map <silent> <buffer> " 
	\ . s:SpellGetOption("spell_next_error_map","<Leader>sn") 
	\ . ' /\<\(' . escape(b:spellerrors, "\\") . '\)\><cr>:nohl<cr>'
  execute "map <silent> <buffer> " 
	\ . s:SpellGetOption("spell_previous_error_map","<Leader>sp") 
	\ . ' ?\<\(' . escape(b:spellerrors, "\\") . '\)\><cr>:nohl<cr>'
endfunction                                        
                                                   
" Function: s:SpellSaveIskeyword() {{{2
" save keyword definition, and add language specific keyword.
function! s:SpellSaveIskeyword()
  let l:options="spell_".b:spell_language."_iskeyword"
  if exists("s:".l:options)
    let l:ik_options=s:SpellGetOption(l:options,s:{l:options})
  else
    let l:ik_options=s:SpellGetOption(l:options,"")
  endif
  let w:iskeyword=&iskeyword
  let &iskeyword=w:iskeyword.l:ik_options
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
  let @_=system('(echo "*'.expand("<cword>"). '"; echo "#") | ' 
	\ . b:spell_executable . b:spell_options 
	\ . " -a -d ".b:spell_language)
  if exists("b:spellcorrected")
    let b:spellcorrected=b:spellcorrected."\\|".escape(expand("<cword>"),"'")
  else
    let  b:spellcorrected=escape(expand("<cword>"),"'")
  endif

  syntax case match
  execute "syntax match SpellCorrected \"\\<\\(".b:spellcorrected
	\ . "\\)\\>\" transparent contains=NONE ".b:spell_syntax_options
  call s:SpellLoadIskeyword()
endfunction


" Function: s:SpellAccept() {{{2
" add lowercased keyword under cursor to local dictionary
function! s:SpellAccept() 
  call s:SpellSaveIskeyword()
  let @_=system('(echo "&'.expand("<cword>") . '";echo "#") | '
	\ . b:spell_executable . b:spell_options 
	\ . " -a -d ".b:spell_language)
  if exists("b:spellcorrectedi")
    let b:spellicorrected=b:spellicorrected."\\|".escape(expand("<cword>"),"'")
  else
    let  b:spellicorrected=escape(expand("<cword>"),"'")
  endif

  syntax case ignore
  execute "syntax match SpellCorrected \"\\<\\(".b:spellicorrected
	\ . "\\)\\>\" transparent contains=NONE ".b:spell_syntax_options
  call s:SpellLoadIskeyword()
endfunction


" Function: s:SpellIgnore() {{{2
" ignore keyword under cursor for current vim session.
function! s:SpellIgnore() 
  call s:SpellSaveIskeyword()
  if exists("b:spellcorrected")
    let b:spellcorrected=b:spellcorrected."\\|".escape(expand("<cword>"),"'")
  else
    let  b:spellcorrected=escape(expand("<cword>"),"'")
  endif
  syntax case match
  execute "syntax match SpellCorrected \"\\<\\(".b:spellcorrected
	\ . "\\)\\>\" transparent contains=NONE ".b:spell_syntax_options
  call s:SpellLoadIskeyword()
endfunction


" Function: s:SpellCheckLanguage() {{{2
" verify that a language is defined or else defined one.
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

" Function: s:SpellVerifyLanguage(a:language) {{{2
" Verify teh availability of the language for the previously selected
" spell checker.
function! s:SpellVerifyLanguage(language)
  if  b:spell_executable == "ispell" || b:spell_executable == "aspell"
    let l:dirs = system("echo word |". b:spell_executable ." -l -d". a:language ) 
    if v:shell_error != 0
      echo "Language '". a:language ."' not known from ". b:spell_executable ."."
      return 1
    endif
  else
    echo "No driver for '". b:spell_executable."' spell checker."
    return 1
  endif
  return 0
endfunction

" Function: s:SpellGetDicoList() {{{2
" try to find a list of installed dictionaries
function! s:SpellGetDicoList()
  let l:default = "english,francais"

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
    syn cluster amiCommentGroup		add=SpellErrors,SpellCorrected
    " highlight only in comments (i.e. if SpellErrors are contained).
    let b:spell_syntax_options = "contained"
  elseif &ft == "bib"
    syn cluster bibVarContents     	contains=SpellErrors,SpellCorrected
    syn cluster bibCommentContents 	contains=SpellErrors,SpellCorrected
    let b:spell_syntax_options = "contained"
  elseif &ft == "c" || &ft == "cpp"
    syn cluster cCommentGroup		add=SpellErrors,SpellCorrected
    let b:spell_syntax_options = "contained"
  elseif &ft == "csh"
    syn cluster cshCommentGroup		add=SpellErrors,SpellCorrected
    let b:spell_syntax_options = "contained"
  elseif &ft == "dcl"
    syn cluster dclCommentGroup		add=SpellErrors,SpellCorrected
    let b:spell_syntax_options = "contained"
  elseif &ft == "fortran"
    syn cluster fortranCommentGroup	add=SpellErrors,SpellCorrected
    syn match   fortranGoodWord contained	"^[Cc]\>"
    syn cluster fortranCommentGroup	add=fortranGoodWord
    hi link fortranGoodWord fortranComment
    let b:spell_syntax_options = "contained"
  elseif &ft == "sh" || &ft == "ksh" || &ft == "bash"
    syn cluster shCommentGroup		add=SpellErrors,SpellCorrected
  elseif &ft == "b" 
    syn cluster bCommentGroup		add=SpellErrors,SpellCorrected
    let b:spell_syntax_options = "contained"
  elseif &ft == "xml"
    syn cluster xmlText		add=SpellErrors,SpellCorrected
    syn cluster xmlRegionHook	add=SpellErrors,SpellCorrected

    let b:spell_syntax_options = "contained"
  elseif &ft == "tex"
    syn cluster texCommentGroup		add=SpellErrors,SpellCorrected

    syn cluster texMatchGroup		add=SpellErrors,SpellCorrected

  elseif &ft == "vim"
    syn cluster vimCommentGroup		add=SpellErrors,SpellCorrected

    let b:spell_syntax_options = "contained"
  elseif &ft == "otl"
    syn cluster otlGroup		add=SpellErrors,SpellCorrected
    let b:spell_syntax_options = "contained"
  endif
endfunction

" Function: s:SpellSetupBuffer() {{{2
" Set buffer dependents variables. This function is called when entering a
" buffer.
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
  " spell_auto_type variable (particular case for "all" and "none"), and if
  " nothing is known about b:spell_auto_enable (we do not want to re-enable
  " spell checking on a buffer where it was previously disabled.
  let b:spell_auto_type = s:SpellGetOption("spell_auto_type",
      \"tex,mail,text,html,sgml,otl,none") 
  if !exists("b:spell_auto_enable") 
	\ && ( (strlen(&filetype) 
		\ && (match(b:spell_auto_type,&filetype) >= 0 
		  \ ||match(b:spell_auto_type, "all") >=0 )
	      \ )
	  \ || (!strlen(&filetype)
		\ && match(b:spell_auto_type, "none") >=0 )
	  \ )
    call s:SpellAutoEnable()
  endif

  call s:SpellCheckLanguage()

  call s:SpellTuneCommentSyntax()
endfunction

" Function: s:SpellInstallDocumentation() {{{2
" Install vimspell help documentation
function! s:SpellInstallDocumentation(rev)
  silent! unlet s:help_doc
  if !exists("s:vim_doc_path")
    let s:vim_doc_path = s:vim_doc_path_def
  endif
  if !isdirectory(s:vim_plugin_path) 
	\ || !isdirectory(s:vim_doc_path) 
	\ || filewritable(s:vim_doc_path) != 2
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

" Function: s:SpellCheck() {{{2
" Spell check the text after *writing* the buffer. Define highlighting and
" mapping for correction and navigation.
function! s:SpellCheck() 
  echo "Spell check in progress..."
  " save position
  let l:cursorPosition = line(".") . "normal!" . virtcol(".") . "|"
  syn case match
  call s:SpellCheckLanguage()
  let l:filename=expand("%")
  if strlen(l:filename)
    silent update
  else
    " the buffer is a new one.
    let l:save_mod = &modified
    let l:filename = tempname()
    " save buffer to a temporary file.
    normal 1GO	  
    silent execute  ":2,$w!".l:filename
    execute "1d"
    let &modified = l:save_mod
  endif
  syn match SpellErrors "xxxxx"
  syn clear SpellErrors

  " This is needed that we can use stridx instead of match for unique error
  " list.
  " Clear b:spellerrors when doing a complete check to get rid of old errors
  let b:spellerrors="nonexisitingwordinthisdociumnt\\"
  let b:spellcorrected="nonexisitingwordinthisdociumnt"
  let b:spellicorrected="nonexisitingwordinthisdociumnt"

  let l:errors=system(b:spell_filter . b:spell_executable . b:spell_options 
	\. " -l -d ".b:spell_language." < ".l:filename)
  let l:index=stridx(l:errors, "\n")
  let l:spellcount=0
  let l:errorcount=0

  while (l:index > 0)
    " use stridx/strpart instead of sustitute, because it is faster
    let l:oneError="|".strpart(l:errors, 0, l:index)."\\"
    let l:errors=strpart(l:errors, l:index+1)
    let l:index=stridx(l:errors, "\n")
    let l:errorcount=l:errorcount+1

    " only add new errors
    " stridx instead of match for better performance
    if(stridx(b:spellerrors, l:oneError) == -1 )
      let b:spellerrors=b:spellerrors . l:oneError
      let l:spellcount=l:spellcount+1
  endif
  endwhile

  " remove unneeded tail
  let b:spellerrors=strpart(b:spellerrors, 0, strlen(b:spellerrors)-1)

  " install regex for higlight
  syntax case ignore
  execute "syntax match SpellCorrected \"\\<\\(".b:spellicorrected
	\ . "\\)\\>\" transparent contains=NONE ".b:spell_syntax_options
  syntax case match
  execute "syntax match SpellErrors \"\\<\\(".b:spellerrors."\\)\\>\" "
	\ . b:spell_syntax_options
  execute "syntax match SpellCorrected \"\\<\\(".b:spellcorrected
	\ . "\\)\\>\" transparent contains=NONE ".b:spell_syntax_options

  call s:SpellContextMapping()
  execute l:cursorPosition
  redraw!
  echo "Spell check done: ".l:spellcount." possible spell errors in "
        \ .l:errorcount." words."
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

  " define mappings and syntax highlighting for spelling errors
  syn case match
  call s:SpellCheckLanguage()
  syn match SpellErrors "xxxxx"
  syn clear SpellErrors

  " This is needed that we can use stridx instead of match for unique error
  " list
  if exists("b:spellerrors")
    let b:spellerrors=b:spellerrors."\\"
  else
    let b:spellerrors="nonexisitingwordinthisdociumnt\\"
    let b:spellcorrected="nonexisitingwordinthisdociumnt"
    let b:spellicorrected="nonexisitingwordinthisdociumnt"
  endif

  let l:errors=system(b:spell_filter . b:spell_executable . b:spell_options 
	\ . " -l -d ".b:spell_language." < ".w:tempname)
  let l:index=stridx(l:errors, "\n")

  while (l:index > 0)
    " use stridx/strpart instead of sustitude, because it is faster
    let l:oneError="|".strpart(l:errors, 0, l:index)."\\"
    let l:errors=strpart(l:errors, l:index+1)
    let l:index=stridx(l:errors, "\n")

    " only add new errors
    " use stridx instead of match for better performance
    if(stridx(b:spellerrors, l:oneError) == -1 )
      let b:spellerrors=b:spellerrors . l:oneError
    endif
  endwhile

  " remove unneeded tail
  let b:spellerrors=strpart(b:spellerrors, 0, strlen(b:spellerrors)-1)

  " install regex for syntax highlighting
  syntax case ignore
  execute "syntax match SpellCorrected \"\\<\\(".b:spellicorrected
	\ . "\\)\\>\" transparent contains=NONE ".b:spell_syntax_options
  syntax case match
  execute "syntax match SpellErrors \"\\<\\(".b:spellerrors."\\)\\>\" "
	\ . b:spell_syntax_options 
  execute "syntax match SpellCorrected \"\\<\\(".b:spellcorrected
	\ . "\\)\\>\" transparent contains=NONE ".b:spell_syntax_options

  call s:SpellContextMapping()

  "syntax cluster Spell contains=SpellErrors,SpellCorrected
endfunction

" Function: s:SpellCheckLine() {{{2
" Spell check the line under the cursor *without* writing the buffer. Define
" highlighting and mapping for correction and navigation.
" May be called by a mapping on <Space>, for example.
function! s:SpellCheckLine() 
  " define mappings and syntax highlighting for spelling errors
  syn case match
  call s:SpellCheckLanguage()
  syn match SpellErrors "xxxxx"
  syn clear SpellErrors

  " This is needed that we can use stridx instead of match for unique error
  " list
  if exists("b:spellerrors")
    let b:spellerrors=b:spellerrors."\\"
  else
    let b:spellerrors="nonexisitingwordinthisdociumnt\\"
    let b:spellcorrected="nonexisitingwordinthisdociumnt"
    let b:spellicorrected="nonexisitingwordinthisdociumnt"
  endif

  let l:ispexpr = "echo '".getline('.')."'|".b:spell_filter.b:spell_executable
	\ . b:spell_options . ' -l -d '.b:spell_language
  let l:errors=system(l:ispexpr)
  let l:index=stridx(l:errors, "\n")

  while (l:index > 0)
    " use stridx/strpart instead of sustitude, because it is faster
    let l:oneError="|".strpart(l:errors, 0, l:index)."\\"
    let l:errors=strpart(l:errors, l:index+1)
    let l:index=stridx(l:errors, "\n")

    " only add new errors
    " use stridx instead of match for better performance
    if(stridx(b:spellerrors, l:oneError) == -1 )
      let b:spellerrors=b:spellerrors . l:oneError
    endif
  endwhile

  " remove unneeded tail
  let b:spellerrors=strpart(b:spellerrors, 0, strlen(b:spellerrors)-1)

  " install regex for syntax highlighting
  syntax case ignore
  execute "syntax match SpellCorrected \"\\<\\(".b:spellicorrected
	\ . "\\)\\>\" transparent contains=NONE ".b:spell_syntax_options
  syntax case match
  execute "syntax match SpellErrors \"\\<\\(".b:spellerrors."\\)\\>\" "
	\ . b:spell_syntax_options 
  execute "syntax match SpellCorrected \"\\<\\(".b:spellcorrected
	\ . "\\)\\>\" transparent contains=NONE ".b:spell_syntax_options

  call s:SpellContextMapping()

  "syntax cluster Spell contains=SpellErrors,SpellCorrected
endfunction


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
    execute "autocmd! BufEnter ". filename ." call s:SpellCreateTemp()"
    execute "autocmd! BufWinLeave ". filename ." call s:SpellDeleteTemp()"
  augroup END
  call s:SpellCreateTemp()
  exe "amenu <silent> disable ".s:menu."Spell.Auto"
  exe "amenu <silent> enable ".s:menu."Spell.No\\ auto"
  " add 
  if s:SpellGetOption("spell_insert_mode",1)
    inoremap <buffer> <silent> <unique> <Space> <Space><C-O>:SpellCheckLine<cr>
  endif
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
  iunmap <buffer> <Space>
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
  let b:spell_internal_language_list=s:SpellGetOption("spell_language_list", "")
  if  b:spell_internal_language_list != ""
    " verify user defined language list
    let l:must_verify = 1
  else
    "get language list (spell checker dependent. Ought to be valid)
    let b:spell_internal_language_list=s:SpellGetDicoList()
    let l:must_verify = 0
  endif
  let b:spell_internal_language_list = b:spell_internal_language_list.","
    " Init language menu
  exe "aunmenu <silent> ".s:menu."Spell.Language"
  let l:mlang=substitute(b:spell_internal_language_list,",.*","","")
  while matchstr(l:mlang,",") == "" 
    if !l:must_verify || !s:SpellVerifyLanguage(l:mlang)
      exec "amenu <silent> ".s:prio."50 ".s:menu."Spell.&Language.".l:mlang
	    \ . "  :SpellSetLanguage ".l:mlang."<cr>"
    endif
    " take next one
    let l:mlang=substitute(b:spell_internal_language_list,".*\\C" . l:mlang 
	  \ . ",\\([^,]\\+\\),.*","\\1","")
  endwhile
  "force spell check
  let b:my_changedtick=0
  " remove actual highlighting and spelling errors
  unlet! b:spellerrors
  syn match SpellErrors "xxxxx"
  syn match SpellCorrected "xxxxx"
  syn clear SpellErrors
  syn clear SpellCorrected
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
    let l:res=substitute(b:spell_internal_language_list,".*\\C" 
	  \ . b:spell_language . ",\\([^,]\\+\\),.*","\\1","")
    if matchstr(l:res,",") != "" 
      " if no next, take the first
      let l:res=substitute(b:spell_internal_language_list,",.*","","")
    endif
    let b:spell_language=l:res
  endif
  exec "amenu <silent> disable ".s:menu."Spell.Language.".b:spell_language
  "force spell check
  let b:my_changedtick=0
  " remove actual highlighting and spelling errors
  unlet! b:spellerrors
  syn match SpellErrors "xxxxx"
  syn match SpellCorrected "xxxxx"
  syn clear SpellErrors
  syn clear SpellCorrected
  echo "Language: ".b:spell_language
endfunction

" Function: s:SpellSetLanguage(a:language) {{{2
" Select a language
function! s:SpellSetLanguage(language)
  call s:SpellCheckLanguage()
  if s:SpellVerifyLanguage(a:language)
    return
  endif

  exec "amenu <silent> enable ".s:menu."Spell.Language.".b:spell_language
  let b:spell_language=a:language
  exec "amenu <silent> disable ".s:menu."Spell.Language.".b:spell_language
  "TODO : some verification about arguments ?
  "force spell check
  let b:my_changedtick=0
  " remove actual highlighting and spelling errors
  unlet! b:spellerrors
  syn match SpellErrors "xxxxx"
  syn match SpellCorrected "xxxxx"
  syn clear SpellErrors
  syn clear SpellCorrected
  echo "Language: ".b:spell_language
endfunction

" Function: s:SpellExit() {{{2
" remove syntax highlighting and mapping defined for spell checking.
function! s:SpellExit()
  silent "unmap <silent> <buffer> " 
	\ . s:SpellGetOption("spell_case_accept_map","<Leader>si")
  silent "unmap <silent> <buffer> " 
	\ . s:SpellGetOption("spell_accept_map","<Leader>su")
  silent "unmap <silent> <buffer> " 
	\ . s:SpellGetOption("spell_ignore_map","<Leader>sa")
  silent "unmap <silent> <buffer> " 
	\ . s:SpellGetOption("spell_next_error_map","<Leader>sn")
  silent "unmap <silent> <buffer> " 
	\ . s:SpellGetOption("spell_previous_error_map","<Leader>sp")
  silent "unmap <silent> <buffer> " 
	\ . s:SpellGetOption("spell_exit_map","<Leader>sq")
  syn match SpellErrors "xxxxx"
  syn match SpellCorrected "xxxxx"
  syn clear SpellErrors
  syn clear SpellCorrected
endfunction

" Section: Command definitions {{{1
com! SpellAutoEnable call s:SpellAutoEnable()
com! SpellAutoDisable call s:SpellAutoDisable()
com! SpellCheck call s:SpellCheck()
com! SpellExit call s:SpellExit()
com! SpellProposeAlternatives call s:SpellProposeAlternatives()
com! SpellChangeLanguage call s:SpellChangeLanguage()
com! SpellCheckLine call s:SpellCheckLine()
com! -nargs=1 SpellSetLanguage call s:SpellSetLanguage(<f-args>)
com! -nargs=1 SpellSetSpellchecker call s:SpellSetSpellchecker(<f-args>)
      \<Bar> echo "Spell checker: ".<f-args>

" Allow reloading vimspell.vim
com! SpellReload unlet! loaded_vimspell | SpellAutoDisable 
      \ | runtime plugin/vimspell.vim

" Section: Plugin  mappings {{{1
nnoremap <silent> <unique> <Plug>SpellCheck          :SpellCheck<cr>
nnoremap <silent> <unique> <Plug>SpellCheckLine      :SpellCheckLine<cr>
nnoremap <silent> <unique> <Plug>SpellExit           :SpellExit<cr>
nnoremap <silent> <unique> <Plug>SpellChangeLanguage :SpellChangeLanguage<cr>  
nnoremap <silent> <unique> <Plug>SpellAutoEnable     :SpellAutoEnable<cr>
nnoremap <silent> <unique> <Plug>SpellAutoDisable    :SpellAutoDisable<cr>
nnoremap <silent> <unique> <Plug>SpellProposeAlternatives  
      \ :SpellProposeAlternatives<CR>

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
let s:prio=s:SpellGetOption("spell_root_menu_priority","500.") 
      \ . s:SpellGetOption("spell_menu_priority","10.")

exe "amenu <silent> ".s:prio."10  ".s:menu
      \ . "Spell.&Spell       <Plug>SpellCheck"
exe "amenu <silent> ".s:prio."15  ".s:menu
      \ . "Spell.&Off         <Plug>SpellExit"
exe "amenu <silent> ".s:prio."20  ".s:menu
      \ . "Spell.&Alternative <Plug>SpellProposeAlternatives"
exe "amenu <silent> ".s:prio."30  ".s:menu
      \ . "Spell.&Language.Next\ one <Plug>SpellChangeLanguage"
exe "amenu <silent> ".s:prio."    ".s:menu
      \ . "Spell.&Language.-Sep-   :"
exe "amenu <silent> ".s:prio."40  ".s:menu
      \ . "Spell.-Sep-		:"
exe "amenu <silent> ".s:prio."45  ".s:menu
      \ . "Spell.A&uto <Plug>SpellAutoEnable"
exe "amenu <silent> ".s:prio."50  ".s:menu
      \ . "Spell.&No\\ auto  <Plug>SpellAutoDisable  "
exe "amenu <silent> ".s:prio."100 ".s:menu
      \ . "Spell.-Sep2-	    :"
exe "amenu <silent> ".s:prio."101 ".s:menu
      \ . "Spell.aspell :SpellSetSpellchecker aspell<CR>"
exe "amenu <silent> ".s:prio."102 ".s:menu
      \ . "Spell.ispell :SpellSetSpellchecker ispell<CR>"
exe "amenu <silent> disable ".s:menu."Spell.No\\ auto"



" Section: Doc installation {{{1
" 
  let s:vim_plugin_path  = expand("<sfile>:p:h")
  let s:vim_doc_path_def = expand("<sfile>:p:h:h") . '/doc'
  if !(filewritable(s:vim_doc_path_def) == 2)
    execute ":silent !mkdir " . s:vim_doc_path_def
    if !(filewritable(s:vim_doc_path_def) == 2)
      "try a default configuration in user home.
      let s:vim_doc_path_def = expand("~") . '.vim/doc'
      if !(filewritable(s:vim_doc_path_def) == 2)
	execute ":silent !mkdir " . s:vim_doc_path_def
	if !(filewritable(s:vim_doc_path_def) == 2)
	  "put a warning.
	  echomsg "Unable to open documentation directory"
	  echomsg " type :help add-local-help for more informations."
	endif
      endif
    endif
  endif
  let s:revision=
	\substitute("$Revision: 1.48 $",'\$\S*: \([.0-9]\+\) \$','\1','')
  silent! call s:SpellInstallDocumentation(s:revision)
  if exists("s:help_doc")
    echo "vimspell v" . s:revision . ": Installed help-documentation."
  endif


" Section: Plugin init {{{1
"
  highlight default SpellErrors ctermfg=Red guifg=Red cterm=underline gui=underline term=reverse
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
" vim600: set foldmethod=marker fileencoding=iso-8859-15 tabstop=8 shiftwidth=2 softtabstop=2 smartindent smarttab  :
