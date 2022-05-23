# Site

This is the git repo for www.aurelian.co.nz. It uses hugo to generate statis files and a script to deploy
to a preconfigured server.

## Setup

pull the hugo-fresh theme
```
% git submodule update --init
```

## Deploy

To deploy you'll need to run the `deploy.sh` script.

```
% ./deploy.sh
```

This will generate the static files to `static` and copy them to the server.
