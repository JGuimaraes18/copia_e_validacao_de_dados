#!/bin/bash   
##########################################################################################
# Script para realizar a cópia de um diretório e validar os arquivos copiados via md5sum #
# Autor: João Guimarães																	 #
# Data: 2025-10-06																	  	 #
# Versão: 1.0											 	 				  			 #	
##########################################################################################

# Interação de entrada com o usuário
echo "Digite o diretório de origem:"
read path_origin

echo "Digite o diretório de destino:"
read path_destiny

echo "Digite o nome da saída de log:"
read log_name

# Definicão dos logs
mkdir -p log
log_output="log/$log_name"
log_error="log/erro.log"

# Confirmação do usuário para copiar
echo ""
echo "Confirme para iniciar a cópia '$path_origin' --> '$path_destiny' "
read -p "Deseja continuar? (s/n): " resp
if [[ "$resp" != "s" && "$resp" != "S" && "$resp" != "Sim" && "$resp" != "SIM" && "$resp" != "sim" ]]; then
    echo "Operação cancelada."
    exit 1
fi

# Realiza a cópia e faz o tratamento de erros
rsync -av "$path_origin/" "$path_destiny/" 2>>"$log_error"
return=$?

if [ $return -ne 0 ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Erro na cópia do diretório: $path_origin (código $return)" >>"$log_error"
    exit $return
fi

cd $path_origin || { echo "Erro ao acessar o diretório de origem"; exit 1; }

# Inicia a identificação e validação dos arquivos
echo ""
echo "Iniciando a validação dos arquivos copiados"
echo "...Aguarde..."

for file in $(find .  -type f |cut -c 2-)
do	
		md5_origin=$(md5sum $path_origin/$file |awk '{print $1}')
		md5_destiny=$(md5sum $path_destiny/$file |awk '{print $1}')

		if [ $md5_origin == $md5_destiny ]
		then
			printf "%-15s %-15s %-15s %-15s\n" $file $md5_origin $md5_destiny 'OK' >> $log_output
		else
			printf "%-15s %-15s %-15s %-15s\n" $file $md5_origin $md5_destiny 'ERRO' >> $log_output
		fi
done

echo ""
echo "Cópia e Validação do diretório $path_origin concluída."
echo "Log salvo em $log_output" 
echo "Gerado em $(date '+%Y-%m-%d %H:%M:%S')"

exit