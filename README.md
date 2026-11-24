
## Infrastructure as Code with Terraform & Configuration Management with Ansible

## 1. Project Overview

This project demonstrates the deployment of a multi-tier Java web application on AWS using **Terraform** for infrastructure provisioning and **Ansible** for configuration management and application deployment.

The main objective is to automate the infrastructure setup and application deployment while following AWS networking and security best practices.

### Technologies Used

- **AWS:** EC2, VPC, Subnets, Security Groups, Application Load Balancer
- **Terraform:** Infrastructure as Code (IaC)
- **Ansible:** Configuration Management and Automation
- **Linux:** Ubuntu 24.04 LTS
- **Java:** OpenJDK 17
- **Maven:** Application Build
- **Tomcat 9:** Java Application Server
- **Nginx:** Reverse Proxy
- **MariaDB:** Relational Database
- **Memcached:** Caching Service
- **RabbitMQ:** Message Broker (planned)
- **Git:** Source Code Management

---

## 2. Architecture

The application follows a multi-tier architecture with a public-facing application entry point and private backend services.

### Architecture Components

**Public Tier**

- Application Load Balancer (ALB)
- Application EC2 Instance
- Nginx Reverse Proxy
- Tomcat 9 Application Server

**Private Tier**

- MariaDB Database Server
- RabbitMQ Message Broker
- Memcached Cache Server

### Application Request Flow

```text
                    Internet
                       |
                       |
              Application Load
                  Balancer
                       |
                       | HTTP :80
                       |
                 App EC2
                  Public
                       |
                    Nginx
                     :80
                       |
                    Tomcat
                     :8080
                       |
                VProfile Application
                       |
          +------------+------------+
          |            |            |
          |            |            |
       MariaDB      RabbitMQ     Memcached
        :3306         :5672        :11211
          |            |            |
          +------------+------------+
                  Private Tier
```

### AWS Network Design

- Existing AWS VPC: `vpc-0e5815b97f142c6e6`
- Region: `us-east-1` (N. Virginia)
- Public subnet: Application EC2
- Private subnet: Backend EC2 instances
- Application Load Balancer: Public-facing entry point
- Backend services: Accessible through private networking only

---

## 3. Infrastructure Provisioning with Terraform

Terraform is responsible for provisioning the AWS infrastructure.

### Infrastructure Resources

- AWS networking configuration using the existing VPC and subnets.
- EC2 instances for application and backend services.
- Security Groups for controlling inbound and outbound traffic.
- Application Load Balancer.
- Target Group.
- HTTP Listener.

### EC2 Instances

| Instance         | Role                                | Network |
| ---------------- | ----------------------------------- | ------- |
| App Server       | Nginx, Tomcat, Ansible Control Node | Public  |
| MariaDB Server   | Database                            | Private |
| RabbitMQ Server  | Message Broker                      | Private |
| Memcached Server | Caching                             | Private |

### Security Group Rules

| Component   |  Port | Allowed Source                    |
| ----------- | ----: | --------------------------------- |
| ALB         |    80 | Internet                          |
| ALB         |   443 | Internet (if HTTPS is configured) |
| App EC2     |    80 | ALB Security Group                |
| App EC2     |    22 | Administrator IP                  |
| MariaDB     |  3306 | App EC2 Security Group            |
| RabbitMQ    |  5672 | App EC2 Security Group            |
| Memcached   | 11211 | App EC2 Security Group            |
| Backend SSH |    22 | App EC2 Security Group            |

Backend services are not directly exposed to the public internet.

### Terraform Deployment

Navigate to the Terraform project directory:

```bash
cd terraform/
```

Initialize Terraform:

```bash
terraform init
```

Validate the configuration:

```bash
terraform validate
```

Review the execution plan:

```bash
terraform plan
```

Provision the infrastructure:

```bash
terraform apply
```

Review the infrastructure:

```bash
terraform show
```

**Important:** Do not commit Terraform state files, private keys, or sensitive variables to GitHub.

---

## 4. Ansible Configuration Management

Ansible is installed on the Application EC2 instance, which acts as the Ansible Control Node.

The App EC2 instance is also responsible for hosting the VProfile application.

Ansible connects to the private backend EC2 instances through SSH using the application server as the control node.

