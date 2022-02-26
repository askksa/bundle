" vim: tabstop=2 shiftwidth=2 softtabstop=2 expandtab foldmethod=marker
"    Copyright: Copyright (C) 2012-2015 Brook Hong
"    License: The MIT License
"

set cscopequickfix=s-,g-,d-,c-,t-,e-,f-,i-

if has("python3")
  let g:cs_py = "py3 "
elseif has("python")
  let g:cs_py = "py "
else
  echohl Error
  echo "Error: cscope requires vim compiled with +python or +python3"
  echohl None
  finish
endif

exec g:cs_py "import vim, sys, os.path"
exec g:cs_py "cwd = vim.eval('expand(\"<sfile>:p:h\")')"
exec g:cs_py "sys.path.insert(0, os.path.join(cwd, 'python'))"
exec g:cs_py "from filter_rules_parser import parsing_rules"

if !exists('g:cscope_silent')
  let g:cscope_silent = 0
endif

if !exists('g:cscope_auto_update')
  let g:cscope_auto_update = 0
endif

if !exists('g:cscope_open_location')
  let g:cscope_open_location = 1
endif

if !exists('g:cscope_split_threshold')
  let g:cscope_split_threshold = 5000
endif

if !exists('g:cscope_cmd')
  if executable('cscope')
    let g:cscope_cmd = 'cscope'
  else
    call <SID>Echo('cscope: command not found')
    finish
  endif
endif

if !exists('g:cscope_interested_files')
  let files = readfile(expand("<sfile>:p:h")."/interested.txt")
  let g:cscope_interested_files = join(map(files, 'v:val."$"'), '\|')
endif

let s:cscope_vim_dir = substitute($HOME,'\\','/','g')."/.cscope.vim"
let s:index_file = s:cscope_vim_dir.'/index'


function! s:Echo(msg)
  if g:cscope_silent == 0
    echo a:msg
  endif
endfunction

function! s:ListDirs(A,L,P)
  return keys(s:dbs)
endfunction

function! s:GetBestPath(dir)
  let f = substitute(a:dir,'\\','/','g')
  let bestDir = ""
  for d in keys(s:dbs)
    if stridx(f, d) == 0 && len(d) > len(bestDir)
      let bestDir = d
    endif
  endfor
  return bestDir
endfunction

function! s:CheckAbsolutePath(dir, defaultPath)
  let d = a:dir
  while 1
    if !isdirectory(d)
      echohl WarningMsg | echo "Please input a valid path." | echohl None
      let d = input("", a:defaultPath, 'dir')
    elseif (len(d) < 2 || (d[0] != '/' && d[1] != ':'))
      echohl WarningMsg | echo "Please input an absolute path." | echohl None
      let d = input("", a:defaultPath, 'dir')
    else
      break
    endif
  endwhile
  let d = substitute(d,'\\','/','g')
  let d = substitute(d,'/\+$','','')
  return d
endfunction

function! s:ListFiles(dir)
  let d = []
  let f = []
  let cwd = a:dir
  let sl = &l:stl

  try
    while cwd != ''
      let a = split(globpath(cwd, "*"), "\n")
      for fn in a
        if getftype(fn) == 'dir'
          if exists('g:merged_interested_dirs') && fn !~? g:merged_interested_dirs
            continue
          endif
          if !exists('g:merged_ignored_dirs') || fn !~? g:merged_ignored_dirs
            call add(d, fn)
          endif
        elseif getftype(fn) == 'file'
          if exists('g:merged_interested_files') && fn !~? g:merged_interested_files
            continue
          endif
          if !exists('g:merged_ignored_files') || fn !~? g:merged_ignored_files
            if stridx(fn, ' ') != -1
              let fn = '"'.fn.'"'
            endif
            call add(f, fn)
          endif
        endif
      endfor

      "iterate hidden dirs
      let a = split(globpath(cwd, ".[a-zA-Z0-9]*"), "\n")
      for fn in a
        if getftype(fn) == 'dir'
          if exists('g:merged_interested_dirs') && fn !~? g:merged_interested_dirs
            continue
          endif
          if !exists('g:merged_ignored_dirs') || fn !~? g:merged_ignored_dirs
            call add(d, fn)
          endif
        elseif getftype(fn) == 'file'
          if exists('g:merged_interested_files') && fn !~? g:merged_interested_files
            continue
          endif
          if !exists('g:merged_ignored_files') || fn !~? g:merged_ignored_files
            if stridx(fn, ' ') != -1
              let fn = '"'.fn.'"'
            endif
            call add(f, fn)
          endif
        endif
      endfor
      let cwd = len(d) ? remove(d, 0) : ''
      sleep 1m | let &l:stl = 'Found '.len(f).' files, finding in '.cwd | redrawstatus
    endwhile
  catch /^Vim:Interrupt$/
  catch
    echo "caught" v:exception
  endtry

  sleep 1m | let &l:stl = sl | redrawstatus
  return f
