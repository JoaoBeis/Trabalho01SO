# Trabalho01SO

**Notas:**

Fazer diagramas de arquitetura (flowcharts) para o funcionamento pela prespetiva do utilizador e do código.

**Evolução do trabalho:**

Primeiramente, decidimos começar por definir a lógica do script que consegue distinguir e executar o programa de acordo com os argumentos e flags passadas após o `./vp.sh`. Para isso, recorremos ao comando `getopts` recomendado no enunciado do guião, pois este comando permite analisar e validar flags seguindo um padrão que permite distingur as flags booleanas das flags que exigem um argumento ao serem passadas (guardando automaticamente o valor do argumento na variável interna `$OPTARG`). Este comando também permite agrupar flags (eg: `-vf`), e usando o prefixo `:` no início das opções do `getopts` podemos tratar de erros originados por opções inválidas ou à falta de argumentos obrigatórios.

Após elaborarmos esta parte do script, surgiu um problema: a flag `-p` tem de permitir que sejam passados mais do que um argumento. Ora como o comando `getopts` só consegue processar um argumento por flag, adaptámos a nossa ideia inicial, cuja lógica consiste em colocá-lo dentro de um ciclo `while` com o objetivo de processar cada flag num ciclo while. A vantagem disto é que após cada iteração do `getopts`, é ainda analisada a estrutura da flag atual (se é boolean, se tem 1 argumento, ou se tem mais que 1 argumentos), o que permite depois usar variáveis adequadas, como booleans ou listas, para guardar num conjunto de variáveis quais flags e respetivos argumentos foram passados no terminal. Depois podemos usar os valores guardados nestas variáveis para desenvolver a lógica de cada comando. 

Depois de termos a leitura dos argumentos a funcionar, passámos para a criação das funções principais do modo de proteção (`-p`).

Criámos a função `obter_metadados` para ir buscar a informação necessária de cada ficheiro: dono (`USER`), grupo (`GROUP`), tamanho (`SIZE`), permissões (`PERM`) e a hash `sha256sum` (para detetar alterações no conteúdo).

Na versão atual do script, utilizamos o comando `ls -l` filtrado com o `awk` para extrair as colunas dos metadados e o `sha256sum` para a hash. Reparámos que as permissões extraídas via `ls -l` ficam em formato textual (ex: `-rw-r--r--`), por isso vamos ter de atualizar o script para as permissões ficarem em formato numérico (ex: `755` ou `644`) para ficar como é pedido.

Desenvolvemos a função `proteger` para criar a base de dados de proteção: 
1. Confirma se a lista de diretórios `dir` tem pelo menos um item (se estiver vazia, mostra a mensagem de erro e cancela). Em seguida, cria ou limpa o ficheiro da base de dados (`/tmp/.pdb` por defeito ou o ficheiro indicado na flag `-f`).
2. Percorre os diretórios e os ficheiros dentro deles, e se a flag `-e` tiver sido passada, verifica se algum ficheiro coincide com o padrão a ignorar (ex: `*.log`) e, se coincidir, ignora-o sem o guardar.
3. Para cada ficheiro válido, chama a função `obter_metadados` e escreve a linha formatada no ficheiro de base de dados.
4. No fim de processar tudo, mostra a mensagem de confirmação no terminal com o total de ficheiros processados e os diretórios protegidos.

