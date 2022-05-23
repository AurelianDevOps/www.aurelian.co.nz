---
title: "How to Deploy a Static Site With Hugo"
date: 2022-05-23T12:49:57+12:00
draft: true
---

I thought I would quickly make a post to document how I deploy this site using [hugo](https://gohugo.io).
Although it is a straight forward process it is good idea to document it.

I'll host the site on cloudflare [pages](https://pages.cloudflare.com/)

If you want to follow along you'll need to install hugo on your local machine and sign up to [cloudflare](https://cloudflare.com/) (You can use any provider you want)

## Initial setup

We'll start with settings up the hugo site.
```sh
% hugo new site www.aurelian.co.nz
```
This creates a new directory called `www.aurelian.co.nz` that contains the skeleton files for the site.

```sh
% cd www.aurelian.co.nz
% ls
archetypes
config.yaml
content
layouts
resources
static
themes
```

Now let's add the theme.
```sh
% git submodule add https://github.com/StefMa/hugo-fresh themes/hugo-fresh
```

Copy over the exampleSite's `themes/hugo-fresh/exampleSite/config.toml`. I commented out the sidebar and some of the other elements and renamed the `baseURL` and `title` variables.
```yaml
baseURL: https://www.aurelian.co.nz/
languageCode: en-us
title: aurelian.co.nz
theme: hugo-fresh
...
```

Add our first post.
```sh
% hugo new blog/how-to-deploy-a-static-site-with-hugo.md
```

Let's test it out
```sh
% hugo server -D
```

The `-D` flag tells hugo to include content marked as draft.

## Fixing the blog index

The blog as one issue. The [blog]({{<ref "/blog">}}) link does not generate the index of the posts that I have written.
I suspect it's an issue with the theme.

Looking at the documentation for hugo the theme should use [list templates](https://gohugo.io/templates/lists/) to generate the index.

Creating the `_index.md` does not work and the `hugo serve` does not give any errors when I try to load the blog index.

Looking at `layouts/_default/` in the theme folder shows no list.html file. Lets create one to test it.
```html
{{ define "main" }}
<main>
    <article>
        <header>
            <h1>{{.Title}}</h1>
        </header>
        <!-- "{{.Content}}" pulls from the markdown content of the corresponding _index.md -->
        {{.Content}}
    </article>
    <ul>
    <!-- Ranges through content/posts/*.md -->
    {{ range .Pages }}
        <li>
            <a href="{{.Permalink}}">{{.Date.Format "2006-01-02"}} | {{.Title}}</a>
        </li>
    {{ end }}
    </ul>
</main>
{{ end }}
```

After reloading the site I get my list but it does not render correctly. Indeed this is a [issue](https://github.com/StefMa/hugo-fresh/issues/135) with the theme

![wrong-layout](/images/blog/wrong-layout.png)

To get it to load the correctly we need to include the the other partials and use the correct css class.
```html
{{ define "main" }}
{{ partial "navbar.html" . }}
{{ partial "navbar-clone.html" . }}

<section class="section is-medium">
    <div class="container">
      <div class="columns">
        <div class="column is-centered-tablet-portrait">
          <h1 class="title section-title">{{ .Title }}</h1>
          <h5 class="subtitle is-5 is-muted">{{ .Params.Subtitle }}</h5>
          <div class="divider"></div>
        </div>
      </div>
  
      <div class="content">
        {{.Content}}
        <ul>
            <!-- Ranges through content/blog/*.md -->
            {{ range .Pages }}
                <li>
                    <a href="{{.Permalink}}">{{.Date.Format "2006-01-02"}} | {{.Title}}</a>
                </li>
            {{ end }}
        </ul>
      </div>
    </div>
  </section>
{{ end }}
```
One final thing before I finish this. The Title should say **Blog** and not **Blog**.
Now we can use the `_index.md` file to overwrite the default value.
```yaml
title: "Blog"
date: 2022-05-23T12:49:57+12:00
draft: true
```

This is the result. It looks a bit bare but I'll sort that out later. 
![correct-layout](/images/blog/correct-layout.png)

## Deploying the site
Hugo can deploy 
Deploying is dead simple. We don't to run unit test or anything so lets just use scp to copy it to the server.


## TODO
