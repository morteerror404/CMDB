# README - Sistema de Gestão de Ativos de TI

## 📌 Visão Geral
Sistema completo para controle de ativos de TI, incluindo hardware, dispositivos e ferramentas, com rastreamento de transferências entre setores e status de itens.

## 🗃️ Estrutura Principal

### 📋 Tabelas do Sistema

1. **LOG DE OPERAÇÕES**
   - `id`: Identificador único (ex: 00001)
   - `data_hora`: Data e hora da operação (ex: 05042025 12:00)
   - `tipo_operacao`: Inserir/Transferir/Descarte
   - `quantidade`: Número de itens (1, 2, 3...)
   - `origem`: Usuário/Estoque/Descarte
   - `categoria`: Hardware/Periférico/Dispositivo
   - `destino`: Setor ou usuário
   - `conteudo`: Detalhes do item

2. **FORMULÁRIO DE ITENS**
   - `id`: 0001, 0002...
   - `tipo`: Pessoal/Não-pessoal
   - `nome`: (ex: Alcalde, WD40)
   - `quantidade`: Número de unidades
   - `tipo_quantidade`: Unidade/Litro/Kg
   - `origem`: Nova/Usuário/Estoque/Descarte

3. **HARDWARE**
   - `id`: 00001
   - `nome`: (ex: Fonte Acer MXYZ)
   - `quantidade`: 1
   - `tipo`: Notebook/Desktop
   - `local`: Estoque/Usuário/Descarte

4. **DISPOSITIVOS**
   - Similar à estrutura de hardware

## 🔄 Fluxos de Trabalho

### ➕ Inserção de Novo Item
1. Definir categoria (Hardware/Periférico/Dispositivo)
2. Especificar tipo (Notebook/Desktop para hardware)
3. Registrar quantidade e unidade de medida
4. Definir status inicial (Estoque/Nova/Descarte)

### 🔄 Transferência entre Setores
```sql
-- Exemplo: Transferir fonte para atendimento
INSERT INTO log_operacoes VALUES (
    '00025',
    NOW(),
    'transferir',
    1,
    'estoque',
    'hardware',
    'Atendimento',
    'Fonte Acer MXYZ',
    'Para reposição de equipamento'
);
```

## 📊 Categorias de Itens

| Tipo        | Exemplos                  |
|-------------|---------------------------|
| Hardware    | RAM, CPU, Fonte, Gabinete |
| Periféricos | Teclado, Mouse, Monitor   |
| Dispositivos| Roteadores, Switches      |
| Conexões    | Cabos VGA, HDMI, Rede     |

## 🏢 Setores Organizacionais

- **Atendimento**
- **NOC** (Network Operations Center)
- **Protopel**
- **Mene**

## 🏷️ Convenções de Nomenclatura

1. **IDs**: Sempre 5 dígitos (00001)
2. **Hardware**: 
   - Formato: `[Tipo] [Marca] [Modelo]`  
   - Ex: "Fonte Acer MXYZ"
3. **Localização**:
   - Estoque_[Setor]
   - Usuário_[Nome]
   - Descarte_[Data]

## 🔍 Consultas Úteis

```sql
-- Itens disponíveis em estoque
SELECT * FROM hardware 
WHERE local LIKE 'Estoque%' AND quantidade > 0;

-- Histórico de transferências
SELECT * FROM log_operacoes
WHERE destino = 'Atendimento'
ORDER BY data_hora DESC;

-- Inventário completo por categoria
SELECT categoria, COUNT(*) as total 
FROM log_operacoes 
GROUP BY categoria;
```

## ♻️ Status dos Itens

| Status     | Descrição                     |
|------------|-------------------------------|
| Estoque    | Disponível para distribuição  |
| Usuário    | Atribuído a pessoa/setor      |
| Descarte   | Para descartar/reciclar       |
| Nova       | Item recém-adquirido          |

## ⚙️ Requisitos Técnicos

- Banco de dados SQL (MySQL/PostgreSQL)
- Interface web para operações
- Relatórios periódicos de:
  - Inventário
  - Movimentações
  - Itens para descarte

## 📝 Observações Importantes

1. Todo hardware deve ser classificado como Notebook ou Desktop
2. Itens pessoais devem ser marcados como "Pessoal"
3. O sistema mantém histórico completo de todas as operações
4. Tipos de quantidade devem ser consistentes (evitar misturar Unidade e Kg)