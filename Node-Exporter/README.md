# Download & Configuration Node Exporter
 <mark> Node Exporter provides detailed information about the server such as CPU, disk and memory usage.</mark>
 
*  First, we download the current stable version of Node Exporter
  
       curl -LO https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz

# open the downloaded archive:
       tar xvf node_exporter-0.15.1.linux-amd64.tar.gz
# Set user and group ownership to the node_exporter user you created:
       sudo cp node_exporter-1.8.2.linux-amd64/node_exporter /usr/local/bin
       sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
# Run Node Exporter:
* We create the following file for permanent execution:

      sudo vim /etc/systemd/system/node_exporter.service
# Add to File:
      [Unit] 
      Description=Node Exporter 
      Wants=network-online.target 
      After=network-online.target 
      
      [Service] 
      User=node_exporter 
      Group=node_exporter 
      Type=simple ExecStart=/usr/local/bin/node_exporter 
      
      [Install] 
      WantedBy=multi-user.target

# Then we restart systemd to use the service:
      sudo systemctl daemon-reload
      sudo systemctl start node_exporter
      sudo systemctl status node_exporter
# Configure Prometheus to receive Node Exporter data:
      sudo nano /etc/prometheus/prometheus.yml
# Add to file:
        - job_name: 'node_exporter'
          scrape_interval: 5s
          static_configs:
         - targets: ['localhost:9100']

* Since this exporter is also on the same server as Prometheus is running, we can use localhost instead of the IP address along with the default port of Node Exporter i.e. 9100.


# In the last step, restart the Prometheus service:
      sudo systemctl restart Prometheus
      sudo systemctl status Prometheus


 
