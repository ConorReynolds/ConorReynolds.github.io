#lang pollen

◊(define-meta title "About This Site")
◊(define-meta filename "about-this-site")
◊(define-meta author "Conor Reynolds")
◊(define-meta date "2022-05-20")
◊(define-meta mathjax #t)
◊(define-meta is-draft #f)

This isn't anything like a tutorial or a comprehensive reference---it's just a dump of some of the tools, resources, and thought-processes that went into building this site, in case it would be helpful to anyone. I update this pretty often, depending on how the implementation details for the site change.

◊chapter{Fonts}

I went with Charter. I converted the ◊extlink["https://ctan.org/pkg/xcharter"]{XCharter} OTF fonts to WOFF2, then base64-encoded them and baked them into my CSS. I went with XCharter rather than ◊extlink["https://en.wikipedia.org/wiki/Bitstream_Charter"]{Bitstream Charter} because it has an extended character set and more font variants---including small-caps, which I use for cross-references. Without a properly designed small-caps font, browsers will just scale down regular capitals as a substitute. It looks awful.

The PDF versions are typeset in Matthew Butterick's ◊extlink["https://mbtype.com/fonts/equity/"]{◊em{Equity}.}

◊chapter{Static-Site Generator}

I went with Hugo. I host on GitHub because it's free and because it's linked to my professional GitHub account where I host my projects. It's easy to set up a redirect from my ◊extlink["https://www.cs.nuim.ie/~creynolds"]{department site} (don't click that). If I change departments I can just keep setting up redirects to here. And if GitHub Pages dies for some reason, I can move it easily.

◊chapter{Colour Schemes}

As of 2022-05-25, this site respects the user's preference for light or dark mode. The support for dark mode is currently a ◊em{bit} preliminary, but it should look mostly fine.

◊chapter{How I Write Posts}

I preprocess everything with the ◊extlink["https://docs.racket-lang.org/pollen/"]{Pollen publishing tool} before I push the site live. I've never been a huge fan of Markdown. There are plenty of excellent criticisms of Markdown elsewhere---suffice it to say that, for me, it's far too limited. Hugo's shortcodes go some way to circumventing its limitations, but it's not really enough. Pollen, however, lets me write exactly how I want. I can also use it to generate ◊latex[] code, meaning that each blog post written in Pollen gets a PDF version for free. You can see this one ◊extlink["/posts/about-this-site.pdf"]{here.}

The site is open source and available ◊extlink["https://github.com/ConorReynolds/ConorReynolds.github.io"]{on my GitHub,} if you want to see how it works.

◊chapter{Asides}

The PDF versions of the posts get sidenotes, but on the web you instead get a nice little button. ◊aside{Cool, right? Well, unless you're reading this on a PDF, then it's a little less cool.} These don't quite work right on mobile yet. Depending on the screen size, it might jut outside the viewport. I'll get around to fixing this soon. Maybe.

◊chapter{SASS}

SASS is a really nice CSS extension language. The only problem is that VS Code ◊em{really} doesn't like Hugo's templating code hanging out in my SCSS files. This is annoying mainly because it interferes with autocompletion. My approach is just to avoid Hugo's templating in SASS altogether---it doesn't really make that much sense that styling information should live in a ◊code{config.toml}.

◊chapter{TypeScript}

For ◊extlink["https://github.com/gohugoio/hugo/releases/tag/v0.74.0"]{recent Hugo builds}, using TypeScript is as easy as piping a TS file through ◊code{js.Build}. I try to keep the JS to a minimum because I find it really annoying. The only JS on this site that I've written is the code implementing the font-size buttons, and some minor tweaks that I couldn't otherwise accomplish with CSS. The external JS comes from BibBase on the ◊crossref["/"]{home} page or the MathJax on maths-enabled pages. If you have JS disabled, the BibBase information will be replaced with an iframe. The only thing that definitely won't work is the mathematics.

◊chapter{External Stuff}

This website relies on ◊extlink["https://fontawesome.com/"]{FontAwesome} for the icons in the footer, ◊extlink["https://bibbase.org/"]{BibBase} for the front-page, and ◊extlink["https://www.mathjax.org/"]{MathJax} on maths-enabled pages. The BibBase script additionally adds ◊extlink["https://getbootstrap.com/"]{Bootstrap.} I'd rather it didn't, but I don't think there's much I can do.

The template I based this site on, ◊extlink["https://github.com/ojroques/hugo-researcher"]{hugo-researcher,} used Bootstrap. I figured it would be a ◊em{huge} pain to remove that dependency, but it was actually far easier than expected. This isn't a complicated site, there's no good reason to use Bootstrap.

◊section{BibBase}

This generates a list of my publications on my homepage from a Zotero collection. Pretty useful! I had to heavily modify some of the CSS to get it to gel with the rest of the site. ◊aside{If you want to know what I changed then you can take a look at the source for this site---specifically, take a look at ◊extlink["https://github.com/ConorReynolds/ConorReynolds.github.io/blob/main/assets/sass/style.scss"]{◊code{assets/sass/style.scss}}} If you have Bootstrap included, then the script is ◊em{supposed} to detect that and not include its own version. My experience is that this is unreliable. So, if you're using the script embed---◊extlink["https://bibbase.org/documentation"]{which is recommended}---then make sure to include the option ◊code{css=[link to your bootstrap]} in the URL. This should force BibBase to detect that you already have Bootstrap.

◊section{MathJax}

This is the only thing that definitely won't work without JavaScript. Here's an example (◊extlink["https://en.wikipedia.org/wiki/Cauchy's_integral_formula"]{Cauchy's integral formula}) so you can see what it looks like with and without JS.

◊$${
  f(a) = \frac{1}{2 \pi i} \oint_{\gamma} \frac{f(z)}{z - a}\, \mathrm{d}z
}

◊chapter{Accessibility}

I've tried to design most of the site with accessibility in mind, but I'm far from an expert at this. If you spot any glaring issues then please feel free to ◊extlink["mailto:conor.reynolds@mu.ie"]{email me} and I'd be happy to fix them. There's some more musing on this in the ◊crossref["/posts/hyperlinks"]{hyperlinks} article.