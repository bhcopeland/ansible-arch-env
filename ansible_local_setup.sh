#!/usr/bin/ansible-playbook --ask-vault-pass
---
# Install and setup local env


-  hosts: localhost
   gather_facts: false
   vars_files:
     - secrets.yml
   vars_prompt:
     configure_catalyst: "Configure Catalyst?"
     configure_laptop: "Configure Intel?"
     setup_packages: "Setup pacman/yaourt?"

   tasks:
      - name: configure pacman/packages
        include: configure_pacman.yml
        when: setup_packages.0 is defined

      - name: configure yaort
        include: configure_yaourt.yml
        when: setup_packages.0 is defined

      - name: configure bootup services and files
        include: configure_services.yml

      - name: username setup
        include: configure_user.yml

      - name: sudo setup
        include: configure_sudo.yml

      - name: configure owncloud client
        include: configure_owncloud.yml

      - name: configure catalyst (desktop)
        include: configure_catalyst.yml
        when: configure_catalyst.0 is defined

      - name: configure intel (laptop)
        include: configure_intel.yml
        when: configure_intel.0 is defined