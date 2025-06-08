---
title: Hugo
Date: 2025-06-08
---
## Basic Setup
Hugo is a tool for converting markdown to HTML. It is actually quite straight forward, too! To create a new site you simply run

```
hugo new site <name>
```

and then you have a simple site! You can create a page using

```
hugo new content <path/to/content.md>
```

For example, you could create the Markdown file "Hugo" in directory `content` by running

```
hugo new content Hugo.md
```

Easy-peasy! WHen creating files within Hugo itself files are automatically given YAML front-matter. This page uses 

```
---
title: Hugo
Date: 2025-06-08
---
```

Front-matter is always placed at the very beginning of a file. It is used as file metadata, so the above front-matter tells Hugo that the title of this page is "Hugo", created on date "2025-06-08" (yyy-mm-dd). Your page might use front-matter like 

```
+++
title = Hugo
date = 2025-06-08
+++
```

but is acts the same, to my knowledge. Just note that they don't mix.

## Themes
There is a large list of themes on [the Hugo site](https://themes.gohugo.io/hugo-paper/). They all come with different instructions.

I am using [Paper](https://github.com/nanxiaobei/hugo-paper), which I personally think looks pretty slick. Its instructions are in the [README](https://github.com/nanxiaobei/hugo-paper#install), while some have it in the GitHub Wiki page. 

The only issue that I have had with Paper is that it doesn't nativly support an [\_index.md](index.html). To display it I had to [add a layout](https://github.com/EasyOnHard/easyonhard.github.io/blob/main/layouts/index.html) for `index.html`. I don't know why I had to add that, but it works!