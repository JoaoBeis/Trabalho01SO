#!/bin/bash

# Cores do Test Runner (testes.sh)
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
MAGENTA='\033[1;35m'
WHITE='\033[1;37m'
NC='\033[0m' # Reset para cor padrão

TEST_DIR1="/tmp/demo_vp1"
TEST_DIR2="/tmp/demo_vp2"
BD="/tmp/.pdb_demo"

echo -e "${CYAN}====================================================${NC}"
echo -e "${CYAN}   DEMONSTRAÇÃO DE FUNCIONALIDADES - VIGIA PIRATA   ${NC}"
echo -e "${CYAN}====================================================${NC}"

# 1. PREPARAÇÃO DO AMBIENTE (MÚLTIPLOS DIRETÓRIOS)
echo -e "\n${YELLOW}[PASSO 1] A criar estrutura inicial em múltiplos diretórios de teste...${NC}"
echo -e "${GREEN}➜ Comandos de preparação do ambiente:${NC}"
echo -e "   ${MAGENTA}mkdir -p $TEST_DIR1/documentos $TEST_DIR2/backup${NC}"
echo -e "   ${MAGENTA}echo \"...\" > $TEST_DIR1/ficheiro1.txt${NC}"
echo -e "   ${MAGENTA}echo \"...\" > $TEST_DIR1/ficheiro2.txt${NC}"
echo -e "   ${MAGENTA}echo \"...\" > $TEST_DIR1/documentos/manual.txt${NC}"
echo -e "   ${MAGENTA}echo \"...\" > $TEST_DIR1/app.log${NC}"
echo -e "   ${MAGENTA}echo \"...\" > $TEST_DIR2/backup/dados.txt${NC}"

rm -rf "$TEST_DIR1" "$TEST_DIR2" "$BD"
mkdir -p "$TEST_DIR1/documentos" "$TEST_DIR2/backup"

echo "Conteudo inicial do ficheiro 1" > "$TEST_DIR1/ficheiro1.txt"
echo "Conteudo inicial do ficheiro 2" > "$TEST_DIR1/ficheiro2.txt"
echo "Ficheiro dentro da subpasta" > "$TEST_DIR1/documentos/manual.txt"
echo "Log de sistema" > "$TEST_DIR1/app.log"
echo "Ficheiro no segundo diretorio" > "$TEST_DIR2/backup/dados.txt"

echo -e "\n${GREEN}➜ Estrutura e conteúdo dos diretórios criados:${NC}"
echo -ne "${WHITE}"
echo "➜ Diretório Principal 1: $TEST_DIR1"
ls -la "$TEST_DIR1"
echo -e "\n➜ Subpasta 1: $TEST_DIR1/documentos"
ls -la "$TEST_DIR1/documentos"
echo -e "\n➜ Diretório Principal 2: $TEST_DIR2/backup"
ls -la "$TEST_DIR2/backup"
echo -ne "${NC}"

# 2. CRIAÇÃO DA BASE DE DADOS DE PROTEÇÃO (-p com Múltiplos Diretórios, -f, -e)
echo -e "\n${YELLOW}[PASSO 2] A executar o vp.sh em modo de PROTEÇÃO (-p) com MÚLTIPLOS DIRETÓRIOS...${NC}"
echo -e "${GREEN}➜ Comando executado:${NC} ${MAGENTA}./vp.sh -p $TEST_DIR1 $TEST_DIR2 -f $BD -e \"*.log\"${NC}"
echo -ne "${WHITE}"
./vp.sh -p "$TEST_DIR1" "$TEST_DIR2" -f "$BD" -e "*.log"
echo -ne "${NC}"

echo -e "\n${GREEN}➜ Conteúdo gerado na Base de Dados ($BD):${NC}"
echo -ne "${WHITE}"
cat "$BD"
echo -e "\n${GREEN}➜ Verificação imediata, sem alterações (esperado: 0 modificados e código de saída 0):${NC}"
echo -e "${GREEN}➜ Comando executado:${NC} ${MAGENTA}./vp.sh -v -f $BD -e \"*.log\"${NC}"
echo -ne "${WHITE}"
./vp.sh -v -f "$BD" -e "*.log"
echo "Código de saída: $?"
echo -ne "${NC}"
echo -ne "${NC}"

# 3. SIMULAÇÃO DE ALTERAÇÕES NO SISTEMA (INTRUSÃO EM AMBOS OS DIRETÓRIOS)
echo -e "\n${YELLOW}[PASSO 3] A simular alterações no sistema de ficheiros (em ambos os diretórios)...${NC}"
echo -e "${GREEN}➜ Comandos de alteração executados:${NC}"
echo -e "   1. ${MAGENTA}echo \" Alterado!\" >> $TEST_DIR1/ficheiro1.txt${NC}"
echo -e "   2. ${MAGENTA}chmod 777 $TEST_DIR1/ficheiro2.txt${NC}"
echo -e "   3. ${MAGENTA}rm $TEST_DIR1/documentos/manual.txt${NC}"
echo -e "   4. ${MAGENTA}echo \"Sou um ficheiro novo em DIR1\" > $TEST_DIR1/ficheiro_novo.txt${NC}"
echo -e "   5. ${MAGENTA}echo \"Outro log\" > $TEST_DIR1/novo.log${NC}"
echo -e "   6. ${MAGENTA}echo \" Alterado em DIR2!\" >> $TEST_DIR2/backup/dados.txt${NC}"
echo -e "   7. ${MAGENTA}echo \"Novo ficheiro em DIR2\" > $TEST_DIR2/backup/novo_dir2.txt${NC}"
echo -e "   8. ${MAGENTA}touch -d \"2020-01-01 12:00:00\" $TEST_DIR1/ficheiro2.txt${NC}"

