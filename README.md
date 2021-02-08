# Terraform & AWS DocumentDB-cluster. 
New mongodb databases, users, passwords are created by MongoShell.

It is based on the `terraform-aws-documentdb-cluster` Terraform module to provision a DocumentDB cluster on AWS.
https://registry.terraform.io/modules/cloudposse/documentdb-cluster/aws/latest, https://github.com/cloudposse/terraform-aws-documentdb-cluster

1) Please set environments below up:
```
export AWS_ACCESS_KEY_ID=<Your_AWS_ACCESS_KEY_ID> && export AWS_SECRET_ACCESS_KEY=<Your_AWS_SECRET_ACCESS_KEY>
```
2) Please specify AWS region in the `settings_requirements.tf`.
3) Please set the values below before usage:
```
  `variables.tf`:
  - master_usr				# claster endpoint username
  - master_passwd			# claster endpoint password
  - database_name_{1,2,3}		# thera are 3 test dbs at the momment. You can change number of it.  
  - database_name_{1,2,3}_username	# thera are 3 test dbs_users at the momment. You can change number of it.
  - database_name_{1,2,3}_password	# thera are 3 test dbs_password at the momment. You can change number of it.
  `main_module.tf`:
  - namespace               
  - stage                   		# prod/stage
  - name                    
  - cluster_size            		# at least 3 should be set here due to redundancy
  - instance_class          		# db.t3.medium is the chapest one. Free Tier does not apply here.
  - vpc_id                  		# if change is required
  - subnet_ids              		# if change is required
  - allowed_security_groups 		# if change is required
  - allowed_cidr_blocks 		# you can whitelist needful IPs here or adjust rules in `vpc_subnet_gw_sg_route.tf`.
```
 4) During `terraform plan` or `terraform apply` execution you have to set value for `var.master_passwd` (cluster endpoint password).
 5) Module modifications: TLS is disabled in `terraform-aws-documentdb-cluster/main.tf`. 
 6) Terraform creates vpc, subnets, security group, gw, eip, route rules and DocumentDB cluster, ec2 instance (jumpbox). It connects to the endpoint of the cluster via the mongo shell from jumpbox (actions are described in the `ec2_instance_eip_mongoshell_script.tf`) and creates databases, users, passwords, roles. Jumpbox (ec2 instance) will be automatically turned off after that. Please note that AWS DocumentDB is only avaiable from VPC. However, we are able to check created databases, users, roles from created for this case ec2 instance (jumpbox). After execution of `terraform apply` (ETA ~9min) we can check MongoDB databases and users from the mentioned jumpbox (please uncomment 41 line (ingress rule for whitelisting of 22 port) in the `vpc_subnet_gw_sg_route.tf` for it).
```
ubuntu@ip-xxx-xxx-xxx-xxx:~$ mongo --host <your_hostname>:27017 --username <your_username> --password <your_password>
MongoDB shell version v3.6.22
connecting to: mongodb://documentdb-cluster-testing-docdb.cluster-c1ddsvga1aui.us-east-1.docdb.amazonaws.com:27017/?gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("39540cdf-e699-49e2-9296-69c33b04b0eb") }
MongoDB server version: 3.6.0
Welcome to the MongoDB shell.
For interactive help, type "help".
For more comprehensive documentation, see
	http://docs.mongodb.org/
Questions? Try the support group
	http://groups.google.com/group/mongodb-user

Warning: Non-Genuine MongoDB Detected

This server or service appears to be an emulation of MongoDB rather than an official MongoDB product.

Some documented MongoDB features may work differently, be entirely missing or incomplete, or have unexpected performance characteristics.

To learn more please visit: https://dochub.mongodb.org/core/non-genuine-mongodb-server-warning.

rs0:PRIMARY> show dbs
db_1  0.000GB
db_2  0.000GB
db_3  0.000GB
rs0:PRIMARY> show users
{
	"_id" : "serviceadmin",
	"user" : "serviceadmin",
	"db" : "admin",
	"roles" : [
		{
			"db" : "admin",
			"role" : "root"
		}
	]
}
{
	"_id" : "root",
	"user" : "root",
	"db" : "admin",
	"roles" : [
		{
			"db" : "admin",
			"role" : "root"
		}
	]
}
{
	"_id" : "db_1_user",
	"user" : "db_1_user",
	"db" : "admin",
	"roles" : [
		{
			"db" : "db_1",
			"role" : "readWrite"
		}
	]
}
{
	"_id" : "db_2_user",
	"user" : "db_2_user",
	"db" : "admin",
	"roles" : [
		{
			"db" : "db_2",
			"role" : "readWrite"
		}
	]
}
{
	"_id" : "db_3_user",
	"user" : "db_3_user",
	"db" : "admin",
	"roles" : [
		{
			"db" : "db_3",
			"role" : "readWrite"
		}
	]
}
```
