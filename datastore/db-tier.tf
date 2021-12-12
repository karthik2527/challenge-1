resource "aws_db_subnet_group" "dbtier-subnet-group" {
  name       = "db-tier-subnet-group"
  subnet_ids = [var.private_subnet1, var.private_subnet2]

  tags = {
    Name = "RDS subnet private subnet group"
  }
}


resource "aws_db_parameter_group" "dbtier-parameter-group" {
  name   = "db-tier-parameter-group"
  family = "postgres13"

  parameter {
    name  = "track_functions"
    value = "all"
  }
}



resource "aws_db_instance" "dbtier-database" {
  identifier = "webappdb"
  allocated_storage    = 10
  engine               = var.database_engine
  engine_version       = var.database_engine_version
  instance_class       = var.database_instance_size
  name                 = "webdatabase"
  publicly_accessible = false
  parameter_group_name = aws_db_parameter_group.dbtier-parameter-group.name
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.dbtier-subnet-group.name
  username = "database_admin"
  password = "changeme"
  vpc_security_group_ids = [var.db_security_groups]
}
