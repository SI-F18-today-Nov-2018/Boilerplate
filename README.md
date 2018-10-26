# Boilerplate
Boiler-plate repository with Basic CMakeLists.txt, source layout, travis-ci setup

🚧 __This repository is a work in progress (WIP)__ 🚧

## Recommended Workflow

We suggest that you __DO NOT__ fork this repository. Instead:

1. Create a new empty repository on GitHub, e.g., https://github.com/zbeekman/foo.git
2. Clone this repository locally with `git clone https://github.com/SI-F18-today-Nov-2018/Boilerplate.git`
3. Enter the repository : `cd Boilerplate`
4. Switch the `origin` remote to point to the git repository you just created, i.e., 
     `git remote set-url origin https://github.com/zbeekman/foo.git`
5. Fetch and merge your empty repository from Github, to ensure everything is synced: 
     `git pull origin master`
6. Check that nothing unexpected happened: `git status`
7. If everything looks good (it should show a bunch of untracked files) add all the files: 
     `git add -A`
8. (Optional) Edit the README.md and any other files, then `git add <file>` to stage them.
9. Commit the staged changes: `git commit -m "Importing boilerplate code"`
10. Then push your shiny new project to synchronize with GitHub: 
      `git push --set-upstream origin ; git push --all origin`

## Goals

The goals of this project are:

1. Make it easy to bootstrap an agile, modern open source Fortran project
2. Provide off the shelf [Travis-CI] integration
3. Provide off the shelf [Codecov.io] integration for code coverage metrics
4. Make it easy to host source code documentation built with [FORD] on your project's
   github-pages site via the `gh-pages` branch.

## Further Setup

Not all of the sections below may be of interest to you. Feel free to skip the ones that
are not relevant.

🚧 __This section is a work in progress (WIP)__ 🚧
