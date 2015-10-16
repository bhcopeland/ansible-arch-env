#!/usr/bin/ansible-playbook
---
# Install and setup local env

- name: Install and setup local env
  gather_facts: false
  hosts: localhost
  vars_prompt:
    user_password: "Set your choose a user password?"
    owncloud_password: "Set your owncloud client passwd?"

  tasks:
    # - name: configure pacman/packages
    #   include: configure-pacman.yml

    - name: configure yaort
      include: configure-yaourt.yml

    - name: enable services
      include: enable-services.yml

    - name: username setup
      include: configure-user.yml

    - name: sudo setup
      include: configure-sudo.yml

    - name: setup owncloud
      include: configure-owncloud.yml

    # - name: setup symlinks
    #   include: configure-symlinks.yml