endfunction

function! s:RmDbfiles()
  let odbs = split(globpath(s:cscope_vim_dir, "*"), "\n")
  for f in odbs
    call delete(f)
  endfor
  let s:dbs = {}
endfunction

function! s:FlushIndex()
  let lines = []
  for d in keys(s:dbs)
    call add(lines, d.'|'.s:dbs[d]['id'].'|'.s:dbs[d]['loadtimes'].'|'.s:dbs[d]['dirty'])
  endfor
  call writefile(lines, s:index_file)
endfunction

function! s:CheckNewFile(dir, newfile)
  let ret = 0
  let id = s:dbs[a:dir]['id']
  let cscope_files = s:cscope_vim_dir."/".id.".files"
  let files = readfile(cscope_files)
  if count(files, a:newfile) == 1
    let s:dbs[a:dir]['dirty'] = 1
    let ret = 0
  elseif len(files) > g:cscope_split_threshold
    let cscope_files = s:cscope_vim_dir."/".id."_inc.files"
    if filereadable(cscope_files)
      let files = readfile(cscope_files)
    else
      let files = []
    endif
    if count(files, a:newfile) == 1
      let ret = 0
    else
      call add(files, a:newfile)
      call writefile(files, cscope_files)
      let ret = 1
    endif
    let s:dbs[a:dir]['dirty'] = 2
  else
      call add(files, a:newfile)
      call writefile(files, cscope_files)
      let s:dbs[a:dir]['dirty'] = 1
      let ret = 1
  endif
  return ret
endfunction

function! JobCloseCb(buf)
  exec 'cs kill -1'
  exec 'cs add '.s:cscope_db
endfunction

function! s:CreateDb(dir)
  let id = s:dbs[a:dir]['id']
  let dirty = s:dbs[a:dir]['dirty']
  if dirty == 1
    let cscope_files = s:cscope_vim_dir."/".id.".files"
    let s:cscope_db = s:cscope_vim_dir.'/'.id.'.db'
  elseif dirty == 2
    let cscope_files = s:cscope_vim_dir."/".id."_inc.files"
    let s:cscope_db = s:cscope_vim_dir.'/'.id.'_inc.db'
  else
    let cscope_files = s:cscope_vim_dir."/".id.".files"
    let s:cscope_db = s:cscope_vim_dir.'/'.id.'.db'
    if ! filereadable(cscope_files)
      let files = <SID>ListFiles(a:dir)
      call writefile(files, cscope_files)
    endif
  endif

  exec 'cs kill '.s:cscope_db
  "create cscope database
  if exists('*term_start')
    let l:options = {}
    let l:options['term_name'] = "CscopeUpdate"
    let l:options['hidden'] = '1'
    let l:options['term_finish'] = 'close'
    let l:options['close_cb'] = 'JobCloseCb'
    call term_start(g:cscope_cmd.' -bq -i '.cscope_files.' -f'.s:cscope_db, l:options)
  else
    redir @x
    exec 'silent !'.g:cscope_cmd.' -bq -i '.cscope_files.' -f'.s:cscope_db
    redi END
    if @x =~ "\nCommand terminated\n"
      echohl WarningMsg | echo "Failed to create cscope database for ".a:dir.", please check if " | echohl None
    else
      let s:dbs[a:dir]['dirty'] = 0
      call <SID>FlushIndex()
      cs kill -1
      exec 'cs add '.s:cscope_db
    endif
  endif
endfunction

function! s:InitDb(dir)
  let id = localtime()
  let s:dbs[a:dir] = {}
  let s:dbs[a:dir]['id'] = id
  let s:dbs[a:dir]['loadtimes'] = 0
  let s:dbs[a:dir]['dirty'] = 0
  call <SID>CreateDb(a:dir)
endfunction

function! s:LoadDb(dir)
  cs kill -1
  exe 'cs add '.s:cscope_vim_dir.'/'.s:dbs[a:dir]['id'].'.db'
  if filereadable(s:cscope_vim_dir.'/'.s:dbs[a:dir]['id'].'_inc.db')
    exe 'cs add '.s:cscope_vim_dir.'/'.s:dbs[a:dir]['id'].'_inc.db'
  endif
  let s:dbs[a:dir]['loadtimes'] = s:dbs[a:dir]['loadtimes']+1
  call <SID>FlushIndex()
endfunction

