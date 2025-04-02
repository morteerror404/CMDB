Para instalar um banco de dados **PostgreSQL** no **Parrot OS** (ou em qualquer distribuição baseada em Debian/Ubuntu), siga os passos abaixo:

---

## **1. Instale o PostgreSQL**
Atualize os pacotes e instale o PostgreSQL:
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib -y
```
- `postgresql`: Pacote principal do PostgreSQL.
- `postgresql-contrib`: Pacote com extensões e utilitários adicionais.

---

## **2. Verifique o Serviço PostgreSQL**
O sistema já deve ter iniciado o serviço automaticamente. Confirme com:
```bash
sudo systemctl status postgresql
```
Se não estiver ativo, inicie-o:
```bash
sudo systemctl start postgresql
sudo systemctl enable postgresql  # Para iniciar automaticamente no boot
```

---

## **3. Acesse o PostgreSQL**
O PostgreSQL cria um usuário padrão chamado `postgres`. Para acessar:
```bash
sudo -u postgres psql
```
Você entrará no console do PostgreSQL (`psql`).

---

## **4. (Opcional) Criar um Novo Usuário e Banco de Dados**
Dentro do `psql`, você pode criar um novo usuário e banco de dados:
```sql
CREATE USER seu_usuario WITH PASSWORD 'sua_senha_forte';
CREATE DATABASE seu_banco WITH OWNER seu_usuario;
```
Saia do `psql` com:
```sql
\q
```

---

## **5. Configurar Acesso Remoto (Opcional)**
Se quiser acessar o PostgreSQL de outra máquina:
### **Edite o arquivo de configuração:**
```bash
sudo nano /etc/postgresql/<versão>/main/postgresql.conf
```
Exemplo (versão comum: `15`):
```bash
sudo nano /etc/postgresql/15/main/postgresql.conf
```
Procure a linha:
```ini
#listen_addresses = 'localhost'
```
E altere para:
```ini
listen_addresses = '*'   # Permite conexões de qualquer IP (ou substitua por um IP específico)
```

### **Libere o acesso no `pg_hba.conf`:**
```bash
sudo nano /etc/postgresql/15/main/pg_hba.conf
```
Adicione uma linha para permitir conexões (exemplo para rede local):
```ini
host    all             all             192.168.1.0/24          md5
```
Ou para qualquer IP (não recomendado para produção):
```ini
host    all             all             0.0.0.0/0               md5
```

### **Reinicie o PostgreSQL:**
```bash
sudo systemctl restart postgresql
```

---

## **6. Liberar Porta no Firewall (Se Necessário)**
Se estiver usando **UFW**, libere a porta padrão do PostgreSQL (**5432**):
```bash
sudo ufw allow 5432/tcp
sudo ufw enable
sudo ufw status  # Verifique se a regra foi aplicada
```

---

## **7. Testar a Conexão**
### **Localmente:**
```bash
psql -U seu_usuario -d seu_banco -h 127.0.0.1
```
### **De outra máquina (se configurado para acesso remoto):**
```bash
psql -U seu_usuario -d seu_banco -h <IP_DO_SERVIDOR_POSTGRES>
```

---

## **Dicas de Segurança**
✅ **Altere a senha do usuário `postgres`** (dentro do `psql`):
```sql
ALTER USER postgres WITH PASSWORD 'nova_senha_forte';
```
✅ **Use apenas conexões criptografadas** (SSL) em ambientes de produção.  
✅ **Restrinja IPs permitidos** no `pg_hba.conf` para evitar acessos não autorizados.  
✅ **Considere usar um túnel SSH** para acesso remoto seguro.

---

### **Pronto! Seu PostgreSQL está instalado e configurado.** 🚀  
Se precisar de mais ajuda, digite `man psql` ou consulte a [documentação oficial](https://www.postgresql.org/docs/).