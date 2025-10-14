# 🚨📦 Install & Configuration Alertmanager

* First, you need to download and install the Alertmanager binary file  

        wget https://github.com/prometheus/alertmanager/releases/download/v0.28.0/alertmanager-0.28.0.linux-amd64.tar.gz

# 📦 After downloading, extract the file:  
        tar -xvf alertmanager-0.28.0.linux-amd64.tar.gz

# 🚚 For faster and easier access to Alertmanager, move the binaries to /usr/local/bin:  
        sudo mv alertmanager-0.28.0.linux-amd64/alertmanager /usr/local/bin/  
        sudo mv alertmanager-0.28.0.linux-amd64/amtool /usr/local/bin/

* Alertmanager uses a configuration file called **alertmanager.yml**.  
  Place this file in a dedicated folder:

        sudo mkdir /etc/alertmanager  
        sudo mkdir /etc/alertmanager/templates

# 📝 Create Alertmanager config file:  
        sudo vim /etc/alertmanager/alertmanager.yml

* After creating the file, paste the following configuration:

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

# 🔐 Access settings:  
        sudo chown -R $USER:$USER /etc/alertmanager

# ⚙️ Create systemd service for Alertmanager:  
        sudo vim /etc/systemd/system/alertmanager.service

* After creating the above file, put the following contents inside it:

        [Unit]
        Description=Alertmanager
        After=network.target

        [Service]
        User=alertmanager
        Group=alertmanager
        ExecStart=/usr/local/bin/alertmanager --config.file=/etc/alertmanager/alertmanager.yml --storage.path=/var/lib/alertmanager/

        [Install]
        WantedBy=multi-user.target

# ▶️ Service activation:
        sudo systemctl daemon-reload
        sudo systemctl enable alertmanager
        sudo systemctl start alertmanager

# 🔎 Check service status:
        sudo systemctl status alertmanager

# 🤝 Configure Prometheus to communicate with Alertmanager:
* In the Prometheus configuration file (usually **prometheus.yml**), add a section to configure Alertmanager:

        alerting:
          alertmanagers:
            - static_configs:
                - targets:
                    - 'localhost:9093'   # Address Alertmanager

# 🚨 Defining warning rules in Prometheus:
* To define alert rules in Prometheus, create a file called **alert_rules.yml** and define the alert rules in it:

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

# 📎 Then tell Prometheus to use this file in the **prometheus.yml** file:
        rule_files:
          - "alert_rules.yml"

# 🔁 After making these settings, restart the Prometheus service:
        sudo systemctl daemon-reload
        sudo systemctl enable alertmanager
        sudo systemctl start alertmanager
        sudo systemctl status alertmanager

✅ Done! Your Alertmanager is now configured and connected to Prometheus 🎉