### Ansible Project Structure

```text
ansible/
│
├── ansible.cfg
│
├── inventory/
│   └── hosts
│
├── group_vars/
│   ├── backend.yml
│   └── database.yml
│
└── playbooks/
    ├── mariadb.yml
    ├── memcached.yml
    ├── rabbitmq.yml
    └── app.yml
```

### Ansible Configuration

The `ansible.cfg` file:

```ini
[defaults]
inventory = ./inventory/hosts
remote_user = ubuntu
private_key_file = /home/ubuntu/app-key.pem
host_key_checking = False
retry_files_enabled = False
```

### Inventory Configuration

The `inventory/hosts` file:

```ini
[database]
mariadb ansible_host=10.0.139.42

[message_broker]
rabbitmq ansible_host=10.0.134.175

[cache]
memcached ansible_host=10.0.131.220

[backend:children]
database
message_broker
cache
```

### Test Ansible Connectivity

```bash
ansible backend -m ping
```

Check privilege escalation:

```bash
ansible backend -m command -a "whoami" -b
```

---

## 5. Backend Configuration Playbooks

### 5.1 MariaDB Configuration

Playbook: `playbooks/mariadb.yml`

Responsibilities:

- Install MariaDB Server.
- Install Python MySQL dependencies.
- Configure the MariaDB root password.
- Remove anonymous users.
- Remove the test database.
- Create the application database (`accounts`).
- Create the application database user.
- Configure remote database connectivity.
- Import the VProfile SQL database backup.

Database Configuration:

| Parameter | Value    |
| --------- | -------- |
| Database  | accounts |
| Username  | admin    |
| Password  | admin123 |
| Port      | 3306     |

Execute:

```bash
ansible-playbook playbooks/mariadb.yml
```

### 5.2 Memcached Configuration

Playbook: `playbooks/memcached.yml`

Responsibilities:

- Install Memcached.
- Configure the listening address.
- Configure TCP port 11211.
- Configure UDP port 11111.
- Enable and start the Memcached service.

Execute:

```bash
ansible-playbook playbooks/memcached.yml
```

### 5.3 RabbitMQ Configuration

Playbook: `playbooks/rabbitmq.yml`

Planned responsibilities:

- Install Erlang.
- Install RabbitMQ.
- Enable and start the RabbitMQ service.
- Configure application credentials.
- Configure user permissions.

**Status:** RabbitMQ configuration is postponed and requires completion before the application can use messaging functionality.

---

## 6. Application Deployment with Ansible

Playbook: `playbooks/app.yml`

The application server is configured locally using Ansible.

```yaml
hosts: localhost
connection: local
become: yes
```

### 6.1 Install Dependencies

The playbook installs:

- OpenJDK 17
- Maven
- Git
- Nginx
- Curl

### 6.2 Clone Application Repository

Source repository:

