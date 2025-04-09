#!/bin/bash

# Function to start SSH agent and add specified keys
# Usage example:
# start_ssh_agent "$HOME/.ssh/id_rsa,$HOME/.ssh/id_ed25519"
# or without keys:
# start_ssh_agent
start_ssh_agent() {
   local keys_to_add="$1"  # Comma-separated list of keys

   local ssh_pid_file="$HOME/.config/ssh-agent.pid"
   SSH_AUTH_SOCK="$HOME/.config/ssh-agent.sock"

   if [ -z "$SSH_AGENT_PID" ]; then
       # no PID exported, try to get it from pidfile
       SSH_AGENT_PID=$(cat "$ssh_pid_file" 2>/dev/null)
   fi

   if ! kill -0 $SSH_AGENT_PID &> /dev/null; then
       # the agent is not running, start it
       rm "$SSH_AUTH_SOCK" &> /dev/null
       >&2 echo "Starting SSH agent, since it's not running; this can take a moment"
       eval "$(ssh-agent -s -a "$SSH_AUTH_SOCK")"
       echo "$SSH_AGENT_PID" > "$ssh_pid_file"

       # Add default keys if macOS (-A flag)
       ssh-add -A 2>/dev/null

       # Add keys from the comma-separated list
       if [ -n "$keys_to_add" ]; then
           IFS=',' read -ra KEY_ARRAY <<< "$keys_to_add"
           for key in "${KEY_ARRAY[@]}"; do
               # Trim whitespace
               key=$(echo "$key" | xargs)
               if [ -f "$key" ]; then
                   >&2 echo "Adding key: $key"
                   ssh-add "$key" 2>/dev/null || >&2 echo "Failed to add key: $key"
               else
                   >&2 echo "Key file not found: $key"
               fi
           done
       fi

       >&2 echo "Started ssh-agent with '$SSH_AUTH_SOCK'"
   # else
   #     >&2 echo "ssh-agent on '$SSH_AUTH_SOCK' ($SSH_AGENT_PID)"
   fi

   export SSH_AGENT_PID
   export SSH_AUTH_SOCK
}

