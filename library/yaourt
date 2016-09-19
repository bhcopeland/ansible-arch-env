#!/usr/bin/python
# -*- coding: utf-8 -*-

# (c) 2015, TecSet <http://github.com/tecset>
#
# Based on pacman module written by Afterburn <http://github.com/afterburn>
#
# This module is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This software is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this software.  If not, see <http://www.gnu.org/licenses/>.


DOCUMENTATION = '''
---
module: yaourt
short_description: Manage packages with I(yaourt)
description:
    - Manage packages with the I(yaourt) package manager, a wrapper for 
      Pacman which is used by Arch Linux and its variants, to install
      not only programms shiped with Ṕacman but programms compilable
      through PKGBUILD on aur.archlinux.org
version_added: "2.0"
author:
    - "Marc Mettke (TecSet)"
notes: []
requirements: [ "yaourt" ]
options:
    name:
        description:
            - Name of the package to install, upgrade, or remove.
        required: false
        default: null

    state:
        description:
            - Desired state of the package.
        required: false
        default: "present"
        choices: ["present", "absent", "latest"]

    recurse:
        description:
            - When removing a package, also remove its dependencies, provided
              that they are not required by other packages and were not
              explicitly installed by a user.
        required: false
        default: no
        choices: ["yes", "no"]
        version_added: "1.3"

    force:
        description:
            - Force remove package, without any checks.
        required: false
        default: no
        choices: ["yes", "no"]
        version_added: "2.0"

    update_cache:
        description:
            - Whether or not to refresh the master package lists. This can be
              run as part of a package installation or as a separate step.
        required: false
        default: no
        choices: ["yes", "no"]

    upgrade:
        description:
            - Whether or not to upgrade whole system
        required: false
        default: no
        choices: ["yes", "no"]
        version_added: "2.0"
'''

EXAMPLES = '''
# Install package foo
- yaourt: name=foo state=present

# Upgrade package foo
- yaourt: name=foo state=latest update_cache=yes

# Remove packages foo and bar
- yaourt: name=foo,bar state=absent

# Recursively remove package baz
- yaourt: name=baz state=absent recurse=yes

# Run the equivalent of "yaourt -Sy" as a separate step
- yaourt: update_cache=yes

# Run the equivalent of "yaourt -Su" as a separate step
- yaourt: upgrade=yes

# Run the equivalent of "yaourt -Syu" as a separate step
- yaourt: update_cache=yes upgrade=yes

# Run the equivalent of "yaourt -Rdd", force remove package baz
- yaourt: name=baz state=absent force=yes
'''

import json
import shlex
import os
import re
import sys

def get_version(yaourt_output):
    """Take yaourt -Qi or yaourt -Si output and get the Version"""
    lines = yaourt_output.split('\n')
    for line in lines:
        if 'Version' in line:
            return line.split(':')[1].strip()
    return None

def query_package(module, yaourt_path, name, state="present"):
    """Query the package status in both the local system and the repository. Returns a boolean to indicate if the package is installed, and a second boolean to indicate if the package is up-to-date."""
    if state == "present":
        lcmd = "%s -Qi %s" % (yaourt_path, name)
        lrc, lstdout, lstderr = module.run_command(lcmd, check_rc=False)
        if lrc != 0:
            # package is not installed locally
            return False, False, False

        # get the version installed locally (if any)
        lversion = get_version(lstdout)

        rcmd = "%s -Si %s" % (yaourt_path, name)
        rrc, rstdout, rstderr = module.run_command(rcmd, check_rc=False)
        # get the version in the repository
        rversion = get_version(rstdout)

        if rrc == 0:
            # Return True to indicate that the package is installed locally, and the result of the version number comparison
            # to determine if the package is up-to-date.
            return True, (lversion == rversion), False

        # package is installed but cannot fetch remote Version. Last True stands for the error
        return True, True, True


def update_package_db(module, yaourt_path):
    cmd = "%s -Sy" % (yaourt_path)
    rc, stdout, stderr = module.run_command(cmd, check_rc=False)

    if rc == 0:
        return True
    else:
        module.fail_json(msg="could not update package db")

def upgrade(module, yaourt_path):
    cmdupgrade = "%s -Suqa --noconfirm" % (yaourt_path)
    cmdneedrefresh = "%s -Qqua" % (yaourt_path)
    rc, stdout, stderr = module.run_command(cmdneedrefresh, check_rc=False)

    if rc == 0:
        if module.check_mode:
            data = stdout.split('\n')
            module.exit_json(changed=True, msg="%s package(s) would be upgraded" % (len(data) - 1))
        rc, stdout, stderr = module.run_command(cmdupgrade, check_rc=False)
        if rc == 0:
            module.exit_json(changed=True, msg='System upgraded')
        else:
            module.fail_json(msg="Could not upgrade")
    else:
        module.exit_json(changed=False, msg='Nothing to upgrade')

