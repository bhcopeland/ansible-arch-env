#!/usr/bin/ansible-playbook --ask-vault-pass
---
# Install and setup local env


-  hosts: localhost
   gather_facts: false
   vars_files:
     - secrets.yml
   vars_prompt:
     configure_catalyst: "Configure Catalyst?"
     configure_intel: "Configure Intel (laptop)?"
     setup_packages: "Setup pacman?"
     setup_yaourt: "Setup yaourt?"
     setup_owncloud: "Setup owncloud?"

   tasks:
      - name: configure pacman/packages
        include: configure_pacman.yml
        sudo: yes

      - name: configure yaourt
        include: configure_yaourt.yml
        when: setup_yaourt.0 is defined

      - name: configure systemd services and etc files
        include: configure_services.yml

      - name: user account and folder creation
        include: configure_user.yml

      - name: congiure sudo users
        include: configure_sudo.yml

      - name: configure owncloud client
        include: configure_owncloud.yml
        when: setup_owncloud.0 is defined

      - name: configure catalyst (desktop)
        include: configure_catalyst.yml
        when: configure_catalyst.0 is defined

      - name: configure intel (laptop)
        include: configure_intel.yml
        when: configure_intel.0 is defined
