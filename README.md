# no-framework-site

I'm starting over with pure HTML only. If the site is truly worthwhile, it should be able to stand on its own with just HTML. If it’s navigable and functional, then it works. Otherwise, I’ll keep refining.

My goal is to make my site terminal browser friendly, then move into the browsers and slowly add CSS / JS if needed.

## Goals
- Terminal-browser friendly (Lynx, w3m, etc.)
- Minimal, accessible structure
- Add CSS/JS incrementally, only if needed
- No fancy features / frameworks or automation unless it earns it's place.

## 05-16-2025

I begin by moving the blog posts from my [site](https://www.techwebunraveled.xyz/) into this repository. I searched for ways to rendering it with pug and it seems that sadly I need to install the first package to render markdown. I tried rendering them to HTML with pandoc but they were so ugly so instead I will use filter [markdown-it](https://www.npmjs.com/package/jstransformer-markdown-it). Luckily I only need it at compile not run time.
