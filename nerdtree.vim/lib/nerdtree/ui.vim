"CLASS: UI
"============================================================
let s:UI = {}
let g:NERDTreeUI = s:UI

"FUNCTION: s:UI.centerView() {{{2
"centers the nerd tree window around the cursor (provided the nerd tree
"options permit)
function! s:UI.centerView()
    if g:NERDTreeAutoCenter
        let current_line = winline()
        let lines_to_top = current_line
        let lines_to_bottom = winheight(g:NERDTree.GetWinNum()) - current_line
        if lines_to_top < g:NERDTreeAutoCenterThreshold || lines_to_bottom < g:NERDTreeAutoCenterThreshold
            normal! zz
        endif
    endif
endfunction

"FUNCTION: s:UI._dumpHelp  {{{1
"prints out the quick help
function! s:UI._dumpHelp()
    if self.getShowHelp()
        let help  = "\" NERDTree (" . nerdtree#version() . ") quickhelp~\n"
        let help .= "\" ============================\n"
        let help .= "\" File node mappings~\n"
        let help .= "\" ". (g:NERDTreeMouseMode ==# 3 ? "single" : "double") ."-click,\n"
        let help .= "\" <CR>,\n"
        if self.nerdtree.isTabTree()
            let help .= "\" ". g:NERDTreeMapActivateNode .": open in prev window\n"
        else
            let help .= "\" ". g:NERDTreeMapActivateNode .": open in current window\n"
        endif
        if self.nerdtree.isTabTree()
            let help .= "\" ". g:NERDTreeMapPreview .": preview\n"
        endif
        let help .= "\" ". g:NERDTreeMapOpenInTab.": open in new tab\n"
        let help .= "\" ". g:NERDTreeMapOpenInTabSilent .": open in new tab silently\n"
        let help .= "\" middle-click,\n"
        let help .= "\" ". g:NERDTreeMapOpenSplit .": open split\n"
        let help .= "\" ". g:NERDTreeMapPreviewSplit .": preview split\n"
        let help .= "\" ". g:NERDTreeMapOpenVSplit .": open vsplit\n"
        let help .= "\" ". g:NERDTreeMapPreviewVSplit .": preview vsplit\n"

        let help .= "\"\n\" ----------------------------\n"
        let help .= "\" Directory node mappings~\n"
        let help .= "\" ". (g:NERDTreeMouseMode ==# 1 ? "double" : "single") ."-click,\n"
        let help .= "\" ". g:NERDTreeMapActivateNode .": open & close node\n"
        let help .= "\" ". g:NERDTreeMapOpenRecursively .": recursively open node\n"
        let help .= "\" ". g:NERDTreeMapCloseDir .": close parent of node\n"
        let help .= "\" ". g:NERDTreeMapCloseChildren .": close all child nodes of\n"
        let help .= "\"    current node recursively\n"
        let help .= "\" middle-click,\n"
        let help .= "\" ". g:NERDTreeMapOpenExpl.": explore selected dir\n"

        let help .= "\"\n\" ----------------------------\n"
        let help .= "\" Bookmark table mappings~\n"
        let help .= "\" double-click,\n"
        let help .= "\" ". g:NERDTreeMapActivateNode .": open bookmark\n"
        let help .= "\" ". g:NERDTreeMapOpenInTab.": open in new tab\n"
        let help .= "\" ". g:NERDTreeMapOpenInTabSilent .": open in new tab silently\n"
        let help .= "\" ". g:NERDTreeMapDeleteBookmark .": delete bookmark\n"

        let help .= "\"\n\" ----------------------------\n"
        let help .= "\" Tree navigation mappings~\n"
        let help .= "\" ". g:NERDTreeMapJumpRoot .": go to root\n"
        let help .= "\" ". g:NERDTreeMapJumpParent .": go to parent\n"
        let help .= "\" ". g:NERDTreeMapJumpFirstChild  .": go to first child\n"
        let help .= "\" ". g:NERDTreeMapJumpLastChild   .": go to last child\n"
        "let help .= "\" ". g:NERDTreeMapJumpNextSibling .": go to next sibling\n"
        "let help .= "\" ". g:NERDTreeMapJumpPrevSibling .": go to prev sibling\n"

        let help .= "\"\n\" ----------------------------\n"
        let help .= "\" Filesystem mappings~\n"
        let help .= "\" ". g:NERDTreeMapChangeRoot .": change tree root to the\n"
        let help .= "\"    selected dir\n"
        let help .= "\" ". g:NERDTreeMapUpdir .": move tree root up a dir\n"
        let help .= "\" ". g:NERDTreeMapUpdirKeepOpen .": move tree root up a dir\n"
        let help .= "\"    but leave old root open\n"
        let help .= "\" ". g:NERDTreeMapRefresh .": refresh cursor dir\n"
        let help .= "\" ". g:NERDTreeMapRefreshRoot .": refresh current root\n"
        let help .= "\" ". g:NERDTreeMapMenu .": Show menu\n"
        let help .= "\" ". g:NERDTreeMapChdir .":change the CWD to the\n"
        let help .= "\"    selected dir\n"
        let help .= "\" ". g:NERDTreeMapCWD .":change tree root to CWD\n"

        let help .= "\"\n\" ----------------------------\n"
        let help .= "\" Tree filtering mappings~\n"
        let help .= "\" ". g:NERDTreeMapToggleHidden .": hidden files (" . (self.getShowHidden() ? "on" : "off") . ")\n"
        let help .= "\" ". g:NERDTreeMapToggleFilters .": file filters (" . (self.isIgnoreFilterEnabled() ? "on" : "off") . ")\n"
        let help .= "\" ". g:NERDTreeMapToggleFiles .": files (" . (self.getShowFiles() ? "on" : "off") . ")\n"
        let help .= "\" ". g:NERDTreeMapToggleBookmarks .": bookmarks (" . (self.getShowBookmarks() ? "on" : "off") . ")\n"

        "add quickhelp entries for each custom key map
        let help .= "\"\n\" ----------------------------\n"
        let help .= "\" Custom mappings~\n"
        for i in g:NERDTreeKeyMap.All()
            if !empty(i.quickhelpText)
                let help .= "\" ". i.key .": ". i.quickhelpText ."\n"
            endif
        endfor

        let help .= "\"\n\" ----------------------------\n"
        let help .= "\" Other mappings~\n"
        let help .= "\" ". g:NERDTreeMapQuit .": Close the NERDTree window\n"
        let help .= "\" ". g:NERDTreeMapToggleZoom .": Zoom (maximize-minimize)\n"
        let help .= "\"    the NERDTree window\n"
        let help .= "\" ". g:NERDTreeMapHelp .": toggle help\n"
        let help .= "\"\n\" ----------------------------\n"
        let help .= "\" Bookmark commands~\n"
        let help .= "\" :Bookmark [<name>]\n"
        let help .= "\" :BookmarkToRoot <name>\n"
        let help .= "\" :RevealBookmark <name>\n"
        let help .= "\" :OpenBookmark <name>\n"
        let help .= "\" :ClearBookmarks [<names>]\n"
        let help .= "\" :ClearAllBookmarks\n"
        silent! put =help
    elseif !self.isMinimal()
        let help ="\" Press ". g:NERDTreeMapHelp ." for help\n"
        silent! put =help
    endif
endfunction


"FUNCTION: s:UI.new(nerdtree) {{{1
function! s:UI.New(nerdtree)
    let newObj = copy(self)
    let newObj.nerdtree = a:nerdtree
    let newObj._showHelp = 0
    let newObj._ignoreEnabled = 1
    let newObj._showFiles = g:NERDTreeShowFiles
    let newObj._showHidden = g:NERDTreeShowHidden
    let newObj._showBookmarks = g:NERDTreeShowBookmarks

    return newObj
endfunction

"FUNCTION: s:UI.getPath(ln) {{{1
"Gets the full path to the node that is rendered on the given line number
"
"Args:
"ln: the line number to get the path for
"
"Return:
"A path if a node was selected, {} if nothing is selected.
"If the 'up a dir' line was selected then the path to the parent of the
"current root is returned
function! s:UI.getPath(ln)
    let line = getline(a:ln)

    let rootLine = self.getRootLineNum()

    "check to see if we have the root node
    if a:ln == rootLine
        return self.nerdtree.root.path
    endif

    if line ==# s:UI.UpDirLine()
        return self.nerdtree.root.path.getParent()
    endif

    let indent = self._indentLevelFor(line)

    "remove the tree parts and the leading space
    let curFile = self._stripMarkup(line, 0)

    let wasdir = 0
    if curFile =~# '/$'
        let wasdir = 1
        let curFile = substitute(curFile, '/\?$', '/', "")
    endif

    let dir = ""
    let lnum = a:ln
    while lnum > 0
        let lnum = lnum - 1
        let curLine = getline(lnum)
        let curLineStripped = self._stripMarkup(curLine, 1)

        "have we reached the top of the tree?
        if lnum == rootLine
            let dir = self.nerdtree.root.path.str({'format': 'UI'}) . dir
            break
        endif
        if curLineStripped =~# '/$'
            let lpindent = self._indentLevelFor(curLine)
            if lpindent < indent
                let indent = indent - 1

                let dir = substitute (curLineStripped,'^\\', "", "") . dir
                continue
            endif
        endif
    endwhile
    let curFile = self.nerdtree.root.path.drive . dir . curFile
    let toReturn = g:NERDTreePath.New(curFile)
    return toReturn
endfunction

"FUNCTION: s:UI.getLineNum(file_node){{{1
"returns the line number this node is rendered on, or -1 if it isnt rendered
function! s:UI.getLineNum(file_node)
    "if the node is the root then return the root line no.
    if a:file_node.isRoot()
        return self.getRootLineNum()
    endif

    let totalLines = line("$")

    "the path components we have matched so far
    let pathcomponents = [substitute(self.nerdtree.root.path.str({'format': 'UI'}), '/ *$', '', '')]
    "the index of the component we are searching for
    let curPathComponent = 1

    let fullpath = a:file_node.path.str({'format': 'UI'})

    let lnum = self.getRootLineNum()
    while lnum > 0
        let lnum = lnum + 1
        "have we reached the bottom of the tree?
        if lnum ==# totalLines+1
            return -1
        endif

        let curLine = getline(lnum)

        let indent = self._indentLevelFor(curLine)
        if indent ==# curPathComponent
            let curLine = self._stripMarkup(curLine, 1)

            let curPath =  join(pathcomponents, '/') . '/' . curLine
            if stridx(fullpath, curPath, 0) ==# 0
                if fullpath ==# curPath || strpart(fullpath, len(curPath)-1,1) ==# '/'
                    let curLine = substitute(curLine, '/ *$', '', '')
                    call add(pathcomponents, curLine)
                    let curPathComponent = curPathComponent + 1

                    if fullpath ==# curPath
                        return lnum
                    endif
                endif
            endif
        endif
    endwhile
    return -1
endfunction

"FUNCTION: s:UI.getRootLineNum(){{{1
"gets the line number of the root node
function! s:UI.getRootLineNum()
    let rootLine = 1
    while getline(rootLine) !~# '^\(/\|<\)'
        let rootLine = rootLine + 1
    endwhile
    return rootLine
endfunction

"FUNCTION: s:UI.getShowBookmarks() {{{1
function! s:UI.getShowBookmarks()
    return self._showBookmarks
endfunction

"FUNCTION: s:UI.getShowFiles() {{{1
function! s:UI.getShowFiles()
    return self._showFiles
endfunction

"FUNCTION: s:UI.getShowHelp() {{{1
function! s:UI.getShowHelp()
    return self._showHelp
endfunction

"FUNCTION: s:UI.getShowHidden() {{{1
function! s:UI.getShowHidden()
    return self._showHidden
endfunction

"FUNCTION: s:UI._indentLevelFor(line) {{{1
function! s:UI._indentLevelFor(line)
    "have to do this work around because match() returns bytes, not chars
    let numLeadBytes = match(a:line, '\M\[^ '.g:NERDTreeDirArrowExpandable.g:NERDTreeDirArrowCollapsible.']')
    " The next line is a backward-compatible workaround for strchars(a:line(0:numLeadBytes-1]). strchars() is in 7.3+
    let leadChars = len(split(a:line[0:numLeadBytes-1], '\zs'))

    return leadChars / s:UI.IndentWid()
endfunction

"FUNCTION: s:UI.IndentWid() {{{1
function! s:UI.IndentWid()
    return 2
endfunction

"FUNCTION: s:UI.isIgnoreFilterEnabled() {{{1
function! s:UI.isIgnoreFilterEnabled()
    return self._ignoreEnabled == 1
endfunction

"FUNCTION: s:UI.isMinimal() {{{1
function! s:UI.isMinimal()
    return g:NERDTreeMinimalUI
endfunction

"FUNCTION: s:UI.MarkupReg() {{{1
function! s:UI.MarkupReg()
    return '^\(['.g:NERDTreeDirArrowExpandable.g:NERDTreeDirArrowCollapsible.'] \| \+['.g:NERDTreeDirArrowExpandable.g:NERDTreeDirArrowCollapsible.'] \| \+\)'
endfunction

"FUNCTION: s:UI._renderBookmarks {{{1
function! s:UI._renderBookmarks()

    if !self.isMinimal()
        call setline(line(".")+1, ">----------Bookmarks----------")
        call cursor(line(".")+1, col("."))
    endif

    if g:NERDTreeBookmarksSort == 1 || g:NERDTreeBookmarksSort == 2
        call g:NERDTreeBookmark.SortBookmarksList()
    endif

    for i in g:NERDTreeBookmark.Bookmarks()
        call setline(line(".")+1, i.str())
        call cursor(line(".")+1, col("."))
    endfor

    call setline(line(".")+1, '')
    call cursor(line(".")+1, col("."))
endfunction

"FUNCTION: s:UI.restoreScreenState() {{{1
"
"Sets the screen state back to what it was when nerdtree#saveScreenState was last
"called.
"
"Assumes the cursor is in the NERDTree window
function! s:UI.restoreScreenState()
    if !has_key(self, '_screenState')
        return
    endif
    exec("silent vertical resize " . self._screenState['oldWindowSize'])

    let old_scrolloff=&scrolloff
    let &scrolloff=0
    call cursor(self._screenState['oldTopLine'], 0)
    normal! zt
    call setpos(".", self._screenState['oldPos'])
    let &scrolloff=old_scrolloff
endfunction

"FUNCTION: s:UI.saveScreenState() {{{1
"Saves the current cursor position in the current buffer and the window
"scroll position
function! s:UI.saveScreenState()
    let win = winnr()
    call g:NERDTree.CursorToTreeWin()
    let self._screenState = {}
    let self._screenState['oldPos'] = getpos(".")
    let self._screenState['oldTopLine'] = line("w0")
    let self._screenState['oldWindowSize']= winwidth("")
    call nerdtree#exec(win . "wincmd w")
endfunction

"FUNCTION: s:UI.setShowHidden(val) {{{1
function! s:UI.setShowHidden(val)
    let self._showHidden = a:val
endfunction

"FUNCTION: s:UI._stripMarkup(line, removeLeadingSpaces){{{1
"returns the given line with all the tree parts stripped off
"
"Args:
"line: the subject line
"removeLeadingSpaces: 1 if leading spaces are to be removed (leading spaces =
"any spaces before the actual text of the node)
function! s:UI._stripMarkup(line, removeLeadingSpaces)
    let line = a:line
    "remove the tree parts and the leading space
    let line = substitute (line, g:NERDTreeUI.MarkupReg(),"","")

    "strip off any read only flag
    let line = substitute (line, ' \['.g:NERDTreeGlyphReadOnly.'\]', "","")

    "strip off any bookmark flags
    let line = substitute (line, ' {[^}]*}', "","")

    "strip off any executable flags
    let line = substitute (line, '*\ze\($\| \)', "","")

    "strip off any generic flags
    let line = substitute (line, '\[[^]]*\]', "","")

    let wasdir = 0
    if line =~# '/$'
        let wasdir = 1
    endif
    let line = substitute (line,' -> .*',"","") " remove link to
    if wasdir ==# 1
        let line = substitute (line, '/\?$', '/', "")
    endif

    if a:removeLeadingSpaces
        let line = substitute (line, '^ *', '', '')
    endif

    return line
endfunction

"FUNCTION: s:UI.render() {{{1
function! s:UI.render()
    setlocal modifiable

    "remember the top line of the buffer and the current line so we can
    "restore the view exactly how it was
    let curLine = line(".")
    let curCol = col(".")
    let topLine = line("w0")

    "delete all lines in the buffer (being careful not to clobber a register)
    silent 1,$delete _

    call self._dumpHelp()

    "delete the blank line before the help and add one after it
    if !self.isMinimal()
        call setline(line(".")+1, "")
        call cursor(line(".")+1, col("."))
    endif

    if self.getShowBookmarks()
        call self._renderBookmarks()
    endif

    "add the 'up a dir' line
    if !self.isMinimal()
        call setline(line(".")+1, s:UI.UpDirLine())
        call cursor(line(".")+1, col("."))
    endif

    "draw the header line
    let header = self.nerdtree.root.path.str({'format': 'UI', 'truncateTo': winwidth(0)})
    call setline(line(".")+1, header)
    call cursor(line(".")+1, col("."))

    "draw the tree
    silent put =self.nerdtree.root.renderToString()

    "delete the blank line at the top of the buffer
    silent 1,1delete _

    "restore the view
    let old_scrolloff=&scrolloff
    let &scrolloff=0
    call cursor(topLine, 1)
    normal! zt
    call cursor(curLine, curCol)
    let &scrolloff = old_scrolloff

    setlocal nomodifiable
endfunction


"FUNCTION: UI.renderViewSavingPosition {{{1
"Renders the tree and ensures the cursor stays on the current node or the
"current nodes parent if it is no longer available upon re-rendering
function! s:UI.renderViewSavingPosition()
    let currentNode = g:NERDTreeFileNode.GetSelected()

    "go up the tree till we find a node that will be visible or till we run
    "out of nodes
    while currentNode != {} && !currentNode.isVisible() && !currentNode.isRoot()
        let currentNode = currentNode.parent
    endwhile

    call self.render()

    if currentNode != {}
        call currentNode.putCursorHere(0, 0)
    endif
endfunction

"FUNCTION: s:UI.toggleHelp() {{{1
function! s:UI.toggleHelp()
    let self._showHelp = !self._showHelp
endfunction

" FUNCTION: s:UI.toggleIgnoreFilter() {{{1
" toggles the use of the NERDTreeIgnore option
function! s:UI.toggleIgnoreFilter()
    let self._ignoreEnabled = !self._ignoreEnabled
    call self.renderViewSavingPosition()
    call self.centerView()
endfunction

" FUNCTION: s:UI.toggleShowBookmarks() {{{1
" toggles the display of bookmarks
function! s:UI.toggleShowBookmarks()
    let self._showBookmarks = !self._showBookmarks
    if self.getShowBookmarks()
        call self.nerdtree.render()
        call g:NERDTree.CursorToBookmarkTable()
    else
        call self.renderViewSavingPosition()
    endif
    call self.centerView()
endfunction

" FUNCTION: s:UI.toggleShowFiles() {{{1
" toggles the display of hidden files
function! s:UI.toggleShowFiles()
    let self._showFiles = !self._showFiles
    call self.renderViewSavingPosition()
    call self.centerView()
endfunction

" FUNCTION: s:UI.toggleShowHidden() {{{1
" toggles the display of hidden files
function! s:UI.toggleShowHidden()
    let self._showHidden = !self._showHidden
    call self.renderViewSavingPosition()
    call self.centerView()
endfunction

" FUNCTION: s:UI.toggleZoom() {{{1
" zoom (maximize/minimize) the NERDTree window
function! s:UI.toggleZoom()
    if exists("b:NERDTreeZoomed") && b:NERDTreeZoomed
        let size = exists("b:NERDTreeOldWindowSize") ? b:NERDTreeOldWindowSize : g:NERDTreeWinSize
        exec "silent vertical resize ". size
        let b:NERDTreeZoomed = 0
    else
        exec "vertical resize"
        let b:NERDTreeZoomed = 1
    endif
endfunction

"FUNCTION: s:UI.UpDirLine() {{{1
function! s:UI.UpDirLine()
    return '.. (up a dir)'
endfunction
