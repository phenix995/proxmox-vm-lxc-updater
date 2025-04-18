#!/bin/bash

SESSION="proxmox-update"
tmux new-session -d -s $SESSION

# Extract only valid node names (skip headers and metadata)
nodes=$(pvecm nodes | awk 'NR>2 && $3 != "-" {print $3}')

for node in $nodes; do
    # Check if node is online
    status=$(pvesh get /nodes/$node/status 2>/dev/null | grep -oP '"online":\K(\w+)')
    if [ "$status" = "true" ]; then
        # Build the command to run on the node
        cmd="apt update && apt upgrade -y; for vm in \$(qm list | awk '{print \$1}' | tail -n +2); do qm exec \$vm apt update && apt upgrade -y; done; for ct in \$(pct list | awk '{print \$1}' | tail -n +2); do pct exec \$ct apt update && apt upgrade -y; done"
        tmux new-window -t $SESSION -n "$node" "ssh root@$node \"$cmd\""
    fi
done

tmux attach -t $SESSION
