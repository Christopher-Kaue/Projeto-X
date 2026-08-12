# Projeto-X — FADERGS (Oficina IA)

## Estrutura

```
backend/    → Java (model, store, WEB-INF)
frontend/   → JSP, CSS, imagens
public/     → Landing page (Vercel)
```

## Executar local

```bash
start-server.bat
# ou: cd backend && mvn jetty:run
```

Acesse: http://localhost:8080/login.jsp  
Login: RA `123456` / Senha `senha123`

## Deploy

- **GitHub:** repositório Projeto-X
- **App completo (Java/JSP):** [Render](https://render.com) via `Dockerfile` + `render.yaml`
- **Vercel:** serve `public/` e redireciona para o app no Render

## Aviso

Protótipo de oficina — dados em memória, sem autenticação de produção.
