# terrasible :: Ansible w/ Terraform Case Study

This repository creates 1 WEB node ( with `nginx` installed ) and 2 APP nodes that runs a spesific `golang` code running on them in AWS Cloud. Thus, you need to have an AWS account in order to run this repository. `terraform` will create `t1.micro` AWS instances that will fits with the free plan, if you are eligible. If not, these are the cheapest option that AWS has.

## Architecture

Application that is written in `golang` is just a mere simple web server listening on port `tcp/8484`. The code is stored in [terrasible-example-code](http://github.com/eerkunt/terrasible-example-code) repository.

`nginx` running in WEB node is just used for simple Load Balancing in `round-robin` mode.

All `security groups` configured within AWS allows you to connect instances via `ssh` and `tcp/8484`. It also allows you to send `ICMP Echo` (`ping`) messages to instances.

## Requirements

- terraform
- ansible
- AWS account

## How to run ?

1. Clone the repository

	`~# git clone http://github.com/eerkunt/terrasible`

2. Change to given directory
	
	`~# cd terrasible`

3. Change anything that is related within the script `deploy.sh` in root directory of repository ;

	```bash
	# Configuration Parameters
	DIR_root="/path/to/terrasible/directory"
	DIR_infra="${DIR_root}/infra"
	DIR_cm="${DIR_root}/cm"

	BIN_terraform="/usr/local/bin/terraform"
	BIN_ansiblePlaybook='/usr/local/bin/ansible-playbook'

	terraformStateFile="${DIR_infra}/terraform.tfstate"

	ansiblePlaybook="${DIR_cm}/main.yml"
	ansibleHosts="${DIR_cm}/hosts"
	ansibleUser="ubuntu"

	nginxConfTemplate="${DIR_cm}/files/nginx-template.conf"
	nginxConfFinal="${DIR_cm}/files/nginx.conf"

	publicKey="~/.ssh/publicKeys/id_rsa.pub"
	```
	
4. Change anything that you would like to change within `infra/variables.tf` 

	```
	#
	# Most probably this won't work on your environment
	# Thus, simple change it the the path you have.
	#
	variable "publicKeyPath" {
  		description = "Public key path for communicating with infrastructure"
  		default = "~/.ssh/publicKeys/id_rsa.pub"
	}

	variable "publicKeyName" {
  		description = "Public Key Name"
  		default = "jo-U2FpbnNidXJ5"
	}
	```
5. Run `deploy.sh`.

6. Point your browser to the IP that `deploy.sh` said if everything runs properly.

## What does it do ?

The script initiates `terraform` to create ( or modify ) the structured in AWS Cloud environment, then after being sure that the cloud is up and available script push the job to the `ansible` to provision everything.

In a basic manner, `ansible` does ;

1. Upgrade every package on every system
2. Install NGINX and configure as a Round-Robin proxy for APP servers which has been populated via `terraform output` output. ( tcp/8484 )
3. Install needed packages like `golang`, `ruby`, `build-essentials` etc on APP servers
4. Install related systemd scripts.
5. Clones the GIT repository from [terrasible-example-code](http://github.com/eerkunt/terrasible-example-code) repository.
6. Checks if Travis CI has a new Build Number and everything is passed.
7. If Travis CI returns good, then we build the code to make it executable.
8. If there is a change, then we restart the service that executes our APP.

	




