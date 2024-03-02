## Docker Commands1
### Local Run

* docker build -t flask_app .
* docker run -p 5000:5000 flask_app
* http://localhost:5000 or http://[::1]:5000/

### ECR Deployment

* aws ecr get-login-password --region 'us-east-1' | docker login --username AWS --password-stdin 153295639067.dkr.ecr.us-east-1.amazonaws.com
* docker tag flask_app:latest 153295639067.dkr.ecr.us-east-1.amazonaws.com/flask_deployment-prod-ecr:latest
* docker push 153295639067.dkr.ecr.us-east-1.amazonaws.com/flask_deployment-prod-ecr:latest

## Terraform Commands
* terraform init
* terraform apply
* terraform destroy

## ipv4 vs ipv6
internet protocol version 4 allows for internet addresses that are 32 bit while ipv6 allows internet addresses that are 128 bits. ipv4 allosws at most 3.5 billions internet addresses and it is at its almost at its cap. However, 70 percent of traffic is still ipv4. When your device connect to the internet, it obtains both ipv4 from ISP and ipv6 from DHCP centers. ipv4 and ipv6 change over time. Now your device tries to connect to a website. if the website support ipv6 then your connection will be ipv6. Your device prefers ipv6 connections over ipv4 if 1- your device supports it 2- your router supports it 3- your internet provider supports it 4- your destination website supports it

your device in the beginning 

## VPC
when you launch your your application, virtual private cloud allow you to isolate your network from other vpcs. it gives you a lot of freedom over your network customization. you can specify port range or you can select your own ip.

within vpc you probabaly need multiple subnets. you want for example a public subnet (where instances could be accesses from the internet) and a private subnet that your backend services could use to interact with each other. 

your security group inbound rules defines the traffic that is allowed to reach your instance (e.g., HTTP on port 80 and HTTPS on port 443) and outbound rule defines the traffic that is allowed to leave your instance (you can set it to traffic all, and protocol all and port range all). 

if you want your security group to allow public internet access. add inbound rules
* type: Custom TCP, protocol: tcp, port: 5000 (if it is a flask application), source ::/0 for ipv6 and 0.0.0.0/0 for ipv4. you should add both sources

if you need public access to your vpc, you need to add an internet gateway. internet gateway is the bridge between your vpc and the internet. After you create your internet gatewayyou need to 
- attach your vpc to your internte gateway. 
- go to route table and make sure that the subnet that is supposed to have access to internet gateway is configure properly to that internet gateway.
