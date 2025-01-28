# Download and install MinIO
     wget  https://dl.min.io/server/minio/release/linux-amd64/minio
     chmod +x minio
# Move the file to the bin path:
     sudo mv minio /usr/local/bin/
# Create user and MinIO storage directory:
      sudo useradd -r minio-user -s /sbin/nologin
      sudo mkdir /usr/local/share/minio
      sudo mkdir /etc/minio
# Determining ownership of directories:
       sudo chown minio-user:minio-user /usr/local/share/minio
       sudo chown minio-user:minio-user /etc/minio
# Create MinIO service :
       sudo nano /etc/systemd/system/minio.service
# Add to File:
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

  # Set configuration file:
        sudo nano /etc/minio/minio.conf

  # Add to File:
        MINIO_ROOT_USER=your-username 
        MINIO_ROOT_PASSWORD=your-password
  # Enable and start the MinIO service:
         sudo systemctl daemon-reload
         sudo systemctl enable minio
         sudo systemctl start minio
         systemctl status minio
  # Access to MinIO:
         http://localhost:9000
   <mark>Enable metrics in MinIO for prometheus:</mark>

   # Enable metrics in MinIO:
         sudo nano /etc/minio/minio.conf
   # Add to end of the file:
         MINIO_PROMETHEUS_AUTH_TYPE=public
   # Checking address metrics in MinIO:
         http://<minio_server_ip>:9000/minio/v2/metrics/cluster
   # Setting up Prometheus for MinIO monitoring:
  * On your Prometheus server, edit the Prometheus configuration file (prometheus.yml) and add a new Job to monitor MinIO
    
                scrape_configs:
                 - job_name: 'minio'
                   metrics_path: '/minio/v2/metrics/cluster'
                   static_configs:
                    - targets: ['<minio_server_ip>:9000']

    # Restart services:
           sudo systemctl restart minio
           sudo systemctl restart prometheus



