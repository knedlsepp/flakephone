{ config, pkgs, ... }:
{
  imports = [
    (import <mobile-nixos/lib/configuration.nix> { device = "pine64-pinephone-braveheart"; })
  ];
  users.users."sepp" = {
    isNormalUser = true;
    initialPassword = "";
    extraGroups = [ "wheel" "networkmanager" "input" ];
  };
  nixpkgs.overlays = [
    (self: super: {
      myVim = super.vim_configurable.customize {
        name = "vi"; # The name is used as a binary!
        vimrcConfig = {
          customRC = ''
            set encoding=utf-8
            au BufNewFile,BufFilePre,BufRead *.md set filetype=markdown
            au BufNewFile,BufRead,BufReadPost *.f90 set syntax=fortran
            au VimEnter * if &diff | execute 'windo set wrap' | endif

            filetype plugin indent on

            set backspace=2 " make backspace work like most other program
            set bg=dark
            set tabstop=4
            set shiftwidth=4
            set expandtab
            set wildmenu

            set autoindent
            set smartindent

            let g:ycm_python_binary_path = 'python'
            let g:ycm_autoclose_preview_window_after_insertion = 1

            let g:ycm_key_list_select_completion = ['<TAB>']
            let g:ycm_key_list_previous_completion = ['<S-TAB>']
            let g:ycm_key_list_stop_completion = ['<C-y>', '<UP>', '<DOWN>']

            let g:ycm_semantic_triggers = {
            \   'python': [ 're!\w{2}' ]
            \ }

            let g:gitgutter_enabled = 1

            colorscheme gruvbox
            " Show whitespace
            highlight ExtraWhitespace ctermbg=red guibg=red
            match ExtraWhitespace /\s\+$/
            autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
            autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
            autocmd InsertLeave * match ExtraWhitespace /\s\+$/
            autocmd BufWinLeave * call clearmatches()

            " Keep visual mode active
            vnoremap < <gv
            vnoremap > >gv

            " Remember last position
            if has("autocmd")
              au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
            endif

            " sync default register to clipboard
            if has('unnamedplus')
              set clipboard=unnamedplus
            else
              set clipboard=unnamed
            endif

            if executable('pyls')
                au User lsp_setup call lsp#register_server({
                    \ 'name': 'pyls',
                    \ 'cmd': {server_info->['pyls']},
                    \ 'whitelist': ['python'],
                    \ })
            endif

            set foldmethod=expr
              \ foldexpr=lsp#ui#vim#folding#foldexpr()
              \ foldtext=lsp#ui#vim#folding#foldtext()

            let g:lsp_diagnostics_echo_cursor = 1 " Show the error in the status bar

            if executable('clangd')
                augroup lsp_clangd
                    autocmd!
                    autocmd User lsp_setup call lsp#register_server({
                                \ 'name': 'clangd',
                                \ 'cmd': {server_info->['clangd', '--compile-commands-dir=build', '--log=verbose']},
                                \ 'whitelist': ['c', 'cpp', 'objc', 'objcpp'],
                                \ })
                    autocmd FileType c setlocal omnifunc=lsp#complete
                    autocmd FileType cpp setlocal omnifunc=lsp#complete
                    autocmd FileType objc setlocal omnifunc=lsp#complete
                    autocmd FileType objcpp setlocal omnifunc=lsp#complete
                augroup end
            endif
          '';
          packages.myVimPackage = with super.vimPlugins; {
            start = let
              async-vim = super.vimUtils.buildVimPluginFrom2Nix {
                pname = "async-vim";
                version = "2019-07-18";
                src = super.fetchFromGitHub {
                  owner = "prabirshrestha";
                  repo = "async.vim";
                  rev = "627a8c4092df24260d3dc2104bc1d944c78f91ca";
                  sha256 = "1hqrfk3wi82gq4qw71xcy1zyplwb8w7bnm6kybpn27hgpipygrvv";
                };
              };
              vim-lsp = super.vimUtils.buildVimPluginFrom2Nix {
                pname = "vim-lsp";
                version = "2019-11-02";
                src = super.fetchFromGitHub {
                  owner = "prabirshrestha";
                  repo = "vim-lsp";
                  rev = "efff12608f334edcc6878ce9a790b136c7fa92c6";
                  sha256 = "1lb6fylsr7krk471lh4m23j18hp6xa0izxzg14xw1xzaacf4p603";
                };
              }; in
            [
              # youcompleteme
              async-vim
              ctrlp
              vim-airline
              vim-airline-themes
              fugitive
              nerdtree
              gitgutter
              molokai
              vim-colorstepper # Use F6/F7 to select your favorite colorscheme
              awesome-vim-colorschemes
              vim-yapf
              vim-lsp
            ];
            opt = [  ];
          };
        };
      };
    }
  )];
  environment.systemPackages = with pkgs; [
    myVim
    htop
    git
    sgtpuzzles
  ];
  services.ntp.enable = true;
  services.xserver = {
    enable = true;
    videoDrivers = [ "modesetting" ];
    desktopManager.xfce.enable = true;
    desktopManager.xfce.enableXfwm = false;
    displayManager.lightdm = {
      enable = true;
      autoLogin = {
        enable = true;
        user = "sepp";
      };
    };
  };



  networking.hostName = "flakephone";
  networking.wireless = {
    enable = true;
    networks = {
      knoedelnetz = {
        # Generated using `wpa_passphrase knoedelnetz`. A slight security issue, but I don't have wired networking yet...
        pskRaw = "1aeec582e79412fc44efa16ebfd399e22be96bbcf7a7eab9e00b94972c487c18";
      };
      bananaNet = {
        # Generated using `wpa_passphrase bananaNet`. A slight security issue, but I don't have wired networking yet...
        pskRaw = "8932ea09b8f3b13d65a770a6f49c1ed84383bd5d7bc0c9b2cd3d5d5ea883863c";
      };
    };
  };
  systemd.services.wpa_supplicant.serviceConfig = {
    # First login attempt doesn't work for whatever reason
    Restart = "always";
    RestartSec = 8;
    StartLimitIntervalSec = 0; # Don't stop trying after a couple of restarts
  };
  networking.useDHCP = false;
  networking.interfaces.wlan0.useDHCP = true;
  networking.enableIPv6 = false;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";

  time.timeZone = "Europe/Vienna";

  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/Z8395cyaul/PIgLDCSgHWrg3h1xiALouLu8gAOYb9CtN05VTSOINuI95rcdPFIQC+2vconZ/sW2j+mUmsrIP6b2eFm1XRg6Nicu9tPK+fqksSqL2TjPijwmeptljDwUN/F5YfCRCFCixAtRq5wTARbEzC8hDvnfaoimiRD4JyMCnRJvEAZxh5AsY5vD42sQVmS1xh7lx80gd7ARdeKh5xBV/ccnFzON0U9HTM4DNSa2URV+QCJec1ORYHAfo+DdmR+q7J96lVp5UbLki1Ym4KEW6eCUeOZ6bAq8aaFlWmlwFIMNOzfEc/kZRDurRj8IJx5BWzI1RPRg9Z+ChqbZh josef.kemetmueller@PC-18801"
    ];
  };
}