" 0 -- loaded
" 1 -- cancelled
function! s:AutoLoadDb(dir)
  let ret = 0
  let m_dir = <SID>GetBestPath(a:dir)
  if m_dir == ""
    echohl WarningMsg | echo "Can not find proper cscope db." | echohl None
    let ret = 1
  else
    let id = s:dbs[m_dir]['id']
    if cscope_connection(2, s:cscope_vim_dir.'/'.id.'.db') == 0
      call <SID>LoadDb(m_dir)
    endif
  endif
  return ret
endfunction

function! s:ClearDb(dir)
  cs kill -1
  if a:dir != ""
    echo "clear database:".a:dir.""
    let id = s:dbs[a:dir]['id']
    call delete(s:cscope_vim_dir."/".id.".files")
    call delete(s:cscope_vim_dir.'/'.id.'.db')
    call delete(s:cscope_vim_dir.'/'.id.'.db.in')
    call delete(s:cscope_vim_dir.'/'.id.'.db.po')
    call delete(s:cscope_vim_dir."/".id."_inc.files")
    call delete(s:cscope_vim_dir.'/'.id.'_inc.db')
    call delete(s:cscope_vim_dir.'/'.id.'_inc.db.in')
    call delete(s:cscope_vim_dir.'/'.id.'_inc.db.po')
    unlet s:dbs[a:dir]
  endif
  call <SID>FlushIndex()
endfunction

function! s:ListDbs()
  let dirs = keys(s:dbs)
  if len(dirs) == 0
    echo "You have no cscope dbs now."
  else
    let s = [' ID                   LOADTIMES    PATH']
    for d in dirs
      let id = s:dbs[d]['id']
      if cscope_connection(2, s:cscope_vim_dir.'/'.id.'.db') == 1
        let l = printf("*%d  %10d            %s", id, s:dbs[d]['loadtimes'], d)
      else
        let l = printf(" %d  %10d            %s", id, s:dbs[d]['loadtimes'], d)
      endif
      call add(s, l)
    endfor
    echo join(s, "\n")
  endif
endfunction

function! s:LoadIndex()
  let s:dbs = {}
  if ! isdirectory(s:cscope_vim_dir)
    call mkdir(s:cscope_vim_dir)
  elseif filereadable(s:index_file)
    let idx = readfile(s:index_file)
    for i in idx
      let e = split(i, '|')
      if len(e) == 0
        call delete(s:index_file)
        call <SID>RmDbfiles()
      else
        let db_file = s:cscope_vim_dir.'/'.e[1].'.db'
        if filereadable(db_file)
          if isdirectory(e[0])
            let s:dbs[e[0]] = {}
            let s:dbs[e[0]]['id'] = e[1]
            let s:dbs[e[0]]['loadtimes'] = e[2]
            let s:dbs[e[0]]['dirty'] = (len(e) > 3) ? e[3] :0
          else
            call delete(db_file)
          endif
        endif
      endif
    endfor
  else
    call <SID>RmDbfiles()
  endif
endfunction

function! s:PreloadDb()
  let dirs = split(g:cscope_preload_path, ';')
  for m_dir in dirs
    let m_dir = <SID>CheckAbsolutePath(m_dir, m_dir)
    if ! has_key(s:dbs, m_dir)
      call <SID>InitDb(m_dir)
    endif
    call <SID>LoadDb(m_dir)
  endfor
endfunction

function! ToggleLocationList()
  let l:own = winnr()
  lw
  let l:cwn = winnr()
  if(l:cwn == l:own)
    if &buftype == 'quickfix'
      lclose
    elseif len(getloclist(winnr())) > 0
      lclose
    else
      echohl WarningMsg | echo "No location list." | echohl None
    endif
  endif
endfunction

function! CscopeFind(action, word)
  let dbl = <SID>AutoLoadDb(expand('%:p:h'))
  if dbl == 0
    try
      execute "normal mZ"
      execute "lcs find ".a:action." ".a:word
      if g:cscope_open_location == 1
        execute "lopen 6"
      endif
      execute "wincmd p"
      execute "normal `Z"
    catch
      echohl WarningMsg | echo 'Can not find '.a:word.' with querytype as '.a:action.'.' | echohl None
    endtry
  endif
endfunction

function! CscopeFindInteractive(pat)
    call inputsave()
    let qt = input("\nChoose a querytype for '".a:pat."'(:help cscope-find)\n  c: functions calling this function\n  d: functions called by this function\n  e: this egrep pattern\n  f: this file\n  g: this definition\n  i: files #including this file\n  s: this C symbol\n  t: this text string\n\n  or\n  <querytype><pattern> to query `pattern` instead of '".a:pat."' as `querytype`, Ex. `smain` to query a C symbol named 'main'.\n> ")
    call inputrestore()
    if len(qt) > 1
        call CscopeFind(qt[0], qt[1:])
    elseif len(qt) > 0
        call CscopeFind(qt, a:pat)
    endif
    call feedkeys("\<CR>")
