#!/bin/bash

#Para utilizarlo se debe hacer lo siguiente "./web_stealer.sh lista_ip.txt wordlist_para_grepear.txt 60 (tiempo en segundos que va a repetir esta operación)"

# Verifica que se proporcionen los parámetros necesarios
if [ $# -lt 3 ]; then
    echo "Uso: $0 <archivo_urls_ips> <archivo_palabras> <tiempo_sleep>"
    exit 1
fi

# Lee los archivos de entrada
url_ip_file=$1
word_list_file=$2
sleep_time=$3

# Verifica que los archivos existan
if [ ! -f $url_ip_file ] || [ ! -f $word_list_file ]; then
    echo "Error: Archivos de entrada no encontrados."
    exit 1
fi

# Verifica que el tiempo de espera sea un número
if ! [[ $sleep_time =~ ^[0-9]+$ ]]; then
    echo "Error: El tiempo de espera debe ser un número entero."
    exit 1
fi

# Lee las URL/IPs desde el archivo de entrada
urls_ips=($(cat $url_ip_file))

# Lee las palabras desde el archivo de entrada y las separa por comas
words=$(cat $word_list_file | tr '\n' ',' | sed 's/,$//')

# Archivo temporal para la última salida
temp_output_file="temp_output.txt"

while true; do
  # Limpiar la consola antes de mostrar el contenido del archivo temporal
  clear

  # Decoración con "*"
  echo "*************************************************"
  echo "* Palabras a buscar:"
  echo "* $words"
  echo "*************************************************"
  echo "* Lista de objetivos:"
  # Realiza el bucle sobre cada URL/IP
  for url_ip in "${urls_ips[@]}"; do
      # Construye la URL final
      final_url="${url_ip}"

      # Realiza la solicitud con curl y guarda el resultado en el archivo temporal
      output_file="${url_ip}.txt"

      for word in "${words[@]}"; do
          # Realiza la solicitud con curl y filtra con grep
          curl -s $final_url | grep $word >> $output_file
      done

      # Ordena y elimina duplicados en el archivo
      sort -u -o $output_file $output_file

      # Muestra el número de líneas en el archivo generado
      num_lines=$(wc -l < $output_file)
      echo "* $url_ip - lineas: $num_lines"
  done

  # Muestra el contenido del archivo temporal con decoración
  echo "*************************************************"
  cat $temp_output_file | sed 's/^/* /'

  # Mueve el contenido del archivo generado al archivo temporal
  mv $output_file $temp_output_file

  # Espera el tiempo especificado antes de repetir el bucle
  sleep $sleep_time
done

echo "Proceso completado."

