How I manage my dotfiles?
- I have a gitignore with the value "*". This will ignore all files.
- When I add a file, I use `git add -f $FILE_NAME`. Since we've ignored all files, we need to use `-f` to forcefully add a file.
- Once a file has been committed, then I don't need to use `-f` anymore because once a file is committed, git won't ignore it.
