<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.fadergs.store.DataStore" %>
<%@ page import="com.fadergs.model.Aluno" %>
<%@ page import="com.fadergs.model.UC" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Collections" %>
<%
    String ra = (String) session.getAttribute("ra");
    if (ra == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    DataStore store = DataStore.getInstance();
    Aluno aluno = store.buscarAluno(ra);
    String nome = aluno != null ? aluno.getNome() : (String) session.getAttribute("nome");
    String curso = aluno != null ? aluno.getCurso() : (String) session.getAttribute("curso");

    String action = request.getParameter("action");

    if ("POST".equalsIgnoreCase(request.getMethod()) && action != null) {
        if ("adicionarUC".equals(action)) {
            String nomeUC = request.getParameter("nomeUC");
            String semestreStr = request.getParameter("semestre");
            if (nomeUC != null && !nomeUC.trim().isEmpty() && semestreStr != null) {
                try {
                    int semestre = Integer.parseInt(semestreStr.trim());
                    store.criarNovaUC(nomeUC.trim(), semestre, ra);
                } catch (NumberFormatException ignored) {}
            }
            response.sendRedirect("dashboard.jsp?msg=uc_adicionada");
            return;
        }

        if ("editarUC".equals(action)) {
            String ucId = request.getParameter("ucId");
            String nomeUC = request.getParameter("nomeUC");
            String semestreStr = request.getParameter("semestre");
            UC uc = store.buscarUC(ra, ucId);
            if (uc != null && nomeUC != null && semestreStr != null) {
                try {
                    uc.setNome(nomeUC.trim());
                    uc.setSemestre(Integer.parseInt(semestreStr.trim()));
                    store.atualizarUC(uc);
                } catch (NumberFormatException ignored) {}
            }
            response.sendRedirect("dashboard.jsp?msg=uc_editada");
            return;
        }

        if ("excluirUC".equals(action)) {
            String ucId = request.getParameter("ucId");
            if (ucId != null) {
                store.removerUC(ra, ucId);
            }
            response.sendRedirect("dashboard.jsp?msg=uc_excluida");
            return;
        }

        if ("configuracoes".equals(action)) {
            String novoNome = request.getParameter("nome");
            String novaSenha = request.getParameter("senha");
            String novoCurso = request.getParameter("curso");
            if (aluno != null && novoNome != null && novoCurso != null) {
                aluno.setNome(novoNome.trim());
                aluno.setCurso(novoCurso.trim());
                if (novaSenha != null && !novaSenha.trim().isEmpty()) {
                    aluno.setSenha(novaSenha);
                }
                store.atualizarAluno(aluno);
                session.setAttribute("nome", aluno.getNome());
                session.setAttribute("curso", aluno.getCurso());
            }
            response.sendRedirect("dashboard.jsp?msg=config_salva");
            return;
        }
    }

    String msg = request.getParameter("msg");
    Map<Integer, List<UC>> ucsPorSemestre = store.agruparPorSemestre(ra);
    List<Integer> semestres = new java.util.ArrayList<>(ucsPorSemestre.keySet());
    semestres.sort(Collections.reverseOrder());

    String editUcId = request.getParameter("editUc");
    UC ucEditando = editUcId != null ? store.buscarUC(ra, editUcId) : null;
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - FADERGS</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/extras.css">
</head>
<body class="dashboard-page">

    <header class="dashboard-header">
        <h2>Bem vindo, <%= nome %>!</h2>
        <div class="header-right">
            <jsp:include page="includes/logo.jsp"/>
            <a href="logout.jsp" class="btn-sair">Sair</a>
        </div>
    </header>

    <% if (msg != null) {
        String texto = "";
        if ("uc_adicionada".equals(msg)) texto = "UC adicionada com sucesso!";
        else if ("uc_editada".equals(msg)) texto = "UC editada com sucesso!";
        else if ("uc_excluida".equals(msg)) texto = "UC excluída com sucesso!";
        else if ("config_salva".equals(msg)) texto = "Alterações salvas com sucesso!";
        else if ("media_salva".equals(msg)) texto = "Média salva com sucesso!";
        if (!texto.isEmpty()) { %>
            <div class="toast-success" id="toastSuccess"><%= texto %></div>
    <%  }
    } %>

    <main class="dashboard-content">
        <% if (semestres.isEmpty()) { %>
            <div class="semestre-header-row">
                <div class="semestre-title-block">
                    <div class="curso-nome"><%= curso %></div>
                </div>
                <button type="button" class="btn-add-uc" onclick="openModal('modalAdicionar')">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                        <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
                    </svg>
                    Adicionar UC
                </button>
            </div>
            <p style="text-align:center; color:#666; margin-top:24px;">
                Nenhuma UC cadastrada. Clique em "Adicionar UC" para começar.
            </p>
        <% } %>

        <% for (int idx = 0; idx < semestres.size(); idx++) {
            Integer sem = semestres.get(idx);
            List<UC> ucs = ucsPorSemestre.get(sem);
        %>
            <div class="semestre-group">
                <div class="semestre-header-row">
                    <div class="semestre-title-block">
                        <div class="curso-nome"><%= curso %></div>
                        <div class="semestre-num"><%= sem %>º Semestre</div>
                    </div>
                    <% if (idx == 0) { %>
                        <button type="button" class="btn-add-uc" onclick="openModal('modalAdicionar')">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                                <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
                            </svg>
                            Adicionar UC
                        </button>
                    <% } %>
                </div>
                <div class="uc-grid">
                    <% for (UC uc : ucs) {
                        int percent = uc.getNotaPercentual();
                    %>
                        <div class="uc-card">
                            <div class="uc-card-header">
                                <h3><%= uc.getNome() %></h3>
                                <div class="uc-card-actions">
                                    <button type="button" title="Editar"
                                            onclick="openEditModal('<%= uc.getId() %>', '<%= uc.getNome().replace("'", "\\'") %>', <%= uc.getSemestre() %>)">
                                        <svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                            <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/>
                                            <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/>
                                        </svg>
                                    </button>
                                    <button type="button" title="Excluir"
                                            onclick="openExcluirModal('<%= uc.getId() %>', '<%= uc.getNome().replace("'", "\\'") %>')">
                                            <svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                <polyline points="3 6 5 6 21 6"/>
                                                <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/>
                                            </svg>
                                    </button>
                                </div>
                            </div>
                            <div class="uc-score">
                                <span class="score-value"><%= uc.getNotaFormatada() %></span>
                                <span class="score-percent"><%= percent %>%</span>
                            </div>
                            <div class="progress-bar">
                                <div class="progress-bar-fill" style="width: <%= percent %>%"></div>
                            </div>
                            <a href="calcular-media.jsp?ucId=<%= uc.getId() %>" class="btn-calcular">Calcular Média</a>
                        </div>
                    <% } %>
                </div>
            </div>
        <% } %>
    </main>

    <button type="button" class="settings-fab" title="Configurações" onclick="openModal('modalConfig')">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <circle cx="12" cy="12" r="3"/>
            <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/>
        </svg>
    </button>

    <div class="modal-overlay" id="modalAdicionar">
        <div class="modal-card">
            <button type="button" class="modal-close" onclick="closeModal('modalAdicionar')" aria-label="Fechar"></button>
            <h2>Adicionar UC</h2>
            <form method="post" action="dashboard.jsp">
                <input type="hidden" name="action" value="adicionarUC">
                <div class="form-group">
                    <label for="addNomeUC">Nome da UC:</label>
                    <input type="text" id="addNomeUC" name="nomeUC" required>
                </div>
                <div class="form-group">
                    <label for="addSemestre">Semestre:</label>
                    <input type="number" id="addSemestre" name="semestre" min="1" max="12" required>
                </div>
                <button type="submit" class="btn-primary">Salvar</button>
            </form>
        </div>
    </div>

    <div class="modal-overlay" id="modalEditar">
        <div class="modal-card">
            <button type="button" class="modal-close" onclick="closeModal('modalEditar')" aria-label="Fechar"></button>
            <h2>Editar UC</h2>
            <form method="post" action="dashboard.jsp">
                <input type="hidden" name="action" value="editarUC">
                <input type="hidden" id="editUcId" name="ucId" value="">
                <div class="form-group">
                    <label for="editNomeUC">Nome da UC:</label>
                    <input type="text" id="editNomeUC" name="nomeUC" required>
                </div>
                <div class="form-group">
                    <label for="editSemestre">Semestre:</label>
                    <input type="number" id="editSemestre" name="semestre" min="1" max="12" required>
                </div>
                <button type="submit" class="btn-primary">Salvar</button>
            </form>
        </div>
    </div>

    <div class="modal-overlay" id="modalExcluir">
        <div class="modal-card modal-confirm">
            <h2>Excluir UC</h2>
            <p id="excluirMsg">Deseja realmente excluir esta UC?</p>
            <form method="post" action="dashboard.jsp" class="confirm-actions">
                <input type="hidden" name="action" value="excluirUC">
                <input type="hidden" id="excluirUcId" name="ucId" value="">
                <button type="button" class="btn-cancel" onclick="closeModal('modalExcluir')">Cancelar</button>
                <button type="submit" class="btn-danger">Excluir</button>
            </form>
        </div>
    </div>

    <div class="modal-overlay" id="modalConfig">
        <div class="modal-card">
            <button type="button" class="modal-close" onclick="closeModal('modalConfig')" aria-label="Fechar"></button>
            <h2>Configurações</h2>
            <form method="post" action="dashboard.jsp">
                <input type="hidden" name="action" value="configuracoes">
                <div class="form-group">
                    <label for="configRa">RA:</label>
                    <input type="text" id="configRa" value="<%= ra %>" readonly style="background:#f5f5f5;">
                </div>
                <div class="form-group">
                    <label for="configNome">Nome:</label>
                    <input type="text" id="configNome" name="nome" value="<%= nome %>" required>
                </div>
                <div class="form-group">
                    <label for="configSenha">Senha:</label>
                    <input type="password" id="configSenha" name="senha" placeholder="Deixe vazio para manter a senha atual">
                </div>
                <div class="form-group">
                    <label for="configCurso">Curso:</label>
                    <input type="text" id="configCurso" name="curso" value="<%= curso %>" required>
                </div>
                <button type="submit" class="btn-primary">Salvar Alterações</button>
            </form>
        </div>
    </div>

    <script>
        function openModal(id) {
            document.getElementById(id).classList.add('active');
        }

        function closeModal(id) {
            document.getElementById(id).classList.remove('active');
        }

        function openExcluirModal(ucId, nome) {
            document.getElementById('excluirUcId').value = ucId;
            document.getElementById('excluirMsg').textContent = 'Deseja realmente excluir a UC "' + nome + '"?';
            openModal('modalExcluir');
        }

        function openEditModal(ucId, nome, semestre) {
            document.getElementById('editUcId').value = ucId;
            document.getElementById('editNomeUC').value = nome;
            document.getElementById('editSemestre').value = semestre;
            openModal('modalEditar');
        }

        document.querySelectorAll('.modal-overlay').forEach(overlay => {
            overlay.addEventListener('click', function(e) {
                if (e.target === overlay) overlay.classList.remove('active');
            });
        });

        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                document.querySelectorAll('.modal-overlay.active').forEach(m => m.classList.remove('active'));
            }
        });

        setTimeout(function() {
            var t = document.getElementById('toastSuccess');
            if (t) t.classList.add('hide');
        }, 4000);

        <% if (ucEditando != null) { %>
        openEditModal('<%= ucEditando.getId() %>', '<%= ucEditando.getNome().replace("'", "\\'") %>', <%= ucEditando.getSemestre() %>);
        <% } %>
    </script>
</body>
</html>
