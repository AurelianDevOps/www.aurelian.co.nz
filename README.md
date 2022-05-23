# www.aurelian.co.nz

This is the git repo for www.aurelian.co.nz. It uses hugo to generate static files and a Cloudflare Pages to host the site.

## Setup

Update the hugo-fresh theme
```sh
% git submodule update --init
```

To add content use hugo
```sh
% hugo new blog/new-article.md
```

## Deploy

To deploy just commit the changes and push to the github repo. Cloudflare will automatically update the page from the repo.

```sh
% git add .
% git commit -m "Added blog/new-article.md"
% git push
```
