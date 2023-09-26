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
  "body": `I am a PhD student at Maynooth University . My research interests include the theory of institutions , the Coq proof assistant , the Event‑B formal modelling tool , and formal software design in general. I’m working on formalising the theory of institutions in Coq, with the institution for Event‑B as a primary use-case—supervised by Prof Rosemary Monahan and funded by the Irish Research Council . The formalisation is open source and available on my GitHub . Publications The following is pulled from my Zotero account. See the source repo for details on how this is generated, or you can read about this site . Machine-Assisted Proofs for Institutions in Coq . Reynolds, C.; and Monahan, R. In Aït-Ameur, Y.; and Crăciun, F., editor(s), Theoretical Aspects of Software Engineering , pages 180–196 , Cham , 2022 . Springer International Publishing Link BibTeX @inproceedings{reynolds_machine-assisted_2022, address = {Cham}, title = {Machine-{Assisted} {Proofs} for {Institutions} in {Coq}}, copyright = {All rights reserved}, isbn = {978-3-031-10363-6}, doi = {10/gqfnb6}, booktitle = {Theoretical {Aspects} of {Software} {Engineering}}, publisher = {Springer International Publishing}, author = {Reynolds, Conor and Monahan, Rosemary}, editor = {Aït-Ameur, Yamine and Crăciun, Florin}, year = {2022}, pages = {180–196}, } Using Dafny to Solve the VerifyThis 2021 Challenges . Farrell, M.; Reynolds, C.; and Monahan, R. In Proceedings of the 23rd ACM International Workshop on Formal Techniques for Java-like Programs , pages 32–38 , New York, NY, USA , July 13, 2021 . Association for Computing Machinery Link BibTeX @inproceedings{farrell_using_2021, address = {New York, NY, USA}, series = {{FTfJP} 2021}, title = {Using {Dafny} to {Solve} the {VerifyThis} 2021 {Challenges}}, isbn = {978-1-4503-8543-5}, doi = {10/gp5v6h}, urldate = {2022-05-16}, booktitle = {Proceedings of the 23rd {ACM} {International} {Workshop} on {Formal} {Techniques} for {Java}-like {Programs}}, publisher = {Association for Computing Machinery}, author = {Farrell, Marie and Reynolds, Conor and Monahan, Rosemary}, month = jul, year = {2021}, keywords = {Dafny, Deductive Verification, Verification Challenges, VerifyThis}, pages = {32–38}, } Formalizing the Institution for Event-B in the Coq Proof Assistant . Reynolds, C. In Raschke, A.; and Méry, D., editor(s), Rigorous State-Based Methods , pages 162–166 , Cham , 2021 . Springer International Publishing Link BibTeX @inproceedings{reynolds_formalizing_2021, address = {Cham}, series = {Lecture {Notes} in {Computer} {Science}}, title = {Formalizing the {Institution} for {Event}-{B} in the {Coq} {Proof} {Assistant}}, copyright = {All rights reserved}, isbn = {978-3-030-77543-8}, doi = {10/gpjt7c}, language = {en}, booktitle = {Rigorous {State}-{Based} {Methods}}, publisher = {Springer International Publishing}, author = {Reynolds, Conor}, editor = {Raschke, Alexander and Méry, Dominique}, year = {2021}, keywords = {Coq, Event-B, Institution theory}, pages = {162–166}, }`,
  "url": `index.html`,
});

searchIndex.addDoc({
  "id": id++,
  "title": `Contact`,
  "toctitle": `Contact`,
  "body": `The best way to contact me is by email at conor.reynolds@mu.ie . My social links extend only as far as a GitHub account , a GitLab account , a LinkedIn account , and a Twitter account . These are also listed in the footer.`,
  "url": `contact.html`,
});

searchIndex.addDoc({
  "id": id++,
  "title": `Curriculum Vitae`,
  "toctitle": `CV`,
  "body": `Education PhD in Computer Science , Maynooth University, 2019–pres. MSc in Mathematics , Maynooth University, 2018–2019 ( h1 ) BSc in Computational Thinking , Maynooth University, 2015–2018 ( h1 ) Awards Government of Ireland Postgraduate Scholarship Programme Award , awarded by the Irish Research Council in 2019. (This is my PhD funding.) Hamilton Prize in Mathematics, awarded in 2017 by the Royal Irish Academy to the best undergraduate students of mathematics in Ireland in their penultimate year of study. Various ‘best student’ awards internal to Maynooth University, including the Turing and Cook Prizes for Computer Science and the Delort Prize for Mathematics.`,
  "url": `cv.html`,
});

