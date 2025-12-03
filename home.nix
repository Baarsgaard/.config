{ config, pkgs, ... }:

{
  home.stateVersion = "25.11"; # Do not touch

  home.username = "ste";
  home.homeDirectory = "/home/${config.home.username}";

  home.packages = [
    pkgs.containerd
    pkgs.dive
    pkgs.docker
    pkgs.docker-buildx
    pkgs.docker-compose
    pkgs.gh
    pkgs.jq
    pkgs.kind
    pkgs.ko
    pkgs.kubectl
    pkgs.kubernetes-helm
    pkgs.kustomize
    pkgs.unzip
    pkgs.wslu
    pkgs.yq-go
    pkgs.zsh-fzf-tab
    # pkgs.ansible
    # pkgs.lychee
    # pkgs.open-policy-agent
    # pkgs.terraform
    # pkgs.typos
    # pkgs.vault

    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  home.sessionVariables = {
    BROWSER = "wslview";
    COLORTERM = "truecolor";
    EDITOR = "hx";
    MANPAGER = "bat -l man -p";
    HIST_STAMPS = "yyyy-mm-dd";
    # SSH_AUTH_SOCK = "${config.home.homeDirectory}/.ssh/agent.sock"; # Sharing socket across shells
  };
  home.sessionPath = ["${config.home.homeDirectory}/.local/bin"];

  services = {
    home-manager.autoUpgrade = {
      enable = true;
      frequency = "weekly";
    };
    ssh-agent.enable = true;
  };

  # Let Home Manager install and manage itself.
  programs = {
    home-manager.enable = true;
    bun.enable = true;
    fd.enable = true;
    ripgrep.enable = true;
    bat.enable = true;
    go.enable = true;
    cargo.enable = false;
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    includes = ["~/.config.d/*"];
    extraOptionOverrides = {
      strictHostkeyChecking = "yes";
      connectTimeout = "5";
    };
    matchBlocks = {
      "*" = {

        hashKnownHosts = false;
        addKeysToAgent = "yes";
        identitiesOnly = true;

        controlMaster = "auto";
        controlPersist = "10m";
        controlPath = "~/.ssh/.sock-%C";

        serverAliveCountMax = 3;
        serverAliveInterval = 5;
      };
      server = {
        user = "ste";
        hostname = "remote.steff.tech";
      };
      kindle = {
        user = "root";
        identityFile = "~/.ssh/kindle";
        hostname = "192.168.15.244";
        extraOptions = {
          StrictHostkeyChecking = "no";
          UserKnownHostsFile = "/dev/null";
        };
      };
    };
  };

  # Remember to add '/home/ste/.nix-profile/bin/zsh' to /etc/shells before running `chsh -s /home/ste/.nix-profile/bin/zsh`
  programs.zsh = {
    enable = true;

    initContent = ''
      PROMPT="%{$fg[cyan]%}%c%{$reset_color%} "'$(git_prompt_info)'"
      %(?:%{$fg[green]%}:%{$fg[red]%})> %{$reset_color%}"
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
    '';
    history = {
      size = 20000;
      extended = true;
      ignoreAllDups = true;
    };
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "fzf"
        "git"
        "golang"
        "helm"
        "kubectl"
        "wd"
        # "ansible"
        # "bun"
        # "fluxcd"
        # "ripgrep"
        # "rust"
        # "terraform"
      ];

      extraConfig = "
# Update automatically without asking
zstyle ':omz:update' mode auto
# How often to auto-update (days).
zstyle ':omz:update' frequency 30
";
    };
    shellAliases = {
      grep = "grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox,.vscode}";
      la = "ls -A --group-directories-first";
      ll = "ls -CF1h --group-directories-first";
      l = "ls -alh --group-directories-first --file-type";

      # Ansible
      agr = "ansible-galaxy install -r requirements.yml";
      al = "ansible-lint";
      ap = "ansible-playbook";
      av = "ansible-vault";

      # GIT
      gcm  = "git commit -m";
      glp  = "git branch --merged next | grep -v '^[ *]*next$' | xargs git branch -d";
      glr  = "git pull origin \"$(git rev-parse --abbrev-ref --short origin/HEAD)\" --rebase";
      grp  = "git remote update origin --prune";
      gstv = "git status -vv";
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    historyWidgetOptions = ["+s" "+m" "-x"];
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Steffen Baarsgaard";
        email = "steff.bpoulsen@gmail.com";
        signingkey = "~/.ssh/id_ed25519.pub";
      };
      core = {
        editor = "hx";
        autocrlf = "input";
        fileMode = false;
        # hooksPath = "~/.config/git/hooks";
      };

      # Ease of use
      branch.autosetuprebase = "always";
      pull.rebase = true;
      push.default = "current";
      fetch.prune = true;
      rerere.enabled = true;
      pager.branch = false;
      rebase = {
        autosquash = true;
        updateRefs = true;
      };

      oh-my-zsh = {
        hide-status = 1;
        hide-dirty = 1;
      };
    };

    signing = {
      format = "ssh";
      key = "~/.ssh/id_ed25519";
      signByDefault = true;
    };

    ignores = [
      ".env*"
      ".helix/"
      ".intellij/"
      ".taplo.toml"
      ".vscode/"
    ];
  };

  programs.tmux = {
    enable = true;
    clock24 = true;

    escapeTime = 20;
    mouse = true;
    # keyMode = "vi";

    extraConfig = "
# Open buffer into EDITOR, either screen height or full buffer (e/E)
bind e run 'tmux capture-pane -S 0 -p -J > /tmp/tmux-$USER-edit && tmux new-window \"$EDITOR /tmp/tmux-$USER-edit\"'
bind E run 'tmux capture-pane -S - -p -J > /tmp/tmux-$USER-edit && tmux new-window \"$EDITOR /tmp/tmux-$USER-edit\"'

# vi like history/copy-mode
set-window-option -g mode-keys vi
bind-key -T copy-mode-vi v send -X begin-selection
bind-key -T copy-mode-vi V send -X select-line

# WSL2
set -s copy-command 'clip.exe'
bind-key -T copy-mode-vi y send -X copy-pipe-and-cancel 'clip.exe'

# # Linux
# set -s copy-command 'xclip -in -selection clipboard'
# bind-key -T copy-mode-vi y send -X copy-pipe-and-cancel 'xclip -in -selection clipboard'

# # Mac
# set -s copy-command 'pbcopy'
# bind-key -T copy-mode-vi y send -X copy-pipe-and-cancel 'pbcopy'
";
  };
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      features = "decorations";
    };
  };

  programs.helix = {
    enable = true;
    defaultEditor = true;

    settings = {
      theme = "ayu_evolve";
      editor = {
        auto-format = true;
        line-number = "relative";
        mouse = false;
        shell = ["bash" "-c"];
        end-of-line-diagnostics = "hint";
        # rainbow-brackets = true;

        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        file-picker.hidden = false;
        inline-diagnostics.cursor-line = "error";
        indent-guides = {
          render = true;
          character = "╎";
          skip-levels = 0;
        };
        lsp = {
          display-messages = true;
          display-inlay-hints = true;
          snippets = true;
        };
        # word-completion = {
        #   enable = true;
        #   trigger-length = 4;
        # };
      };

      keys.normal."+" = {
        b = ":pipe base64 -d";
        j = [":pipe jq" ":set-language json" "collapse_selection"];
        s = ["split_selection_on_newline" ":sort" "keep_primary_selection" "collapse_selection"];
        # v = ":sh ansible-vault decrypt Ctrl+%" # Waiting for 3134
      };
    };

    languages = {
      language-server = {
        regal = {
          command = "regal";
          args = ["language-server"];
          config.provideFormatter = true;
        };
        rust-analyzer.config = {
          checkOnSave = true;
          check.command = "clippy";
        };
        taplo.config.formatting = {
          align_entries = true;
          reorder_keys = true;
          trailing_newline = true;
        };
        yaml-language-server.config.yaml = {
          completion = true;
          format.enable = false; # Removes newlines...
          hover = true;
          validation = true;
          schemas = {
            # kubernetes = "*.y{a,}ml";
            "https://json.schemastore.org/github-workflow.json" = [".github/workflows/*.y{a,}ml"];
            "https://raw.githubusercontent.com/kyverno/chainsaw/main/.schemas/json/test-chainsaw-v1alpha1.json" = ["chainsaw-test.yaml"];
            # "https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json" = ["*docker-compose*.y{a,}ml"];
          };
        };
      };

      language = [
        {
          name = "bash";
          formatter = {
            command = "shfmt";
            args = ["-i" "2"];
          };
        }
        {
          name = "go";
          formatter.command = "gofmt";
        }
        {
          name = "markdown";
          language-servers = ["markdown-oxide"];
        }
        {
          name = "rego";
          indent = {
            tab-width = 4;
            unit = "\t";
          };
          language-servers = ["regal" "regols"];
        }
        {
          name = "toml";
          formatter = {
            command = "taplo";
            args = ["format" "-"];
          };
        }
        {
          name = "yaml";
          auto-format = false;
          language-servers = ["yaml-language-server"];
          # language-servers = ["yaml-language-server" "ansible-language-server"];
        }
      ];
    };

    extraPackages = [
      pkgs.bash-language-server
      pkgs.dockerfile-language-server
      pkgs.golangci-lint-langserver
      pkgs.gopls
      pkgs.helm-ls
      pkgs.markdown-oxide
      pkgs.nil
      pkgs.shellcheck
      pkgs.shfmt
      pkgs.superhtml
      pkgs.taplo
      pkgs.yaml-language-server
      # pkgs.ansible-language-server
      # pkgs.regal
      # pkgs.regols
      # pkgs.ruff
      # pkgs.rustup
      # pkgs.systemd-lsp
      # pkgs.terraform-ls
      # pkgs.ty
    ];
  };
}
