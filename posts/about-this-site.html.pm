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

◊codeblock['pollen #:wrap #t "◊section{Publications}\n\nThe following is pulled from my Zotero account. ◊aside{See the ◊extlink[\"https://github.com/ConorReynolds/ConorReynolds.github.io/blob/main/src/zotero.rkt\"]{source repo} for details on how this is generated.}"]{}

The function ◊code{bib-items} is defined in ◊extlink["https://github.com/ConorReynolds/ConorReynolds.github.io/blob/main/src/zotero.rkt"]{◊code{src/zotero.rkt}.} It pulls my publications directly from Zotero's API and constructs a list of divs that I can splice into the document. This is done at compile time, so a user visiting the page just sees plain HTML. And that's it! It loads faster, it's easier to customise, and it provides almost as much automation---all for a meagre fraction of the time I spent tweaking BibBase. ◊aside{Though, if this isn't your cup of tea, I would still highly recommend BibBase as an alternative.}

◊section{Full-Text Search}

The site comes with non-fuzzy full-text search. This was a feature that I created for another project I'm working on, but it works for any(?) Pollen-generated website, so I figured I'd add it for fun. It's basically a thin wrapper over ◊extlink["http://elasticlunr.com/"]{elasticlunr} and is ◊em{very} barebones, but it's fast and gets the job done.

◊section{Syntax Highlighting}

Pollen comes with a ◊extlink["https://git.matthewbutterick.com/mbutterick/pollen/src/commit/c182a30f57ea5096440aea3d097f5fe3b78bb236/pollen/unstable/pygments.rkt#L157"]{◊code{highlight}} function, which statically generates syntax-highlighted code using ◊extlink["https://pygments.org/"]{Pygments.} I was not particularly enamoured with the provided styles. Some are nice, but few suit the style of this site. There was also no lexer for Pollen. Without one, showcasing examples of Pollen markup would prove some unpleasant combination of tricky and annoying.

I decided to try writing my own monochrome style. It suits the site, sure, but it's pretty boring. I also decided to add a Pollen lexer, which you can find ◊extlink["https://github.com/ConorReynolds/ConorReynolds.github.io/blob/main/pygments/pollen.py"]{here.} It's almost certainly ◊em{far} too simple, but it works fine on the basic snippets I've tried.

The easiest way to add new lexers, it seems, is to just fork a copy of Pygments, add the lexer directly, rebuild the lexer mapping with ◊code{make mapfiles} (as ◊extlink["https://pygments.org/docs/lexerdevelopment/#adding-and-testing-a-new-lexer"]{described in the docs}), then pip install your local copy of Pygments. You can throw your custom styles in there too while you're at it.
