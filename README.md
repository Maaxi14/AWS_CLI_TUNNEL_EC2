# AWS Services EC2 Tunnel - Port forwarding

[**Official GitHub repo**](https://github.com/mjmoreno-14/AWS_CLI_TUNNEL_EC2)

This project provides a Docker container that simplifies creating SSH tunnels to AWS EC2 instances and AWS services (like RDS, DocumentDB) using AWS SSM (Systems Manager).

## What it does

The `ec2-tunnel` Docker container contains a Bash script (`ec2-tunnel.sh`) that automates the process of establishing SSH tunnels. It prompts the user for AWS credentials, asks whether the target is an EC2 instance or an AWS service, lists available running EC2 instances (if applicable), prompts for the remote and local ports, and then uses the AWS CLI to create the SSH tunnel via SSM.

Key features:

*   Uses AWS SSM for secure tunneling without SSH keys.
*   Supports tunneling to both EC2 instances and AWS services (requires an EC2 instance as a bastion).
*   Prompts for AWS credentials (Access Key ID, Secret Access Key, optional Session Token).
*   Lists running EC2 instances to select from.
*   Prompts for remote and local ports.
*   Logs all actions with timestamps.

## How to use

There are two ways to use this image: building it yourself or using a pre-built image from a `.tar.gz` file.

**1. Building the Docker image:**

```bash
docker build -t ec2-tunnel .
```

**2. Using a pre-built image (.tar.gz):**

1.  Copy the `ec2-tunnel.tar.gz` file to your machine.
2.  Load the image:

    ```bash
    gunzip -c ec2-tunnel.tar.gz | docker load
    ```

3.  Run the Docker container:

    ```bash
    docker run -it ec2-tunnel
    ```

The script will guide you through the process.

## Requirements

*   Docker installed.
*   AWS credentials (Access Key ID, Secret Access Key).
*   An EC2 instance with SSM Agent installed and configured (required even for tunneling to AWS services).
*   For AWS services, the EC2 instance must have network access to the service.

## Security Considerations

For production environments, it is strongly recommended to use IAM Roles or AWS Secrets Manager to manage AWS credentials instead of providing them directly to the script.

## Lo que hace

El contenedor Docker `ec2-tunnel` contiene un script Bash (`ec2-tunnel.sh`) que automatiza el proceso de establecer túneles SSH. Solicita al usuario las credenciales de AWS, pregunta si el destino es una instancia EC2 o un servicio de AWS, muestra una lista de las instancias EC2 en ejecución (si aplica), solicita los puertos remoto y local, y luego utiliza la AWS CLI para crear el túnel SSH a través de SSM.

Características principales:

*   Utiliza AWS SSM para crear túneles seguros sin necesidad de claves SSH.
*   Soporta la creación de túneles tanto a instancias EC2 como a servicios de AWS (requiere una instancia EC2 como bastión).
*   Solicita las credenciales de AWS (ID de clave de acceso, Clave de acceso secreta, Token de sesión opcional).
*   Muestra una lista de las instancias EC2 en ejecución para seleccionar.
*   Solicita los puertos remoto y local.
*   Registra todas las acciones con marcas de tiempo (fecha y hora).

## Cómo usar

Hay dos maneras de usar esta imagen: construyéndola tú mismo o usando una imagen pre-construida desde un archivo `.tar.gz`.

**1. Construir la imagen de Docker:**

```bash
docker build -t ec2-tunnel .
```

**2. Usando una imagen pre-construida (.tar.gz):**

1.  Copia el archivo `ec2-tunnel.tar.gz` a tu máquina.
2.  Carga la imagen:

    ```bash
    gunzip -c ec2-tunnel.tar.gz | docker load
    ```

3.  Ejecuta el contenedor de Docker:

    ```bash
    docker run -it ec2-tunnel
    ```

El script te guiará a través del proceso.

## Requisitos

*   Docker instalado.
*   Credenciales de AWS (ID de clave de acceso, Clave de acceso secreta).
*   Una instancia EC2 con el Agente de SSM instalado y configurado (requerido incluso para la creación de túneles a servicios de AWS).
*   Para los servicios de AWS, la instancia EC2 debe tener acceso de red al servicio.

## Consideraciones de seguridad

Para entornos de producción, se recomienda encarecidamente utilizar Roles de IAM o AWS Secrets Manager para administrar las credenciales de AWS en lugar de proporcionarlas directamente al script.