# Atividade de Docker + AWS | COMPASS UOL
![Arquitetura](https://github.com/jeancalistro/atv-docker-aws-compass/blob/main/arquitetura.png?raw=true)
## Requisitos AWS

* **VPC**
    * 2 Subnets Privadas (Instâncias) e 2 Subnets Públicas (Load Balancer)
    * Internet Gateway e Nat Gateway
    * Route Tables
* **RDS**
    * MySQL
* **Security Groups**
    * database
    * ec2-instances
    * load-balancer
* **Modelo de Execução**
    * Amazon Linux 2 AMI
    * t3.small
    * [User Data](https://github.com/jeancalistro/atv-docker-aws-compass/blob/main/user_data.sh)
* **EFS**
* **Load Balancer Classic**
* **Auto Scaling**

## Requisitos Docker

* Dockerfile ou Docker compose
* Imagem do wordpress
* [compose.yaml](https://github.com/jeancalistro/atv-docker-aws-compass/blob/main/compose.yaml)



## VPC | CONSOLE AWS

1. Procure pelo serviço de **VPC**.
2. Selecione **Criar VPC**.

## Subnets | CONSOLE AWS

1. Procure pela VPC feature **Subnet**.
2. Selecione criar **sub-rede**.
3. Selecione a **VPC** criada anteriormente.
4. Crie duas subnets **privadas** e duas **públicas**, em **AZ** diferentes.

## Internet Gateway | CONSOLE AWS

1. Procure pela VPC feature **Internet Gateway**
2. Selecione **Criar Gateway da Internet**
3. Associe na **VPC** criada anteriormente.

## Nat Gateway | CONSOLE AWS

1. Procure pela VPC feature **Nat Gateway**.
2. Selecione **Criar Gateway Nat**.
3. Escolha uma **Subnet pública** para criar o Nat Gateway.
4. Aloque um **IP elástico** para atribuir ao Nat Gateway.

## Route Tables | CONSOLE AWS

1. Procure pela VPC feature **Route Table**.
2. Selecione **Criar tabela de rotas**.
3. Crie duas **Route Tables**, uma **pública** e uma **privada**.
4. Na **pública** adicione uma **rota** para o **Internet Gateway**.
5. Na **privada** adicione uma **rota** para o **Nat Gateway**.

## EFS | CONSOLE AWS

1. Procure pelo serviço de **EFS**.
2. Selecione **Criar sistema de arquivos > Personalizar**.
3. Na etapa de **Acesso à rede** nos destinos de montagem escolha as duas **subnets privadas**.

## RDS | CONSOLE AWS

1. Procure pelo serviço de **RDS**.
2. Selecione **Criar banco de dados**.
3. Escolha o mecanismo **MySQL**.
4. Por motivos de segurança, opte por **negar** o acesso público.

## Modelo de Execução | CONSOLE AWS

1. Procure pelo EC2 feature **Launch Templates**.
2. Selecione **Criar modelo de Execução**.
3. Escolha o tipo de instância **t3.small**.
4. Não inclua **subnet** no modelo, isso ficará por conta do auto scaling decidir.
5. Em **user data** coloque o seguinte conteúdo: [User Data](https://github.com/jeancalistro/atv-docker-aws-compass/blob/main/user_data.sh).

## Load Balancer Classic | CONSOLE AWS

1. Procure pelo EC2 feature **Load Balancers**.
2. Selecione **Criar Load Balancer**.
3. Em **Mapeamento de Rede** escolha as **subnets públicas**, uma em cada **AZ**.
4. Em **Listeners** escolha o protocolo **HTTP** na porta **80**.
5. Em **Verificação de Integridade** coloque o caminho que será usado para verificar se a aplicação está íntegra.
6. Não é necessário adicionar **instâncias** na criação do load balancer.

## Auto Scaling Groups | CONSOLE AWS

1. Procure pelo EC2 feature **Auto Scaling Groups**.
2. Selecione **Criar grupo do Auto Scaling**.
3. Escolha o **Modelo de Execução** criado anteriormente.
4. Em **Rede** escolha as **Subnets Privadas**, uma em cada **AZ**.
5. Anexe o **Load Balancer** criado anteriormente e em **Verificação de Integridade** opte pelo **ELB**.
6. Para esse laboratório, a **capacidade mínima** deve ser de pelo menos duas **instâncias**.

## User Data | CONSOLE AWS

```
#!/bin/bash
sudo yum update -y
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose
sudo chmod +x /usr/bin/docker-compose
sudo docker volume create --driver local --opt type=nfs --opt=o=addr=fs-013b0cb0ec5585cc7.efs.us-east-1.amazonaws.com,nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport --opt device=:/ wordpress-content
echo HOST_DB=HOST >> .envdb
echo USER_DB=USER >> .envdb
echo PASSWORD_DB=PASSWORD >> .envdb
echo NAME_DB=DATABASE >> .envdb
curl https://raw.githubusercontent.com/jeancalistro/atv-docker-aws-compass/main/compose.yaml -o compose.yaml
sudo docker-compose --env-file .envdb up -d
```

## compose.yaml | DOCKER

```
name: project-wordpress
services:
  wordpress:
    image: wordpress
    restart: always
    ports:
      - 80:80
    environment:
      WORDPRESS_DB_HOST: $HOST_DB
      WORDPRESS_DB_USER: $USER_DB
      WORDPRESS_DB_PASSWORD: $PASSWORD_DB
      WORDPRESS_DB_NAME: $NAME_DB
    volumes:
      - wordpress-content:/var/www/html
volumes:
  wordpress-content:
    external: true
```
