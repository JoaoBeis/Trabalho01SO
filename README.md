# Trabalho01SO

**Notas:**

Fazer diagramas de arquitetura (flowcharts) para o funcionamento pela prespetiva do utilizador e do código.

**Evolução do trabalho:**

Primeiramente, decidimos começar por definir a lógica do script que consegue distinguir e executar o programa de acordo com os argumentos e flags passadas após o `./vp.sh`. Para isso, recorremos ao comando `getopts` recomendado no enunciado do guião, pois este comando permite analisar e validar flags seguindo um padrão que permite distingur as flags booleanas das flags que exigem um argumento ao serem passadas (guardando automaticamente o valor do argumento na variável interna `$OPTARG`). Este comando também permite agrupar flags (eg: `-vf`), e usando o prefixo `:` no início das opções do `getopts` podemos tratar de erros originados por opções inválidas ou à falta de argumentos obrigatórios.

Após elaborarmos esta parte do script, surgiu um problema: a flag `-p` tem de permitir que sejam passados mais do que um argumento. Ora como o comando `getopts` só consegue processar um argumento por flag, adaptámos a nossa ideia inicial, cuja lógica consiste em colocá-lo dentro de um ciclo `while` com o objetivo de processar cada flag num ciclo while. A vantagem disto é que após cada iteração do `getopts`, é ainda analisada a estrutura da flag atual (se é boolean, se tem 1 argumento, ou se tem mais que 1 argumentos), o que permite depois usar variáveis adequadas, como booleans ou listas, para guardar num conjunto de variáveis quais flags e respetivos argumentos foram passados no terminal. Depois podemos usar os valores guardados nestas variáveis para desenvolver a lógica de cada comando. 

Depois de termos a leitura dos argumentos a funcionar, passámos para a criação das funções principais do modo de proteção (`-p`).

Criámos a função `obter_metadados` para ir buscar a informação necessária de cada ficheiro: dono (`USER`), grupo (`GROUP`), tamanho (`SIZE`), permissões (`PERM`) e a hash `sha256sum` (para detetar alterações no conteúdo).

Para resolver a questão do formato das permissões devolvidas pelo `ls -l` (que surgem em formato textual, ex: `-rw-r--r--`), criámos a função auxiliar `calcular_perm()`. Esta função analisa os caracteres das permissões por blocos de 3 bits (Dono, Grupo, Outros) e calcula o seu valor numérico correspondente (soma de 4 para `r`, 2 para `w` e 1 para `x`), convertendo a string textual para a notação octal padrão (ex: `755` ou `644`). Esta conversão é depois integrada na função `obter_metadados`, juntamente com a extração dos campos `USER`, `GROUP`, `SIZE` e a hash `SHA256`.

Desenvolvemos a função `proteger` para criar a base de dados de proteção: 
1. Confirma se a lista de diretórios `dir` tem pelo menos um item (se estiver vazia, mostra a mensagem de erro e cancela). Em seguida, cria ou limpa o ficheiro da base de dados (`/tmp/.pdb` por defeito ou o ficheiro indicado na flag `-f`).
2. Percorre os diretórios e os ficheiros dentro deles, e se a flag `-e` tiver sido passada, verifica se algum ficheiro coincide com o padrão a ignorar (ex: `*.log`) e, se coincidir, ignora-o sem o guardar.
3. Para cada ficheiro válido, chama a função `obter_metadados` e escreve a linha formatada no ficheiro de base de dados.
4. No fim de processar tudo, mostra a mensagem de confirmação no terminal com o total de ficheiros processados e os diretórios protegidos.

Quando começámos a trabalhar na função `verificar` percebemos que a lógica da função da flag `e` era igual, e para evitar código duplicado colocámos essa lógica numa função dedicada `excluir`, que recebe como argumento o caminho do ficheiro que está a ser analisado de momento no loop for. Depois compara esse ficheiro ao `$padrao_ignorar`, e caso sejam iguais, a função retorna 0, caso contrário retorna 1. Por defeito, se `-e` não for chamado ou não receber argumento, a função `excluir` retorna 1.
Na função `proteger`, no início de cada ciclo for é testada a função `excluir`, e caso esta retorne 0 (true), temos um `continue` que salta para a próxima iteração, logo, ignora essa ficheiro, como pretendido.
Na função `verificar` temos de usar a função `excluir` duas vezes: uma durante a leitura dos ficheiros que estão na base de dados de proteção, e outra na leitura dos ficheiros protegidos no sistema. Isto permite ao utilizador ignorar ficheiros que ele sabe que foram alterados ou adicionados, tanto na perspetiva da base de dados de proteção, tal como na dos ficheiros do sistema que estão a ser analisados.

Com isto, passámos para a função `verificar`, que dividimos em duas partes:
1. Primeiro, lemos a base de dados linha a linha. Para cada ficheiro registado, começamos por passar pela função `excluir` para ver se é para ignorar. Se não for, confirmamos se o ficheiro ainda existe no disco — se tiver desaparecido, conta como apagado. Se ainda lá estiver, calculamos os metadados atuais e comparamos com os guardados. Quando há diferenças, usamos o comando `diff` sobre os metadados e usamos o `grep` para perceber exatamente o que mudou (se foi a Posse com `USER`/`GROUP`, as Permissões com `PERM`, ou o Conteúdo com `SIZE`/`SHA256`), criando uma descrição bem clara da alteração.
2. A segunda parte do `verificar` serve para apanhar ficheiros novos. Para isso, fomos buscar os diretórios protegidos que ficaram gravados na base de dados (usando `cut`, `dirname` e `sort -u`) e percorremos o que está atualmente dentro dessas pastas no disco. Voltamos a passar a função `excluir` para não considerar ficheiros temporários novos e comparamos a lista de ficheiros do disco com a lista que tínhamos na base de dados usando o `diff`. Os ficheiros que aparecem no disco mas não estavam na base de dados são assinalados como novos. No fim de tudo, a função mostra um resumo com o total de ficheiros verificados, modificados, apagados e novos.

Por último, criámos a função `alerta` para concentrar numa função a impressão das mensagens no terminal sempre que é detetada alguma alteração. Além de mostrar o texto no ecrã, esta função verifica se a flag `-s` foi ativada na linha de comandos. Se tiver sido ativada, envia também o aviso diretamente para os logs do sistema operativo usando o comando `logger -p user.alert -t vp`.