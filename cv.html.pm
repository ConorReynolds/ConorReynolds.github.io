#lang pollen

◊(define-meta toc-title "CV")
◊(define-meta title "Curriculum Vitae")
◊(define-meta subtitle "Under construction 🚧")

◊section-ruled{Research Activities}

My publications are on the ◊xref{home page}, if you're looking for those. Some other things I'm doing or have done:

◊ul[#:compact #f]{  
  ◊item{
    I'm on the program committee for ◊extlink["https://smcit-scc.space/"]{IEEE SMC-IT 2024}. ◊aside{Pronounced 'smack it'. I think all conference names should be this amusing.}
  }
  ◊item{
    I'm the web chair (that is, I made the website) for ◊extlink["https://ifm2024.cs.manchester.ac.uk/"]{iFM 2024}. It's built using ◊extlink["https://docs.racket-lang.org/pollen/"]{Pollen}, same as this site.
  }
}

◊section-ruled{PhD Thesis}

Supervised by Prof Rosemary Monahan, I put ◊extlink["https://iep.utm.edu/insti-th/"]{institution theory} in the ◊extlink["https://coq.inria.fr/"]{Coq proof assistant}. You can see it ◊extlink["https://github.com/ConorReynolds/coq-institutions"]{on GitHub}.

Institution theory studies logical systems in general using category theory. An institution is a mathematical object which is supposed to approximate a 'logical system', and so by studying institutions we hope to study logical systems in general.

I encoded some of the general theory of institutions in Coq and (more significantly) instantiated the theory to a few concrete logics, mostly first-order logic and its variants. I also constructed a trace semantics for Event-B as an institution and combined it with linear temporal logic as a duplex construction. ◊aside{This sounds a lot fancier than it is, but it's still neat.}

◊section-ruled{Work & Education}

◊hang-list[#:compact #t]{
  ◊item{
    Postdoctoral Research Associate in ◊em{Computer Science}, University of Manchester, 2023–pres.
  }
  ◊item{
    PhD in ◊em{Computer Science}, Maynooth University, 2019–2023
  }
  ◊item{
    MSc in ◊em{Mathematics}, Maynooth University, 2018–2019 (◊sc-form{h1})
  }
  ◊item{
    BSc in ◊em{Computational Thinking}, Maynooth University, 2015–2018 (◊sc-form{h1})
  }
}

◊section-ruled{Awards}

◊hang-list[#:compact #f]{
  ◊item{
    ◊em{Government of Ireland Postgraduate Scholarship Programme Award}, awarded by the ◊extlink["https://research.ie"]{Irish Research Council} in 2019. This was my PhD funding.
  }
  ◊item{
    ◊em{Hamilton Prize in Mathematics}, awarded in 2017 by the ◊extlink["https://www.ria.ie/grants-awards/prizes/hamilton-prize-mathematics"]{Royal Irish Academy} to the best undergraduate students of mathematics in Ireland in their penultimate year of study.
  }
  ◊item{
    ◊em{Cook Prize in Computer Science}, awarded to the best second-year computer science student at Maynooth University.
  }
  ◊item{
    ◊em{Delort Prize in Mathematics}, awarded in 2016 to the best first-year mathematics student at Maynooth University. 
  }
  ◊item{
    ◊em{Turing Prize in Computer Science}, awarded in 2016 to the best first-year Computational Thinking student at Maynooth University.
  }
}
