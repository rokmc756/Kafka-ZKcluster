Ansible Sematext Agent Install Role
=========================================

Install Sematext Agent.

Dependencies
------------
None

Example Playbooks
-------------------------
```
- hosts: all
  become: yes
  roles:
    - { role: sematext.spm-monitor-install }
```

License
-------

Apache2

Author Information
------------------

Ciprian Hacman <ciprian.hacman@sematext.com>
