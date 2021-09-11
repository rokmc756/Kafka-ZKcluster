#!/bin/bash
ansible-playbook -u jomoon setup-kafka.yml -i ansible-hosts --tags="firewalld,java,kafka"
# ansible-playbook -u jomoon kafka.yml -i hosts --tags="firewalld,java,kafka,zookeeper"
