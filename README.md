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

## Aviso

Protótipo de oficina — dados em memória, sem autenticação de produção.
