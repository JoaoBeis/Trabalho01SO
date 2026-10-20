# Trabalho01SO

**Evolução do trabalho:**

Primeiramente, decidimos começar por definir a lógica do script que consegue distinguir e executar o programa de acordo com os argumentos e flags passadas após o `./vp.sh`. Para isso, recorremos ao comando `getopts` recomendado no enunciado do guião, pois este comando permite analisar e validar flags seguindo um padrão que permite distingur as flags booleanas das flags que exigem um argumento ao serem passadas (guardando automaticamente esse valor na variável interna `$OPTARG`). Este comando também permite agrupar flags (eg: `-vf`), e usando o prefixo `:` no início das opções do `getopts` podemos tratar de erros devido a opções inválidas ou à falta de argumentos obrigatórios.

Após elaborarmos esta parte do script, surgiu um problema: a flag `-p` tem de permitir que sejam passados mais do que um argumento. Ora como o comando `getopts` só consegue processar um argumento por flag, adaptámos a nossa ideia inicial, cuja lógica consiste em colocá-lo dentro de um ciclo `while` com o objetivo de processar cada flag num ciclo while. A vantagem disto é que após cada iteração do `getopts`, é ainda analisada a estrutura da flag atual (se é boolean, tem 1 argumento, ou mais argumentos), o que permite depois usar variáveis adequadas, como booleans ou listas, para guardar num conjunto de variáveis quais flags e respetivos argumentos foram passados no terminal. Depois podemos usar os valores guardados nestas variáveis para desenvolver a lógica de cada comando. 

