---
title: ◊(select-from-metas 'title metas)
date: ◊(select-from-metas 'date metas)
draft: ◊(if (select-from-metas 'is-draft metas) "true" "false")
mathjax: ◊(if (select-from-metas 'mathjax metas) "true" "false")
pdf: ◊(string-append (select-from-metas 'filename metas) ".pdf")
---

<h1>◊(select-from-metas 'title metas)</h1>

◊(->html doc)