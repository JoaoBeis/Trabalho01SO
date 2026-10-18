#!/bin/bash

modo_p=false
modo_v=false
ficheiro_db="/tmp/.pdb"
padrao_ignorar=""
usar_logger=false
dir=()

function msg_erro()
{
    echo "Uso: ./vp [{-p <dir1[<dir2>...] | -v}] [-f <ficheiro>] [-e <ignore_pattern>] [-s]"
    echo "       -p : Protege e guarda informação acerca de um ou mais diretórios"
    echo "       -v : Verifica alterações em ficheiros desde que foram protegidos"
    echo "       -f : Indicação do nome do ficheiro onde a base de dados será guardada (Por defeito será tmp/.pdb)"
    echo "       -e : Permite a exclusão de ficheiros voláteis (ex. *.tmp, *.log, /tmp/*) da proteção e verificação"
    echo "       -s : Emissão de alertas de alta prioridade para o sistema de logging usando o logger"
}

# executa enquanto existirem argumentos na linha de comandos
while [ $# -gt 0 ]; do

    # o getopts processa todas as flags seguidas até encontrar um argumento sem "-"
    while getopts ":pvf:e:s" opt; do
        case "$opt" in
            p) modo_p=true ;;
            v) modo_v=true ;;
            f) ficheiro_db="$OPTARG" ;; 
            e) padrao_ignorar="$OPTARG" ;;
            s) usar_logger=true ;;
            \?) echo "Invalid switch -$OPTARG"; msg_erro; exit 1 ;;
            :)  echo "Falta argumento para -$OPTARG"; msg_erro; exit 1 ;;
        esac
    done

    # elimina da linha de comandos as flags que o getopts acabou de ler
    shift $((OPTIND - 1))

    # se ainda sobrar algum argumento, significa que o getopts parou num diretório (argumento de -p)
    if [ $# -gt 0 ]; then
        dir+=("$1") # guarda o diretório no array (argumento de -p)
        shift              # avança 1 argumento para "consumir" o diretório (argumento de -p)
        OPTIND=1           # reinicia o índice do getopts para ele voltar a procurar flags
    fi
done

if [ "$modo_p" = true ] && [ "$modo_v" = true ]; then
    echo "Não é possível introduzir -p e -v simultaneamente."
    msg_erro
    exit 1
fi

if [ "$modo_p" = false ] && [ "$modo_v" = false ]; then 
    modo_v=true
fi

function obter_metadados() {
    local ficheiro="$1"

    local user=$(ls -l "$ficheiro" | awk '{print $3}')
    local group=$(ls -l "$ficheiro" | awk '{print $4}')
    local size=$(ls -l "$ficheiro" | awk '{print $5}')
    local perm=$(ls -l "$ficheiro" | awk '{print $1}')
    local sha256=$(sha256sum "$ficheiro" | awk '{print $1}')

    # Retorna tudo numa linha separado por |
    echo "$user|$group|$size|$perm|$sha256"
}


function proteger(){
    if [ ${dir[@]} -eq 0 ]; then
        echo " Tem de ser indicado algum diretorio."
        msg_erro
        exit 1
    fi

    > "$ficheiro_db"
}