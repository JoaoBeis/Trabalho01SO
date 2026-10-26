#!/bin/bash

modo_p=false
modo_v=false
ficheiro_bd="/tmp/.pdb"
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
            f) ficheiro_bd="$OPTARG" ;; 
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

if [ "$modo_p" = true ] && [ "$modo_v" = true ]; then # se for introduzido -p e -v nao pode
    echo "Não é possível introduzir -p e -v simultaneamente."
    msg_erro
    exit 1
fi

if [ "$modo_p" = false ] && [ "$modo_v" = false ]; then # se não for introduzido nem -p nem -v automaticamente é implementado o a flag -v
    modo_v=true
fi

function obter_metadados() { # aqui a permissao aparece na forma --rw--r e supostamente devia aparecer 755, 644..
    local ficheiro="$1"

    local user=$(ls -l "$ficheiro" | awk '{print $3}')
    local group=$(ls -l "$ficheiro" | awk '{print $4}')
    local size=$(ls -l "$ficheiro" | awk '{print $5}')
    local perm=$(ls -l "$ficheiro" | awk '{print $1}')
    local sha256=$(sha256sum "$ficheiro" | awk '{print $1}')

    # Retorna tudo numa linha separado por |
    echo " USER=$user,  GROUP=$group,   SIZE=$size,  PERM =$perm, SHA256=$sha256"
}

function excluir() {
    case "$1" in 
        $padrao_ignorar) continue ;; # ignora o $padrao_ignorar (argumento da funcao: $1)
    esac
}

function proteger() {
    if [ ${#dir[@]} -eq 0 ]; then  # se o numero de diretorios for igual a 0 
        echo "Tem de ser indicado algum diretorio."
        msg_erro
        exit 1
    fi

    if ! : > "$ficheiro_bd"; then
        echo "Não foi possível criar a base de dados."
        exit 1
    fi

    ficheiros=0

    for diretorio in "${dir[@]}"; do

        if [ ! -d "$diretorio" ]; then 
            echo " O diretório '$diretorio' não existe."
            continue
        fi
        
        for ficheiro in "$diretorio"/*; do

            if [ -f "$ficheiro" ]; then
        
                if [ -n "$padrao_ignorar" ]; then # se -e foi chamado
                    excluir "$ficheiro"
                fi

                metadados=$(obter_metadados "$ficheiro")

                if [ $? -eq 0 ]; then
                    echo "$ficheiro|$metadados" >> "$ficheiro_bd" # 
                    ficheiros=$((ficheiros + 1))
                else
                    echo " Não é possível obter_metadados de '$ficheiro'."
                fi
            fi
        done
    done

    echo "Base de dados de proteção $ficheiro_bd criada com sucesso."
    echo "Ficheiros processados: $ficheiros | Diretórios protegidos: ${dir[*]}"
}

function verificar() {
    if [ ! -f "$ficheiro_bd" ]; then 
        echo " A base de dados '$ficheiro_bd' não existe, tem de ser criada com a flag -p."
        exit 1 # termina com erro
    fi

    local verificados=0 modificados=0 apagados=0 novos=0 # variaveis que so existem dentro da função logo usamos local
    local linha ficheiro guardado atual desc d # linha da base de dados lida/ o caminho do ficheiro/ os metadados antigos e os novos
    local sep="-----------------------------------------------------------------------------------------------------------------------------"
    
    while IFS= read -r linha; do          # 1. lê uma linha
        ficheiro=${linha%%|*}             # 2. separa o caminho
        guardado=${linha#*|}

        if [ -n "$padrao_ignorar" ]; then
            excluir
        fi

        verificados=$((verificados+1))

        if [ ! -f "$ficheiro" ]; then
            alerta "$ficheiro foi APAGADO"
            echo " Informação inicial: $guardado"
            echo " Informação atual: [Ficheiro não encontrado no sistema]"
            removidos=$((removidos + 1))
            continue
        fi
        
        atual=$(obter_metadados "$ficheiro")

        if [ "$atual" = "$guardado" ]; then
            bons=$((bons + 1))
        else
            alerta "ALTERADO: $ficheiro"
            alterados=$((alterados + 1))
        fi              
    
    done < "$ficheiro_bd"

    echo "Verificação concluída: $bons sem alterações | $alterados alterados | $removidos removidos"

    [ $((alterados + removidos)) -eq 0 ]
}   

function alerta() {
    echo "$1"
    if [ "$usar_logger" = true ]; then 
        logger -p user.alert -t vp "$1" # -p defininimos o nivel de prioridade o -t é para colcoar o programa vp a gerar o log
    fi
}