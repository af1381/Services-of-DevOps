## ⬇️ Download Alertmanager
wget https://github.com/prometheus/alertmanager/releases/download/v0.28.0/alertmanager-0.28.0.linux-amd64.tar.gz

## 📦 Extract
tar -xvf alertmanager-0.28.0.linux-amd64.tar.gz

## 🚚 Move binaries to /usr/local/bin
sudo mv alertmanager-0.28.0.linux-amd64/alertmanager /usr/local/bin/
sudo mv alertmanager-0.28.0.linux-amd64/amtool /usr/local/bin/

## 🗂️ Create config folders
sudo mkdir /etc/alertmanager
sudo mkdir /etc/alertmanager/templates

## 📝 Create /etc/alertmanager/alertmanager.yml
sudo vim /etc/alertmanager/alertmanager.yml
# Paste:
# ---
global:
  smtp_smarthost: 'smtp.gmail.com:587'
  smtp_from: 'your-email@gmail.com'
  smtp_auth_username: 'your-email@gmail.com'
  smtp_auth_password: 'your-email-password'
  smtp_require_tls: true

route:
  receiver: 'email-alerts'

receivers:
  - name: 'email-alerts'
    email_configs:
      - to: 'destination-email@gmail.com'
# ---

## 🔐 Fix ownership (adjust if you run as another user)
sudo chown -R $USER:$USER /etc/alertmanager

## ⚙️ Create systemd service /etc/systemd/system/alertmanager.service
sudo vim /etc/systemd/system/alertmanager.service
# Paste:
# ---
[Unit]
Description=Alertmanager
After=network.target

[Service]
User=alertmanager
Group=alertmanager
ExecStart=/usr/local/bin/alertmanager --config.file=/etc/alertmanager/alertmanager.yml --storage.path=/var/lib/alertmanager/

[Install]
WantedBy=multi-user.target
# ---

## ▶️ Enable & start service
sudo systemctl daemon-reload
sudo systemctl enable alertmanager
sudo systemctl start alertmanager

## 🔍 Check status
sudo systemctl status alertmanager

## 🤝 Configure Prometheus to talk to Alertmanager (prometheus.yml)
alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - 'localhost:9093'  # Alertmanager address
          
## 🚨 Create Prometheus alert rules (alert_rules.yml)
groups:
  - name: example-alert
    rules:
      - alert: InstanceDown
        expr: up == 0
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Instance {{ $labels.instance }} is down"

## 📎 Tell Prometheus to load the rules (prometheus.yml)
rule_files:
  - "alert_rules.yml"

## 🔁 Reload / restart after changes
# Reload Prometheus (preferred if supported by your setup)
sudo systemctl reload prometheus || sudo systemctl restart prometheus
sudo systemctl status prometheus

# If you changed Alertmanager config:
sudo systemctl reload alertmanager || sudo systemctl restart alertmanager
sudo systemctl status alertmanager

✅ Done! Open UI: http://localhost:9093