def remove_packages(module, yaourt_path, packages):
    if module.params["recurse"]:
        args = "Rs"
    else:
        args = "R"

def remove_packages(module, yaourt_path, packages):
    if module.params["force"]:
        args = "Rdd"
    else:
        args = "R"

    remove_c = 0
    # Using a for loop incase of error, we can report the package that failed
    for package in packages:
        # Query the package first, to see if we even need to remove
        installed, updated, latestError = query_package(module, yaourt_path, package)
        if not installed:
            continue

        cmd = "%s -%s %s --noconfirm" % (yaourt_path, args, package)
        rc, stdout, stderr = module.run_command(cmd, check_rc=False)

        if rc != 0:
            module.fail_json(msg="failed to remove %s" % (package))

        remove_c += 1

    if remove_c > 0:

        module.exit_json(changed=True, msg="removed %s package(s)" % remove_c)

    module.exit_json(changed=False, msg="package(s) already absent")


def install_packages(module, yaourt_path, state, packages, package_files):
    install_c = 0
    package_err = []
    additionalmessage = ""

    for i, package in enumerate(packages):
        # if the package is installed and state == present or state == latest and is up-to-date then skip
        installed, updated, latestError = query_package(module, yaourt_path, package)
        if latestError and state == 'latest':
            package_err.append(package)
        
        if installed and (state == 'present' or (state == 'latest' and updated)):
            continue

        if package_files[i]:
            params = '-U %s' % package_files[i]
        else:
            params = '-Sa %s' % package

        cmd = "%s %s --noconfirm" % (yaourt_path, params)
        rc, stdout, stderr = module.run_command(cmd, check_rc=False)

        if rc != 0:
            module.fail_json(msg="failed to install %s" % (package))

        install_c += 1

    if install_c > 0:
        module.exit_json(changed=True, msg="installed %s package(s)" % (install_c))

    if state == 'latest' and len(package_err) > 0:
        additionalmessage = "Install Latest not possible because Version cought not be fetched for: " + ''.join(package_err)
    module.exit_json(changed=False, msg="package(s) already installed. %s" % (additionalmessage))


def check_packages(module, yaourt_path, packages, state):
    would_be_changed = []
    for package in packages:
        installed, updated, latestError = query_package(module, yaourt_path, package)
        if ((state in ["present", "latest"] and not installed) or
                (state == "absent" and installed) or
                (state == "latest" and not updated)):
            would_be_changed.append(package)
    if would_be_changed:
        if state == "absent":
            state = "removed"
        module.exit_json(changed=True, msg="%s package(s) would be %s" % (
            len(would_be_changed), state))
    else:
        module.exit_json(changed=False, msg="package(s) already %s" % state)


def main():
    module = AnsibleModule(
        argument_spec    = dict(
            name         = dict(aliases=['pkg', 'package'], type='list'),
            state        = dict(default='present', choices=['present', 'installed', "latest", 'absent', 'removed']),
            recurse      = dict(default=False, type='bool'),
            force        = dict(default=False, type='bool'),
            upgrade      = dict(default=False, type='bool'),
            update_cache = dict(default=False, aliases=['update-cache'], type='bool')
        ),
        required_one_of = [['name', 'update_cache', 'upgrade']],
        supports_check_mode = True)

    yaourt_path = module.get_bin_path('yaourt', True)

    if not os.path.exists(str(yaourt_path)):
        module.fail_json(msg="cannot find yaourt, in path %s" % (yaourt_path))

    p = module.params

    # normalize the state parameter
    if p['state'] in ['present', 'installed']:
        p['state'] = 'present'
    elif p['state'] in ['absent', 'removed']:
        p['state'] = 'absent'

    if p["update_cache"] and not module.check_mode:
        update_package_db(module, yaourt_path)
        if not (p['name'] or p['upgrade']):
            module.exit_json(changed=True, msg='Updated the package master lists')

    if p['update_cache'] and module.check_mode and not (p['name'] or p['upgrade']):
        module.exit_json(changed=True, msg='Would have updated the package cache')

    if p['upgrade']:
        upgrade(module, yaourt_path)

    if p['name']:
        pkgs = p['name']

        pkg_files = []
        for i, pkg in enumerate(pkgs):
            if pkg.endswith('.pkg.tar.xz'):
                # The package given is a filename, extract the raw pkg name from
                # it and store the filename
                pkg_files.append(pkg)
                pkgs[i] = re.sub('-[0-9].*$', '', pkgs[i].split('/')[-1])
            else:
                pkg_files.append(None)

        if module.check_mode:
            check_packages(module, yaourt_path, pkgs, p['state'])

        if p['state'] in ['present', 'latest']:
            install_packages(module, yaourt_path, p['state'], pkgs, pkg_files)
        elif p['state'] == 'absent':
            remove_packages(module, yaourt_path, pkgs)

# import module snippets
from ansible.module_utils.basic import *

if __name__ == "__main__":
    main()
