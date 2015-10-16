#!/usr/bin/ansible-playbook -c local --extra-vars=vars.yml
---
# Install and setup local env

- name: Install and setup local env
  hosts: localhost
  gather_facts: false
  vars_prompt:
    user_password: "Set your choose a user password?"
    owncloud_passwd: "Set your owncloud client passwd?"

  tasks:
    - name: configure pacman/packages
      include: configure-pacman.yml

    - name: configure yaort
      include: configure-yaourt.yml

    - name: enable services
      include: enable-services.yml

    - name: username setup
      include: configure-user.yml

    - name: setup owncloud
      command: owncloudcmd --user bhcopeland --password {{owncloud_passwd}} --non-interactive --trust $HOME/.local/share/data/ownCloud https://bcc.linaro.org/owncloud
      when: owncloud_install == 'yes'
