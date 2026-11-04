#!/bin/bash

# Cores para destacar os passos e comandos no terminal
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
MAGENTA='\033[1;35m'
NC='\033[0m'

TEST_DIR="/tmp/demo_vp"
BD="/tmp/.pdb_demo"

echo -e "${CYAN}====================================================${NC}"
echo -e "${CYAN}   DEMONSTRAÇÃO DE FUNCIONALIDADES - VIGIA PIRATA   ${NC}"
echo -e "${CYAN}====================================================${NC}"

# 1. PREPARAÇÃO DO AMBIENTE
echo -e "\n${YELLOW}[PASSO 1] A criar estrutura inicial de ficheiros de teste...${NC}"
echo -e "${GREEN}➜ Comandos de preparação do ambiente:${NC}"
echo -e "   ${MAGENTA}mkdir -p $TEST_DIR/documentos${NC}"
echo -e "   ${MAGENTA}echo \"...\" > $TEST_DIR/ficheiro1.txt${NC}"
echo -e "   ${MAGENTA}echo \"...\" > $TEST_DIR/ficheiro2.txt${NC}"
echo -e "   ${MAGENTA}echo \"...\" > $TEST_DIR/documentos/manual.txt${NC}"
echo -e "   ${MAGENTA}echo \"...\" > $TEST_DIR/app.log${NC}"

rm -rf "$TEST_DIR" "$BD"
mkdir -p "$TEST_DIR/documentos"

echo "Conteudo inicial do ficheiro 1" > "$TEST_DIR/ficheiro1.txt"
echo "Conteudo inicial do ficheiro 2" > "$TEST_DIR/ficheiro2.txt"
echo "Ficheiro dentro da subpasta" > "$TEST_DIR/documentos/manual.txt"
echo "Log de sistema" > "$TEST_DIR/app.log"

echo -e "\nConteúdo da pasta $TEST_DIR:"
ls -la "$TEST_DIR"
ls -la "$TEST_DIR/documentos"

# 2. CRIAÇÃO DA BASE DE DADOS DE PROTEÇÃO (-p, -f, -e)
echo -e "\n${YELLOW}[PASSO 2] A executar o vp.sh em modo de PROTEÇÃO (-p)...${NC}"
echo -e "${GREEN}➜ Comando executado:${NC} ${MAGENTA}./vp.sh -p $TEST_DIR -f $BD -e \"*.log\"${NC}"
./vp.sh -p "$TEST_DIR" -f "$BD" -e "*.log"

echo -e "\n--- Conteúdo gerado na Base de Dados ($BD) ---"
cat "$BD"

# 3. SIMULAÇÃO DE ALTERAÇÕES NO SISTEMA (INTRUSÃO)
echo -e "\n${YELLOW}[PASSO 3] A simular alterações no sistema de ficheiros...${NC}"
echo -e "${GREEN}➜ Comandos de alteração executados:${NC}"
echo -e "   1. ${MAGENTA}echo \" Alterado!\" >> $TEST_DIR/ficheiro1.txt${NC}"
echo -e "   2. ${MAGENTA}chmod 777 $TEST_DIR/ficheiro2.txt${NC}"
echo -e "   3. ${MAGENTA}rm $TEST_DIR/documentos/manual.txt${NC}"
echo -e "   4. ${MAGENTA}echo \"Sou um ficheiro novo\" > $TEST_DIR/ficheiro_novo.txt${NC}"
echo -e "   5. ${MAGENTA}echo \"Outro log\" > $TEST_DIR/novo.log${NC}"

echo " Alterado!" >> "$TEST_DIR/ficheiro1.txt"
chmod 777 "$TEST_DIR/ficheiro2.txt"
rm "$TEST_DIR/documentos/manual.txt"
echo "Sou um ficheiro novo" > "$TEST_DIR/ficheiro_novo.txt"
echo "Outro log" > "$TEST_DIR/novo.log"

# 4. VERIFICAÇÃO DE ALTERAÇÕES (-v, -f, -e, -s)
echo -e "\n${YELLOW}[PASSO 4] A executar o vp.sh em modo de VERIFICAÇÃO (-v)...${NC}"
echo -e "${GREEN}➜ Comando executado:${NC} ${MAGENTA}./vp.sh -v -f $BD -e \"*.log\" -s${NC}"
./vp.sh -v -f "$BD" -e "*.log" -s

echo -e "\n${GREEN}➜ Comando para consultar os registos no Syslog:${NC} ${MAGENTA}journalctl -t vp -n 5 --no-pager${NC}"
journalctl -t vp -n 5 --no-pager

# 5. TESTE DE ERROS DE SINTAXE E ARGUMENTOS INVÁLIDOS
echo -e "\n${YELLOW}[PASSO 5] A testar validações de erro e argumentos inválidos...${NC}"

echo -e "\n${GREEN}A) Testar -p e -v simultaneamente:${NC}"
echo -e "${GREEN}➜ Comando executado:${NC} ${MAGENTA}./vp.sh -p $TEST_DIR -v${NC}"
./vp.sh -p "$TEST_DIR" -v

echo -e "\n${GREEN}B) Testar opção inexistente (-x):${NC}"
echo -e "${GREEN}➜ Comando executado:${NC} ${MAGENTA}./vp.sh -x${NC}"
./vp.sh -x

echo -e "\n${GREEN}C) Testar flag que exige argumento sem o fornecer (-f):${NC}"
echo -e "${GREEN}➜ Comando executado:${NC} ${MAGENTA}./vp.sh -f${NC}"
./vp.sh -f

echo -e "\n${GREEN}D) Testar proteção (-p) sem especificar diretórios:${NC}"
echo -e "${GREEN}➜ Comando executado:${NC} ${MAGENTA}./vp.sh -p${NC}"
./vp.sh -p

echo -e "\n${GREEN}E) Testar verificação (-v) com BD inexistente:${NC}"
echo -e "${GREEN}➜ Comando executado:${NC} ${MAGENTA}./vp.sh -v -f /tmp/bd_inexistente_999.pdb${NC}"
./vp.sh -v -f /tmp/bd_inexistente_999.pdb

echo -e "\n${GREEN}F) Testar proteção de um diretório que não existe no sistema:${NC}"
echo -e "${GREEN}➜ Comando executado:${NC} ${MAGENTA}./vp.sh -p /tmp/diretorio_que_nao_existe_123 -f $BD${NC}"
./vp.sh -p /tmp/diretorio_que_nao_existe_123 -f "$BD"

# LIMPEZA FINAL
rm -rf "$TEST_DIR" "$BD"
echo -e "\n${CYAN}====================================================${NC}"
echo -e "${CYAN}        DEMONSTRAÇÃO CONCLUÍDA COM SUCESSO          ${NC}"
echo -e "${CYAN}====================================================${NC}"