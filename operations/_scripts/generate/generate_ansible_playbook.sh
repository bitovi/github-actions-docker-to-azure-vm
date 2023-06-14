#!/bin/bash
# shellcheck disable=SC1091

set -e
echo "In $(basename $0)"
[[ -n $DEBUG_MODE && $DEBUG_MODE == 'true' ]] && set -x

source "$GITHUB_ACTION_PATH/operations/_scripts/generate/generate_helpers.sh"

PLAYBOOK_PATH=$GITHUB_ACTION_PATH/operations/deployment/ansible/playbook.yml

echo -en "- name: Ensure hosts is up and running
  hosts: bitops_servers
  gather_facts: no
  tasks:
  - name: Wait for hosts to come up
    wait_for_connection:
      timeout: 300

- name: Ansible tasks
  hosts: bitops_servers
  become: true
  tasks:
" > $PLAYBOOK_PATH

# Adding docker cleanup task to playbook
if [[ $DOCKER_FULL_CLEANUP = true ]]; then
echo -en "
  - name: Docker Cleanup
    include_tasks: tasks/docker_cleanup.yml
" >> $PLAYBOOK_PATH
fi

# Adding app_repo cleanup task to playbook
if [[ $APP_DIRECTORY_CLEANUP = true ]]; then
echo -en "
  - name: EC2 Cleanup
    include_tasks: tasks/ec2_cleanup.yml
" >> $PLAYBOOK_PATH
fi

# Continue adding the defaults
echo -en "
  - name: Include install
    include_tasks: tasks/install.yml
  - name: Include fetch
    include_tasks: tasks/fetch.yml
    # Notes on why unmounting is required can be found in umount.yaml
  - name: Unmount efs
    include_tasks: tasks/umount.yml
" >> $PLAYBOOK_PATH

# if [[ $(alpha_only "$AWS_EFS_CREATE") == true ]] || [[ $(alpha_only "$AWS_EFS_CREATE_HA") == true ]] || [[ $AWS_EFS_MOUNT_ID != "" ]]; then
# echo -en "
#   - name: Mount efs
#     include_tasks: tasks/mount.yml
#     when: mount_efs
# " >> $PLAYBOOK_PATH
# fi

echo -en "
  - name: Include start
    include_tasks: tasks/start.yml
" >> $PLAYBOOK_PATH
