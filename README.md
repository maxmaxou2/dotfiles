# Dotfiles

Here are my dotfiles, I will be adding to it and explaining along the way.

A journey begins.

## Setup/

### HomeBrew related
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
ln -s ~/dotfiles/.Brewfile ~/.Brewfile
brew bundle --global
```

### Symlinks
```
stow conda hammerspoon karabiner nvim pdb rich ssh tmux zsh clang-format
```

### Additional steps

- Karabiner :
    - Open Karabiner-Elements from your Applications folder.
    - Grant necessary permissions in System Preferences > Security & Privacy (Input Monitoring and Accessibility). 

- Postgres related :
```
createuser --superuser $USER -U postgres
createdb $USER -U $USER
```


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

- **Mason** - Package manager for LSP servers
- **mason-lspconfig** - Auto enabling of mason lsp servers
- **blink-cmp** - Completion engine with blink effect
- **nvim-lspconfig** - Native LSP configuration
- **conform** - Formatter plugin, lightweight yet powerful

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

## Keymap Cheatsheet

### Neovim Keymaps

#### General
- `<Space>` - Leader key
- `<leader>e` - Open file explorer (Ex)
- `<C-s>` - Save file (works in normal, insert, and visual modes)

#### Window Management
- `<C-Up/Down/Left/Right>` - Resize windows
- `<C-w>q` or `<C-w><C-q>` - Close split and navigate left (Tmux aware)
- `<leader>gd` - Open definition in vertical split
- `<leader>gg` - Open references in vertical split
- `<leader>gr` - Open LSP references in vertical split

#### Clipboard Operations
- `<leader>y` - Copy to system clipboard
- `<leader>Y` - Copy line to system clipboard (from cursor to end)
- `<leader>yy` - Copy whole line to system clipboard
- `<leader>p` - Paste from system clipboard
- `<leader>P` - Paste before from system clipboard
- `<leader>yp` - Copy full file path to clipboard
- `<leader>yn` - Copy filename to clipboard
- `<leader>yd` - Copy parent directory path to clipboard

#### Navigation
- `<C-d>` - Scroll down (centered)
- `<C-u>` - Scroll up (centered)
- `<C-j>` - Go down a pane (Tmux aware)
- `<C-k>` - Go up a pane (Tmux aware)
- `<C-h>` - Go left a pane (Tmux aware)
- `<C-l>` - Go right a pane (Tmux aware)

#### Indentation
- `<S-Tab>` - Unindent (normal and insert mode)
- `<Tab>` - Indent (visual mode)
- `<S-Tab>` - Unindent (visual mode)

#### Development
- `<leader>bp` - Insert Python breakpoint
- `<leader>bd` - Insert Dagster debugger breakpoint
- `<leader>T` - Launch nearest test, test file or test class
- `<leader>S` - Launch nearest test, test file or test class while updating snapshots

#### Telescope (Fuzzy Finder)
- `<C-p>` - Find files (git files if in repo, all files otherwise)
- `<leader>ps` - Grep with input prompt
- `<leader>pf` - Live grep
- `<leader>w` - Fuzzy find in current buffer
- `gr` - Find LSP references
- `gd` - Go to LSP definition
- `<leader>gr` - Go to LSP references in a new v-split
- `<leader>gd` - Go to LSP definition in a new v-split

#### Diffview
- `<leader>dv` - Opens up telescope git branches listing and show diffview for the selected, quit diffview if already opened
- `<leader>df` - Toggles file tree display

### Hammerspoon Keymaps

#### Window Management
- `ctrl + cmd + F` - Make focused window fullscreen (custom fullscreen)

#### Application Management
- `ctrl + cmd + k` - Toggle key logger display
- `ctrl + cmd + m` - Screen swapping functionality

Note: Additional Hammerspoon keybindings for application quick launch (ctrl + cmd + [number]) are configured but not explicitly listed in the configuration files.

This cheatsheet will be continuously updated as new keymaps are added to my configuration.
