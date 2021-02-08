module "documentdb-cluster" {
  # source  = "cloudposse/documentdb-cluster/aws"
  # version = "0.8.0"
  # insert the 10 required variables here
  source                  = "./terraform-aws-documentdb-cluster"
  namespace               = "documentdb-cluster"
  stage                   = "testing"
  name                    = "docdb"
  cluster_size            = 1
  master_username         = var.master_usr
  master_password         = var.master_passwd
  instance_class          = "db.t3.medium"
  vpc_id                  = aws_vpc.docdb-vpc.id
  subnet_ids              = [aws_subnet.subnet_docdb_1.id, aws_subnet.subnet_docdb_2.id]
  allowed_security_groups = [aws_security_group.sg_docdb.id]
  allowed_cidr_blocks     = ["172.32.0.0/16"]
}

output "endpoint" {
  value       = module.documentdb-cluster.endpoint
  description = "Endpoint of the DocumentDB cluster"
}
