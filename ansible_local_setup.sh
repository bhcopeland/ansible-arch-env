#!/usr/bin/ansible-playbook --ask-vault-pass
---
# Install and setup local env

-  hosts: localhost
   gather_facts: false
   become: yes
##   ignore_errors: yes
   vars_files:
     - secrets.yml
   vars_prompt:
     - name: "configure_video_amdgpu"
       prompt: "Configure xf86-video-amdgpu?"
     - name: "configure_intel"
       prompt: "Configure xf86-video-intel?"
     - name: "setup_aur"
       prompt: "Setup aur packages?"
     - name: "setup_pacman"
       prompt: "Setup pacman packages?"

   tasks:
      - name: configure video_drivers
        include: configure_video_drivers.yml
        when: (configure_intel.0 is defined) or (configure_video_amdgpu.0 is defined)

      - name: user/sudo and folder creation
        include: configure_user.yml

      - name: configure pacman/packages
        include: configure_pacman.yml
        when: setup_pacman.0 is defined

      - name: configure aur
        include: configure_aur.yml
        when: setup_aur.0 is defined

      - name: configure systemd services and etc files
        include: configure_services.yml

      - name: configure symlinks
        include: configure_symlinks.yml
        when: setup_owncloud.0 is defined
