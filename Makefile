.PHONY: setup-venv ansible ansible-dry

# Stub for now makefile

setup-venv:
	bash ./scripts/setup-venv.sh

ansible:
	source .venv/bin/activate && ansible-playbook playbooks/local.yml -i inventory/localhost

ansible-dry:
	source .venv/bin/activate && ansible-playbook playbooks/local.yml -i inventory/localhost --check --diff