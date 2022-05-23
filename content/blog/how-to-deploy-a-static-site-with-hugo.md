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

Copy over the example config file `themes/hugo-fresh/exampleSite/config.toml`. I commented out the sidebar and some of the other elements and renamed the `baseURL` and `title` variables.
```yaml
baseURL: https://www.aurelian.co.nz/
languageCode: en-us
title: aurelian.co.nz
theme: hugo-fresh

#googleAnalytics:

# Disables warnings
disableKinds:
  - taxonomy
  - taxonomyTerm
markup:
  goldmark:
    renderer:
      unsafe: true # Allows you to write raw html in your md files

params:
  # Open graph allows easy social sharing. If you don't want it you can set it to false or just delete the variable
  openGraph: false
  # Used as meta data; describe your site to make Google Bots happy
  description: Consulting and end user support
  navbarlogo:
  # Logo (from static/images/logos/___)
    image: logos/aurelian.svg
    link: /
  font:
    name: "Open Sans"
    sizes: [400,600]
  hero:
    # Main hero title
    title: Consulting and Support
    # Hero subtitle (optional)
    subtitle: Restore your computing world
    # Button text
    buttontext: Contact us
    # Where the main hero button links to
    buttonlink: "/contact"
    # Hero image (from static/images/___)
    image: illustrations/worker.svg
    # Footer logos (from static/images/logos/clients/___.svg)
    # clientlogos:
    # - systek
    # - tribe
    # - kromo
    # - infinite
    # - gutwork

  # Customizable navbar. For a dropdown, add a "sublinks" list.
  navbar:
  - title: Blog
    url: /blog
  - title: Services
    url: /services
  - title: Pricing
    url: /pricing
  - title: Contact Us
    url: /contact

  section1:
    title: Services
    subtitle: that we offer
    tiles:
    - title: Websites & Emails
      icon: mouse-globe
      text: Custom sites and email for your domain
      url: /domain
      buttonText: Get Started
    - title: Integration & Automation
      icon: plug-cloud
      text: Service integrations with 3rd party apps and automation
      url: /integrations
      buttonText: Get started
    - title: Support
      icon: laptop-cloud
      text: End user support for Windows, macOS and Linux
      url: /support
      buttonText: Get started

  section2:
    title: Secure, powerful and efficient
    subtitle: let us handle it
    features:
    - title: Secure
      text: We like keep things simple for you. Structure and protect your data.
      # Icon (from /images/illustrations/icons/___.svg)
      icon: shield-checkmark-outline
    - title: Powerfull
      text: Use the right tool for the job. We design solutions around AWS and Google Cloud Platform.
      icon: logo-amazon
    - title: Efficient
      text: Get the most out of your money
      icon: golf-outline

  section5: true
  footer:
    # Logo (from /images/logos/___)
    logo: aurelian-alt.svg
    # Social Media Title
    socialmediatitle: Follow Us
    # Social media links (GitHub, Twitter, etc.). All are optional.
    socialmedia:
    - link: https://github.com/AurelianDevOps
      # Icons are from Font Awesome
      icon: github
    - link: https://twitter.com/AurelianDevOps
      icon: twitter
    bulmalogo: true
    quicklinks:
      column1:
        title: "Services"
        links:
        - text: Why choose us?
          link: /choose-us
        - text: About
          link: /about
      column2:
        title: "Blog"
        links:
        - text: Latest blog entry
          link: /blog/how-to-deploy-a-static-site-with-hugo/
```

Add the first post.
```sh
% hugo new blog/how-to-deploy-a-static-site-with-hugo.md
```

Let's test it out. The `-D` flag tells hugo to include content marked as draft.
```sh
% hugo server -D
```

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
One final thing before I finish this. The title should say **Blog** and not **Blogs**.
Now we can use the `_index.md` file to overwrite the default value and change the draft variable to `false`
```yaml
title: "Blog"
date: 2022-05-23T12:49:57+12:00
draft: false
```

## Deploying the site
Hugo can also deploy directly to a Google Cloud Storage (GCS) bucket, an AWS S3 bucket, and/or an Azure Storage container. But I'm going to use Cloudflare Pages.

We'll use [github](https://github.com) so that Cloudflare can pull changes and build the site with Hugo. 

I'm using my public ssh key to authenticate. See [Generating a new ssh key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) and [Adding a new ssh key to your github account](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)

```sh
% git init .
% git commit -m "Initial commit"
% git branch -M main
% git remote add origin git@github.com:AurelianDevOps/www.aurelian.co.nz.git
% git push -u origin main
```

The last thing we need to do is set up Cloudflare to [deploy](https://developers.cloudflare.com/pages/framework-guides/deploy-a-hugo-site/)  our site and connect our custom domain.

The nice thing about Cloudflare Pages is that we can just push changes with git and Cloudflare will rebuild the static files automatically.

## Whats next?

I going to build a api so that I can add some basic features like a contact form, organize the blog urls by date, and fix some of the `hugo-fresh` theme issues.
