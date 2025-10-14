<mark>The Push Gateway service is used to store data that is executed for a short period of time, so that it is completed within a few seconds. One of its uses is to monitor bash scripts, where we can store bash script data and perform monitoring operations using Prometheus and Grafana.</mark>

# 🚀📦 Download and Configure Prometheus Pushgateway

# 📥 Download Pushgateway:
     sudo wget https://github.com/prometheus/pushgateway/releases/download/v1.5.1/pushgateway-1.10.0.freebsd-amd64.tar.gz

# 📦 Extract the file:
     sudo tar -xvf pushgateway-1.5.1.linux-amd64.tar.gz

# 🏷️ Rename the extracted folder for easier access:
     sudo mv pushgateway-1.5.1.linux-amd64 pushgateway

# ⚙️ Create a Systemd service for Pushgateway:
     sudo nano /etc/systemd/system/pushgateway.service

# ✍️ Add to File:
        [Unit]
        Description=Prometheus Push Gateway
        After=network.target

        [Service]
        User=nobody
        ExecStart=/opt/pushgateway/pushgateway
        Restart=always

        [Install]
        WantedBy=multi-user.target

# ▶️ Activate and start Pushgateway service:
       sudo systemctl daemon-reload
       sudo systemctl enable pushgateway
       sudo systemctl start pushgateway
       sudo systemctl status pushgateway

# 🔐 Allow Pushgateway port through firewall:
       sudo ufw allow 9091/tcp
       sudo ufw reload

# 🌐 Access Pushgateway Web UI:
       http://<IP-Address>:9091

---

<mark>🧠 Configure Prometheus to collect data from Pushgateway</mark>

* After installing Pushgateway, configure Prometheus to read data from it.

# 📝 Edit Prometheus configuration file:
       sudo vim /etc/prometheus/prometheus.yml

# ✍️ Add this section under scrape_configs:
        scrape_configs:
         - job_name: 'pushgateway'
           static_configs:
            - targets: ['localhost:9091']

# 🔁 Restart Prometheus to apply changes:
       sudo systemctl restart prometheus

---

# 📊 Push data to Pushgateway:

# Push a custom metric:
       echo "some_metric 3.14" | curl --data-binary @- http://localhost:9091/metrics/job/some_job

<mark>🧩 Note:</mark>  
* `some_metric` → Metric name  
* `3.14` → Metric value  
* `some_job` → Job name  

# Push short-term data example:
       echo "test_metric 7.89" | curl --data-binary @- http://localhost:9091/metrics/job/test_job

# 🌐 View pushed data in Pushgateway:
       http://localhost:9091/metrics

# Example output:
       test_metric{instance="",job="test_job"} 7.89

# 🔭 View metrics in Prometheus:
       http://<my-ip-address>:9090

<mark>🧠 Note:</mark>  
* In the **Prometheus UI → Graph tab**, enter the metric name you pushed (e.g. `test_metric`)  
  and you should see the value you sent appear in real time.

---

# ⚙️ Automating a Short-Term Job

* You can automate metric pushing using a simple **bash script**, for example:

        #!/bin/bash
        metric_value=$(shuf -i 1-100 -n 1)
        echo "random_metric $metric_value" | curl --data-binary @- http://localhost:9091/metrics/job/random_job

# ▶️ Finally, run your script:
        bash random_metric.sh

---

✅ Done! 🎉  
Your **Prometheus Pushgateway** is now fully installed and integrated.  
You can now:
- 🧾 Send short-lived metrics (e.g., script runtimes)
- 📈 View data in **Pushgateway**
- 🔍 Monitor and visualize results directly through **Prometheus & Grafana**

🚀 Enjoy real-time visibility for all your short-running jobs!
