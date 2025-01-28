# Download and configure Push Gateway
     sudo wget https://github.com/prometheus/pushgateway/releases/download/v1.5.1/pushgateway-1.10.0.freebsd-amd64.tar.gz
# After downloading, unzip the file
     sudo tar -xvf pushgateway-1.5.1.linux-amd64.tar.gz
# Rename the extracted folder to make it easier to use
     sudo mv pushgateway-1.5.1.linux-amd64 pushgateway
# We need to set the Push Gateway as an operating system service so that it can be easily managed
     sudo nano /etc/systemd/system/pushgateway.service
* Add to File:
  
        [Unit]
        Description=Prometheus Push Gateway
        After=network.target

        [Service]
        User=nobody
        ExecStart=/opt/pushgateway/pushgateway
        Restart=always

        [Install]
        WantedBy=multi-user.target
# Activation and start service:]
       sudo systemctl daemon-reload
       sudo systemctl enable pushgateway
       sudo systemctl start pushgateway
       sudo systemctl status pushgateway

# Port forwarding with firewall:
       sudo ufw allow 9091/tcp
       sudo ufw reload

# Access to Pushgateway:
       http://<IP-Address>:9091



