export SSH_ENV="$HOME/.ssh/agent.env"

function start_agent {
    echo "Initializing new SSH agent..."
    /usr/bin/ssh-agent -s > "${SSH_ENV}"
    chmod 600 "${SSH_ENV}"
    source "${SSH_ENV}" > /dev/null
}

# Check if SSH agent is running
if [ -f "${SSH_ENV}" ]; then
    source "${SSH_ENV}" > /dev/null
    # Test if the agent is alive
    ps -ef | grep "${SSH_AGENT_PID}" | grep -v grep > /dev/null || {
        start_agent;
    }
else
    start_agent;
fi

ssh-add -l &>/dev/null || ssh-add &>/dev/null
