#lang pollen

◊(require xml)

◊(define-meta title "About This Site")
◊(define-meta math? #false)
◊(define-meta created "2022-09-23")

◊title-block{
  ◊title{About This Site}
  ◊subtitle{Pollen + Makefile = all you need}
}

This site is built using ◊extlink["https://docs.racket-lang.org/pollen"]{Pollen,} an incredibly flexible tool for creating web books. To oversimplify: Pollen source files are fed in, written in a markup language of one's own design, and HTML is spat out. It's like ◊latex[] for the web---but where ◊latex[] is a giant macro preprocessor, Racket is a modern programming language. This site is ◊extlink["https://github.com/ConorReynolds/ConorReynolds.github.io"]{open source,} so feel free to have a dig around to see how it works.

Instead of explaining in detail exactly what makes Pollen great, I'll provide an example of how I use it.

I wanted to list my publications on the front page of my site. I also wanted to automate this process, since the job of curating such a list by hand is initially tedious and eventually forgotten outright.

I maintain a list of my publications on my Zotero account. In the past I used ◊extlink["https://bibbase.org/"]{BibBase} to present this information on my site, but found that it was extremely finicky to style to my liking, and very slow to load. For longer lists the wait becomes nearly unbearable.

I eventually got sick of this and decided to generate the information at compile time with a small Racket script. The source for the ◊xref{home} page looks something like this:

◊; Copy–pasted from VSCode for syntax highlighting (with some modifications)
◊(cons 'verbatim `(,(string->xexpr "<div class=\"highlight code-wrap\"><pre><div><span style=\"color: var(--fg-color);\">◊</span><span style=\"color: #219aa5;\">section</span><span style=\"color: var(--fg-color);\">{Publications}</span></div><br/><div><span style=\"color: var(--fg-color);\">The following is pulled from my Zotero account. ◊</span><span style=\"color: #219aa5;\">aside</span><span style=\"color: var(--fg-color);\">{See the ◊</span><span style=\"color: #219aa5;\">extlink</span><span style=\"color: var(--fg-color);\">[</span><span style=\"color: #555555;\">\"https://github.com/ConorReynolds/ConorReynolds.github.io/blob/main/src/zotero.rkt\"</span><span style=\"color: var(--fg-color);\">]{source repo} for details on how this is generated.}</span></div><br/><div><span style=\"color: var(--fg-color);\">◊(</span><span style=\"color: #219aa5;\">cons</span><span style=\"color: var(--fg-color);\"> '@ ◊(bib-items))</span></div></pre></div>")))

The function ◊code{bib-items} is defined in ◊extlink["https://github.com/ConorReynolds/ConorReynolds.github.io/blob/main/src/zotero.rkt"]{◊code{src/zotero.rkt}.} It pulls my publications directly from Zotero's API and constructs a list of divs that I can splice into the document. This is done at compile time, so a user visiting the page just sees plain HTML. And that's it! It loads faster, it's easier to customise, and it provides almost as much automation---all for a meagre fraction of the time I spent tweaking BibBase. ◊aside{Though, if this isn't your cup of tea, I would still highly recommend BibBase as an alternative.}

◊section{Full-Text Search}

The site comes with non-fuzzy full-text search. This was a feature that I created for another project I'm working on, but it works for any(?) Pollen-generated website, so I figured I'd add it for fun. It's basically a thin wrapper over ◊extlink["http://elasticlunr.com/"]{elasticlunr} and is ◊em{very} barebones, but it's fast and gets the job done.
