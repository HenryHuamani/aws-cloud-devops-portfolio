# Technical Notes – Amazon EC2

## What is Amazon EC2?

Amazon Elastic Compute Cloud (EC2) is an AWS service that provides resizable virtual servers in the cloud.

EC2 allows organizations to deploy applications and workloads without purchasing or maintaining physical servers.

## Main EC2 Components

### EC2 Instance

An EC2 instance is a virtual server running inside AWS.

An instance includes:

* Virtual CPU
* Memory
* Network interfaces
* Operating system
* Storage
* Security configuration

### Amazon Machine Image

An Amazon Machine Image (AMI) is a template used to launch EC2 instances.

An AMI may include:

* Operating system
* Preinstalled applications
* System configuration
* Launch permissions
* Block device mappings

Examples:

* Ubuntu Server
* Amazon Linux
* Windows Server
* Red Hat Enterprise Linux

### Instance Type

The instance type defines the computing capacity assigned to the EC2 instance.

It determines:

* Number of virtual CPUs
* Available memory
* Network performance
* Storage options

For this laboratory, a Free Tier eligible instance type was selected.

### Key Pair

A key pair provides secure authentication for Linux EC2 instances.

It consists of:

* Public key stored by AWS
* Private key downloaded by the administrator

The private key must never be shared or uploaded to a public repository.

### Security Group

A Security Group is a stateful virtual firewall associated with an EC2 instance or network interface.

It controls:

* Inbound traffic
* Outbound traffic
* Protocols
* Ports
* Allowed source addresses

In this laboratory, SSH access through TCP port 22 was restricted to the administrator's public IP address.

### Elastic Block Store

Amazon Elastic Block Store (EBS) provides persistent block storage for EC2 instances.

EBS volumes can store:

* Operating system files
* Application data
* Logs
* Databases

Data stored on an EBS volume can persist when the instance is stopped.

### Public IP Address

A public IP address allows communication with an EC2 instance over the Internet.

The default public IPv4 address may change when the instance is stopped and started.

### Elastic IP Address

An Elastic IP is a static public IPv4 address allocated to an AWS account.

It remains assigned until it is explicitly released.

## EC2 Instance Lifecycle

```text
Pending
   ↓
Running
   ↓
Stopping
   ↓
Stopped
   ↓
Terminated
```

### Stop

The instance is powered off, but the configuration and supported EBS volumes remain available.

### Start

A stopped instance is powered on again.

### Reboot

The operating system is restarted without changing the instance configuration.

### Terminate

The instance is permanently deleted.

## SSH Access

Secure Shell (SSH) is the protocol used to connect securely to Linux servers.

The connection requires:

* Reachable public IP or DNS name
* Security Group rule allowing TCP port 22
* Correct operating-system username
* Correct private key
* Secure permissions on the private key file

## Laboratory Configuration

The following configuration was used:

* Operating system: Ubuntu Server
* Authentication: SSH key pair
* Access port: TCP 22
* Security Group source: administrator public IP
* Client: OpenSSH for Windows
* Terminal: PowerShell

## Security Considerations

* Do not expose SSH to `0.0.0.0/0` unless strictly required.
* Never upload private keys to GitHub.
* Prefer IAM roles instead of static AWS credentials inside EC2.
* Keep the operating system updated.
* Remove unused Security Group rules.
* Use Systems Manager Session Manager when appropriate.
