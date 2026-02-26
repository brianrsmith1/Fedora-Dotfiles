## After Installation

After the installation is complete, follow these steps to ensure everything is working properly:

1. **Run p10k configure**: Execute `p10k configure` to personalize your Powerlevel10k prompt and themes.

2. **Manual .zshrc Configuration**: After the installation is complete you may be required to manually paste the .zshrc code into the config structure due to p10k. Do so by using the directory `cd ~/.zshrc` and pasting the code accordingly.

3. **fastfetch Troubleshooting**: If fastfetch does not pop up automatically on a new terminal startup, try these fixes in order:
   - `source ~/.zshrc`
   - `chsh -s $(which zsh)`
   - `chsh -s /usr/bin/zsh`
   - `echo $SHELL` - This should output `/usr/bin/zsh` or `/bin/zsh`