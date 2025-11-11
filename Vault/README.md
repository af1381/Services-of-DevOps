
# Vault Setup with Docker Compose and PostgreSQL 🚀🔐

This guide explains how to set up **HashiCorp Vault** using **Docker Compose**, with a **PostgreSQL** backend and detailed instructions for initialization, unsealing, and configuration. 💡

---

## Prerequisites 🛠️

1. **Docker** and **Docker Compose** installed.
2. **PostgreSQL** Docker image.
3. Basic knowledge of how to work with Docker containers and Vault.

---

## 1. Directory Structure 🗂️

Create the directory structure for Vault and PostgreSQL:

```bash
mkdir -p /home/hesaba/Vault/config /home/hesaba/Vault/data /home/hesaba/Vault/logs /home/hesaba/Vault/pg-data
```

Make sure these directories are accessible by the user running the containers:

```bash
chown -R $USER:$USER /home/hesaba/Vault
```

---

## 2. Docker Compose File 🐳

Create a `docker-compose.yml` file for Vault and PostgreSQL:

```yaml
version: "3.9"

services:
  postgres:
    image: postgres:16
    container_name: postgres
    restart: unless-stopped
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: "${POSTGRES_PASSWORD}"  # Loaded from .env file
      POSTGRES_DB: appdb
    volumes:
      - ./pg-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U $$POSTGRES_USER -d $$POSTGRES_DB -h 127.0.0.1"]
      interval: 10s
      timeout: 5s
      retries: 20
    networks:
      - vault-net

  vault:
    image: hashicorp/vault:1.21
    container_name: vault
    entrypoint: ["/bin/vault"]
    command: ["server", "-config=/vault/config/vault.hcl", "-log-level=debug"]
    restart: unless-stopped
    cap_add:
      - IPC_LOCK
    ulimits:
      memlock:
        soft: -1
        hard: -1
    environment:
      VAULT_API_ADDR: "http://vault:8200"
    volumes:
      - ./config/vault.hcl:/vault/config/vault.hcl:ro
      - ./data:/vault/file
      - ./logs:/vault/logs
    ports:
      - "8200:8200"
    depends_on:
      postgres:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "vault", "status", "-address=http://127.0.0.1:8200"]
      interval: 10s
      timeout: 5s
      retries: 12
    networks:
      - vault-net

networks:
  vault-net:
    driver: bridge
```

This configuration includes both Vault and PostgreSQL containers with health checks and volume mapping for persistent data. 📊

---

## 3. Vault Configuration (`vault.hcl`) ⚙️

Create a `vault.hcl` configuration file in the `config/` folder:

```hcl
ui = true
disable_mlock = true

api_addr     = "http://vault:8200"
cluster_addr = "http://vault:8201"

# Raft Storage Backend
storage "raft" {
  path    = "/vault/file"
  node_id = "vault-1"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1  # Disable TLS for testing; enable in production
}

# Audit log
audit "file" {
  path = "/vault/logs/audit.log"
}

telemetry {
  prometheus_retention_time = "24h"
  disable_hostname = true
}
```

---

## 4. Starting the Containers 🚀

### Step 1: Start the Containers
```bash
docker compose up -d
```

### Step 2: Check the Status of Vault
```bash
docker exec -it vault sh -lc 'export VAULT_ADDR="http://127.0.0.1:8200"; vault status'
```

The output should show:
- `Initialized: false` (Vault is not initialized yet)
- `Sealed: true` (Vault is sealed) 🔒

---

## 5. Initialize Vault 🛠️

### Step 1: Initialize Vault
```bash
docker exec -i vault sh -lc 'export VAULT_ADDR="http://127.0.0.1:8200"; vault operator init -key-shares=1 -key-threshold=1' | tee /home/hesaba/Vault/cluster-keys.txt
```

The output will contain:
- **Unseal Key 1** (which you will use to unseal Vault) 🔑
- **Initial Root Token** (used for the initial login) 🏛️

### Step 2: Unseal Vault
Use the `Unseal Key 1` from the output above to unseal Vault.

