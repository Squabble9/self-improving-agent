#!/bin/bash
# Self-Improvement Learning Helper
# Provides utilities for per-agent learning management

set -e

# Get the current agent ID
get_agent_id() {
    echo "${OPENCLAW_AGENT_ID:-${USER:-default}}"
}

# Get the learnings directory for the current agent
get_learnings_dir() {
    local agent_id
    agent_id=$(get_agent_id)
    echo "${HOME}/.openclaw/agents/${agent_id}/.learnings"
}

# Get the common learnings file path
get_common_learnings_file() {
    echo "${HOME}/.openclaw/workspace/.learnings/COMMON.md"
}

# Initialize learnings directory for current agent
init_learnings() {
    local agent_id learnings_dir common_dir
    agent_id=$(get_agent_id)
    learnings_dir=$(get_learnings_dir)
    common_dir="${HOME}/.openclaw/workspace/.learnings"
    
    echo "Initializing learnings for agent: ${agent_id}"
    
    # Create agent-specific learnings directory
    mkdir -p "${learnings_dir}"
    
    # Create common learnings directory
    mkdir -p "${common_dir}"
    
    # Create learning files if they don't exist
    if [ ! -f "${learnings_dir}/LEARNINGS.md" ]; then
        cat > "${learnings_dir}/LEARNINGS.md" << 'EOF'
# Learnings Log

Captured learnings, corrections, and discoveries. Review before major tasks.

---
EOF
        echo "Created: ${learnings_dir}/LEARNINGS.md"
    fi
    
    if [ ! -f "${learnings_dir}/ERRORS.md" ]; then
        cat > "${learnings_dir}/ERRORS.md" << 'EOF'
# Errors Log

Captured errors and failures. Review to prevent recurring issues.

---
EOF
        echo "Created: ${learnings_dir}/ERRORS.md"
    fi
    
    if [ ! -f "${learnings_dir}/FEATURE_REQUESTS.md" ]; then
        cat > "${learnings_dir}/FEATURE_REQUESTS.md" << 'EOF'
# Feature Requests Log

User-requested capabilities and enhancements.

---
EOF
        echo "Created: ${learnings_dir}/FEATURE_REQUESTS.md"
    fi
    
    # Create common learnings file if it doesn't exist
    if [ ! -f "${common_dir}/COMMON.md" ]; then
        cat > "${common_dir}/COMMON.md" << 'EOF'
# Common Learnings

Cross-agent issues and shared conventions that affect all agents.

---
EOF
        echo "Created: ${common_dir}/COMMON.md"
    fi
    
    echo "Learnings initialized successfully!"
    echo "Agent-specific: ${learnings_dir}"
    echo "Common: ${common_dir}/COMMON.md"
}

# Show current learnings status
status() {
    local agent_id learnings_dir common_file
    agent_id=$(get_agent_id)
    learnings_dir=$(get_learnings_dir)
    common_file=$(get_common_learnings_file)
    
    echo "=== Self-Improvement Learning Status ==="
    echo "Agent ID: ${agent_id}"
    echo ""
    echo "Agent-specific learnings: ${learnings_dir}"
    if [ -d "${learnings_dir}" ]; then
        echo "  Directory: EXISTS"
        for file in LEARNINGS.md ERRORS.md FEATURE_REQUESTS.md; do
            if [ -f "${learnings_dir}/${file}" ]; then
                local count
                count=$(grep -c "^## \[" "${learnings_dir}/${file}" 2>/dev/null || echo "0")
                echo "  - ${file}: ${count} entries"
            else
                echo "  - ${file}: NOT FOUND"
            fi
        done
    else
        echo "  Directory: NOT FOUND"
    fi
    
    echo ""
    echo "Common learnings: ${common_file}"
    if [ -f "${common_file}" ]; then
        local count
        count=$(grep -c "^## \[" "${common_file}" 2>/dev/null || echo "0")
        echo "  - COMMON.md: ${count} entries"
    else
        echo "  - COMMON.md: NOT FOUND"
    fi
}

# List pending items
list_pending() {
    local agent_id learnings_dir common_file
    agent_id=$(get_agent_id)
    learnings_dir=$(get_learnings_dir)
    common_file=$(get_common_learnings_file)
    
    echo "=== Pending Learnings for agent: ${agent_id} ==="
    echo ""
    
    if [ -d "${learnings_dir}" ]; then
        for file in LEARNINGS.md ERRORS.md FEATURE_REQUESTS.md; do
            if [ -f "${learnings_dir}/${file}" ]; then
                echo "--- ${file} ---"
                grep -B2 "Status\*\*: pending" "${learnings_dir}/${file}" | grep "^## \[" || echo "  No pending items"
                echo ""
            fi
        done
    else
        echo "Learnings directory not found. Run: $0 init"
    fi
    
    echo "=== Pending Common Learnings ==="
    if [ -f "${common_file}" ]; then
        grep -B2 "Status\*\*: pending" "${common_file}" | grep "^## \[" || echo "  No pending items"
    else
        echo "Common learnings file not found."
    fi
}

# Show usage
usage() {
    cat << EOF
Usage: $0 [command]

Commands:
  init       Initialize learnings directory for current agent
  status     Show current learnings status
  pending    List pending learnings
  dir        Print the learnings directory path
  agent      Print the current agent ID
  help       Show this help message

Environment Variables:
  OPENCLAW_AGENT_ID    The agent ID (default: \$USER or "default")

Examples:
  $0 init                    # Initialize learnings for current agent
  $0 status                  # Show learnings status
  $0 pending                 # List pending items
EOF
}

# Main command handler
case "${1:-help}" in
    init)
        init_learnings
        ;;
    status)
        status
        ;;
    pending)
        list_pending
        ;;
    dir)
        get_learnings_dir
        ;;
    agent)
        get_agent_id
        ;;
    help|--help|-h)
        usage
        ;;
    *)
        echo "Unknown command: $1"
        usage
        exit 1
        ;;
esac
