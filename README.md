# Projeto-X — Protótipo FADERGS (Oficina IA)

Aplicação web de demonstração para gestão de Unidades Curriculares (UCs) de alunos, construída com **HTML, CSS e JSP**.

## Tecnologias

- Java 11+
- JSP / Servlet (Tomcat)
- Maven

## Estrutura

```
src/main/java/com/fadergs/
  model/     → Aluno, UC, Avaliacao, SubAvaliacao
  store/     → DataStore (armazenamento em memória)
src/main/webapp/
  login.jsp
  cadastro.jsp
  dashboard.jsp
  calcular-media.jsp
  css/style.css
```

## Como executar (localhost)

### Opção rápida (Windows)
Dê duplo clique em `start-server.bat` ou execute no terminal:

```bash
start-server.bat
```

### Opção manual
```bash
mvn jetty:run
```

Acesse: **http://localhost:8080/login.jsp**

> O servidor Jetty roda na porta **8080**. Para parar, pressione `Ctrl+C` no terminal.

## Usuário de exemplo

| RA     | Senha    | Nome   |
|--------|----------|--------|
| 123456 | senha123 | Fulano |

## Telas

| Página | Descrição |
|--------|-----------|
| `login.jsp` | Autenticação por RA e Senha |
| `cadastro.jsp` | Cadastro de novo aluno |
| `dashboard.jsp` | UCs agrupadas por semestre, modais de adicionar/editar UC e configurações |
| `calcular-media.jsp` | Lançamento de notas ponderadas por avaliação |

## Aviso

Este é um **protótipo de oficina**: senhas em texto puro, dados em memória (perdidos ao reiniciar o servidor), sem autenticação de produção.
