#!/bin/bash

SESSION="proxmox-update"
tmux new-session -d -s $SESSION

for node in $(pvecm nodes); do
    # Check if node is online
    status=$(pvesh get /nodes/$node/status | grep 'status' | awk '{print $2}')
    if [ "$status" = "online" ]; then
        # Build the command to run on the node
        cmd="apt update && apt upgrade -y; for vm in \$(qm list | awk '{print \$1}' | tail -n +2); do qm exec \$vm apt update && apt upgrade -y; done; for ct in \$(pct list | awk '{print \$1}' | tail -n +2); do pct exec \$ct apt update && apt upgrade -y; done"
        tmux new-window -t $SESSION -n "$node" "ssh root@$node \"$cmd\""
    fi
done

tmux attach -t $SESSION
