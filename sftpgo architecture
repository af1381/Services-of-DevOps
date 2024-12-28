  # Install SftpGo (with pkg)
 
 # Download file from Github repository:
     sudo wget https://github.com/drakkan/sftpgo/releases/download/v2.6.4/sftpgo_2.6.4-1_amd64.deb

 # Install service:
        sudo dpkg -i sftpgo_2.6.4-1_amd64.deb

 # Create Service:
        sudo systemctl enable sftpgo
        sudo systemctl start sftpgo
        sudo systemctl status sftpgo
        sudo systemctl status sftpgo

        
  # Install pgadmin & postgress-sql 
  # install the public key for the repository (if not done previously):  
       curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo gpg --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg

  # Create the repository configuration file:
        sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list && apt update'
        
  # Install pgAdmin:
       sudo apt install pgadmin4

  # Configure the webserver, if you installed pgadmin4-web:
        
     sudo /usr/pgadmin4/bin/setup-web.sh
     
  # Install PostgreSQL:
      sudo apt -y install postgresql
      sudo systemctl start postgresql
      sudo systemctl enable postgresql
      systemctl status postgresql

   
