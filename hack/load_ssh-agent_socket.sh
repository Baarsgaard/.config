#!/bin/bash

# Auto load existing ssh-agent socket
export SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"
ssh-add -l 2>/dev/null >/dev/null
if [ $? -ge 2 ] && [ -S "$SSH_AUTH_SOCK" ]; then
  pkill ssh-agent
  rm -rf "$SSH_AUTH_SOCK" || true

  ssh-agent -s -a "$SSH_AUTH_SOCK" >/dev/null
  ssh-add "$HOME/.ssh/commit_rsa"
fi
