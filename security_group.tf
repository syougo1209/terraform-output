module "http_sg" {
  source      = "./modules/security_group"
  name        = "http-sg"
  vpc_id      = aws_vpc.aisk_prd.id
  port        = 80
  cidr_blocks = ["0.0.0.0/0"]
}

module "https_sg" {
  source      = "./modules/security_group"
  name        = "https-sg"
  vpc_id      = aws_vpc.aisk_prd.id
  port        = 443
  cidr_blocks = ["0.0.0.0/0"]
}

module "http_redirect_sg" {
  source      = "./modules/security_group"
  name        = "http-redirect-sg"
  vpc_id      = aws_vpc.aisk_prd.id
  port        = 8080
  cidr_blocks = ["0.0.0.0/0"]
}

module "nginx_sg" {
  source      = "./security_group"
  name        = "nginx-sg"
  vpc_id      = aws_vpc.aisk_prd.id
  port        = 80
  cidr_blocks = [aws_vpc.aisk_prd.cidr_block]
}

module "mysql_sg" {
  source      = "./security_group"
  name        = "mysql-sg"
  vpc_id      = aws_vpc.aisk_prd.id
  port        = 3306
  cidr_blocks = [aws_vpc.aisk_prd.cidr_block]
}
