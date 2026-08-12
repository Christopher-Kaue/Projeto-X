<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.fadergs.store.DataStore" %>
<%@ page import="com.fadergs.model.Aluno" %>
<%
    // ATENÇÃO: protótipo de oficina — senha em texto puro, sem persistência real.
    // Futuramente: DAO + banco de dados + hash de senha.

    String erro = null;
    String raParam = request.getParameter("ra");
    String nomeParam = request.getParameter("nome");
    String senhaParam = request.getParameter("senha");
    String cursoParam = request.getParameter("curso");

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        if (raParam == null || raParam.trim().isEmpty()
                || nomeParam == null || nomeParam.trim().isEmpty()
                || senhaParam == null || senhaParam.trim().isEmpty()
                || cursoParam == null || cursoParam.trim().isEmpty()) {
            erro = "Todos os campos são obrigatórios.";
        } else if (!raParam.matches("\\d+")) {
            erro = "RA deve conter apenas números.";
        } else if (raParam.length() < 6) {
            erro = "RA deve ter no mínimo 6 dígitos.";
        } else if (nomeParam.trim().split("\\s+").length < 2) {
            erro = "Nome deve conter pelo menos duas palavras.";
        } else if (senhaParam.length() < 6) {
            erro = "Senha deve ter no mínimo 6 caracteres.";
        } else {
            DataStore store = DataStore.getInstance();
            if (store.raExiste(raParam.trim())) {
                erro = "RA já cadastrado. Utilize outro RA ou faça login.";
            } else {
                Aluno novo = new Aluno(raParam.trim(), nomeParam.trim(), senhaParam, cursoParam.trim());
                store.cadastrarAluno(novo);
                response.sendRedirect("login.jsp?cadastro=ok");
                return;
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cadastro - FADERGS</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body class="auth-page">

    <div class="auth-card">
        <div class="logo">
            <jsp:include page="includes/logo.jsp"/>
        </div>

        <% if (erro != null) { %>
            <div class="error-message"><%= erro %></div>
        <% } %>

        <form method="post" action="cadastro.jsp" id="cadastroForm">
            <div class="form-group">
                <label for="ra">RA:</label>
                <input type="text" id="ra" name="ra"
                       value="<%= raParam != null ? raParam : "" %>"
                       maxlength="20">
            </div>

            <div class="form-group">
                <label for="nome">Nome:</label>
                <input type="text" id="nome" name="nome"
                       value="<%= nomeParam != null ? nomeParam : "" %>">
            </div>

            <div class="form-group">
                <label for="senha">Senha:</label>
                <input type="password" id="senha" name="senha">
            </div>

            <div class="form-group">
                <label for="curso">Curso:</label>
                <input type="text" id="curso" name="curso"
                       value="<%= cursoParam != null ? cursoParam : "" %>">
            </div>

            <button type="submit" class="btn-primary" id="btnCadastrar" disabled>Cadastre-se</button>
        </form>

        <a href="login.jsp" class="auth-link">Voltar ao Login</a>
    </div>

    <script>
        const campos = ['ra', 'nome', 'senha', 'curso'];
        const btnCadastrar = document.getElementById('btnCadastrar');

        function validarCampos() {
            let todosPreenchidos = true;
            campos.forEach(id => {
                const el = document.getElementById(id);
                if (el.value.trim().length === 0) todosPreenchidos = false;
            });
            btnCadastrar.disabled = !todosPreenchidos;
        }

        campos.forEach(id => {
            document.getElementById(id).addEventListener('input', validarCampos);
        });
        validarCampos();
    </script>
</body>
</html>
