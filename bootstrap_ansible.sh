#!/usr/bin/ansible-playbook
---
# Install and setup local env


- name: setup ansible
  hosts: localhost
  gather_facts: false

  tasks:
    - get_url:
        url: "https://raw.githubusercontent.com/TecSet/ansible-modules-extras/devel/packaging/os/yaourt.py"
        dest: "/usr/lib/python2.7/site-packages/ansible/modules/extras/packaging/os/"
      sudo: yes
