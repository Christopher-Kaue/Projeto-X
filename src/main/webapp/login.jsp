<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.fadergs.store.DataStore" %>
<%@ page import="com.fadergs.model.Aluno" %>
<%
    // ATENÇÃO: autenticação simplificada para protótipo de oficina.
    // Sem hash de senha, sem sessão segura — não usar em produção.

    String erro = null;
    String raParam = request.getParameter("ra");
    String senhaParam = request.getParameter("senha");

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        if (raParam == null || raParam.trim().isEmpty() || senhaParam == null || senhaParam.trim().isEmpty()) {
            erro = "RA e Senha são obrigatórios.";
        } else if (!raParam.matches("\\d{6,}")) {
            erro = "RA inválido. Use apenas números (mínimo 6 dígitos).";
        } else {
            DataStore store = DataStore.getInstance();
            if (store.autenticar(raParam.trim(), senhaParam)) {
                Aluno aluno = store.buscarAluno(raParam.trim());
                session.setAttribute("ra", aluno.getRa());
                session.setAttribute("nome", aluno.getNome());
                session.setAttribute("curso", aluno.getCurso());
                response.sendRedirect("dashboard.jsp");
                return;
            } else {
                // Mensagem genérica — não indica se RA ou senha está errado
                erro = "RA ou senha incorretos. Tente novamente.";
            }
        }
    }

    String cadastroSucesso = request.getParameter("cadastro");
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - FADERGS</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body class="auth-page">

    <div class="auth-card">
        <div class="logo">
            <jsp:include page="includes/logo.jsp"/>
        </div>

        <% if (cadastroSucesso != null) { %>
            <div class="success-message">Cadastro realizado! Faça login para continuar.</div>
        <% } %>

        <% if (erro != null) { %>
            <div class="error-message"><%= erro %></div>
        <% } %>

        <form method="post" action="login.jsp" id="loginForm">
            <div class="form-group">
                <label for="ra">RA:</label>
                <input type="text" id="ra" name="ra"
                       value="<%= raParam != null ? raParam : "" %>"
                       maxlength="20" autocomplete="username">
            </div>

            <div class="form-group">
                <label for="senha">Senha:</label>
                <input type="password" id="senha" name="senha"
                       autocomplete="current-password">
            </div>

            <button type="submit" class="btn-primary" id="btnEntrar" disabled>Entrar</button>
        </form>

        <a href="cadastro.jsp" class="auth-link">Cadastre-se</a>
    </div>

    <script>
        const raInput = document.getElementById('ra');
        const senhaInput = document.getElementById('senha');
        const btnEntrar = document.getElementById('btnEntrar');

        function validarCampos() {
            const raValido = raInput.value.trim().length > 0;
            const senhaValida = senhaInput.value.trim().length > 0;
            btnEntrar.disabled = !(raValido && senhaValida);
        }

        raInput.addEventListener('input', validarCampos);
        senhaInput.addEventListener('input', validarCampos);
        validarCampos();
    </script>
</body>
</html>
