# Dotfiles

## Notes:
- For nvim, I'm using nvchad. So it is a submodule
- If I get the following issue when doing git status:
    
    ```bash
    Changes not staged for commit:
      (use "git add <file>..." to update what will be committed)
      (use "git restore <file>..." to discard changes in working directory)
      (commit or discard the untracked or modified content in submodules)
            modified:   alacritty/.config/alacritty/catppuccin (modified content)
            modified:   nvim/.config/nvim (modified content)
    ```

    Then the solution is to go into those submodule and commiting or restoring changes.
- For logseq, don't do `stow logseq`. This is because there is a .graph folder which will be overwritten.

## Usage:

```bash
# ~/dotfiles
stow <package-name>

# eg:
stow nvim
stow alacritty
```

