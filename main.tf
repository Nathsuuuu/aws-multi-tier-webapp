
 AWS Multi-Tier Web App Deployment (Terraform)
 Region: ap-southeast-2 (Sydney)


 --- PROVIDER CONFIGURATION ---
provider "aws" {
  region = "ap-southeast-2"
}


 1. VPC SETUP

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}


 2. SUBNETS (Public + Private)

 Public Subnet
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-southeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-a"
  }
}

 Private Subnet A
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-southeast-2a"

  tags = {
    Name = "private-subnet-a"
  }
}

 Private Subnet B
resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-southeast-2b"

  tags = {
    Name = "private-subnet-b"
  }
}


 3. INTERNET GATEWAY + ROUTE TABLE

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}


 4. SECURITY GROUPS

 Web Server SG (for EC2)
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}

 Database SG (for RDS)
resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  description = "Allow MySQL from web subnet"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "MySQL from web_sg"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db-sg"
  }
}


 5. EC2 INSTANCE (Web Server)

resource "aws_instance" "web" {
  ami                         = "ami-0df609f69029c9bdb"  Amazon Linux 2 in ap-southeast-2
  instance_type               = "t3.micro"  Free Tier eligible
  subnet_id                   = aws_subnet.public_a.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true
  key_name                    = "my-key"  🔑 Replace with your actual key

  user_data = <<-EOF
              !/bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              echo "<h1>Deployed with Terraform!</h1>" > /var/www/html/index.html
              sudo systemctl enable httpd
              sudo systemctl start httpd
              EOF

  tags = {
    Name = "web-server"
  }
}


 6. RDS DATABASE (MySQL)

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db-subnet-group"
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  tags = {
    Name = "db-subnet-group"
  }
}

resource "aws_db_instance" "app_db" {
  identifier             = "mydb-instance"
  allocated_storage      = 20
  db_name                = "mydb"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"  Free Tier eligible in Sydney
  username               = "admin"
  password               = "password123!"
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false

  tags = {
    Name = "mydb-instance"
  }
}


 END OF CONFIGURATION


