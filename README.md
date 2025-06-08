# Dotfiles

Here are my dotfiles, I will be adding to it and explaining along the way.

A journey begins.

## Setup/

### Dependencies
```
brew install git tmux tmuxp hammerspoon neovim
brew install --cask karabiner-elements
```

### Symlinks
```
ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
ln -s ~/dotfiles/.hammerspoon ~/.hammerspoon
ln -s ~/dotfiles/.tmux ~/.tmux

ln -s ~/dotfiles/.config/nvim ~/.config/nvim
ln -s ~/dotfiles/.config/karabiner ~/.config/karabiner
```

### Additional steps

- Karabiner :
    - Open Karabiner-Elements from your Applications folder.
    - Grant necessary permissions in System Preferences > Security & Privacy (Input Monitoring and Accessibility). 


## Todo List/

- Add scripts calling general commands for setup

## Neovim Configuration

My Neovim setup is designed for a modern development experience with a focus on productivity and ergonomics. Here's a breakdown of the key plugins and their purposes:

### Core Plugins

- **LazyVim** - Plugin manager and configuration framework
- **Catppuccin** - A soothing pastel theme for Neovim
- **Telescope** - Fuzzy finder for files, buffers, and more
  - With `telescope-fzf-native` for better performance
- **Treesitter** - Advanced syntax highlighting and code navigation
  - With `nvim-treesitter-context` for showing code context
  - With `playground` for debugging syntax highlighting
  - With `nvim-treesitter-textobjects` for smart text objects

### LSP and Completion

- **LSP Zero** - Easy LSP configuration
- **Mason** - Package manager for LSP servers
- **blink-cmp** - Completion engine with blink effect
- **nvim-lspconfig** - Native LSP configuration

### Navigation and Editing

- **Harpoon2** - Quick file navigation between frequently used files
- **Leap** - Quick motion plugin for faster navigation
- **nvim-surround** - Easy text surrounding operations
- **nvim-autopairs** - Automatic bracket pairing
- **nvim-ufo** - Modern folding experience
- **vim-tmux-navigator** - Seamless navigation between Vim and tmux splits

### Development Tools

- **vim-test** - Testing support
- **avante.nvim** - AI-powered coding assistant

### Quality of Life

- **bigfile** - Better handling of large files
- **yeet** - Quick file operations
- **persistence** - Session management
- **vim-be-good** - Neovim training game
- **cellular-automaton** - Fun animations

### Special Features

- **Azerty Layout Support** - Custom configuration for AZERTY keyboard layout
- **Custom Keymaps** - Personalized key mappings for improved workflow

This configuration is continuously evolving as I discover new tools and better ways to work with Neovim. Feel free to explore and adapt any parts that you find useful!

## Hammerspoon Configuration/

My Hammerspoon setup includes several productivity-enhancing features:

### Key Logger
- Displays active key presses in real-time
- Toggle with `ctrl + cmd + k`
- Useful for presentations and debugging keyboard inputs
- Cycles through predefined positions before disabling

### Application Quick Launch
- Fast application switching using keyboard shortcuts
- Mapped to `ctrl + cmd + [number]`
- Common applications mapped to numbers (7,8,9, etc.)
- Provides instant access to frequently used applications
- Application window maximization (fake fullscreen) using ctrl + cmd + F

### Multi-Display Management
- Intelligent window management for multiple displays
- Automatically saves window positions when disconnecting external monitors
- Restores window layouts when reconnecting displays
- Screen swapping functionality with `ctrl + cmd + m`
- Maintains application workspace consistency across different display configurations

This setup ensures a smooth workflow when transitioning between single and multi-monitor setups while providing quick access to applications and keyboard input visualization when needed.


