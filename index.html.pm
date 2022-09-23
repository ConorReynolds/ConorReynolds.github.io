#lang pollen

◊(define-meta title "Home")

◊title-block{
  ◊title{Conor Reynolds}
  ◊subtitle{PhD Student & Formal Methods Researcher}
}

I am a PhD student at ◊extlink["https://www.maynoothuniversity.ie/"]{Maynooth University.} My research interests include the ◊extlink["https://iep.utm.edu/insti-th/"]{theory of institutions,} the ◊extlink["https://coq.inria.fr/"]{Coq proof assistant,} the ◊extlink["http://www.event-b.org/"]{Event‑B formal modelling tool,} and formal software design in general.

I'm working on formalising the theory of institutions in Coq, with the institution for Event‑B as a primary use-case---supervised by Dr Rosemary Monahan and funded by the ◊extlink["https://research.ie/"]{Irish Research Council.} The formalisation is open source and available ◊extlink["https://github.com/ConorReynolds/coq-institutions"]{on my GitHub.}

◊section{Publications}

The following is pulled from my Zotero account. ◊aside{See the ◊extlink["https://github.com/ConorReynolds/ConorReynolds.github.io/blob/main/src/zotero.rkt"]{source repo} for details on how this is generated.}

◊(cons '@ ◊(bib-items))
