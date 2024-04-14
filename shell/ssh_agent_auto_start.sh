#!/bin/bash
# shellcheck disable=SC1090

SSH_ENV="$HOME/Desktop/stuff/000_dotfiles/.ssh/agent-environment"

function start_agent {
    echo "Initialising new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' >"${SSH_ENV}"
    echo "SSH agent started successfully."
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" >/dev/null
    /usr/bin/ssh-add
}

# Source SSH settings, if applicable
if [ -f "${SSH_ENV}" ]; then
    . "${SSH_ENV}" >/dev/null
    # Check if the SSH agent is still running
    if ! ps -p "${SSH_AGENT_PID}" >/dev/null; then
        echo "SSH agent not active, starting new agent..."
        start_agent
    fi
else
    echo "SSH environment file not found, starting new agent..."
    start_agent
fi
