# README - Sistema de Gerenciamento de Ativos de TI

## Visão Geral
Este sistema foi projetado para gerenciar ativos de TI, incluindo hardware, ferramentas e dispositivos, com controle de transferências entre setores e usuários. O sistema mantém um registro completo (log) de todas as operações realizadas.

## Estrutura do Banco de Dados

### Tabelas Principais

1. **Log de Operações**
   - Registra todas as transações do sistema
   - Campos: data/hora, tipo de operação, quantidade, origem, destino, categoria, tipo

2. **Formulário de Itens**
   - Cadastro de todos os itens gerenciados
   - Campos: ID, tipo (pessoal/não-pessoal), nome, quantidade, tipo de quantidade, origem

3. **Hardware**
   - Itens de hardware específicos
   - Campos: ID, nome, quantidade, origem, local, tipo (Notebook/Desktop)

4. **Dispositivos**
   - Dispositivos diversos
   - Campos: ID, nome, quantidade, origem, local

5. **Setores**
   - Divisões organizacionais
   - Campos: nome, pendências, andar

6. **Categorias**
   - Terminais, Conexões, Hardware, Periféricos, Dispositivos

## Fluxos Principais

### Transferência de Itens
1. Selecionar item (ferramenta, peça de hardware ou dispositivo)
2. Especificar quantidade
3. Definir origem (usuário, estoque, descarte)
4. Definir destino (usuário, estoque, descarte)
5. Registrar observações

### Tipos de Operações
- Inserção: Adição de novos itens ao sistema
- Transferência: Movimentação entre origens/destinos
- Descarte: Remoção de itens do inventário ativo

## Convenções

### Nomenclatura de Itens
- **Hardware**: Seguir padrão "Tipo Marca Modelo" (ex: "Fonte Acer MXYZ")
- **Dispositivos**: Nome descritivo (ex: "Rolander Citro")
- **Conexões**: Tipo + especificação (ex: "Cabo VGA 2.0m")

### Códigos de Identificação
- Formato: 00001 (5 dígitos)
- Sequencial único para cada tabela

## Exemplos de Uso

### Registrar Transferência
```sql
INSERT INTO log_operacoes VALUES (
    '00001',
    CURRENT_TIMESTAMP,
    'transferir',
    1,
    'estoque',
    'hardware',
    'Marcela Atendimento',
    'Fonte Acer MXYZ',
    'Transferência para atendimento ao cliente'
);
```

### Consultar Itens em Estoque
```sql
SELECT * FROM hardware 
WHERE origem = 'estoque' AND quantidade > 0
ORDER BY nome;
```

## Status de Itens
- **Estoque**: Disponível para uso
- **Usuário**: Atribuído a uma pessoa
- **Descarte**: Não está mais em condições de uso

## Setores
- Atendimento
- NOC
- Protopel
- Mene

## Requisitos do Sistema
- Banco de dados SQL (MySQL, PostgreSQL ou similar)
- Interface para registro de operações
- Relatórios de inventário e movimentação

## Observações
- O sistema mantém histórico completo de todas as operações
- Cada item pode ter seu tipo de quantidade específico (unidades, kg, litros)
- A localização física dos itens é rastreada (estoque, setor específico)