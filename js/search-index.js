var searchIndex = elasticlunr(function () {
  this.setRef('id');
  this.addField('title');
  this.addField('body');
});

var id = 0;

searchIndex.addDoc({
  "id": id++,
  "title": `Home`,
  "body": `Conor Reynolds PhD Student & Formal Methods Researcher I am a PhD student at Maynooth University. My research interests include the theory of institutions, the Coq proof assistant, the Event‑B formal modelling tool, and formal software design in general. I’m working on formalising the theory of institutions in Coq, with the institution for Event‑B as a primary use-case—supervised by Dr Rosemary Monahan and funded by the Irish Research Council. The formalisation is open source and available on my GitHub. Publications The following is pulled from my Zotero account. See the source repo for details on how this is generated. Machine-Assisted Proofs for Institutions in Coq . Reynolds, C.; and Monahan, R. In Aït-Ameur, Y.; and Crăciun, F., editor(s), Theoretical Aspects of Software Engineering , pages 180–196 , Cham , 2022 . Springer International Publishing Link BibTeX @inproceedings{reynolds_machine-assisted_2022, address = {Cham}, title = {Machine-{Assisted} {Proofs} for {Institutions} in {Coq}}, isbn = {978-3-031-10363-6}, url = {https://doi.org/10.1007/978-3-031-10363-6_13}, doi = {10/gqfnb6}, abstract = {The theory of institutions provides an abstract mathematical framework for specifying logical systems and their semantic relationships. Institutions are based on category theory and have deep roots in a well-developed branch of algebraic specification. However, there are no machine-assisted proofs of correctness for institution-theoretic constructions—chiefly satisfaction conditions for institutions and their (co)morphisms—making them difficult to incorporate into mainstream formal methods. This paper therefore provides the details of our approach to formalizing a fragment of the theory of institutions in the Coq proof assistant. We instantiate this framework with the institutions FOPEQ for first-order predicate logic and EVT for the Event-B specification language, both of which will serve as an illustration and evaluation of the overall approach.}, booktitle = {Theoretical {Aspects} of {Software} {Engineering}}, publisher = {Springer International Publishing}, author = {Reynolds, Conor and Monahan, Rosemary}, editor = {Aït-Ameur, Yamine and Crăciun, Florin}, year = {2022}, pages = {180–196}, } Formalizing the Institution for Event-B in the Coq Proof Assistant . Reynolds, C. In Raschke, A.; and Méry, D., editor(s), Rigorous State-Based Methods , pages 162–166 , Cham , 2021 . Springer International Publishing Link BibTeX @inproceedings{reynolds_formalizing_2021, address = {Cham}, series = {Lecture {Notes} in {Computer} {Science}}, title = {Formalizing the {Institution} for {Event}-{B} in the {Coq} {Proof} {Assistant}}, copyright = {All rights reserved}, isbn = {978-3-030-77543-8}, doi = {10.1007/978-3-030-77543-8_17}, language = {en}, booktitle = {Rigorous {State}-{Based} {Methods}}, publisher = {Springer International Publishing}, author = {Reynolds, Conor}, editor = {Raschke, Alexander and Méry, Dominique}, year = {2021}, keywords = {Coq, Event-B, Institution theory}, pages = {162–166}, } Using Dafny to Solve the VerifyThis 2021 Challenges . Farrell, M.; Reynolds, C.; and Monahan, R. In Proceedings of the 23rd ACM International Workshop on Formal Techniques for Java-like Programs , pages 32–38 , New York, NY, USA , July 13, 2021 . Association for Computing Machinery Link BibTeX @inproceedings{farrell_using_2021, address = {New York, NY, USA}, series = {{FTfJP} 2021}, title = {Using {Dafny} to {Solve} the {VerifyThis} 2021 {Challenges}}, isbn = {978-1-4503-8543-5}, doi = {10.1145/3464971.3468422}, abstract = {This paper provides an experience report of using the Dafny program verifier, at the VerifyThis 2021 program verification competition. The competition aims to evaluate the usability of logic-based program verification tools in a controlled experiment, challenging both the verification tools and the users of those tools. We present the two challenges that we tackled during the competition and discuss our solutions. As a result, we identify strengths and weaknesses of Dafny in the verification of relatively complex algorithms, and report on our experience of applying Dafny in this setting.}, urldate = {2022-05-16}, booktitle = {Proceedings of the 23rd {ACM} {International} {Workshop} on {Formal} {Techniques} for {Java}-like {Programs}}, publisher = {Association for Computing Machinery}, author = {Farrell, Marie and Reynolds, Conor and Monahan, Rosemary}, month = jul, year = {2021}, keywords = {Dafny, Deductive Verification, Verification Challenges, VerifyThis}, pages = {32–38}, }`,
  "url": `index.html`,
});

