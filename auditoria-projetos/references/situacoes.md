# Cinco situações que aparecem sempre

Use quando o usuário descrever um sintoma em vez de pedir auditoria completa, ou para priorizar na etapa 3.

## 1. Leu os 111 e travou

A lista é grande, tudo parece urgente, o resultado foi não fazer nada.
**Saída:** rodar a auditoria e olhar só o grupo FALTA E IMPORTA AGORA. Em projeto novo costuma ter menos de dez itens, quase sempre: segredo no repositório (#67), sem backup testado (#84), sem índice no banco (#25), query N+1 (#27), CORS errado (#76), sem jeito de voltar atrás (#55).

## 2. O app funciona na máquina e morre com duas pessoas

Testou sozinho, estava perfeito; subiu, dois usuários entraram e começou a dar erro que não reproduz.
**Saída:** quase sempre é o Bloco 2: condição de corrida (#39), pool de conexões estourado (#28) ou query N+1 (#27) que só aparece com volume. Comece contando quantas consultas o banco recebe por requisição; essa medida denuncia os três.

## 3. A conta da nuvem veio muito maior que o esperado

Poucos usuários e a fatura não bate.
**Saída:** os suspeitos são os mesmos: sem cache (#2) e todo mundo bate no banco; sem CDN (#48, #49) e o servidor entrega imagem; algo ligado sem ninguém usar (#88). Ligar o alerta de orçamento **antes** de otimizar qualquer coisa.

## 4. Há backup, mas nunca foi restaurado

O painel diz que rodou todo dia; ninguém nunca tentou trazer de volta.
**Saída:** backup que nunca foi restaurado é suposição (#84). Marcar uma hora, restaurar numa base separada e conferir se os dados estão lá. É o teste mais barato do checklist inteiro.

## 5. O alerta dispara e ninguém sabe o que fazer

Chegou a notificação de madrugada; quem está de plantão abre o painel e não sabe por onde começar.
**Saída:** alerta sem procedimento escrito é só barulho (#62, #109, #110, #111). Para cada alerta, escrever junto: o que significa, o que olhar primeiro e o que fazer para estancar o problema. Se não dá para escrever, o alerta provavelmente não deveria acordar ninguém.
