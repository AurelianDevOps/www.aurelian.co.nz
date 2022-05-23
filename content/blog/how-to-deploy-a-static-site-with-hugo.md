---
title: "How to Deploy a Static Site With Hugo"
date: 2022-05-23T12:49:57+12:00
draft: false
---

I thought I would quickly make a post to document how I deploy this site using [hugo](https://gohugo.io).
Although it is a straight forward process it is good idea to document it.

I'll host the site on Cloudflare [Pages](https://pages.cloudflare.com/)

If you want to follow along you'll need to install hugo on your local machine and sign up to [Cloudflare](https://cloudflare.com/) (You can use any provider you want)

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
Now we can use the `_index.md` file to overwrite the default value and change the draft variable to `false`
```yaml
title: "Blog"
date: 2022-05-23T12:49:57+12:00
draft: false
```

## Deploying the site
Hugo can also deploy directly to a Google Cloud Storage (GCS) bucket, an AWS S3 bucket, and/or an Azure Storage container. But I'm going to use Cloudflare Pages.

We'll use [github](https://github.com) to host our code for Cloudflare to use. 

I'm using my public ssh key to authenticate. See [Generating a new ssh key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) and [Adding a new ssh key to your github account](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)

```sh
% git init .
% git commit -m "Initial commit"
% git branch -M main
% git remote add origin git@github.com:unusualTrouble/www.aurelian.co.nz.git
% git push -u origin main
```

The last thing we need to do is set up Cloudflare to [deploy](https://developers.cloudflare.com/pages/framework-guides/deploy-a-hugo-site/)  our site and connect our custom domain.

The nice thing about Cloudflare Pages is that we can just push out changes with `git` and Cloudflare will rebuild the static files automatically.

## Whats next?

I going to build a api so that I can add some basic features like a contact form, organize the blog urls by date, and fix some of the `hugo-fresh` theme issues.