```bash
UNSEAL=$(awk '/Unseal Key/ {print $4; exit}' /home/hesaba/Vault/cluster-keys.txt)
docker exec -it vault sh -lc 'export VAULT_ADDR="http://127.0.0.1:8200"; vault operator unseal '"$UNSEAL"
```

### Step 3: Login with Root Token
After unsealing Vault, use the **Initial Root Token** from the output of the `init` step to log in.

```bash
ROOT=$(awk '/Initial Root Token/ {print $4; exit}' /home/hesaba/Vault/cluster-keys.txt)
docker exec -it vault sh -lc 'export VAULT_ADDR="http://127.0.0.1:8200"; vault login '"$ROOT"
```

---

## 6. Configure Database Secrets Engine (Optional) 🔐

If you want to enable dynamic secrets for PostgreSQL, you can set up the **Database Secrets Engine**:

### Step 1: Enable the Database Secrets Engine
```bash
docker exec -e PG_ROOT_PASSWORD="$POSTGRES_PASSWORD" -it vault sh -lc '
export VAULT_ADDR="http://127.0.0.1:8200"
vault secrets enable -path=database database || true
vault write database/config/my-postgres   plugin_name="postgresql-database-plugin"   allowed_roles="app-role,app-ro"   connection_url="postgresql://{{username}}:{{password}}@postgres:5432/postgres?sslmode=disable"   username="postgres"   password="$PG_ROOT_PASSWORD"
'
```

### Step 2: Define Roles for Dynamic Credentials
```bash
docker exec -it vault sh -lc '
export VAULT_ADDR="http://127.0.0.1:8200"

# Define Read/Write role
vault write database/roles/app-role   db_name="my-postgres"   creation_statements="
    CREATE ROLE "{{name}}" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';
    GRANT CONNECT ON DATABASE appdb TO "{{name}}";
    GRANT USAGE ON SCHEMA public TO "{{name}}";
    GRANT SELECT,INSERT,UPDATE,DELETE ON ALL TABLES IN SCHEMA public TO "{{name}}";
    GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public TO "{{name}}";
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT,INSERT,UPDATE,DELETE ON TABLES TO "{{name}}";
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO "{{name}}";
  "   default_ttl="1h"   max_ttl="24h"

# Define Read-Only role
vault write database/roles/app-ro   db_name="my-postgres"   creation_statements="
    CREATE ROLE "{{name}}" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';
    GRANT CONNECT ON DATABASE appdb TO "{{name}}";
    GRANT USAGE ON SCHEMA public TO "{{name}}";
    GRANT SELECT ON ALL TABLES IN SCHEMA public TO "{{name}}";
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO "{{name}}";
  "   default_ttl="30m"   max_ttl="12h"
'
```

### Step 3: Retrieve Dynamic Credentials
```bash
docker exec -it vault sh -lc 'export VAULT_ADDR="http://127.0.0.1:8200"; vault read database/creds/app-role'
# Or Read-Only credentials:
# docker exec -it vault sh -lc 'export VAULT_ADDR="http://127.0.0.1:8200"; vault read database/creds/app-ro'
```

---

## 7. Additional Considerations ⚖️

- **TLS**: Once you're ready for production, enable **TLS** by configuring the `tls_cert_file` and `tls_key_file` fields in `vault.hcl`.
- **Backups**: 
  - **Vault Raft Snapshot**: Take periodic snapshots of your Vault data using `vault operator raft snapshot save`.
  - **PostgreSQL**: Use `pg_dump` for logical backups or backup the `pg-data` directory for physical backups.
- **Security**: 
  - Always store your `cluster-keys.txt` in a secure place.
  - Rotate secrets periodically using Vault's built-in features.
- **Automatic Unsealing**: Configure automatic unsealing using **KMS** for cloud environments like AWS, GCP, etc.

---

## Conclusion 🎉

You've successfully set up HashiCorp Vault with Docker Compose and PostgreSQL! You can now securely manage your secrets, access policies, and databases with Vault. 🔒

If you have any questions or need further assistance, feel free to ask! 🤖💬
