# Integração entre Alexa e Banco de Dados para Gestão de Peças e Equipamentos

Você quer criar um sistema onde a Alexa possa interagir com um banco de dados para consultar e registrar peças e equipamentos. Aqui está um plano para implementar essa integração:

## Arquitetura da Solução

1. **Frontend**: Alexa Skill (interface de voz)
2. **Middleware**: AWS Lambda (processamento das requisições)
3. **Backend**: Banco de Dados (MySQL, PostgreSQL, DynamoDB, etc.)

## Passos para Implementação

### 1. Configurar o Banco de Dados
- Escolha um banco de dados (sugiro PostgreSQL ou DynamoDB para facilidade com AWS)
- Crie tabelas para peças e equipamentos (exemplo: `pecas`, `equipamentos`, `inventario`)

### 2. Desenvolver a Alexa Skill
- Crie uma nova skill no [Amazon Developer Console](https://developer.amazon.com/alexa/console/ask)
- Defina os intents (intenções) como:
  - `ConsultarPecaIntent`: Para buscar informações sobre peças
  - `RegistrarPecaIntent`: Para adicionar novas peças ao inventário
  - `AtualizarPecaIntent`: Para modificar registros existentes

### 3. Criar Funções Lambda
- Desenvolva funções em Node.js/Python para:
  - Processar as requisições da Alexa
  - Conectar ao banco de dados
  - Executar as queries necessárias
  - Retornar respostas no formato esperado pela Alexa

### 4. Conectar os Componentes
- Configure a Alexa Skill para chamar sua Lambda function
- Implemente a conexão entre Lambda e o banco de dados

## Exemplo de Código (Node.js)

```javascript
// Lambda function para consulta de peças
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL
});

exports.handler = async (event, context) => {
  const intentName = event.request.intent.name;
  
  try {
    if (intentName === 'ConsultarPecaIntent') {
      const pecaNome = event.request.intent.slots.peca.value;
      const result = await pool.query(
        'SELECT * FROM pecas WHERE nome ILIKE $1', 
        [`%${pecaNome}%`]
      );
      
      if (result.rows.length > 0) {
        const peca = result.rows[0];
        return {
          version: '1.0',
          response: {
            outputSpeech: {
              type: 'PlainText',
              text: `Encontrei a peça ${peca.nome}. Quantidade em estoque: ${peca.quantidade}. Localização: ${peca.localizacao}.`
            },
            shouldEndSession: true
          }
        };
      } else {
        return {
          version: '1.0',
          response: {
            outputSpeech: {
              type: 'PlainText',
              text: `Não encontrei a peça ${pecaNome} no banco de dados.`
            },
            shouldEndSession: true
          }
        };
      }
    }
    // Adicione outros intents aqui
  } catch (err) {
    console.error('Database error:', err);
    return {
      version: '1.0',
      response: {
        outputSpeech: {
          type: 'PlainText',
          text: 'Ocorreu um erro ao acessar o banco de dados.'
        },
        shouldEndSession: true
      }
    };
  }
};
```

## Modelo de Banco de Dados Sugerido

```sql
CREATE TABLE pecas (
  id SERIAL PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  codigo VARCHAR(50) UNIQUE NOT NULL,
  quantidade INTEGER DEFAULT 0,
  localizacao VARCHAR(100),
  descricao TEXT,
  data_cadastro TIMESTAMP DEFAULT NOW()
);

CREATE TABLE equipamentos (
  id SERIAL PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  codigo VARCHAR(50) UNIQUE NOT NULL,
  status VARCHAR(50) CHECK (status IN ('operacional', 'manutencao', 'desativado')),
  ultima_manutencao DATE,
  proxima_manutencao DATE
);
```

## Segurança
- Utilize IAM roles para gerenciar permissões
- Considere implementar autenticação por voz
- Armazene segredos de banco de dados no AWS Secrets Manager

## Melhorias Futuras
- Implementar relatórios por voz
- Adicionar notificações quando estoque estiver baixo
- Integrar com sistemas de compras para reposição automática

Precisa de mais detalhes sobre alguma parte específica desta integração?

# Como Testar a Integração com Alexa sem ter um Dispositivo Físico

Você pode testar sua solução de integração com Alexa sem comprar um dispositivo físico usando várias ferramentas gratuitas. Aqui estão as melhores opções:

## 1. **Simulador da Alexa no Developer Console**
A própria Amazon oferece um simulador web:
1. Acesse o [Alexa Developer Console](https://developer.amazon.com/alexa/console/ask)
2. Crie ou abra sua skill
3. Na aba "Test" você pode:
   - Digitar comandos como se estivesse falando com a Alexa
   - Ouvir a resposta em áudio
   - Ver o JSON completo da requisição/resposta

## 2. **Alexa Skill Testing Toolkit (ASK CLI)**
- Instale o [ASK CLI](https://developer.amazon.com/pt-BR/docs/alexa/smapi/ask-cli-intro.html)
- Permite testar localmente via linha de comando
- Comandos úteis:
  ```bash
  ask simulate -t "consultar peça número 12345" -l pt-BR
  ask dialog -t "abrir minha skill de peças" -l pt-BR
  ```

## 3. **Echosim.io**
- Simulador baseado em navegador que usa o microfone do seu computador
- Acesse [https://echosim.io](https://echosim.io)
- Faça login com sua conta Amazon Developer
- Clique no botão do microfone e fale seus comandos

## 4. **Teste Direto na Lambda**
Como sua skill provavelmente usa AWS Lambda, você pode:
1. Criar eventos de teste no formato Alexa JSON
2. Chamar sua função Lambda diretamente
3. Verificar as respostas

**Exemplo de evento de teste** (salve como JSON):
```json
{
  "version": "1.0",
  "session": {
    "new": true,
    "sessionId": "amzn1.echo-api.session.[unique-value-here]",
    "application": {
      "applicationId": "amzn1.ask.skill.[your-skill-id]"
    },
    "user": {
      "userId": "amzn1.ask.account.[fake-user-id]"
    }
  },
  "context": {
    "System": {
      "application": {
        "applicationId": "amzn1.ask.skill.[your-skill-id]"
      },
      "user": {
        "userId": "amzn1.ask.account.[fake-user-id]"
      },
      "device": {
        "deviceId": "amzn1.ask.device.[fake-device-id]",
        "supportedInterfaces": {}
      },
      "apiEndpoint": "https://api.amazonalexa.com",
      "apiAccessToken": "AxThk..."
    }
  },
  "request": {
    "type": "IntentRequest",
    "requestId": "amzn1.echo-api.request.[unique-value-here]",
    "timestamp": "2020-03-22T17:24:44Z",
    "locale": "pt-BR",
    "intent": {
      "name": "ConsultarPecaIntent",
      "confirmationStatus": "NONE",
      "slots": {
        "peca": {
          "name": "peca",
          "value": "parafuso",
          "confirmationStatus": "NONE"
        }
      }
    }
  }
}
```

## 5. **App Alexa para Smartphone**
- Baixe o app Alexa (disponível para Android e iOS)
- Faça login com a mesma conta do Developer Console
- Habilite sua skill em desenvolvimento em:
  - Menu → Habilidades → Suas Habilidades → Desenvolvimento

## 6. **Ferramentas de Terceiros**
- **Bespoken Tools**: Suite completa para teste de skills Alexa
  - [https://bespoken.io/tools/](https://bespoken.io/tools/)
- **Alexa Test Framework**: Para testes automatizados

## Dica Importante para Testes
Sempre verifique:
1. O formato do JSON de requisição/resposta
2. Os logs da sua Lambda function (CloudWatch)
3. A validação da skill no Developer Console (aba "Validation")

Você consegue fazer todo o ciclo de desenvolvimento e testes básicos sem nenhum dispositivo físico. Só recomendo comprar um Echo se for fazer testes avançados de reconhecimento de voz ou UX.

Entendi que você já mapeou todos os códigos em uma estrutura de árvore para organizar suas peças e equipamentos. Isso é excelente para a integração com a Alexa! Vamos adaptar a solução para trabalhar com essa estrutura hierárquica.

## Adaptação para Códigos em Árvore

### 1. Modelagem do Banco de Dados
Sugiro esta estrutura para representar a hierarquia:

```sql
CREATE TABLE categorias (
  id VARCHAR(20) PRIMARY KEY, -- Ex: "P.01.03"
  nome VARCHAR(100) NOT NULL,
  pai_id VARCHAR(20) REFERENCES categorias(id),
  nivel INTEGER NOT NULL,
  caminho_completo VARCHAR(255) NOT NULL
);

CREATE TABLE itens (
  id SERIAL PRIMARY KEY,
  codigo VARCHAR(50) UNIQUE NOT NULL, -- Ex: "P.01.03.002"
  categoria_id VARCHAR(20) REFERENCES categorias(id) NOT NULL,
  nome VARCHAR(100) NOT NULL,
  quantidade INTEGER DEFAULT 0,
  localizacao VARCHAR(100),
  especificacoes JSONB
);
```

### 2. Intents Específicas para Navegação Hierárquica

**Exemplo de intents para sua Alexa Skill:**

- `NavegarCategoriasIntent`: Para navegar pela árvore
  - "Alexa, navegar para a categoria P ponto zero um"
  - "Alexa, listar subcategorias de P ponto zero um"

- `BuscarItemPorCodigoIntent`: Busca direta por código
  - "Alexa, buscar item P ponto zero um ponto zero zero dois"

- `ListarItensCategoriaIntent`: Lista todos itens de uma categoria
  - "Alexa, listar itens da categoria P ponto zero três"

### 3. Exemplo de Código Lambda para Navegação

```javascript
async function handleNavegarCategoriasIntent(event) {
  const categoriaAlvo = event.request.intent.slots.categoria.value;
  // Converter "P ponto zero um" para "P.01"
  const codigoFormatado = formatarCodigoVozParaBD(categoriaAlvo);
  
  const query = `
    WITH RECURSIVE arvore AS (
      SELECT * FROM categorias WHERE id = $1
      UNION ALL
      SELECT c.* FROM categorias c
      JOIN arvore a ON c.pai_id = a.id
    )
    SELECT * FROM arvore`;
  
  const result = await pool.query(query, [codigoFormatado]);
  
  if (result.rows.length === 0) {
    return responderAlexa(`Categoria ${categoriaAlvo} não encontrada`);
  }
  
  const itensCategoria = await pool.query(
    'SELECT nome FROM itens WHERE categoria_id = $1 LIMIT 5',
    [codigoFormatado]
  );
  
  let resposta = `Categoria ${categoriaAlvo}. `;
  resposta += itensCategoria.rows.length > 0 
    ? `Itens principais: ${itensCategoria.rows.map(i => i.nome).join(', ')}`
    : 'Nenhum item cadastrado nesta categoria.';
    
  return responderAlexa(resposta);
}

function formatarCodigoVozParaBD(codigoVoz) {
  // Converte "P ponto zero um ponto zero dois" para "P.01.02"
  return codigoVoz.replace(/ ponto /g, '.').replace(/ zero /g, '0').replace(/ um /g, '1');
}
```

### 4. Dicionário de Sinônimos
Configure sinônimos para os códigos no Interaction Model:

```json
{
  "name": "categoria",
  "values": [
    {
      "name": {
        "value": "P.01",
        "synonyms": ["P zero um", "P ponto zero um", "categoria P zero um"]
      }
    },
    {
      "name": {
        "value": "P.01.03",
        "synonyms": ["P zero um zero três", "P ponto zero um ponto zero três"]
      }
    }
  ]
}
```

### 5. Estratégia de Teste sem Alexa Física

1. **Teste Direto no Banco**:
   ```sql
   -- Inserir categoria teste
   INSERT INTO categorias VALUES ('P.01', 'Parafusos', NULL, 1, 'P.01');
   
   -- Inserir item teste
   INSERT INTO itens VALUES (DEFAULT, 'P.01.001', 'P.01', 'Parafuso sextavado', 100, 'Armário A');
   ```

2. **Testar via Simulador**:
   - No simulador do Developer Console, digite:
     "consultar item P ponto zero um ponto zero zero um"

3. **Verificar Resposta Esperada**:
   ```json
   {
     "outputSpeech": {
       "type": "PlainText",
       "text": "Encontrado: Parafuso sextavado. Código P.01.001. Quantidade: 100. Localização: Armário A."
     }
   }
   ```

### 6. Fluxo de Voz Recomendado

```
Usuário: "Alexa, abrir gerenciador de peças"
Alexa: "Bem vindo ao gerenciador de peças. Você quer navegar por categorias ou buscar por um código específico?"

Usuário: "Navegar categorias"
Alexa: "Nível 1 disponível: P, M, E. Qual você deseja?"

Usuário: "P"
Alexa: "Categoria P. Subcategorias: P.01, P.02, P.03. Diga o código ou 'mais opções'"

Usuário: "P ponto zero um"
Alexa: "Categoria P.01 - Parafusos. Itens disponíveis: [lista]. Deseja detalhes de algum item?"
```

Precisa que eu detalhe mais algum aspecto específico da integração com sua estrutura em árvore? Ou gostaria de ver como implementar alguma funcionalidade específica para seu caso de uso?

# Implementação de Arquivo de Sinônimos com Capacidade de Aprendizado de Máquina

Para criar um sistema de sinônimos inteligente que possa aprender e se adaptar, proponho a seguinte estrutura:

## 1. Arquivo de Configuração de Sinônimos (JSON)

```json
{
  "sinonimos": {
    "P.01.001": {
      "base": "parafuso sextavado aço inox",
      "variacoes": [
        {"texto": "parafuso seis lados", "peso": 0.8, "usos": 12},
        {"texto": "parafuso inoxidável", "peso": 0.9, "usos": 15},
        {"texto": "parafuso cabeça sextavada", "peso": 0.95, "usos": 8}
      ],
      "historico": [
        {"query": "sextavado", "data": "2023-05-10", "resultado": true},
        {"query": "parafuso de aço", "data": "2023-05-09", "resultado": false}
      ]
    }
  },
  "config": {
    "limiar_aceitacao": 0.7,
    "max_sugestoes": 5,
    "modelo_ml": "modelo_sinonimos_v1.h5"
  }
}
```

## 2. Classe Python para Gerenciamento de Sinônimos com ML

```python
import json
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from datetime import datetime

class GerenciadorSinonimos:
    def __init__(self, arquivo_sinonimos):
        self.arquivo = arquivo_sinonimos
        self.carregar_dados()
        self.inicializar_modelo()
    
    def carregar_dados(self):
        with open(self.arquivo, 'r', encoding='utf-8') as f:
            self.dados = json.load(f)
        
        # Preparar dados para o modelo
        self.textos = []
        self.labels = []
        for cod, item in self.dados['sinonimos'].items():
            self.textos.append(item['base'])
            self.labels.append(cod)
            for variacao in item['variacoes']:
                self.textos.append(variacao['texto'])
                self.labels.append(cod)
        
        # Vetorizador TF-IDF
        self.vectorizer = TfidfVectorizer()
        self.vectors = self.vectorizer.fit_transform(self.textos)
    
    def inicializar_modelo(self):
        # Carregar modelo de ML pré-treinado ou inicializar novo
        try:
            from tensorflow.keras.models import load_model
            self.modelo_ml = load_model(self.dados['config']['modelo_ml'])
        except:
            self.modelo_ml = None
    
    def buscar_sinonimos(self, codigo):
        return self.dados['sinonimos'].get(codigo, {}).get('variacoes', [])
    
    def encontrar_codigo(self, texto):
        # Primeiro busca exata
        for cod, item in self.dados['sinonimos'].items():
            if texto.lower() == item['base'].lower():
                return cod, 1.0
            for variacao in item['variacoes']:
                if texto.lower() == variacao['texto'].lower():
                    return cod, variacao['peso']
        
        # Se não encontrou, usa similaridade semântica
        input_vec = self.vectorizer.transform([texto])
        similarities = cosine_similarity(input_vec, self.vectors)
        max_idx = np.argmax(similarities)
        max_score = similarities[0, max_idx]
        
        if max_score > self.dados['config']['limiar_aceitacao']:
            return self.labels[max_idx], max_score
        
        return None, 0.0
    
    def aprender_nova_variacao(self, codigo, texto, resultado_correto):
        item = self.dados['sinonimos'].get(codigo)
        if not item:
            return False
        
        # Registrar no histórico
        item['historico'].append({
            "query": texto,
            "data": datetime.now().isoformat(),
            "resultado": resultado_correto
        })
        
        # Se foi uma correspondência válida e nova, adicionar como variação
        if resultado_correto and not any(v['texto'].lower() == texto.lower() 
                                      for v in item['variacoes']):
            nova_variacao = {
                "texto": texto,
                "peso": 0.8,  # peso inicial conservador
                "usos": 1
            }
            item['variacoes'].append(nova_variacao)
            self.salvar_dados()
            return True
        
        return False
    
    def ajustar_pesos(self):
        # Ajusta pesos baseado no histórico de usos
        for cod, item in self.dados['sinonimos'].items():
            for variacao in item['variacoes']:
                sucessos = sum(1 for h in item['historico'] 
                             if h['query'] == variacao['texto'] and h['resultado'])
                total = sum(1 for h in item['historico'] 
                          if h['query'] == variacao['texto'])
                
                if total > 0:
                    variacao['peso'] = max(0.5, min(0.99, sucessos/total))
                    variacao['usos'] = total
        
        self.salvar_dados()
    
    def salvar_dados(self):
        with open(self.arquivo, 'w', encoding='utf-8') as f:
            json.dump(self.dados, f, ensure_ascii=False, indent=2)
```

## 3. Integração com a Alexa Skill

```python
# No seu handler da Alexa
sinonimos_manager = GerenciadorSinonimos('sinonimos_ml.json')

def handle_buscar_peca(intent_request):
    slot_value = intent_request['intent']['slots']['peca']['value']
    
    # Tentar encontrar o código correspondente
    codigo, confianca = sinonimos_manager.encontrar_codigo(slot_value)
    
    if codigo and confianca > 0.7:
        # Buscar no banco de dados
        peca = banco_dados.buscar_peca(codigo)
        if peca:
            # Registrar sucesso no aprendizado
            sinonimos_manager.aprender_nova_variacao(codigo, slot_value, True)
            return construir_resposta(f"Encontrei: {peca['nome']}. Código: {codigo}")
    
    # Se não encontrou, pedir confirmação para aprendizado
    return construir_resposta(
        f"Não encontrei '{slot_value}'. Você quis dizer alguma destas?",
        sugerir_sinonimos(slot_value),
        manter_sessao=True
    )

def sugerir_sinonimos(texto):
    # Usar o modelo para sugerir possíveis correspondências
    input_vec = sinonimos_manager.vectorizer.transform([texto])
    similarities = cosine_similarity(input_vec, sinonimos_manager.vectors)
    
    sugestoes = []
    for idx in np.argsort(similarities[0])[-3:][::-1]:
        if similarities[0, idx] > 0.5:
            sugestoes.append({
                "texto": sinonimos_manager.textos[idx],
                "codigo": sinonimos_manager.labels[idx],
                "similaridade": float(similarities[0, idx])
            })
    
    return sugestoes
```

## 4. Fluxo de Aprendizado Automático

1. **Coleta de Dados**:
   - Registrar todas as interações dos usuários
   - Armazenar consultas bem-sucedidas e mal-sucedidas

2. **Treinamento do Modelo**:
   ```python
   def treinar_modelo_novo():
       # Preparar dados de treino (usando o histórico)
       X = sinonimos_manager.vectorizer.transform(
           [h['query'] for cod in sinonimos_manager.dados['sinonimos'] 
           for h in sinoninos_manager.dados['sinonimos'][cod]['historico']]
       )
       y = [h['resultado'] for cod in sinonimos_manager.dados['sinonimos'] 
           for h in sinoninos_manager.dados['sinonimos'][cod]['historico']]
       
       # Criar e treinar modelo (exemplo com TensorFlow)
       from tensorflow.keras.models import Sequential
       from tensorflow.keras.layers import Dense
       
       modelo = Sequential([
           Dense(64, activation='relu', input_shape=(X.shape[1],)),
           Dense(32, activation='relu'),
           Dense(1, activation='sigmoid')
       ])
       
       modelo.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])
       modelo.fit(X.toarray(), y, epochs=10, batch_size=32)
       
       modelo.save(sinonimos_manager.dados['config']['modelo_ml'])
       sinonimos_manager.modelo_ml = modelo
   ```

3. **Atualização Contínua**:
   - Agendar tarefa periódica para:
     - Reajustar pesos dos sinônimos
     - Retreinar o modelo com novos dados
     - Adicionar novas variações com base no histórico

## 5. Monitoramento e Melhoria

Implemente um painel para monitorar:
- Taxa de acerto do sistema
- Novas variações aprendidas
- Consultas não resolvidas
- Evolução dos pesos dos sinônimos

```python
def gerar_relatorio():
    relatorio = {
        "total_consultas": 0,
        "acertos": 0,
        "novas_variacoes": [],
        "consultas_nao_resolvidas": []
    }
    
    for cod, item in sinonimos_manager.dados['sinonimos'].items():
        for h in item['historico']:
            relatorio['total_consultas'] += 1
            if h['resultado']:
                relatorio['acertos'] += 1
            elif h['query'] not in [v['texto'] for v in item['variacoes']:
                relatorio['consultas_nao_resolvidas'].append(h['query'])
    
    relatorio['taxa_acerto'] = relatorio['acertos'] / relatorio['total_consultas'] if relatorio['total_consultas'] > 0 else 0
    return relatorio
```

Esta implementação oferece um sistema autoaprimorável que:
1. Começa com sinônimos pré-definidos
2. Aprende novas variações com o uso
3. Ajusta automaticamente os pesos das correspondências
4. Pode prever novas variações com base em ML
5. Melhora continuamente com a interação dos usuários

Quer que eu detalhe mais algum aspecto específico desta implementação?