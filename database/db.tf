resource "aws_instance" "database_server" {
    ami                    = var.ami
    instance_type          = var.database_instance_type
    key_name               = var.key_name
    vpc_security_group_ids = [aws_security_group.ameenah-sparta-database-sg.id]
    associate_public_ip_address = true
    tags = {
    Name  = "tech501-sparta-${var.owner_name}-database"
    Owner = var.owner_name
    }
    user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
                echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
                sudo apt-get update
                wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb
                sudo dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb
                sudo apt-get install -y mongodb-org
                sudo sed -i "s/^bindIp: 127.0.0.1/bindIp: 0.0.0.0/" /etc/mongod.conf
                sudo systemctl start mongod
                sudo systemctl enable mongod
                EOF
}


output "database_server_public_ip" {
    description = "Public IP of database server"
    value       = aws_instance.database_server.public_ip
}

resource "aws_security_group" "ameenah-sparta-database-sg" {
    name        = "sparta-${var.owner_name}-db-sg"
    description = "Allow MongoDB access from app tier"
    vpc_id      = "vpc-07e47e9d90d2076da"  # Default VPC

    ingress {
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    }

    ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    }

    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }
}