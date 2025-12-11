# TesteHapvida
# CRUD de Clientes - Prova Técnica Oracle Forms & PL/SQL

Este repositório contém a solução desenvolvida para a prova técnica de Backend, focada na criação de um módulo de Cadastro de Clientes (CRUD) utilizando a stack Oracle.

## 🚀 Tecnologias Utilizadas

*   **Frontend/UI:** Oracle Forms 12c
*   **Backend/Lógica:** PL/SQL (Package `PKG_CLIENTE`)
*   **Banco de Dados:** Oracle Database (19c/XE)

## 📐 Arquitetura da Solução

A solução segue o princípio de **separação de responsabilidades** em três camadas:
1.  **Forms:** Atua como a camada de apresentação e orquestração transacional (`COMMIT`/`ROLLBACK`).
2.  **Package PL/SQL (`PKG_CLIENTE`):** Atua como a **API de Negócio**, centralizando todas as regras, validações e operações DML (INSERT, UPDATE, DELETE).
3.  **Banco de Dados:** Garante a persistência e integridade dos dados.

## 📂 Estrutura do Repositório

Todos os arquivos estão localizados na pasta `/src`.

| Arquivo | Descrição |
| :--- | :--- |
| `create.sql` | Script completo para criação da tabela `TB_CLIENTE`, `SEQUENCE`, `TRIGGER` e o `PACKAGE PKG_CLIENTE` (Specification e Body). |
| `drop.sql` | Script para remoção de todos os objetos criados. |
| `CLIENTE.fmb` | Arquivo fonte do módulo Oracle Forms. |
| `CLIENTE.fmx` | Arquivo binário compilado do Forms. |


## ✨ Destaques da Implementação

*   **Tratamento de Erros:** Implementação do trigger `ON-ERROR` no Forms para mapear os erros `-20001`, `-20002` e `-20003` do package para mensagens amigáveis ao usuário.
*   **Validação de Dados:** Uso de uma procedure auxiliar (`VALIDAR_DADOS_COMUNS`) no package para garantir que todas as regras de negócio (Nome, Email, CEP, UF) sejam aplicadas de forma consistente em Inserção e Atualização.
*   **LOV Dinâmico:** Criação dinâmica do Record Group de UFs no `WHEN-NEW-FORM-INSTANCE` para popular o LOV.
