{
  pkgs,
  inputs,
  ...
}: let
  nvim-spell-de-utf8-dictionary = builtins.fetchurl {
    url = "https://ftp.nluug.nl/pub/vim/runtime/spell/de.utf-8.spl";
    sha256 = "1ld3hgv1kpdrl4fjc1wwxgk4v74k8lmbkpi1x7dnr19rldz11ivk";
  };

  nvim-spell-de-utf8-suggestions = builtins.fetchurl {
    url = "https://ftp.nluug.nl/pub/vim/runtime/spell/de.utf-8.sug";
    sha256 = "0j592ibsias7prm1r3dsz7la04ss5bmsba6l1kv9xn3353wyrl0k";
  };
in {
  home.file = {
    ".config/nvim/init.lua".source = ./init.lua;
    ".config/nvim/lua".source = ./lua;
    ".config/nvim/lsp".source = ./lsp;
    ".config/nvim/after".source = ./after;
    ".config/nvim/spell/de.utf-8.spl".source = nvim-spell-de-utf8-dictionary;
    ".config/nvim/spell/de.utf-8.sug".source = nvim-spell-de-utf8-suggestions;
  };

  programs.neovim = {
    enable = true;
    package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
    plugins = with pkgs.vimPlugins; [
      aerial-nvim
      blink-cmp
      conform-nvim
      diffview-nvim
      dressing-nvim
      fzf-lua
      gitsigns-nvim
      indent-blankline-nvim
      lualine-nvim
      luasnip
      friendly-snippets
      catppuccin-nvim
      nvim-autopairs
      nvim-dap
      nvim-dap-ui
      nvim-dap-virtual-text
      nvim-nio
      nvim-lint
      nvim-lspconfig
      nvim-surround
      (nvim-treesitter.withPlugins
        (p:
          with p; [
            lua
            vim
            vimdoc
            diff
            nix
            cpp
            c
            c_sharp
            typst
            python
            markdown
            markdown_inline
            just
            gitignore
            gitcommit
            gitattributes
            git_rebase
            git_config
            css
            scss
            html
            javascript
            typescript
            tsx
            json
            xml
            bash
            rust
          ]))
      nvim-treesitter-context
      nvim-ts-autotag
      nvim-web-devicons
      overseer-nvim
      render-markdown-nvim
      typst-preview-nvim
      oil-nvim
      img-clip-nvim
      plenary-nvim
      nui-nvim
      lazydev-nvim
      rustaceanvim
    ];
  };

  home.packages = with pkgs; [
    rust-analyzer
    rustfmt
    fzf
    fd
    ripgrep
    tree-sitter
    alejandra
    nil
    stylua
    lua-language-server
    lua
    typst
    tinymist
    websocat
    typstyle
    clang-tools
    clang
    lldb
    pyright
    black
    python3
    prettierd
    bash-language-server
    beautysh
    vscode-langservers-extracted
    lemminx
    xmlformat
    csharp-ls
    csharpier
    typescript-language-server
  ];
}
