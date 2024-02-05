#!/bin/bash

CGROUP_ROOT_PATH='/sys/fs/cgroup'
RUSTLAND_CGROUP="${CGROUP_ROOT_PATH}/scx-rustland"

# Setup controllers
echo '+memory' > "${CGROUP_ROOT_PATH}/cgroup.subtree_control"

# Cgroup create
if [ ! -d "${RUSTLAND_CGROUP}" ]; then
    echo 'Creating cgroup'
    mkdir "${RUSTLAND_CGROUP}"
fi
echo '1' > "${RUSTLAND_CGROUP}/memory.compact_disable"

# Cgroup migration
echo "Moving to cgroup ${RUSTLAND_CGROUP}"
echo $$ > "${RUSTLAND_CGROUP}/cgroup.procs"

# Program start
echo 'Starting program:'
echo "| in cgroup: $(cat /proc/self/cgroup)"
echo "| with compact_disable="$(cat "${RUSTLAND_CGROUP}/memory.compact_disable")
target/debug/scx_rustland

# Cgroup removal
echo 'Removing cgroup...'
# Move back to root cgroup
echo $$ > "${CGROUP_ROOT_PATH}/cgroup.procs"
# Now that it's empty, remove it
rmdir "${RUSTLAND_CGROUP}"

echo 'Goodbye!'
