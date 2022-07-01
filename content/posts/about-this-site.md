---
title: "About This Site"
date: 2022-05-20T15:16:57+01:00
draft: false
mathjax: true
---

# About This Site

This isn't anything like a tutorial or a comprehensive reference---it's just a dump of some of the tools, resources, and thought-processes that went into building this site, in case it would be helpful to anyone.

## Fonts

I went with Charter. I converted the {{< extlink "XCharter" "https://ctan.org/pkg/xcharter" >}} OTF fonts to WOFF2, then base64-encoded them and baked them into my CSS. I went with XCharter rather than {{< extlink "Bitstream Charter" "https://en.wikipedia.org/wiki/Bitstream_Charter" >}} because it has an extended character set and more font variants---including small-caps, which I use for cross-references. Without a properly designed small-caps font, browsers will just scale down regular capitals as a substitute. It looks awful.

## Tool

I went with Hugo. Why? Not sure. Looked good, figured I'd give it a shot. I quite like it now. I host on GitHub because it's free and because it's linked to my professional GitHub account where I host my projects. It's easy to set up a redirect from my {{< extlink "department site" "https://www.cs.nuim.ie/~creynolds" >}} (don't click that). If I change departments I can just keep setting up redirects to here. And if GitHub Pages dies for some reason, I can move it easily.

## Colour Schemes

As of 2022-05-25, this site respects the user's preference for light or dark mode. The support for dark mode is currently a *bit* preliminary, but it should look mostly fine.

## Shortcodes

I came for the static-site generation, but I stayed for the templating and the shortcodes. I have two main shortcodes in effect as of right now. The first is for cross-references:

```html
<a class="crossref"
   {{ printf "href=%q" (ref .Page (.Get 1)) | safeHTMLAttr }}
   >{{ .Get 0 | markdownify }}</a>
```

This allows me to write `{{</* crossref "shortcodes" "#shortcodes" */>}}` and get the cross-reference {{< crossref "shortcodes" "#shortcodes" >}}, which will just link to this section; or `{{</* crossref "home" "/" */>}}`, which generates {{< crossref "home" "/" >}} and links to the home page. The second is similar and works for external links.

```html
<a class="extlink"
   href="{{ .Get 1 }}"
   >{{ .Get 0 | markdownify }}</a>
```

Both are extremely simple, but very useful. If you want to use these, I'd recommend turning off goldmark's linkify option in your config.

```toml
[markup.goldmark.extensions]
   linkify = false
```

If you don't, then raw links will be ‘linkified’ by `markdownify` before being sent to the shortcode, where they're turned into a link *again*. You could also just leave out the `markdownify`, but then you don't get to use markdown in your shortcode.

If you combine this with some {{< extlink "custom VS Code snippets" "https://code.visualstudio.com/docs/editor/userdefinedsnippets" >}}, you have a much more extensible system for hyperlinks that allows you to style them however you like.

## Sidenotes

I considered adding sidenotes to distinguish endnotes from academic references, but I've decided that sidenotes are *way* too much hassle to bother with. Endnotes are enough, mainly because we have backlinks. Try it![^1]

[^1]: Click the chevron at the end to jump back up to where you were.

In his *Elements of Typographic Style*, Robert Bringhurst has this to say about endnotes:

> Endnotes can be just as economical of space, less trouble to design and less expensive to set, and they can comfortably run to any length. They also leave the text page clean except for a peppering of superscripts. They do, however, require the serious reader to use two bookmarks and to read with both hands as well as both eyes, swapping back and forth between the popular and the persnickety parts of the text.

Here, we have all the benefits of endnotes with none of Bringhurst's disadvantages, due to backlinks; though we sadly don't benefit from the ‘life and variety’ of sidenotes, and there is a minor tax of two clicks.

## Smart Quotes

Smart quotes in Hugo seem to cause a few issues for me. For example, if I set the above as `'life and variety'` (note the straight quotes), it renders as 'life and variety'. You can see that the opening quote is wrong.[^2] I'm not sure what is causing this.

It doesn't matter much to me, since I have my own ways of inserting quotes with {{< extlink "AutoHotKey" "https://www.autohotkey.com/" >}} on Windows and {{< extlink "compose keys" "https://en.wikipedia.org/wiki/Compose_key" >}} on Linux. I'm sure there are editor-specific ways to accomplish this too. It's not a huge deal. I still get most of the benefits of automation, but if something comes out wrong I can manually correct it.

[^2]: If the opening quote ever fixes itself, please let me know.

## SASS

SASS is a really nice CSS extension language. Hugo lets me use it, so I'm a happy boy. The only problem is that VS Code *really* doesn't like Hugo's templating code hanging out in my SCSS files. This is annoying mainly because it interferes with autocompletion. ~~My workaround was just to have a `main.scss` with all the templating code bound to variables, then just `@import` the rest of my SCSS files at the end.~~ My new approach is just to avoid Hugo's templating in SASS whenever possible---it doesn't really make that much sense that styling information should live in a `config.toml`.

## TypeScript

Hugo *also* lets me use TypeScript---i.e. JavaScript, but more sane. For {{< extlink "recent Hugo builds" "https://github.com/gohugoio/hugo/releases/tag/v0.74.0" >}}, this is as easy as piping a TS file through `js.Build`. I try to keep the JavaScript to a minimum because I find it really annoying. The only JS on this site that I've written is the code implementing the font-size buttons, and a tweak which replaces the {{< extlink "left hook arrow" "https://www.compart.com/en/unicode/U+21A9" >}} in the endnotes with a FontAwesome chevron. Any external JS comes from BibBase on the {{< crossref "home" "/" >}} page or the MathJax on maths-enabled pages. If you have JavaScript disabled, the BibBase information will be replaced with an iframe. The only thing that definitely won't work is the mathematics.

## External Stuff

This website relies on {{< extlink "FontAwesome" "https://fontawesome.com/" >}} for the icons in the footer, {{< extlink "BibBase" "https://bibbase.org/" >}} for the front-page, and {{< extlink "MathJax" "https://www.mathjax.org/" >}} on maths-enabled pages. The BibBase script additionally adds {{< extlink "Bootstrap" "https://getbootstrap.com/" >}}. I'd rather it didn't, but I don't think there's much I can do.

The template I based this site on, {{< extlink "hugo-researcher" "https://github.com/ojroques/hugo-researcher" >}}, used Bootstrap. I figured it would be a *huge* pain to remove that dependency, but it was actually far easier than expected. This isn't a complicated site, there's no good reason to use Bootstrap.

### BibBase

This generates a list of my publications on my homepage from a Zotero collection. Pretty useful! I had to heavily modify some of the CSS to get it to gel with the rest of the site.[^3] If you have Bootstrap included, then the script is *supposed* to detect that and not include its own version. My experience is that this is unreliable. So, if you're using the script embed---{{< extlink "which is recommended" "https://bibbase.org/documentation" >}}---then make sure to include the option `css=[link to your bootstrap]` in the URL. This should force BibBase to detect that you already have Bootstrap.

### MathJax

This is the only thing that definitely won't work without JavaScript. Here's an example ({{< extlink "Cauchy's integral formula" "https://en.wikipedia.org/wiki/Cauchy%27s_integral_formula" >}}) so you can see what it looks like with and without JS.

$$
f(a) = \frac{1}{2 \pi i} \oint_{\gamma} \frac{f(z)}{z - a}\\, \mathrm{d}z
$$

## Accessibility

I've tried to design most of the site with accessibility in mind, but I'm far from an expert at this. If you spot any glaring issues then please feel free to {{< extlink "email me" "mailto:conor.reynolds@mu.ie" >}} and I'd be happy to fix them. There's some more musing on this in the {{< crossref "hyperlinks" "hyperlinks" >}} article.

[^3]: If you want to know what I changed then you can take a look at the source for this site---specifically, take a look at {{< extlink "`assets/sass/style.scss`" "https://github.com/ConorReynolds/ConorReynolds.github.io/blob/main/assets/sass/style.scss" >}}.