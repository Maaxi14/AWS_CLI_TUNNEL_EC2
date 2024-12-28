#!/bin/bash

# Función para mostrar un mensaje de error y salir con fecha y hora
error_exit() {
  timestamp=$(date +"%d-%m-%Y %H:%M:%S")
  echo "$timestamp Error: $1" >&2
  exit 1
}

# Función para mostrar un mensaje con fecha y hora
log_message() {
  timestamp=$(date +"%d-%m-%Y %H:%M:%S")
  echo "$timestamp $1"
}

# Solicitar las credenciales y el token temporal
log_message "Iniciando script ec2-tunnel.sh"
read -p "Introduce tu Access Key ID: " AWS_ACCESS_KEY_ID || error_exit "No se proporcionó Access Key ID."
read -p "Introduce tu Secret Access Key: " AWS_SECRET_ACCESS_KEY || error_exit "No se proporcionó Secret Access Key."
read -p "Introduce tu Session Token (opcional, presiona Enter para omitir): " AWS_SESSION_TOKEN

# Exportar las variables de entorno
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
if [[ -n "$AWS_SESSION_TOKEN" ]]; then
  export AWS_SESSION_TOKEN
fi

# Preguntar el tipo de destino
while true; do
  read -p "El túnel es para un servicio de AWS (RDS, DocumentDB, etc.)? (s/n): " is_aws_service
  case "$is_aws_service" in
    s|S)
      is_aws_service=true
      break
      ;;
    n|N)
      is_aws_service=false
      break
      ;;
    *)
      log_message "Respuesta inválida. Por favor, introduce 's' o 'n'."
      ;;
  esac
done

# Obtener la lista de instancias EC2 con manejo de errores
log_message "Obteniendo lista de instancias EC2..."
instances=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,Tags[?Key==`Name`].Value[] | [0], State.Name]' --output json 2>/dev/null | jq -r '.[][] | select(.[1] == "running") | .[0] + " " + (.[1] // "Sin nombre")')
if [[ $? -ne 0 ]]; then
    error_exit "Error al obtener la lista de instancias EC2. Verifica tus credenciales y configuración de AWS."
fi

# Verificar si hay instancias corriendo
if [[ -z "$instances" ]]; then
  log_message "No se encontraron instancias EC2 corriendo."
  exit 0
fi

# Mostrar las instancias en un menú numerado con less para paginación
log_message "Selecciona una instancia para crear el túnel (esta instancia debe tener acceso al servicio de AWS):"
printf "%s\n" "$instances" | less

# Obtener la opción del usuario con validación
read -p "Introduce el número de la instancia: " instance_number
if ! [[ "$instance_number" =~ ^[0-9]+$ ]] || (( instance_number < 1 )) || (( instance_number > $(wc -l <<< "$instances") )); then
    error_exit "Número de instancia inválido."
fi

instance=$(awk "NR==$instance_number" <<< "$instances")

# Obtener el ID de la instancia seleccionada
instance_id=$(echo "$instance" | awk '{print $1}')

# Obtener el nombre de la instancia seleccionada
instance_name=$(echo "$instance" | cut -d' ' -f2-)

# Solicitar el endpoint si es un servicio de AWS
if [[ "$is_aws_service" == true ]]; then
  read -p "Introduce el endpoint del servicio de AWS (ej: database.xyz.us-east-1.rds.amazonaws.com): " aws_service_endpoint || error_exit "No se proporcionó el endpoint del servicio de AWS."
fi

# Solicitar puertos
read -p "Introduce el puerto de la aplicación remota: " remote_port || error_exit "No se proporcionó el puerto remoto."
read -p "Introduce el puerto local para el túnel: " local_port || error_exit "No se proporcionó el puerto local."

log_message "Creando túnel SSH..."

# Crear el túnel SSH usando AWS CLI y SSM con manejo de errores
if [[ "$is_aws_service" == false ]]; then
    aws ssm start-session \
        --target "$instance_id" \
        --document-name AWS-StartPortForwardingSession \
        --parameters '{"portNumber":["'$remote_port'"],"localPortNumber":["'$local_port'"]}' 2>/dev/null
else
    aws ssm start-session \
        --target "$instance_id" \
        --document-name AWS-StartPortForwardingSessionToRemoteHost \
        --parameters '{"host":["'$aws_service_endpoint'"],"portNumber":["'$remote_port'"],"localPortNumber":["'$local_port'"]}' 2>/dev/null
fi

if [[ $? -ne 0 ]]; then
    error_exit "Error al crear el túnel SSH. Verifica que SSM esté configurado correctamente y que la instancia tenga acceso al servicio."
fi

log_message "Túnel SSH creado. Conéctate a tu aplicación local usando el puerto $local_port."

#Mensaje para cerrar la sesion
read -p "Presiona Enter para cerrar la sesión SSM..."

aws ssm terminate-session --session-id $(aws ssm describe-sessions --filters "Name=Target,Values=$instance_id" --query "Sessions[].SessionId" --output text) 2>/dev/null

log_message "Sesión SSM terminada."
log_message "Script ec2-tunnel.sh finalizado"