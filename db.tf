resource "aws_db_parameter_group" "aisk" {
  name   = "aisk"
  family = "mysql5.7"

  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
}

resource "aws_db_option_group" "aisk" {
  name                 = "aisk"
  engine_name          = "mysql"
  major_engine_version = "5.7"

  option {
    option_name = "MARIADB_AUDIT_PLUGIN"
  }
}

resource "aws_db_subnet_group" "aisk" {
  name       = "aisk"
  subnet_ids = [aws_subnet.private_0.id, aws_subnet.private_1.id]
}
resource "aws_db_instance" "aisk-db" {
  identifier                 = "aisk-db"
  engine                     = "mysql"
  engine_version             = "5.7.25"
  instance_class             = "db.t3.small"
  allocated_storage          = 20
  max_allocated_storage      = 100
  storage_type               = "gp2"
  username                   = "admin"
  password                   = "VeryStrongPassword!"
  publicly_accessible        = false
  backup_window              = "09:10-09:40"
  backup_retention_period    = 30
  maintenance_window         = "mon:10:10-mon:10:40"
  auto_minor_version_upgrade = false
  deletion_protection        = false
  skip_final_snapshot        = true
  port                       = 3306
  apply_immediately          = false
  vpc_security_group_ids     = [module.mysql_sg.security_group_id]
  parameter_group_name       = aws_db_parameter_group.aisk.name
  option_group_name          = aws_db_option_group.aisk.name
  db_subnet_group_name       = aws_db_subnet_group.aisk.name

  lifecycle {
    ignore_changes = [password]
  }
}
