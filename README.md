# ansible-arch-env

To run the playbook: "./ansible_local_setup.sh"

Passwords are asked on prompt. If passwords are skipped the step will be skipped.

System wide vars set in group_vars/all

OwnCloud keeps all my config in sync across multiple computers.

# Vault

ansible-vault create secrets.yml

secrets.yml:
 - user_password: hiddenpassword
 - owncloud_password: hiddenpassword
