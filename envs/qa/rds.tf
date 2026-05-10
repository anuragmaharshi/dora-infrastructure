resource "aws_db_subnet_group" "main" {
  name        = "dora-qa-db-subnet-group"
  description = "Subnet group for dora-qa RDS — uses both public subnets. RDS is not publicly accessible; ECS tasks reach it via security group rule."
  subnet_ids  = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  tags = {
    Name        = "dora-qa-db-subnet-group"
    Environment = "qa"
    Project     = "dora"
  }
}

resource "aws_db_instance" "postgres" {
  identifier        = "dora-qa-postgres"
  engine            = "postgres"
  engine_version    = "15"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp2"

  db_name  = "dora"
  username = "dora"
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible    = false
  multi_az               = false
  skip_final_snapshot    = true
  deletion_protection    = false
  apply_immediately      = true

  backup_retention_period = 0

  tags = {
    Name        = "dora-qa-postgres"
    Environment = "qa"
    Project     = "dora"
  }
}
