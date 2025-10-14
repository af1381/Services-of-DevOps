# 🪣⚙️ Install & Configure MinIO + Enable Prometheus Metrics (All-in-One)

# 📥 Download and install MinIO:
     wget https://dl.min.io/server/minio/release/linux-amd64/minio
     chmod +x minio

# 🚚 Move the file to the bin path:
     sudo mv minio /usr/local/bin/

# 👤 Create user and MinIO storage directories:
     sudo useradd -r minio-user -s /sbin/nologin
     sudo mkdir /usr/local/share/minio
     sudo mkdir /etc/minio

# 🔐 Set ownership of directories:
     sudo chown minio-user:minio-user /usr/local/share/minio
     sudo chown minio-user:minio-user /etc/minio

# ⚙️ Create MinIO systemd service:
     sudo nano /etc/systemd/system/minio.service

# ✍️ Add to File:
     [Unit]
     Description=MinIO
     Documentation=https://docs.min.io
     Wants=network-online.target
     After=network-online.target

     [Service]
     User=minio-user
     Group=minio-user
     EnvironmentFile=-/etc/minio/minio.conf
     ExecStart=/usr/local/bin/minio server /usr/local/share/minio
     Restart=always
     LimitNOFILE=65536

     [Install]
     WantedBy=multi-user.target

# 🧩 Create configuration file:
     sudo nano /etc/minio/minio.conf

# ✍️ Add to File:
     MINIO_ROOT_USER=your-username
     MINIO_ROOT_PASSWORD=your-password

# ▶️ Enable and start MinIO service:
     sudo systemctl daemon-reload
     sudo systemctl enable minio
     sudo systemctl start minio
     sudo systemctl status minio

# 🌐 Access the MinIO web interface:
     http://localhost:9000

---

# 📊 Enable metrics in MinIO for Prometheus monitoring:

# 🧠 Edit the MinIO configuration file again:
     sudo nano /etc/minio/minio.conf

# ✍️ Add to end of the file:
     MINIO_PROMETHEUS_AUTH_TYPE=public

# 🔎 Check metrics endpoint in browser:
     http://<minio_server_ip>:9000/minio/v2/metrics/cluster

---

# 📈 Setting up Prometheus for MinIO monitoring:

* On your **Prometheus server**, edit the Prometheus configuration file (**prometheus.yml**)  
  and add a new Job to scrape metrics from MinIO:

        scrape_configs:
         - job_name: 'minio'
           metrics_path: '/minio/v2/metrics/cluster'
           static_configs:
            - targets: ['<minio_server_ip>:9000']

---

# 🔁 Restart services to apply changes:
     sudo systemctl restart minio
     sudo systemctl restart prometheus

✅ Done! 🎉  
Your **MinIO object storage** is now up and running 🪣, and **Prometheus** is collecting its metrics 📊  
Access logs and stats via:
👉 MinIO Console → `http://<minio_server_ip>:9000`  
👉 Prometheus → Targets → Job: `minio` 🚀
