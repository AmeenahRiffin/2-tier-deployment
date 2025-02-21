resource "aws_instance" "sparta_app" {
    ami                    = var.ami
    instance_type          = var.app_instance_type
    key_name               = var.key_name
    vpc_security_group_ids = [aws_security_group.ameenah-sparta-app-sg.id]
    associate_public_ip_address = true
    tags = {
    Name  = "tech501-sparta-${var.owner_name}-app"
    Owner = var.owner_name
    }
    user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install -y nginx
                sudo apt install -y git
                curl -fsSL https://deb.nodesource.com/setup_current.x | sudo -E bash -
                sudo apt install -y nodejs
                curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
                export NVM_DIR="$HOME/.nvm"
                [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
                [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
                nvm install node
                wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
                echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
                sudo apt-get update
                wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb
                sudo dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb
                sudo apt-get install -y mongodb-org               
                export DB_HOST=mongodb://172.31.61.32:27017/posts
                sudo systemctl enable nginx
                sudo systemctl start nginx
                git clone https://github.com/AmeenahRiffin/tech501-sparta-app/
                mv tech501-sparta-app/* ./
                cd app
                npm install
                sudo npm install -g pm2
                pm2 start app.js
                sudo sed -i 's|try_files.*|proxy_pass http://127.0.0.1:3000;|' /etc/nginx/sites-available/default
                sudo systemctl restart nginx
                EOF
}

output "sparta_app_public_ip" {
    description = "Public IP of Sparta App server"
    value       = aws_instance.sparta_app.public_ip
}

resource "aws_security_group" "ameenah-sparta-app-sg" {
    name        = "sparta-${var.owner_name}-app-sg"
    description = "Allow HTTP and SSH access for two tier deployment."
    vpc_id      = "vpc-07e47e9d90d2076da"  # Default VPC

    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }
}

