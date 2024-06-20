elasticlunr.clearStopWords();

var searchIndex = elasticlunr(function () {
  this.setRef('id');
  this.addField('title');
  this.addField('toctitle');
  this.addField('body');
});

var id = 0;

searchIndex.addDoc({
  "id": id++,
  "title": `Conor Reynolds`,
  "toctitle": `Home`,
  "body": `I’m a postdoc at the University of Manchester working on a variety of things. I’m part of the Autonomy and Verification group . I spent my PhD encoding the theory of institutions in the Coq proof assistant . (It’s all on GitHub .) There are six or so concrete logics encoded there as of this writing, depending on how you count it. I wrote lots of teaching resources while I was a PhD student at Maynooth . You can see a small selection of them here . 2024 FRETting and Formal Modelling: A Mechanical Lung Ventilator . Farrell, M., Luckcuck, M., Monahan, R., Reynolds, C., and Sheridan, O. In International Conference on Rigorous State Based Methods , ( Switzerland ), Springer Cham . Link BibTeX @inproceedings{farrell_fretting_2024, address = {Switzerland}, title = {{FRETting} and {Formal} {Modelling}: {A} {Mechanical} {Lung} {Ventilator}}, language = {English}, booktitle = {International {Conference} on {Rigorous} {State} {Based} {Methods}}, publisher = {Springer Cham}, author = {Farrell, Marie and Luckcuck, Matt and Monahan, Rosemary and Reynolds, Conor and Sheridan, Oisin}, month = jun, year = {2024}, } Reasoning about logical systems in the Coq proof assistant . Reynolds, C., and Monahan, R. Science of Computer Programming , 233 , 103054 . Link BibTeX @article{reynolds_reasoning_2024, title = {Reasoning about logical systems in the {Coq} proof assistant}, volume = {233}, issn = {0167-6423}, url = {https://www.sciencedirect.com/science/article/pii/S0167642323001363}, doi = {10/gs7f2x}, abstract = {The theory of institutions provides an abstract mathematical framework for specifying logical systems and their semantic relationships. Institutions are based on category theory and have deep roots in a well-developed branch of algebraic specification. However, there are no machine-assisted proofs of correctness for institution-theoretic constructions—chiefly satisfaction conditions for institutions and their (co)morphisms—making them difficult to incorporate into mainstream formal methods. This paper therefore provides the details of our approach to formalizing a fragment of the theory of institutions in the Coq proof assistant. We instantiate this framework with the institutions FOPEQ for first-order predicate logic and EVT for the Event-B specification language, and define some institution-independent constructions, all of which serve as an illustration and evaluation of the overall approach.}, urldate = {2023-11-30}, journal = {Science of Computer Programming}, author = {Reynolds, Conor and Monahan, Rosemary}, month = mar, year = {2024}, pages = {103054}, } 2022 Machine-Assisted Proofs for Institutions in Coq . Reynolds, C., and Monahan, R. In Theoretical Aspects of Software Engineering , ( Cham ), Springer International Publishing , 180–196 . Link BibTeX @inproceedings{reynolds_machine-assisted_2022, address = {Cham}, title = {Machine-{Assisted} {Proofs} for {Institutions} in {Coq}}, copyright = {All rights reserved}, isbn = {978-3-031-10363-6}, doi = {10/gqfnb6}, booktitle = {Theoretical {Aspects} of {Software} {Engineering}}, publisher = {Springer International Publishing}, author = {Reynolds, Conor and Monahan, Rosemary}, editor = {Aït-Ameur, Yamine and Crăciun, Florin}, year = {2022}, pages = {180–196}, } 2021 Using Dafny to Solve the VerifyThis 2021 Challenges . Farrell, M., Reynolds, C., and Monahan, R. In Proceedings of the 23rd ACM International Workshop on Formal Techniques for Java-like Programs , ( New York, NY, USA ), Association for Computing Machinery , 32–38 . Link BibTeX @inproceedings{farrell_using_2021, address = {New York, NY, USA}, series = {{FTfJP} 2021}, title = {Using {Dafny} to {Solve} the {VerifyThis} 2021 {Challenges}}, isbn = {978-1-4503-8543-5}, doi = {10/gp5v6h}, urldate = {2022-05-16}, booktitle = {Proceedings of the 23rd {ACM} {International} {Workshop} on {Formal} {Techniques} for {Java}-like {Programs}}, publisher = {Association for Computing Machinery}, author = {Farrell, Marie and Reynolds, Conor and Monahan, Rosemary}, month = jul, year = {2021}, pages = {32–38}, } Formalizing the Institution for Event-B in the Coq Proof Assistant . Reynolds, C. In Rigorous State-Based Methods , ( Cham ), Springer International Publishing , 162–166 . Link BibTeX @inproceedings{reynolds_formalizing_2021, address = {Cham}, series = {Lecture {Notes} in {Computer} {Science}}, title = {Formalizing the {Institution} for {Event}-{B} in the {Coq} {Proof} {Assistant}}, copyright = {All rights reserved}, isbn = {978-3-030-77543-8}, doi = {10/gpjt7c}, language = {en}, booktitle = {Rigorous {State}-{Based} {Methods}}, publisher = {Springer International Publishing}, author = {Reynolds, Conor}, editor = {Raschke, Alexander and Méry, Dominique}, year = {2021}, pages = {162–166}, }`,
  "url": `index.html`,
});

