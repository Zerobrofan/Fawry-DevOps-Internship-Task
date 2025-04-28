# DNS/Network Troubleshooting Guide 📕
This guide outlines the steps to troubleshoot, verify, and restore connectivity to an internal web service that is suddenly unreachable.

## Troubleshooting Steps 📝

### 1. Verify DNS Resolution

Compare resolution from system DNS servers vs. public DNS (8.8.8.8):

```bash
# Check current DNS servers
cat /etc/resolv.conf

# Resolve using system DNS
host internal.example.com
# or
nslookup internal.example.com

# Resolve using Google's DNS
host internal.example.com 8.8.8.8
# or
nslookup internal.example.com 8.8.8.8

# More detailed query with dig
dig internal.example.com @8.8.8.8
```

### 2. Diagnose Service Reachability

Check if the web service is actually reachable:

```bash
# HTTP check
curl -v http://internal.example.com
# or by IP if DNS is the issue
curl -v http://[resolved-ip-address]

# HTTPS check
curl -v https://internal.example.com

# TCP connection test
telnet internal.example.com 80
# or 
nc -vz internal.example.com 80

# SSL handshake verification
openssl s_client -connect internal.example.com:443

# Check locally running services
ss -tulpn | grep -E ':(80|443)'
```
### Screenshot of Steps 1 & 2 📷
![verify and diagnose](https://github.com/user-attachments/assets/5f1050f4-5642-4eff-bf80-00f33db16773)

### 3. Potential Causes

#### DNS Resolution Issues:
- Local DNS server is down or not responding
- Missing or incorrect DNS record for internal.example.com
- Incorrect nameservers in /etc/resolv.conf
- DNS caching issues (stale records)
- Split-horizon DNS misconfiguration
- Internal domain not in DNS search path

#### Network Connectivity Issues:
- Firewall blocking access to port 80/443
- Broken network route to the server
- Proxy settings interference
- VPN issues for internal resources
- Network interface configuration problems

#### Service Issues:
- Web server not running or crashed
- Web server listening on unexpected port
- Incorrect virtual host configuration
- SSL certificate issues
- Server-side blocking or rate limiting

#### Client-specific Issues:
- Incorrect entries in local /etc/hosts
- Local firewall rules
- Browser cache/DNS cache issues

### 4. Solutions for Common Issues

#### DNS Issues:

**Missing/Incorrect DNS Record**
```bash
# On the DNS server:
nsupdate
> server your-dns-server
> zone example.com
> update add internal.example.com 3600 A 192.168.1.100
> send
> quit
```
**Screenshot 📷**
![Missing DNS record issue a](https://github.com/user-attachments/assets/f7f433ed-4e4d-4a66-8f4e-934c38ff1100)


**Incorrect DNS Servers**
```bash
# Edit resolv.conf (temporary fix)
sudo nano /etc/resolv.conf
# Add: nameserver 192.168.1.53

# For permanent fix with NetworkManager
sudo nano /etc/NetworkManager/conf.d/dns.conf
# Add:
# [main]
# dns=none

sudo nano /etc/NetworkManager/system-connections/your-connection.nmconnection
# Add under [ipv4] section:
# dns=192.168.1.53;8.8.8.8
# dns-search=example.com

sudo systemctl restart NetworkManager
```
**Screenshots 📷**
![b1](https://github.com/user-attachments/assets/3a7205e5-059c-47ec-9e0b-7b9e47e6a60a)
![b2](https://github.com/user-attachments/assets/87278baa-50ef-4a45-ae34-688a2785fed6)
![b3](https://github.com/user-attachments/assets/805a2fd9-119e-4d4d-9ed3-7ece15df1fc9)
![b4](https://github.com/user-attachments/assets/dc178d30-6440-4862-bdc7-6706a2203f2b)


#### Network Connectivity Issues:
**Routing Issues**
```bash
# Check route to server
traceroute internal.example.com
# Add specific route
sudo ip route add 192.168.1.0/24 via 192.168.0.1 dev eth0
```
**Screenshot 📷**
![routing issues](https://github.com/user-attachments/assets/0a985d9e-08bc-4b7c-b71c-5ed8bd930cba)


#### Service Issues:
**Web Server Not Running**
```bash
# Check if service is running
ssh admin@internal.example.com "systemctl status nginx"  # or apache2
# Check listening ports
ssh admin@internal.example.com "ss -tulpn | grep -E ':(80|443)'"
# Start the web service
ssh admin@internal.example.com "sudo systemctl start nginx"  # or apache2
```
**Screenshot 📷**
![web server not running](https://github.com/user-attachments/assets/a5f0e498-b120-4cf5-8a0c-90353c79386a)



### 5. Bonus: Local Testing with /etc/hosts

Bypass DNS temporarily:

```bash
# Add entry to /etc/hosts
sudo nano /etc/hosts
# Add: 192.168.1.100 internal.example.com

# Test resolution
getent hosts internal.example.com
```
**Screenshots 📷**
![Capture](https://github.com/user-attachments/assets/04e6db41-5a71-4a2a-b3f8-17b16cce69e8)
![Capture1](https://github.com/user-attachments/assets/ac1bf2c0-0119-4603-9e48-44481b75025f)

### Configure Persistent DNS Settings:

#### Using systemd-resolved:

```bash
sudo mkdir -p /etc/systemd/resolved.conf.d/
sudo nano /etc/systemd/resolved.conf.d/custom-dns.conf

# Add:
[Resolve]
DNS=192.168.1.53 8.8.8.8
Domains=example.com

sudo systemctl restart systemd-resolved
```
**Screenshots 📷**
![Capture](https://github.com/user-attachments/assets/a06ad672-659f-4849-989e-72371520ddb1)
![Capture1](https://github.com/user-attachments/assets/9d7a488d-ead3-457a-a556-d1314596c2de)
