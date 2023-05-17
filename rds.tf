resource "aws_db_instance" "default" {
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  username             = "testdb"
  password             = random_password.password.result
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  db_subnet_group_name        = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.test_app_rds.id]
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_db_subnet_group" "default" {
  name       = "main1"
  subnet_ids = toset(module.vpc.private_subnets)

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_security_group" "test_app_rds" {
  name        = "test-app-sg-rds"
  description = "Allow 3306 port inbound traffic"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "allow_mysql_ingress" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = aws_security_group.test_app.id
  security_group_id = aws_security_group.test_app_rds.id
}