searchIndex.addDoc({
  "id": id++,
  "title": `Contact`,
  "toctitle": `Contact`,
  "body": `The best way to contact me is by email at conor.reynolds@manchester.ac.uk My social links extend only as far as a GitHub account , a LinkedIn account , and a Twitter account . These are also listed in the footer.`,
  "url": `contact.html`,
});

searchIndex.addDoc({
  "id": id++,
  "title": `Curriculum Vitae`,
  "toctitle": `CV`,
  "body": `Research Activities My publications are on the home page , if you’re looking for those. Some other things I’m doing or have done: I’m on the program committee for IEEE SMC-IT 2024 . Pronounced ‘smack it’. I think all conference names should be this amusing. I’m the web chair (that is, I made the website) for iFM 2024 . It’s built using Pollen , same as this site. PhD Thesis Supervised by Prof Rosemary Monahan, I put institution theory in the Coq proof assistant . You can see it on GitHub . Institution theory studies logical systems in general using category theory. An institution is a mathematical object which is supposed to approximate a ‘logical system’, and so by studying institutions we hope to study logical systems in general. I encoded some of the general theory of institutions in Coq and (more significantly) instantiated the theory to a few concrete logics, mostly first-order logic and its variants. I also constructed a trace semantics for Event-B as an institution and combined it with linear temporal logic as a duplex construction. This sounds a lot fancier than it is, but it’s still neat. Work & Education Postdoctoral Research Associate in Computer Science , University of Manchester, 2023–pres. PhD in Computer Science , Maynooth University, 2019–2023 MSc in Mathematics , Maynooth University, 2018–2019 ( h1 ) BSc in Computational Thinking , Maynooth University, 2015–2018 ( h1 ) Awards Government of Ireland Postgraduate Scholarship Programme Award , awarded by the Irish Research Council in 2019. This was my PhD funding. Hamilton Prize in Mathematics , awarded in 2017 by the Royal Irish Academy to the best undergraduate students of mathematics in Ireland in their penultimate year of study. Cook Prize in Computer Science , awarded to the best second-year computer science student at Maynooth University. Delort Prize in Mathematics , awarded in 2016 to the best first-year mathematics student at Maynooth University. Turing Prize in Computer Science , awarded in 2016 to the best first-year Computational Thinking student at Maynooth University.`,
  "url": `cv.html`,
});

searchIndex.addDoc({
  "id": id++,
  "title": `Posts`,
  "toctitle": `Posts`,
  "body": `∅`,
  "url": `posts.html`,
});

