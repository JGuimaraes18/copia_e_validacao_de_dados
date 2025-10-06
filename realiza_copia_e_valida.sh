#!/bin/bash   
##########################################################################################
# Script para realizar a cópia de um diretório e validar os arquivos copiados via md5sum #
# Autor: João Guimarães																	 #
# Data: 2025-10-06																	  	 #
# Versão: 1.0											 	 				  			 #	
##########################################################################################

# Interação de entrada com o usuário
echo "Digite o diretório de origem:"
read path_origem

echo "Digite o diretório de destino:"
read path_destino

# Definicão dos logs
dir=$(basename $path_origem)
mkdir -p log
log_saida="log/$dir.log"
log_erro="log/erro.log"

# Confirmação do usuário para copiar
echo ""
echo "Confirme para iniciar a cópia '$path_origem' --> '$path_destino' "
read -p "Deseja continuar? (s/n): " resp
if [[ "$resp" != "s" && "$resp" != "S" && "$resp" != "Sim" && "$resp" != "SIM" && "$resp" != "sim" ]]; then
    echo "Operação cancelada."
    exit 1
fi

# Realiza a cópia e faz o tratamento de erros
rsync -av "$path_origem/" "$path_destino/" 2>>"$log_erro"
ret=$?

if [ $ret -ne 0 ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Erro na cópia do diretório: $path_origem (código $ret)" >>"$log_erro"
    exit $ret
fi

cd $path_origem || { echo "Erro ao acessar o diretório de origem"; exit 1; }

# Inicia a identificação e validação dos arquivos
echo ""
echo "Iniciando a validação dos arquivos copiados"
echo "...Aguarde..."

for file in $(find .  -type f |cut -c 2-)
do	
		md5_origem=$(md5sum $path_origem/$file |awk '{print $1}')
		md5_destino=$(md5sum $path_destino/$file |awk '{print $1}')

		if [ $md5_origem == $md5_destino ]
		then
			printf "%-15s %-15s %-15s %-15s\n" $file $md5_origem $md5_destino 'OK' >> $log_saida
		else
			printf "%-15s %-15s %-15s %-15s\n" $file $md5_origem $md5_destino 'ERRO' >> $log_saida
		fi
done

echo ""
echo "Cópia e Validação do diretório $path_origem concluída."
echo "Log salvo em $log_saida" 
echo "Gerado em $(date '+%Y-%m-%d %H:%M:%S')"

exit