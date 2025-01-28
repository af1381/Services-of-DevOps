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

  <mark>Configure Prometheus to collect data from the Push Gateway</mark>:

  *  After installing Push Gateway, you need to configure Prometheus to read information from Push Gateway


# Edit the Prometheus configuration file:
       sudo vim /etc/prometheus/prometheus.yml

* Then add this section to the file so that Prometheus can collect data from the Push Gateway:

        scrape_configs:
         - job_name: 'pushgateway'
           static_configs:
            - targets: ['localhost:9091']



# Restart Prometheus:
       sudo systemctl restart prometheus


# Push data to Push Gateway:
       echo "some_metric 3.14" | curl --data-binary @- http://localhost:9091/metrics/job/some_job
<mark>Note:</mark>

* some_metric: is the name of the metric.
* 3.14: is a metric value.
* some_job: is the name of your job


# Push short-term data to Push Gateway:
        echo "test_metric 7.89" | curl --data-binary @- http://localhost:9091/metrics/job/test_job
# View data in Push Gateway:
        http://localhost:9091/metrics
# Here, you should see the metric you submitted, like this:
        test_metric{instance="",job="test_job"} 7.89
# View data through Prometheus:
        http://<my-ip-addres>:9090

<mark>Note:</mark>
* To view the data, we enter Prometheus and in the graph tab, we enter the name of the metric that we created, and then we run it, we must see the value we gave it


# Automating a short-term job:
* To automatically send metrics to a short-term script, for example, write a simple bash script like the following

        #!/bin/bash
        metric_value=$(shuf -i 1-100 -n 1)  echo "random_metric $metric_value" | curl --data-binary @- http://localhost:9091/metrics/job/random_job


# And finally:
        bash random_metric.sh

       

