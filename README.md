# bootstrap.sh

This is a simple, one-script bootstrapper that I use to create the
following files on many different Unix-like systems:

- `.bashrc` (most shell config happens here)
- `.bash_profile` (pulls in .bashrc)
- `.bash_logout` (clears screen)
- `.gitconfig`
- `.inputrc` (to make bash tab-completion case insensitive)
- `.tmux.conf`
- `.vimrc`
- `.zshrc` and `.zlogout` (only if zsh is installed)

All of the files, except `.gitconfig` and `.inputrc`, can be extended by
creating a new file of the same name with `.local` appended. The
`bootstrap.sh` script can be extended the same way. The intent here is
not to make something super-customizable, but to allow for subtle
differences between hosts that would otherwise be overwritten if the
files above were edited.

`bootstrap.sh` is in the public domain.
