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
#     configure_catalyst: "Configure Catalyst?"
     configure_xf86-video-ati: "Configure xf86-video-ati?"
     configure_xf86-video-amdgpu: "Configure xf86-video-amdgpu?"
     configure_intel: "Configure xf86-video-intel?"
#     setup_packages: "Setup pacman?"
     setup_yaourt: "Setup aur packages?"
#     setup_owncloud: "Setup owncloud?"

   tasks:
      - name: configure pacman/packages
        include: configure_pacman.yml

      - name: configure aur
        include: configure_aur.yml
        when: setup_yaourt.0 is defined

      - name: configure systemd services and etc files
        include: configure_services.yml

      - name: user account and folder creation
        include: configure_user.yml

      - name: configure sudo users
        include: configure_sudo.yml

      - name: configure symlinks (OwnCloud)
        include: configure_symlinks.yml
        when: setup_owncloud.0 is defined

      - name: configure catalyst (desktop)
        include: configure_catalyst.yml
        when: configure_catalyst.0 is defined

      - name: configure intel (laptop)
        include: configure_intel.yml
        when: configure_intel.0 is defined
