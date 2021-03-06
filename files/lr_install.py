#!/usr/bin/env python3

# Copyright 2017 MDSLAB - University of Messina
# All Rights Reserved.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

import os
import site

if os.path.exists('/iotronic_lightningrod/'):
    print("Cleaning install folders...")
    os.system('rm -rf ' + site.getsitepackages()[0]
              + '/iotronic_lightningrod/etc')
    os.system('rm -rf ' + site.getsitepackages()[0]
              + '/iotronic_lightningrod/templates')
    print("Moving installation folders...")
    os.system('mv -f /iotronic_lightningrod/* '
              + site.getsitepackages()[0] + '/iotronic_lightningrod/')

py_dist_pack = site.getsitepackages()[0]
print("Python packages folder: " + py_dist_pack)

print('Iotronic environment creation:')
if not os.path.exists('/etc/iotronic/'):
    os.makedirs('/etc/iotronic/', 0o644)
    print(' - /etc/iotronic/ - Created.')
    os.system('cp ' + py_dist_pack + '/iotronic_lightningrod/'
              + 'templates/settings.example.json /etc/iotronic/settings.json')
    print(' - settings.json - Created.')
    os.system('cp ' + py_dist_pack + '/iotronic_lightningrod/'
              + 'etc/iotronic/iotronic.conf /etc/iotronic/iotronic.conf')
    print(' - iotronic.conf - Created.')
else:
    print(' - /etc/iotronic/ - Already exists.')
    if not os.path.isfile('/etc/iotronic/settings.json'):
        os.system('cp ' + py_dist_pack + '/iotronic_lightningrod/templates/'
                  + 'settings.example.json /etc/iotronic/settings.json')
        print(' - settings.json - Created.')
    else:
        print(' - settings.json - Already exists.')

    if not os.path.isfile('/etc/iotronic/iotronic.conf'):
        os.system('cp ' + py_dist_pack + '/iotronic_lightningrod/'
                  + 'etc/iotronic/iotronic.conf /etc/iotronic/iotronic.conf')
        print(' - iotronic.conf - Created.')
    else:
        os.system('cp ' + py_dist_pack + '/iotronic_lightningrod/'
                  + 'etc/iotronic/iotronic.conf /etc/iotronic/iotronic.conf')
        print(' - iotronic.conf - Overwritten.')


if not os.path.exists('/var/lib/iotronic/'):
    os.makedirs('/var/lib/iotronic/plugins', 0o644)
    print(' - /var/lib/iotronic/plugins - Created.')
    os.system('cp ' + py_dist_pack + '/iotronic_lightningrod/templates/'
              + 'plugins.example.json /var/lib/iotronic/plugins.json')
    os.system('cp ' + py_dist_pack + '/iotronic_lightningrod/templates/'
              + 'services.example.json /var/lib/iotronic/services.json')
    print(' - configuration files added.')
else:
    print(' - /var/lib/iotronic/ - Already exists.')

    if not os.path.isfile('/var/lib/iotronic/plugins.json'):
        os.system('cp ' + py_dist_pack + '/iotronic_lightningrod/templates/'
                  + 'plugins.example.json /var/lib/iotronic/plugins.json')
        print(' - plugins.json - Created.')
    else:
        print(' - plugins.json - Already exists.')

    if not os.path.isfile('/var/lib/iotronic/services.json'):
        os.system('cp ' + py_dist_pack + '/iotronic_lightningrod/templates/'
                  + 'services.example.json /var/lib/iotronic/services.json')
        print(' - services.json - Created.')
    else:
        print(' - services.json - Already exists.')


print('Logging configuration: ')
if not os.path.exists('/var/log/iotronic/'):
    os.makedirs('/var/log/iotronic/', 0o644)
    print(' - /var/log/iotronic/ - Created.')
else:
    print(' - /var/log/iotronic/ - Already exists.')

os.system('cp ' + py_dist_pack + '/iotronic_lightningrod/etc/logrotate.d/'
          + 'lightning-rod.log /etc/logrotate.d/lightning-rod.log')
print(' - logrotate configured.')


"""
os.system('cp ' + py_dist_pack + '/iotronic_lightningrod/scripts/'
          + 'configure_lr.py /usr/bin/configure_lr')
os.chmod('/usr/bin/configure_lr', 0o744)
"""