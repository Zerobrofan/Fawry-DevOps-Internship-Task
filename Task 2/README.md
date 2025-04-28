# DNS/Network Troubleshooting Guide

This guide outlines the steps to troubleshoot, verify, and restore connectivity to an internal web service that is suddenly unreachable.

## Scenario

The internal web dashboard (hosted on `internal.example.com`) is suddenly unreachable from multiple systems. The service seems up, but users get "host not found" errors. This suggests a DNS or network misconfiguration issue.

## Troubleshooting Steps

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

#### Network Connectivity Issues:

**Firewall Blocking**
```bash
# Allow web traffic
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Make persistent
sudo netfilter-persistent save
```

**Routing Issues**
```bash
# Add specific route
sudo ip route add 192.168.1.0/24 via 192.168.0.1 dev eth0
```

#### Service Issues:

**Web Server Not Running**
```bash
# Start the web service
sudo systemctl start nginx  # or apache2
```

**Virtual Host Configuration**
```bash
# Check and fix config
sudo nano /etc/nginx/sites-enabled/internal.example.com
sudo nginx -t && sudo systemctl restart nginx
```

### 5. Bonus: Local Testing with /etc/hosts

Bypass DNS temporarily:

```bash
# Add entry to /etc/hosts
sudo nano /etc/hosts
# Add: 192.168.1.100 internal.example.com

# Test resolution
getent hosts internal.example.com
```

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

#### Using NetworkManager:

```bash
sudo nmcli connection modify "Your Connection" ipv4.dns "192.168.1.53 8.8.8.8"
sudo nmcli connection modify "Your Connection" ipv4.dns-search "example.com"
sudo nmcli connection down "Your Connection" && sudo nmcli connection up "Your Connection"
```

## Documentation Best Practices

When troubleshooting, always:
1. Document the issue with screenshots
2. Record each command used and its output
3. Note the specific changes made to resolve the issue
4. Test to confirm the solution works
5. Document the root cause and solution for future reference
