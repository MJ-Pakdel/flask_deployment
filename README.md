## Docker Commands
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

## session_id, device_id and ip_address
http requests have different component. Header is always populated and one of the component of header is User-Agent which has data such as ip address. So the ip of the client always is always known for the website. of cource the user can uses the vpn and in that case the website knows the ip addess of the vpn server. However, ip address is not reliable for identifing the user since it can change even within the same session if the user is using mobile networks or vpns. 

To identify the user within the same session, host uses cookies. one of the infomation in the cookies is session_id. when you reach out to the website and you accept that host to collect cookies on you, host website tells browser what info needs to be collected as cookies. session_id is always one of those cookies. another thing might be for example your state of interest (things in your shopping cart). cookies are stored on your browser. they are used so host webiste reconize you within the same sessioin, so if you send 10 requests to the host website, all of them will have cookies. The life of cookies are short . the moment you close the browser, cookies disappear. so session_id cannot be used to identify the user if user uses the website tommorrow. 

if we want to identify recurrning user, host website needs to ask browser to log devide_id as part of the cookies. Regulations to collect devide_ids are a bit harder. 

update:
ios and chrome never allow website to collect device_id as part of the cookies even if the user aggrees to cookies. website used a technique called fingerprinting to which is a combination of data such as ip address, browser attributes, os attributes, font of the client etc to identify recurring user. it is not 100% accurate like device id but it is good enough. 
## VPC
when you launch your your application, virtual private cloud allow you to isolate your network from other vpcs. it gives you a lot of freedom over your network customization. you can specify port range or you can select your own ip. You cannot launch some services without attaching to a vpc and a subnet such as launching ec2, fargate, managed airflow, or rds

within vpc you probabaly need multiple subnets. you want for example a public subnet (where instances could be accesses from the internet) and a private subnet that your backend services could use to interact with each other. 

for launching microservices (an app that does only one job and is independent from other services, it has for example its own rds), you need 
1. **SUBNET**:  
subnets allow you to have different protocols inside your vpc. For example you usually need multiple subnets. Maybe one subnet that allows public access through the internet and another subnet that allows your backend services to interact with each other.  
2. **SUCURITY GROUP**:  
for the security group you need inbound rule and outbound rule. You need one security group for your ecs task and anohter security group for your application load balancer. Each security group has inbound rule and outbound rule. for example your ecs sucurity group inbound rule might say that traffic from any ip address can access the app as long as it is from port 5000 and it talks to port 5000 within the container. outbound rule can enable outgoing traffic from any port to any port and and destination (ip) addresses. So your ecs task and application load balancer need to connect to corresponding security groups. 
3. **INTERNET GATEWAY OR NAT GATEWAY**: If you need public access to your app you need to define an internet gateway that is the bridge between your app and the internet. you need to attach your vpc to that internet gateway. Nat gateway on the other hand Allows resources in private subnets to initiate outbound internet traffic (e.g., for software updates) without receiving inbound traffic from the internet. Your vpc need to attach to both interntet gateway and nat gateway.
4. **ROUTE TABLE**: After you define your internet gateway for example, you need your route table map traffic from any public ip addresses to the internet gateway. That is why that after creating the routetable, make sure that for example subnet with public access is attached to the route table with public access and subnet with private backend access is attached to the route table with private route table

## Application Load Balancer:
You launch an ecs task. You decide for example cpu is 256 and ram is 512. A load balancer has two importance usecases
* makes your app scalable: it scales out your tasks when traffic increases. so you will have 10 seperate cpus with 10 isolated tasks. it distribute traffic from unhealthy to healthy tasks. 
* You can use it for blue green deployment (minimizes down time and risk by having two identical production enviornment) load balancer allows you dedicate 80% of traffic to the blue (old enviornmetn) and 20% of traffic to the green (new enviornment) and you can gradually change it.  

## WSS FARGATE:
it is serverless compute engine for containers. AWS fargate can support both ecs and eks (elastic kubernetes service). it means when you go to elastic kubernetes service in AWS, AWS fargate is an option for you. Fargate is like databricks. you just say I want this cpu and ram but you no longer need to own and manage cpus themselves. Remember that fargate by itself does not scale out like databricks does. For scaling out you need to put an application load balancer in front of it. 

## EKS:
Remember that Kubernetes is a container mangement service exactly like ecs.
the coice between ecs and eks comes down to 
* epertise required: ecs requires less expertise and eks requires more
* app simplicity: if app is simple, ecs might be enough and you can launch it quickly. for sophisticated apps, eks gives you higher flexibility
* agnosticity: kubernetes is cloud agnostic so you can easily migrate your code from aws to gcp. very simple.  



