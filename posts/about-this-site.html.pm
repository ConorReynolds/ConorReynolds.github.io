#lang pollen

◊(require xml)

◊(define-meta toc-title "About This Site")
◊(define-meta title "About This Site")
◊(define-meta math? #false)
◊(define-meta created "2022-09-23")

This site is built using ◊extlink["https://docs.racket-lang.org/pollen"]{Pollen,} an incredibly flexible tool for creating web books. To oversimplify: Pollen source files go in, written in a markup language of your own design, and HTML comes out. It's like ◊latex[] for the web---but where ◊latex[] is a giant macro preprocessor, Racket is a modern programming language. This turns out to have quite a few benefits. This site is ◊extlink["https://github.com/ConorReynolds/ConorReynolds.github.io"]{open source,} so feel free to have a dig around to see how it works.

Instead of explaining in detail exactly what makes Pollen great, I'll provide an example of how I use it.

I wanted to list my publications on the front page of my site. I also wanted to automate this process, since the job of curating such a list by hand is initially tedious and eventually forgotten outright.

I already maintain a list of my publications on my Zotero account. In the past I used ◊extlink["https://bibbase.org/"]{BibBase} to present this information on my site, but found that it was extremely finicky to style to my liking, and very slow to load. For longer lists the wait becomes nearly unbearable.

It occurred to me that this information could be generated at compile time with a small Racket script rather than every time the site is served. Pollen easily facilitates this. Part of the source for the ◊xref{home} page looks something like this:

◊codeblock['pollen #:name "index.html.pm" #:wrap #t "◊section{Publications}\n\nThe following is pulled from my Zotero account. ◊aside{See the ◊extlink[\"https://github.com/ConorReynolds/ConorReynolds.github.io/blob/main/src/zotero.rkt\"]{source repo} for details on how this is generated.}\n\n◊(cons '@ ◊(bib-items))"]{}

The function ◊code{bib-items} is defined in ◊extlink["https://github.com/ConorReynolds/ConorReynolds.github.io/blob/main/src/zotero.rkt"]{◊code{src/zotero.rkt}.} It pulls my publications directly from Zotero's API and constructs a list of divs that I can splice into the document. Since this is done at compile time, a user visiting the page just sees plain HTML.

That's all there is to it. It loads faster, it's easier to customise, and it provides almost as much automation---all for a fraction of the time I spent tweaking BibBase. ◊aside{Though, if this isn't your cup of tea, I would still highly recommend BibBase as an alternative.}

◊section{Full-Text Search}

The site comes with non-fuzzy full-text search. This was a feature that I created for another project I'm working on, but it works for any(?) Pollen-generated website, so I figured I'd add it for fun. It's basically a thin wrapper over ◊extlink["http://elasticlunr.com/"]{elasticlunr} and is ◊em{very} barebones, but it's fast and gets the job done.

Some known weirdness includes (but is certainly not limited to):

◊ul[#:compact #false]{
  ◊item{
    There's some incongruity between the actual search term and what elasticlunr matches due to its ◊extlink["http://elasticlunr.com/docs/stemmer.js.html"]{stemmer.} This can prevent the searcher hook from finding the term that was actually matched.
  }

  ◊item{
    Sometimes hidden places are searched. ◊aside{Like these asides, for example.} Since they're hidden, the browser's search functionality---invoked in JS as ◊code{window.find}---can't find them.
  }
}

While it would be nice to include a more detailed preview of the context of your search, like for ◊extlink["https://github.com/rust-lang/mdBook"]{mdBook-generated sites,} it seems like overkill. In practice, the search feature was intended primarily to facilitate keyboard-first navigation. To this end, the forward-slash character is set to focus the search bar.

Plenty of sites (like GitHub) and browsers (like Firefox) have this sort of functionality, but I mean---is overriding this considered annoying? I have no idea. Let me know if this is annoying.

◊section{Syntax Highlighting}

Pollen comes with a ◊extlink["https://git.matthewbutterick.com/mbutterick/pollen/src/commit/c182a30f57ea5096440aea3d097f5fe3b78bb236/pollen/unstable/pygments.rkt#L157"]{◊code{highlight}} function, which statically generates syntax-highlighted code using ◊extlink["https://pygments.org/"]{Pygments.} Most styles didn't really suit the site, so ◊extlink["https://github.com/ConorReynolds/ConorReynolds.github.io/blob/main/styles/highlight.scss"]{I wrote my own.}

I also wrote a Pollen lexer, which you can find ◊extlink["https://github.com/ConorReynolds/ConorReynolds.github.io/blob/main/pygments/pollen.py"]{here.} It's almost certainly ◊em{far} too simple, but it works fine on the basic snippets I've tried.

The easiest way to add new lexers, it seems, is to just fork a copy of Pygments, add the lexer directly, rebuild the lexer mapping with ◊code{make mapfiles} (as ◊extlink["https://pygments.org/docs/lexerdevelopment/#adding-and-testing-a-new-lexer"]{described in the docs}), then pip install your local copy of Pygments. You can throw your custom styles in there too while you're at it.

◊section{Full Disclosure}

I use ◊extlink["https://clicky.com"]{clicky} for tracking. I just want a basic overview of traffic, and maybe some insight into where traffic is coming from. No personal data is logged.

Want to opt out? You probably have already. If you have virtually any sort of ad blocker installed---and at this point, who doesn't?---clicky will be blocked. If you have JavaScript disabled, the clicky script won't load. (But neither will some other useful features.)