sleep 1   # garante que o MTIME muda (resolução de 1 segundo)
echo " Alterado!" >> "$TEST_DIR1/ficheiro1.txt"
chmod 777 "$TEST_DIR1/ficheiro2.txt"
rm "$TEST_DIR1/documentos/manual.txt"
echo "Sou um ficheiro novo em DIR1" > "$TEST_DIR1/ficheiro_novo.txt"
echo "Outro log" > "$TEST_DIR1/novo.log"
echo " Alterado em DIR2!" >> "$TEST_DIR2/backup/dados.txt"
echo "Novo ficheiro em DIR2" > "$TEST_DIR2/backup/novo_dir2.txt"
touch -d "2020-01-01 12:00:00" "$TEST_DIR1/ficheiro2.txt"

# 4. VERIFICAÇÃO DE ALTERAÇÕES (-v, -f, -e, -s)
echo -e "\n${YELLOW}[PASSO 4] A executar o vp.sh em modo de VERIFICAÇÃO (-v)...${NC}"
echo -e "${GREEN}➜ Comando executado:${NC} ${MAGENTA}./vp.sh -v -f $BD -e \"*.log\" -s${NC}"
echo -ne "${WHITE}"
./vp.sh -v -f "$BD" -e "*.log" -s
codigo=$?
echo -ne "${NC}"
echo -e "\n${GREEN}➜ Código de saída da verificação:${NC} ${WHITE}$codigo${NC} (1 = foram detetadas alterações)"

echo -e "\n${GREEN}➜ Modo por omissão (sem -v) e opções agrupadas (-vf), mostrando só o resumo:${NC}"
echo -e "${GREEN}➜ Comandos executados:${NC} ${MAGENTA}./vp.sh -f $BD -e \"*.log\" | tail -n 1${NC}"
echo -e "                      ${MAGENTA}./vp.sh -vf $BD -e \"*.log\" | tail -n 1${NC}"
echo -ne "${WHITE}"
./vp.sh -f "$BD" -e "*.log" | tail -n 1
./vp.sh -vf "$BD" -e "*.log" | tail -n 1
echo -ne "${NC}"

echo -e "\n${GREEN}➜ Comando para consultar os registos no Syslog:${NC} ${MAGENTA}journalctl -t vp -n 6 --no-pager${NC}"
echo -ne "${WHITE}"
journalctl -t vp -n 6 --no-pager
echo -ne "${NC}"

# 5. TESTE DE ERROS DE SINTAXE E ARGUMENTOS INVÁLIDOS
echo -e "\n${YELLOW}[PASSO 5] A testar validações de erro e argumentos inválidos...${NC}"

echo -e "\n${GREEN}A) Testar -p e -v simultaneamente:${NC}"
echo -e "${GREEN}➜ Comando executado:${NC} ${MAGENTA}./vp.sh -p $TEST_DIR1 -v${NC}"
echo -ne "${WHITE}"
./vp.sh -p "$TEST_DIR1" -v
echo -ne "${NC}"

echo -e "\n${GREEN}B) Testar opção inexistente (-x):${NC}"
echo -e "${GREEN}➜ Comando executado:${NC} ${MAGENTA}./vp.sh -x${NC}"
echo -ne "${WHITE}"
./vp.sh -x
echo -ne "${NC}"

echo -e "\n${GREEN}C) Testar flag que exige argumento sem o fornecer (-f):${NC}"
echo -e "${GREEN}➜ Comando executado:${NC} ${MAGENTA}./vp.sh -f${NC}"
echo -ne "${WHITE}"
./vp.sh -f
echo -ne "${NC}"

echo -e "\n${GREEN}D) Testar proteção (-p) sem especificar diretórios:${NC}"
echo -e "${GREEN}➜ Comando executado:${NC} ${MAGENTA}./vp.sh -p${NC}"
echo -ne "${WHITE}"
./vp.sh -p
echo -ne "${NC}"

echo -e "\n${GREEN}E) Testar verificação (-v) com BD inexistente:${NC}"
echo -e "${GREEN}➜ Comando executado:${NC} ${MAGENTA}./vp.sh -v -f /tmp/bd_inexistente_999.pdb${NC}"
echo -ne "${WHITE}"
./vp.sh -v -f /tmp/bd_inexistente_999.pdb
echo -ne "${NC}"

echo -e "\n${GREEN}F) Testar proteção de um diretório que não existe no sistema:${NC}"
echo -e "${GREEN}➜ Comando executado:${NC} ${MAGENTA}./vp.sh -p /tmp/diretorio_que_nao_existe_123 -f $BD${NC}"
echo -ne "${WHITE}"
./vp.sh -p /tmp/diretorio_que_nao_existe_123 -f "$BD"
echo -ne "${NC}"

# LIMPEZA FINAL
rm -rf "$TEST_DIR1" "$TEST_DIR2" "$BD"
echo -e "\n${CYAN}====================================================${NC}"
echo -e "${CYAN}        DEMONSTRAÇÃO CONCLUÍDA COM SUCESSO          ${NC}"
echo -e "${CYAN}====================================================${NC}"