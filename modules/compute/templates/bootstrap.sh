#!/bin/bash

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a /var/log/bootstrap/bootstrap.log
}

# Create log directory
mkdir -p /var/log/bootstrap
log_message "Starting bootstrap process"

# Update system packages
log_message "Updating system packages"
yum update -y

# Install required packages
log_message "Installing required packages"
yum install -y \
    awscli \
    docker \
    git \
    python3 \
    python3-pip \
    mysql \
    jq \
    amazon-cloudwatch-agent

# Start and enable Docker
log_message "Starting Docker service"
systemctl start docker
systemctl enable docker

# Install Docker Compose
log_message "Installing Docker Compose"
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Create application log directory
mkdir -p /var/log/app
log_message "Created application log directory"

# Create test application log
echo "Test application log $(date)" | tee -a /var/log/app/test.log
log_message "Created test application log"

# Set up CloudWatch agent configuration
log_message "Setting up CloudWatch agent configuration"
mkdir -p /opt/aws/amazon-cloudwatch-agent/etc/

cat << EOF > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
    "agent": {
        "metrics_collection_interval": 60,
        "run_as_user": "root",
        "logfile": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log",
        "debug": false,
        "region": "us-west-2"
    },
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/bootstrap/bootstrap.log",
                        "log_group_name": "/ec2/bootstrap",
                        "log_stream_name": "{instance_id}",
                        "timezone": "UTC"
                    },
                    {
                        "file_path": "/var/log/amazon/amazon-cloudwatch-agent/amazon-cloudwatch-agent.log",
                        "log_group_name": "/ec2/cloudwatch-agent",
                        "log_stream_name": "{instance_id}",
                        "timezone": "UTC"
                    },
                    {
                        "file_path": "/var/log/app/*.log",
                        "log_group_name": "/ec2/app",
                        "log_stream_name": "{instance_id}/{file_name}",
                        "timezone": "UTC"
                    }
                ]
            }
        }
    },
    "metrics": {
        "metrics_collected": {
            "cpu": {
                "measurement": [
                    "cpu_usage_idle",
                    "cpu_usage_user",
                    "cpu_usage_system"
                ],
                "metrics_collection_interval": 60,
                "totalcpu": true
            },
            "disk": {
                "measurement": [
                    "used_percent",
                    "free",
                    "total",
                    "used"
                ],
                "metrics_collection_interval": 60
            },
            "mem": {
                "measurement": [
                    "mem_used_percent",
                    "mem_available",
                    "mem_total",
                    "mem_used"
                ],
                "metrics_collection_interval": 60
            },
            "swap": {
                "measurement": [
                    "swap_used_percent",
                    "swap_free",
                    "swap_used"
                ],
                "metrics_collection_interval": 60
            }
        }
    }
}
EOF

# Start and enable CloudWatch agent
log_message "Starting CloudWatch agent"
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s
systemctl start amazon-cloudwatch-agent
systemctl enable amazon-cloudwatch-agent

log_message "Bootstrap process completed successfully"
