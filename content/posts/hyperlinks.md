---
title: "What’s with the Hyperlinks?"
date: 2022-05-18T16:57:41+01:00
draft: false
---

# What's with the Hyperlinks?

Readability above all---following Matthew Butterick's example in his {{< extlink "*Practical Typography*" "https://practicaltypography.com/how-to-use.html" >}} web book. One should be able to read the text from start to finish with minimal distractions. Do you know what I find distracting? <span style="color: blue; text-decoration: underline">Horrible blue underlined text</span>. This is design 101: if you want people to notice something, just make it look disgusting.

Styling links in this way is common, but is mercifully becoming less common. That might be all right if your webpage is a glorified link dump (nothing wrong with that). But this webpage is not a link dump---at least, not *just* a link dump. A different approach is necessary:

- If I want to link you somewhere outside this domain, then I will indicate it with an {{< extlink "external link symbol" "#" >}}. This symbol is somehow simultaneously ubiquitous and underused. No doubt a part of the problem is that the symbol has still {{< extlink "not been included in Unicode" "https://www.unicode.org/L2/L2018/18303-external-link.pdf" >}}. It's unobtrusive and it's clear---even if you're colourblind.
- If I want to cross-reference another page inside this domain, I will write it in {{< crossref "small caps" "#" >}} style, following Butterick and Garner. This is similarly unobtrusive and clear.

Text too small? Use the buttons on the top right or the built-in browser zoom. The buttons also work on mobile, where you normally don't get built-in browser zooming.

And finally, for good measure, if you roll over hyperlinks with your mouse, an underline will appear to confirm what you suspected: you're looking at a hyperlink.
