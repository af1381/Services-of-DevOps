# 📜💾 Install & Configure Loki and Promtail (All-in-One)

# 📥 Download Loki and then install:
      wget https://github.com/grafana/loki/releases/download/v3.3.2/loki-linux-amd64.zip
      
      unzip loki-linux-amd64.zip
      
      chmod +x loki-linux-amd64
      
      sudo mv loki-linux-amd64 /usr/local/bin/loki

# 🗂️ Create the configuration file in /etc/loki:
      sudo mkdir /etc/loki

      sudo vim /etc/loki/loki-config.yml

# ✍️ Add to File:
      auth_enabled: false

      server:
        http_listen_port: 3100

      ingester:
        lifecycler:
          ring:
            kvstore:
              store: inmemory
            replication_factor: 1
          final_sleep: 0s
        chunk_idle_period: 5m
        chunk_retain_period: 30s
        max_transfer_retries: 0
 
      schema_config:
        configs:
          - from: 2020-10-24
            store: boltdb-shipper
            object_store: filesystem
            schema: v11
            index:
              prefix: index_
              period: 24h

      storage_config:
        boltdb_shipper:
          active_index_directory: /tmp/loki/index
          cache_location: /tmp/loki/boltdb-cache
          shared_store: filesystem
        filesystem:
          directory: /tmp/loki/chunks

      limits_config:
        enforce_metric_name: false
        reject_old_samples: true
        reject_old_samples_max_age: 168h

      chunk_store_config:
        max_look_back_period: 0s

      table_manager:
        retention_deletes_enabled: false
        retention_period: 0s

# ⚙️ Create a Systemd service for Loki:
       sudo vim /etc/systemd/system/loki.service

# ✍️ Add to File:
       [Unit]
       Description=Loki Log Aggregation System
       After=network.target

       [Service]
       ExecStart=/usr/local/bin/loki -config.file=/etc/loki/loki-config.yml
       Restart=on-failure

       [Install]
       WantedBy=multi-user.target

# ▶️ Activating and launching Loki:
       sudo systemctl daemon-reload
       sudo systemctl enable loki
       sudo systemctl start loki

# 🧠 Check service status:
       sudo systemctl status loki

---

# 🪶 Promtail installation and configuration:

       wget https://github.com/grafana/loki/releases/download/v3.3.2/promtail-linux-amd64.zip

       unzip promtail-linux-amd64.zip

       chmod +x promtail-linux-amd64

       sudo mv promtail-linux-amd64 /usr/local/bin/promtail

# 🗂️ Create Promtail config directory (if not exists):
       sudo mkdir -p /etc/promtail

# 📝 Create Promtail configuration file:
       sudo vim /etc/promtail/promtail-config.yml

# ✍️ Add to File:
       server:
         http_listen_port: 9080
         grpc_listen_port: 0

       positions:
         filename: /tmp/positions.yaml

       clients:
         - url: http://localhost:3100/loki/api/v1/push

       scrape_configs:
         - job_name: system
           static_configs:
             - targets:
                 - localhost
               labels:
                 job: varlogs
                 __path__: /var/log/*log

# ⚙️ Create Systemd service for Promtail:
       sudo vim /etc/systemd/system/promtail.service

# ✍️ Add to File:
       [Unit]
       Description=Promtail Log Collector
       After=network.target

       [Service]
       ExecStart=/usr/local/bin/promtail -config.file=/etc/promtail/promtail-config.yml
       Restart=on-failure

       [Install]
       WantedBy=multi-user.target

# ▶️ Activation and startup of Promtail:
       sudo systemctl daemon-reload
       sudo systemctl enable promtail
       sudo systemctl start promtail

# 🔍 Check service status:
       sudo systemctl status promtail

✅ Done! Loki 🧱 and Promtail 🪶 are installed and running successfully.  
You can now visualize logs in **Grafana → Explore → Data source: Loki** 🎨✨
