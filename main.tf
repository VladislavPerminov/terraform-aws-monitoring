resource "aws_instance" "node_exporter" {
  ami           = "ami-00ac45f3035ff009e"
  instance_type = "t2.micro"
  key_name = "x"
  vpc_security_group_ids = [ aws_security_group.monitoring_sg.id ]
  user_data = templatefile("./install_prometheus_node_exporter.sh", {})

  tags = {
    Name = "exporter"
  }

  root_block_device {
    volume_size = 20
  }
}

resource "aws_instance" "prometheus" {
  ami           = "ami-00ac45f3035ff009e"
  instance_type = "t2.micro"
  key_name = "x"
  vpc_security_group_ids = [ aws_security_group.monitoring_sg.id ]
  user_data = templatefile("./install_prometheus_server_ubuntu.sh", {
    PROMETHEUS_FOLDER_CONFIG = "/etc/prometheus",
    PROMETHEUS_FOLDER_TSDATA = "/etc/prometheus/data"
  })


  tags = {
    Name = "prometheus"
  }

  root_block_device {
    volume_size = 20
  }
}
resource "aws_instance" "grafana" {
  ami           = "ami-00ac45f3035ff009e"
  instance_type = "t2.micro"
  key_name = "x"
  vpc_security_group_ids = [ aws_security_group.monitoring_sg.id ]
  user_data = templatefile("./install_grafana_server_ubuntu.sh", {
    GRAFANA_VERSION = "10.4.2",
    PROMETHEUS_URL  = "http://${aws_instance.prometheus.public_ip}:9090"
  })


  tags = {
    Name = "grafana"
  }

  root_block_device {
    volume_size = 20
  }
}
resource "aws_security_group" "monitoring_sg" {
  name        = "monitoring_sg"
  description = "Allow inbound traffic for Prometheus, Grafana and all outbound traffic"

  ingress = [
    for port in [22,443,80,3000,9100,9090]: {
        description = "unbound rules"
        from_port   = port
        to_port     = port
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = []
        prefix_list_ids  = []
        security_groups  = []
        self             = false
    }
   ]

   
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "monitoring_sg"
  }
}