searchIndex.addDoc({
  "id": id++,
  "title": `Contact`,
  "body": `Contact Email is best: conor.reynolds@mu.ie The best way to contact me is by email at conor.reynolds@mu.ie. My social links, if you can call them that, extend only as far as a GitHub account, a GitLab account, and a Twitter account —created against my better judgement.`,
  "url": `contact.html`,
});

searchIndex.addDoc({
  "id": id++,
  "title": `CV`,
  "body": `Curriculum Vitae Under construction 🚧 Still working on it! In the meantime, here’s some information of questionable note. Education PhD in Computer Science, Maynooth University, 2019–now MSc in Mathematics, Maynooth University, 2018–2019 BSc in Computational Thinking, Maynooth University, 2015–2018 Awards Hamilton Prize in Mathematics, awarded by the Royal Irish Academy in 2017 Turing and Cook Prizes for Computer Science, 2017 Delort Prize for Mathematics, 2016`,
  "url": `cv.html`,
});

searchIndex.addDoc({
  "id": id++,
  "title": `Posts`,
  "body": `Posts Everything I’ve posted to date About This Site ~ Fri, September 23, 2022`,
  "url": `posts.html`,
});

searchIndex.addDoc({
  "id": id++,
  "title": `About This Site`,
  "body": `About This Site Pollen + Makefile = all you need This site is built using Pollen, an incredibly flexible tool for creating web books. To oversimplify: Pollen source files are fed in, written in a markup language of one’s own design, and HTML is spat out. It’s like LaTeX for the web—but where LaTeX is a giant macro preprocessor, Racket is a modern programming language. This site is open source, so feel free to have a dig around to see how it works. Instead of explaining in detail exactly what makes Pollen great, I’ll provide an example of how I use it. I wanted to list my publications on the front page of my site. I also wanted to automate this process, since the job of curating such a list by hand is initially tedious and eventually forgotten outright. I maintain a list of my publications on my Zotero account. In the past I used BibBase to present this information on my site, but found that it was extremely finicky to style to my liking, and very slow to load. For longer lists the wait becomes nearly unbearable. I eventually got sick of this and decided to generate the information at compile time with a small Racket script. The source for the home page looks something like this: 1 2 3 4 5 ◊section{Publications} The following is pulled from my Zotero account. ◊aside{See the ◊extlink[ " https://github.com/ConorReynolds/ConorReynolds.github.io/blob/main/src/zotero.rkt " ]{source repo} for details on how this is generated.} ◊(cons @ ◊(bib-items)) The function bib-items is defined in src/zotero.rkt . It pulls my publications directly from Zotero’s API and constructs a list of divs that I can splice into the document. This is done at compile time, so a user visiting the page just sees plain HTML. And that’s it! It loads faster, it’s easier to customise, and it provides almost as much automation—all for a meagre fraction of the time I spent tweaking BibBase. Though, if this isn’t your cup of tea, I would still highly recommend BibBase as an alternative. Full-Text Search The site comes with non-fuzzy full-text search. This was a feature that I created for another project I’m working on, but it works for any(?) Pollen-generated website, so I figured I’d add it for fun. It’s basically a thin wrapper over elasticlunr and is very barebones, but it’s fast and gets the job done.`,
  "url": `posts/about-this-site.html`,
});

