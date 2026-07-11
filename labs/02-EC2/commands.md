# Commands – Amazon EC2 Laboratory

## Connect to the EC2 Instance

```powershell
ssh -i .\henry-key.pem ubuntu@PUBLIC_DNS
```

Example:

```powershell
ssh -i .\henry-key.pem ubuntu@ec2-example.compute.amazonaws.com
```

Do not publish the private key or use a real public address in documentation when it is unnecessary.

## Enable Detailed SSH Output

```powershell
ssh -vvv -i .\henry-key.pem ubuntu@PUBLIC_DNS
```

The `-vvv` option displays detailed diagnostic information about the SSH connection.

## Review Key Permissions in Windows

```powershell
icacls .\henry-key.pem
```

## Remove Inherited Permissions

```powershell
icacls .\henry-key.pem /inheritance:r
```

## Remove Access for Authenticated Users

```powershell
icacls .\henry-key.pem /remove "NT AUTHORITY\Authenticated Users"
```

## Remove Access for the Built-in Users Group

```powershell
icacls .\henry-key.pem /remove "BUILTIN\Usuarios"
```

The group name may appear as `BUILTIN\Users` on English Windows installations.

## Grant Read Permission to the Owner

```powershell
icacls .\henry-key.pem /grant "DESKTOP-MTQQR2P\PC:(R)"
```

Replace the computer and user name according to the local environment.

## Verify the Current Linux User

```bash
whoami
```

## Display the Hostname

```bash
hostname
```

## Display the Current Directory

```bash
pwd
```

## List Files and Directories

```bash
ls
```

## Display Operating-System Information

```bash
cat /etc/os-release
```

## Display CPU Information

```bash
lscpu
```

## Display Memory Usage

```bash
free -h
```

## Display Disk Usage

```bash
df -h
```

## Display IP Configuration

```bash
ip address
```

## Update Package Information

```bash
sudo apt update
```

## Install Available Package Updates

```bash
sudo apt upgrade -y
```

## Exit the SSH Session

```bash
exit
```
