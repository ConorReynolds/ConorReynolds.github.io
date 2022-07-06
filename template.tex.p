◊string-append{
    \documentclass[a4paper,11pt,oneside,article]{memoir}

    \usepackage[british]{babel}
    \usepackage{microtype}
    \frenchspacing

    \usepackage{mathtools}
    \usepackage{enumitem}

    \usepackage{unicode-math}

    \usepackage{upquote}
    \usepackage{fancyvrb}
    \usepackage{fvextra}
    
    \usepackage{mparhack}

    \usepackage[outputdir=build]{minted}
    \usemintedstyle{monochrome}
    \setminted{
      fontsize=\footnotesize,
      xleftmargin=1.55em,
      autogobble,
      breaklines,
      linenos,
    }

    \usepackage{newunicodechar}
    \newfontfamily{\fallbackfont}{DejaVu Sans}[Scale=MatchLowercase]
    \DeclareTextFontCommand{\textfallback}{\fallbackfont}
    \newcommand{\fallbackchar}[2][\textfallback]{%
        \newunicodechar{#2}{#1{#2}}%
    }

    \fallbackchar{⟶}
    \fallbackchar{∀}
    \fallbackchar{⊨}


    \linespread{1.1}
    \setlength{\parindent}{1em}

    \usepackage[para]{footmisc}

    \usepackage{booktabs}

    \AtBeginDocument{\renewcommand{\models}{\mathrel{\raisebox{-1pt}{\(\vDash\)}}}}

    ◊; Set stock (A4) and trims (none)
    \setstocksize{297mm}{210mm}
    \settrimmedsize{\stockheight}{\stockwidth}{*}
    \settrims{0mm}{0mm}

    ◊; spine / edge / ratio
    \setlrmarginsandblock{30mm}{60mm}{*}%
    \setheaderspaces{20.0mm}{*}{*}%
    ◊; sep / width / push
    \setmarginnotes{7mm}{35mm}{10mm}
    \checkandfixthelayout[fixed]
    
    \setmainfont{Equity OT A}[
        BoldFont = Equity OT A Bold,
        ItalicFont = Equity OT A Italic,
        BoldItalicFont = Equity OT A Bold Italic,
    ]

    \newfontfamily{\equityspaced}{Equity OT A}[
        BoldFont       = Equity OT A Bold,
        ItalicFont     = Equity OT A Italic,
        BoldItalicFont = Equity OT A Bold Italic,
        Numbers        = OldStyle,
        LetterSpace    = 2,
    ]

    \newfontfamily{\equityit}{Equity OT A Italic}

    \setmathfont{latinmodern-math.otf}[
        Path = {/home/creynolds/.fonts/thick-lm-otf/},
        Scale = 1.03,
    ]
    \setmathfont{NewCMMath-Book}[
        Scale=MatchLowercase,
        range={bb},
    ]
    \setmathfont{STIX Two Math}[range={scr,bfscr},StylisticSet=01]
    \setsansfont{Cabin}[Scale=MatchLowercase]
    \setmonofont{FiraCode-Retina.ttf}[
        BoldFont = {FiraCode-Bold.ttf},
        Contextuals = {NoSwash, NoAlternate, NoWordInitial, NoWordFinal, NoLineFinal, NoInner},
        Scale=0.85,
    ]
    \newfontfamily\chapterfont{Equity OT A}[
        Numbers=OldStyle,
        WordSpace={2},
        LetterSpace=20.0,
    ]
    \newfontfamily\prechapfont{SourceSerif4Display-SemiboldIt.otf}[
        LetterSpace=2.0,
    ]
    \newfontfamily\secfont{Equity OT A}[
        Numbers=OldStyle,
        WordSpace={1.5},
    ]
    \newfontfamily\ipafont{Charis SIL}[
        Scale=MatchLowercase,
    ]

    \usepackage{xcolor}
    \definecolor{muted}{gray}{0.05}

    \usepackage{calc}
    \usepackage{hyphenat}
    \hyphenation{
        Java-Script
        Bib-Base
        Math-Jax
    }

    \makechapterstyle{custom}{%
        \chapterstyle{default}
        \setlength{\beforechapskip}{2.5ex}
        \renewcommand*{\chapterheadstart}{\vspace{\beforechapskip}}
        \setlength{\afterchapskip}{1.5ex}
        \renewcommand{\printchaptername}{}
        \renewcommand{\chapternamenum}{}
        \renewcommand{\chaptitlefont}{\secfont\scshape\color{muted}}
        \renewcommand{\chapnumfont}{\chaptitlefont}
        \renewcommand{\printchaptertitle}[1]{\MakeLowercase{##1}}
        \renewcommand{\printchapternum}{\chapnumfont \thechapter\quad}
        \renewcommand{\afterchapternum}{}}

    ◊; \makechapterstyle{custom}{%
    ◊;     \renewcommand{\chapterheadstart}{}
    ◊;     \renewcommand{\printchaptername}{}
    ◊;     \renewcommand{\chapternamenum}{}
    ◊;     \renewcommand{\printchapternum}{}
    ◊;     \renewcommand{\afterchapternum}{}
    ◊;     \renewcommand{\printchaptertitle}[1]{%
    ◊;         \secfont\scshape\color{muted}\MakeLowercase{##1}}
    ◊;     \renewcommand{\afterchaptertitle}{}
    ◊; }
    \chapterstyle{custom}

    \setsecnumdepth{subsection}
    \setsecheadstyle{\equityit\color{muted}\addperiod}
    \setbeforesecskip{-\onelineskip}
    \setaftersecskip{-0.5em}
    \setsecnumformat{\secfont\csname the#1\endcsname\hspace{0.5em} \equityit}
    \setsubsecheadstyle{\normalfont\itshape\color{muted}}

    \usepackage{csquotes}

    \usepackage[
        backend=biber,
        style=authoryear,
        url=false,
        doi=true,
        eprint=false
    ]{biblatex}
    \DeclareDelimFormat{nameyeardelim}{\addcomma\space}
    \addbibresource{references.bib}

    \usepackage[hidelinks]{hyperref}
    \urlstyle{same}

    \title{◊(format "~a" (select-from-metas 'title metas))}
    \author{◊(format "~a" (select-from-metas 'author metas))}
    \date{◊(format "~a" (select-from-metas 'date metas))}

    \pretitle{\begin{raggedright}\Huge\begin{tabular}{rl}\renewcommand{\arraystretch}{0}}
    \posttitle{\par\end{tabular}\end{raggedright}\vskip 2em}
    \preauthor{\begin{raggedright}\huge\itshape\hspace{2.2em}}
    \postauthor{\par\end{raggedright}}
    \predate{}\postdate{}

    \makepagenote
    \continuousnotenums
    ◊; \notepageref
    \renewcommand*{\notesname}{Links}
    \renewcommand*{\notedivision}{\chapter*{\scshape \notesname}}
    \renewcommand*{\pagenotesubhead}[3]{}
    \renewcommand*{\pagenotesubheadstarred}[3]{}

    \begin{document}
    \begin{raggedright}
    {\equityspaced \LARGE \thetitle}\\[1em]
    \text{\small\theauthor}\\
    \textit{\small\href{mailto:conor.reynolds@mu.ie}{conor.reynolds@mu.ie}}
    \end{raggedright}
    \vspace{2em}

    \noindent}
◊(require racket/list)
◊(apply string-append (filter string? (flatten doc)))
◊string-append{
    \vspace*{3.5ex}
    \hrule
    \vspace*{1.5ex}
    \printpagenotes
    \printbibliography
    \end{document}
}