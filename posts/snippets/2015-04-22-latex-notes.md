---
title: LaTeX Notes
tags: LaTeX
---

## Todonotes and Tikzexternalize

If you are using tikzexternalize and todonotes, add this to your preamble:

    \usepackage{letltxmacro}
    
    \LetLtxMacro{\oldmissingfigure}{\missingfigure}
    \renewcommand{\missingfigure}[2][]{\tikzexternaldisable\oldmissingfigure[{#1}]{#2}\tikzexternalenable}
    
    \LetLtxMacro{\oldtodo}{\todo}
    \renewcommand{\todo}[2][]{\tikzexternaldisable\oldtodo[#1]{#2}\tikzexternalenable}

Reference: [tex.sx](http://tex.stackexchange.com/a/115095)

## Spaces

LaTeX has lots of different spaces. For example, `\,` creates a thin space, suitable to separate figures and their units.

Reference: [tex.sx](http://tex.stackexchange.com/a/74354)
