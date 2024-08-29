# add the IP address, username and hostname of the target hosts here

USERNAME=jomoon
COMMON="yes"
ANSIBLE_HOST_PASS="changeme"
ANSIBLE_TARGET_PASS="changeme"
# include ./*.mk

GPHOSTS := $(shell grep -i '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' ./ansible-hosts | sed -e "s/ ansible_ssh_host=/,/g")

all:
	@echo ""
	@echo "[ Available targets ]"
	@echo ""
	@echo "init:            will install basic requirements (will ask several times for a password)"
	@echo "install:         will install the host with what is defined in install-host.yml"
	@echo "update:          run OS updates"
	@echo "ssh:             jump ssh to host"
	@echo "role-update:     update all downloades roles"
	@echo "available-roles: list known roles which can be downloaded"
	@echo "clean:           delete all temporary files"
	@echo ""
	@for GPHOST in ${GPHOSTS}; do \
		IP=$${GPHOST#*,}; \
	    	HOSTNAME=$${LINE%,*}; \
		echo "Current used hostname: $${HOSTNAME}"; \
		echo "Current used IP: $${IP}"; \
		echo "Current used user: ${USERNAME}"; \
		echo ""; \
	done


# - https://ansible-tutorial.schoolofdevops.com/control_structures/
boot: role-update control-vms.yml
	ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} control-vms.yml --extra-vars "power_state=on power_title=Power-On"

shutdown: role-update control-vms.yml
	ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} control-vms.yml --extra-vars "power_state=off power_title=Power-Off"

download: role-update download-kafka.yml
	ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} download-kafka.yml --tags="download"

init: role-update init-hosts.yml
	ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} init-hosts.yml --tags="init"

uninit: role-update init-hosts.yml
	ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -u ${USERNAME} init-hosts.yml --tags="uninit"

install: role-update install-kafka.yml
	ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -i ansible-hosts -u ${USERNAME} install-kafka.yml --tags="install"

uninstall: role-update uninstall-kafka.yml
	ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -i ansible-hosts -u ${USERNAME} uninstall-kafka.yml --tags="uninstall"

upgrade: role-update setup-kafka.yml
	ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -i ansible-hosts -u ${USERNAME} setup-kafka.yml --tags="upgrade"

update:
	ansible-playbook --ssh-common-args='-o UserKnownHostsFile=./known_hosts' -i ${IP}, -u ${USERNAME} update-host.yml

# https://stackoverflow.com/questions/4219255/how-do-you-get-the-list-of-targets-in-a-makefile
no_targets__:
role-update:
	sh -c "$(MAKE) -p no_targets__ | awk -F':' '/^[a-zA-Z0-9][^\$$#\/\\t=]*:([^=]|$$)/ {split(\$$1,A,/ /);for(i in A)print A[i]}' | grep -v '__\$$' | grep '^ansible-update-*'" | xargs -n 1 make --no-print-directory
        $(shell sed -i -e '2s/.*/ansible_become_pass: ${ANSIBLE_HOST_PASS}/g' ./group_vars/all.yml )

ssh:
	ssh -o UserKnownHostsFile=./known_hosts ${USERNAME}@${IP}

install-host.yml:
	cp -a install-host.template install-host.yml

update-host.yml:
	cp -a update-host.template update-host.yml

clean:
	rm -rf ./known_hosts install-host.yml update-host.yml

.PHONY:	all init install update ssh common clean no_targets__ role-update
