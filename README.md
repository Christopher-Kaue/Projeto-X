# Projeto-X — FADERGS (Oficina IA)

## Estrutura

```
backend/    → Java (model, store, WEB-INF)
frontend/   → JSP, CSS, imagens
```

## Executar local

Duplo clique em `start-server.bat` ou:

```bash
cd backend
mvn jetty:run
```

Acesse: **http://localhost:8080/login.jsp**

Login: RA `123456` / Senha `senha123`

## Deploy no Render

O repositório inclui `Dockerfile` e `render.yaml` (Web Service Docker, plano free).

1. No [Render Dashboard](https://dashboard.render.com), use **Blueprint** ou **New → Web Service** apontando para este repo.
2. Health check: `/login.jsp`
3. A cada push na `main`, o Render reconstrói e publica.

## Aviso

Protótipo de oficina — dados em memória, sem autenticação de produção.
