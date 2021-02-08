data "aws_ami" "service" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "service" {
  ami                    = data.aws_ami.service.id
  vpc_security_group_ids = [aws_security_group.sg_docdb.id]
  subnet_id              = aws_subnet.subnet_docdb_1.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.service.key_name
  #  user_data = file("data.sh")
  user_data = <<-EOT
#!/bin/bash
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.6.list
sudo apt-get update
sudo apt-get install -y mongodb-org-shell
mongo --host ${module.documentdb-cluster.endpoint}:27017 --username ${var.master_usr} --password ${var.master_passwd} --eval "db.getSiblingDB('${var.database_name_1}').createUser({user: '${var.database_name_1_username}', pwd: '${var.database_name_1_password}', roles: ['readWrite']})"
mongo --host ${module.documentdb-cluster.endpoint}:27017 --username ${var.master_usr} --password ${var.master_passwd} --eval "db.getSiblingDB('${var.database_name_2}').createUser({user: '${var.database_name_2_username}', pwd: '${var.database_name_2_password}', roles: ['readWrite']})"
mongo --host ${module.documentdb-cluster.endpoint}:27017 --username ${var.master_usr} --password ${var.master_passwd} --eval "db.getSiblingDB('${var.database_name_3}').createUser({user: '${var.database_name_3_username}', pwd: '${var.database_name_3_password}', roles: ['readWrite']})"
echo "use ${var.database_name_1}" > /home/ubuntu/script.js
echo 'db.${var.database_name_1}.insert({"name":"document_1"})' >> /home/ubuntu/script.js
echo "use ${var.database_name_2}" >> /home/ubuntu/script.js
echo 'db.${var.database_name_2}.insert({"name":"document_1"})' >> /home/ubuntu/script.js
echo "use ${var.database_name_3}" >> /home/ubuntu/script.js
echo 'db.${var.database_name_3}.insert({"name":"document_1"})' >> /home/ubuntu/script.js
mongo --host ${module.documentdb-cluster.endpoint}:27017 --username ${var.master_usr} --password ${var.master_passwd} < /home/ubuntu/script.js
rm -f /home/ubuntu/script.js
sleep 10m
poweroff
EOT
  tags = {
    Name = "docdb"
  }
  depends_on = [module.documentdb-cluster]
}

resource "tls_private_key" "service" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "service" {
  key_name   = "tf-key-ec2"
  public_key = tls_private_key.service.public_key_openssh
}

resource "local_file" "service_private_key" {
  content  = tls_private_key.service.private_key_pem
  filename = aws_key_pair.service.key_name
  provisioner "local-exec" {
    command = "chmod 400 ${aws_key_pair.service.key_name}"
  }
}

resource "aws_eip" "my_static_ip" {
  instance = aws_instance.service.id
}

output "ec2_public_ip_address" {
  value = aws_eip.my_static_ip.public_ip
}