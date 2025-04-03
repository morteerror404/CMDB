CREATE TABLE categorias (
  id VARCHAR(20) PRIMARY KEY, -- Ex: "P.01.03"
  nome VARCHAR(120) NOT NULL,
  pai_id VARCHAR(20) REFERENCES categorias(id),
  nivel INTEGER NOT NULL,
  caminho_completo VARCHAR(255) NOT NULL
);

CREATE TABLE itens (
  id SERIAL PRIMARY KEY,
  patri_code VARCHAR(50) UNIQUE NOT NULL, -- Ex: "P.01.03.002"
  categoria_id VARCHAR(20) REFERENCES categorias(id) NOT NULL,
  nome VARCHAR(100) NOT NULL,
  quantidade INTEGER DEFAULT 0,
  localizacao VARCHAR(100),
  especificacoes JSONB
);