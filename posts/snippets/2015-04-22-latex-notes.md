---
title: LaTeX Notes
---

If you are using tikzexternalize and todonotes, add this to your preamble:

    \usepackage{letltxmacro}
    
    \LetLtxMacro{\oldmissingfigure}{\missingfigure}
    \renewcommand{\missingfigure}[2][]{\tikzexternaldisable\oldmissingfigure[{#1}]{#2}\tikzexternalenable}
    
    \LetLtxMacro{\oldtodo}{\todo}
    \renewcommand{\todo}[2][]{\tikzexternaldisable\oldtodo[#1]{#2}\tikzexternalenable}

Reference: [tex.sx](http://tex.stackexchange.com/a/115095)
