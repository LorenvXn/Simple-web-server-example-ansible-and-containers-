#!/usr/bin/python

import sys
import os


from ansible.executor.playbook_executor import PlaybookExecutor
from ansible.inventory.manager import InventoryManager
from ansible.parsing.dataloader import DataLoader
from ansible.vars.manager import VariableManager
from collections import namedtuple

loader = DataLoader()
hosts_path = InventoryManager(loader=loader, sources=sys.argv[1])
variable_manager = VariableManager(loader=loader, inventory=hosts)

playbook_path = sys.argv[2]


Options = namedtuple('Options',
                   ['listtags', 'listtasks', 'listhosts', 'syntax', 'connection',
		                'module_path', 'forks', 'remote_user', 'private_key_file', 
		                'ssh_common_args', 'ssh_extra_args', 'sftp_extra_args', 'scp_extra_args', 
		                'become', 'become_method', 'become_user', 'verbosity', 'check','diff'
                   ])

options = Options(listtags=False, listtasks=False, listhosts=False, syntax=False, 
		  connection='ssh', module_path=None, forks=100, remote_user='tron', 
		  private_key_file=None, ssh_common_args=None, ssh_extra_args=None, 
		  sftp_extra_args=None, scp_extra_args=None, become=True, become_method='sudo', 
		  become_user='tron', verbosity=None, check=False, diff=False)


play = PlaybookExecutor(playbooks=[playbook_path], inventory=hosts_path, 
			variable_manager=variable_manager, loader=loader, options=options, passwords={})

results = play.run()
