# Node Exporter Installation & Setup

This repository contains instructions to install and configure **Prometheus Node Exporter** (v1.8.0) manually on Linux.

---

## 📦 Download & Extract

```bash
# Download the Node Exporter tarball from GitHub (v1.8.0 release - example)
wget https://github.com/prometheus/node_exporter/releases/download/v1.8.0/node_exporter-1.8.0.linux-amd64.tar.gz

# Extract the tarball
tar -xvzf node_exporter-1.8.0.linux-amd64.tar.gz

# Rename the extracted folder for simplicity
mv node_exporter-1.8.0.linux-amd64 node_exporter

# Move into the directory
cd node_exporter
```

---

## 👤 Create Node Exporter User

```bash
# Create a dedicated system user for Node Exporter (no login shell, no home dir)
useradd --no-create-home --shell /bin/false node_exporter
```

---

## 📂 Copy Binary

```bash
# Move the binary to a standard location
cp node_exporter /usr/local/bin/

# Assign correct ownership to the exporter user
chown node_exporter:node_exporter /usr/local/bin/node_exporter
```

---

## ⚙️ Systemd Service File

Create the service file:  
`/etc/systemd/system/node_exporter.service`

```ini
[Unit]
Description=Prometheus Node Exporter            # Service description
Wants=network-online.target                     # Ensure networking is up
After=network-online.target                     # Start only after network is ready

[Service]
User=node_exporter                              # Run as non-privileged user
Group=node_exporter                             # Security best practice
Type=simple                                     # Simple service type
ExecStart=/usr/local/bin/node_exporter \
  --web.listen-address=:9100                     # Port where exporter listens

[Install]
WantedBy=multi-user.target                      # Start service on boot (normal runlevel)
```

---

## 🚀 Start & Enable the Service

```bash
# Reload systemd to recognize the new service
systemctl daemon-reload

# Enable the service (start at boot)
systemctl enable node_exporter

# Start the service
systemctl start node_exporter

# Check the service status
systemctl status node_exporter
```

---

## ✅ Verify

- Node Exporter should now be running on:  
  👉 `http://localhost:9100/metrics`