searchIndex.addDoc({
  "id": id++,
  "title": `Posts`,
  "toctitle": `Posts`,
  "body": `About This Site — 23 September 2022`,
  "url": `posts.html`,
});

searchIndex.addDoc({
  "id": id++,
  "title": `About This Site`,
  "toctitle": `About This Site`,
  "body": `This site is built using Pollen , an incredibly flexible tool for creating web books. To oversimplify: Pollen source files go in, written in a markup language of your own design, and HTML comes out. It’s like LaTeX for the web—but where LaTeX is a giant macro preprocessor, Racket is a modern programming language. This turns out to have quite a few benefits. This site is open source , so feel free to have a dig around to see how it works. Instead of explaining in detail exactly what makes Pollen great, I’ll provide an example of how I use it. I wanted to list my publications on the front page of my site. I also wanted to automate this process, since the job of curating such a list by hand is initially tedious and eventually forgotten outright. I already maintain a list of my publications on my Zotero account. In the past I used BibBase to present this information on my site, but found that it was extremely finicky to style to my liking, and very slow to load. For longer lists the wait becomes nearly unbearable. It occurred to me that this information could be generated at compile time with a small Racket script rather than every time the site is served. Pollen easily facilitates this. Part of the source for the home page looks something like this: index.html.pm 1 2 3 4 5 ◊ section { Publications} The following is pulled from my Zotero account. ◊ aside { See the ◊ extlink [ " ... " ]{ source repo} for details on how this is generated, or you can read ◊ xref [ " posts/about-this-site.html " ]{ about this site}.} ◊ ( cons @ ◊ ( bib-items )) The function bib-items is defined in src/zotero.rkt . It pulls my publications directly from Zotero’s API and constructs a list of divs that I can splice into the document. Since this is done at compile time, a user visiting the page just sees plain HTML. That’s all there is to it. It loads faster, it’s easier to customise, and it provides almost as much automation—all for a fraction of the time I spent tweaking BibBase. Though, if this isn’t your cup of tea, I would still highly recommend BibBase as an alternative. Light and Dark Themes Light and dark themes are defined for the site. I’ll admit to putting more effort into the light theme, so the dark theme might look a little funky by comparison. The theme is chosen by a CSS media query based on your browser or system preferences and can’t otherwise be changed. Hidden Features Some features are easier to signpost than others, but a few features can really suffer aesthetically and ergonomically by aggressive signposting. For example, some acronyms (like this one: LEM law of excluded middle ) can be hovered to reveal their definition. I think styling such abbreviations differently is a mistake. True, the new reader might miss it, but the cost of signposting for the returning reader is much greater. No one wants to be reminded over and over again that acronyms can be hovered. This feature is a bit awkward on mobile devices at the moment. Full-Text Search The site comes with non-fuzzy full-text search. This is currently disabled on posts. Not sure where to put the search bar, frankly. This was a feature that I created for another project I’m working on, but it should work for any Pollen-generated website, so I figured I’d add it for fun. It’s basically a thin wrapper over elasticlunr and is very barebones, but it’s fast and gets the job done. Some known weirdness includes (but is certainly not limited to): There’s some incongruity between the actual search term and what elasticlunr matches due to its stemmer . This can prevent the searcher hook from finding the term that was actually matched. Sometimes hidden places are searched. Like these asides, for example. The search feature works by simulating a Ctrl + F / ⌘ F for the searched term when the page loads, but if the term is hidden then it won’t be found. While it would be nice to include a more detailed preview of the context of a search, like for mdBook-generated sites , it seems like overkill. In practice, the search feature was intended primarily to facilitate keyboard-first navigation. To this end, the forward-slash character is set to focus the search bar. Plenty of sites (like GitHub) and browsers (like Firefox) have this sort of functionality, but I mean—is overriding this considered annoying? I have no idea. Let me know if this is annoying. Syntax Highlighting Pollen comes with a highlight function, which statically generates syntax-highlighted code using Pygments . Most styles didn’t really suit the site, so I wrote my own . I also wrote a Pollen lexer, which you can find here . It’s almost certainly far too simple, but it works fine on the basic snippets I’ve tried. The easiest way to add new lexers, it seems, is to just fork a copy of Pygments, add the lexer directly, rebuild the lexer mapping with make mapfiles (as described in the docs ), then pip install your local copy of Pygments. You can throw your custom styles in there too while you’re at it.`,
  "url": `posts/about-this-site.html`,
});

