module "stage" {
  source = "../01_module" //01module 을 가리킴

  region      = "ap-northeast-2"
  cidr        = "0.0.0.0/0"
  cidr_v6     = "::/0"
  cidr_main   = "10.0.0.0/16"
  name        = "Explorer"
  avazone     = ["a","c"]
  key         = "test"
  public_s    = ["10.0.0.0/24", "10.0.2.0/24"]
  private_s   = ["10.0.1.0/24", "10.0.3.0/24"]
  private_dbs = ["10.0.4.0/24", "10.0.5.0/24"]
  private_ip  = "10.0.2.11"
  private_bastionip = "10.0.0.10"
  
  tomcat_port                   = 8080
  ssh_port                      = 60022
  http_port                     = 80
  mysql_port                    = 63306
  rds_mysql_port                = "63306"
  zero_port                     = 0
  under_port                    = -1
  prot_tcp                      = "tcp"
  prot_http                     = "http"
  prot_icmp                     = "icmp"
  prot_ssh                      = "ssh"
  prot_sql                      = "sql"
  instance                      = "t3.medium"
  instance_t2                   = "t2.micro"
  load_type                     = "application"
  load_internal                 = false
  health_enabled                = true
  health_threshold              = 2
  health_interval               = 5
  health_matcher                = "200"
  health_path                   = "/"
  prot_HTTP                     = "HTTP"
  health_prot                   = "traffic-port"
  health_timeout                = 2
  health_unhealthy_threshold    = 2
  lb_listner_action_type        = "forward"
  lacf_iam                      = "admin_role"
  pg_strategy                   = "cluster"
  auto_min                      = 2
  auto_max                      = 8
  auto_healthcheck_grace_period = 300
  auto_healthcheck_type         = "ELB"
  auto_desired_capacity         = 2
  auto_force_delete             = true
  db_storage                    = 20
  db_storage_type               = "gp2"
  db_engine                     = "mysql"
  db_engine_version             = "8.0"
  db_instacnce_class            = "db.t2.micro"
  db_name                       = "petclinic"
  db_identifier                 = "petclinic"
  db_username                   = "root"
  db_password                   = "petclinic"
  db_parameter_group_name       = "default.mysql8.0"
  db_avazone                    = "ap-northeast-2a"
  db_snapshot                   = true
  ami                           = "ami-0f8b8babb98cc66d0"
}