endfunction

function! CscopeUpdateDb()
  let m_dir = <SID>GetBestPath(expand('%:p:h'))
  if m_dir == ""
    echohl WarningMsg | echo "Can not find proper cscope db, please generate cscope db by CsCreateDb cmd." | echohl None
  else
    call <SID>CheckNewFile(m_dir, expand('%:p'))
    call <SID>CreateDb(m_dir)
  endif
endfunction

function! CscopeMergeFilterRules(dirs_1, dirs_2, files_1, files_2)
  if exists('g:cscope_interested_dirs') && a:dirs_1 != ''
    let g:merged_interested_dirs = g:cscope_interested_dirs.'\|'.a:dirs_1
    echo "cs_interested_dirs => ".g:merged_interested_dirs
  elseif exists('g:cscope_interested_dirs')
    let g:merged_interested_dirs = g:cscope_interested_dirs
    echo "cs_interested_dirs => ".g:merged_interested_dirs
  elseif a:dirs_1 != ''
    let g:merged_interested_dirs = a:dirs_1
    echo "cs_interested_dirs => ".g:merged_interested_dirs
  endif

  if exists('g:cscope_ignored_dirs') && a:dirs_2 != ''
    let g:merged_ignored_dirs = g:cscope_ignored_dirs.'\|'.a:dirs_2
    echo "cs_ignored_dirs => ".g:merged_ignored_dirs
  elseif exists('g:cscope_ignored_dirs')
    let g:merged_ignored_dirs = g:cscope_ignored_dirs
    echo "cs_ignored_dirs => ".g:merged_ignored_dirs
  elseif a:dirs_2 != ''
    let g:merged_ignored_dirs = a:dirs_2
    echo "cs_ignored_dirs => ".g:merged_ignored_dirs
  endif

  if exists('g:cscope_interested_files') && a:files_1 != ''
    let g:merged_interested_files = g:cscope_interested_files.'\|'.a:files_1
    echo "cs_interested_files => ".g:merged_interested_files
  elseif exists('g:cscope_interested_files')
    let g:merged_interested_files = g:cscope_interested_files
    echo "cs_interested_files => ".g:merged_interested_files
  elseif a:files_1 != ''
    let g:merged_interested_files = a:files_1
    echo "cs_interested_files => ".g:merged_interested_files
  endif

  if exists('g:cscope_ignored_files') && a:files_2 != ''
    let g:merged_ignored_files = g:cscope_ignored_files.'\|'.a:files_2
    echo "cs_ignored_files => ".g:merged_ignored_files
  elseif exists('g:cscope_ignored_files')
    let g:merged_ignored_files = g:cscope_ignored_files
    echo "cs_ignored_files => ".g:merged_ignored_files
  elseif a:files_2 != ''
    let g:merged_ignored_files = a:files_2
    echo "cs_ignored_files => ".g:merged_ignored_files
  endif
endfunction

function! s:CreateFilterRules(dir)
  let rules_file = a:dir."/.cscope_config.json"
  if filereadable(rules_file)
    exec g:cs_py 'parsing_rules("'.rules_file.'")'
  else
    echohl WarningMsg | echo "no found cscope config file !!!" | echohl None
  endif
endfunction

function! CscopeCreateDb()
    echohl WarningMsg | echo "please input project path for generating cscope db." | echohl None
    let m_dir = input("", expand('%:p:h'), 'dir')
    if m_dir != ''
      let m_dir = <SID>CheckAbsolutePath(m_dir, expand('%:p:h'))
      echo "\nproject path => ".m_dir
      call <SID>CreateFilterRules(m_dir)
      let ret = input("continue create: y/n ?\n")
      if ret == 'y'
        call <SID>InitDb(m_dir)
        call <SID>LoadDb(m_dir)
      endif
    else
      echohl WarningMsg | echo "invalid project path !!!" | echohl None
    endif

    if exists('g:merged_interested_dirs')
        unlet g:merged_interested_dirs
    endif
    if exists('g:merged_interested_files')
        unlet g:merged_interested_files
    endif
    if exists('g:merged_ignored_dirs')
        unlet g:merged_ignored_dirs
    endif
    if exists('g:merged_ignored_files')
        unlet g:merged_ignored_files
    endif
endfunction

if exists('g:cscope_preload_path')
  call <SID>PreloadDb()
endif

if g:cscope_auto_update == 1
  au BufWritePost * call CscopeUpdateDb()
endif

call <SID>LoadIndex()

com! -nargs=0 CsCreateDb call CscopeCreateDb()
com! -nargs=1 CsClearDb call <SID>ClearDb('<args>')
com! -nargs=0 CsListDbs call <SID>ListDbs()