[https://github.com/hkhcoder/vprofile-project](https://github.com/hkhcoder/vprofile-project)

The repository is cloned into:

```text
/root/vprofile-project
```

### 6.3 Configure application.properties

Before building the application, Ansible updates the database, caching, and messaging configuration.

Example configuration:

```properties
jdbc.url=jdbc:mysql://10.0.139.42:3306/accounts?useUnicode=true&characterEncoding=UTF-8&zeroDateTimeBehavior=convertToNull

jdbc.username=admin


memcached.active.host=10.0.131.220
memcached.active.port=11211

rabbitmq.address=10.0.134.175
rabbitmq.port=5672
rabbitmq.username=test
rabbitmq.password=test
```

The application properties are updated before Maven packaging so that the generated WAR contains the correct environment configuration.

### 6.4 Build the Application

Maven is used to compile and package the application.

```bash
cd /root/vprofile-project

mvn clean package -DskipTests
```

The generated WAR file is located in:

```text
/root/vprofile-project/target/
```

### 6.5 Tomcat 9 Installation

The project uses `javax.servlet` dependencies, so Tomcat 9 is selected instead of Tomcat 10.

Tomcat is installed under:

```text
/opt/tomcat9
```

A dedicated Linux system user runs the Tomcat service.

### 6.6 Deploy the WAR

The generated WAR is deployed as:

```text
/opt/tomcat9/webapps/ROOT.war
```

Tomcat extracts the application into:

```text
/opt/tomcat9/webapps/ROOT/
```

Tomcat runs on port:

```text
8080
```

### 6.7 Nginx Reverse Proxy

Nginx is configured to receive HTTP requests on port 80 and forward them to Tomcat.

Configuration:

```nginx
upstream vproapp {
    server 127.0.0.1:8080;
}

server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://vproapp;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

The Nginx configuration is stored in:

```text
/etc/nginx/sites-available/vproapp
```

The enabled configuration is linked under:

```text
/etc/nginx/sites-enabled/vproapp
```

---

## 7. Application Deployment Execution

Run the application playbook:

```bash
cd /root/ansible

ansible-playbook playbooks/app.yml
```

The playbook automates:

1. Installing application dependencies.
2. Cloning the GitHub repository.
3. Updating application configuration.
4. Building the WAR using Maven.
5. Installing and configuring Tomcat 9.
6. Deploying the generated WAR.
7. Configuring Nginx.
8. Starting and enabling services.

---

## 8. Validation and Testing

### Check Backend Services

On the respective backend EC2 instances:

```bash
sudo systemctl status mariadb
sudo systemctl status memcached
```

RabbitMQ should also be checked after its configuration is completed.

### Test Database Connectivity

From the Application EC2:

```bash
mysql -h 10.0.139.42 -u admin -p accounts
```

### Test Memcached Connectivity

```bash
nc -zv 10.0.131.220 11211
```

### Test RabbitMQ Connectivity

```bash
nc -zv 10.0.134.175 5672
```

### Check Tomcat

```bash
sudo systemctl status tomcat9
```

Check application logs:

```bash
sudo tail -f /opt/tomcat9/logs/catalina.out
```

### Check Nginx

```bash
sudo systemctl status nginx
```

Validate Nginx configuration:

```bash
sudo nginx -t
```

### Test Application Locally

```bash
curl -I http://localhost:8080
```

Test through Nginx:

```bash
curl -I http://localhost
```

### Access the Application

Open the Application Load Balancer DNS name in a browser:

```text
http://<ALB-DNS-NAME>
```

---

## 9. Project Security Considerations

- Backend EC2 instances are deployed in private subnets.
- Security Groups restrict backend access to the Application EC2 Security Group.
- SSH access is restricted to authorized sources.
- Database and application credentials should be stored securely using Ansible Vault.
- Terraform state files and private SSH keys must not be committed to GitHub.
- HTTPS should be configured on the ALB using an AWS Certificate Manager certificate for production deployments.

---

## 10. Current Project Status

| Component                 | Status                        |
| ------------------------- | ----------------------------- |
| Terraform Infrastructure  | Provisioned                   |
| AWS VPC and Subnets       | Existing infrastructure       |
| Application Load Balancer | Configured                    |
| EC2 Instances             | Provisioned                   |
| Ansible Control Node      | Configured                    |
| Ansible Inventory         | Configured                    |
| MariaDB Playbook          | Executed                      |
| Memcached Playbook        | Executed                      |
| RabbitMQ Playbook         | Postponed                     |
| Java and Maven Build      | WAR generated successfully    |
| Tomcat 9                  | Installation initiated        |
| Nginx Reverse Proxy       | Deployment pending validation |
| VProfile Application      | Deployment pending validation |
| End-to-End Testing        | Pending                       |

---

## 11. Key Learning Outcomes

Through this project, I practiced:

- Designing a multi-tier architecture on AWS.
- Provisioning cloud infrastructure using Terraform.
- Managing public and private network resources.
- Implementing Security Group restrictions.
- Configuring backend services using Ansible.
- Automating application builds with Maven.
- Deploying Java applications on Apache Tomcat.
- Configuring Nginx as a reverse proxy.
- Managing application configuration across multiple infrastructure tiers.
- Troubleshooting Linux services and network connectivity.

---

## Conclusion

This project demonstrates an automated approach to deploying a multi-tier Java application on AWS by combining Terraform and Ansible.

Terraform handles infrastructure provisioning, while Ansible automates server configuration and application deployment.

The architecture separates the application layer from backend services, providing a foundation for a secure, maintainable, and scalable cloud environment.
