<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.fadergs.store.DataStore" %>
<%@ page import="com.fadergs.model.UC" %>
<%@ page import="com.fadergs.model.Avaliacao" %>
<%@ page import="com.fadergs.model.SubAvaliacao" %>
<%@ page import="java.util.UUID" %>
<%@ page import="java.util.List" %>
<%
    String ra = (String) session.getAttribute("ra");
    if (ra == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String ucId = request.getParameter("ucId");
    if (ucId == null || ucId.trim().isEmpty()) {
        response.sendRedirect("dashboard.jsp");
        return;
    }

    DataStore store = DataStore.getInstance();
    UC uc = store.buscarUC(ra, ucId);
    if (uc == null) {
        response.sendRedirect("dashboard.jsp");
        return;
    }

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String action = request.getParameter("action");

        if ("salvar".equals(action)) {
            for (Avaliacao av : uc.getAvaliacoes()) {
                if (av.hasSubAvaliacoes()) {
                    for (SubAvaliacao sub : av.getSubAvaliacoes()) {
                        String decParam = request.getParameter("sub_dec_" + sub.getId());
                        String pctParam = request.getParameter("sub_pct_" + sub.getId());
                        sub.setNotaDecimal(null);
                        sub.setNotaPercentual(null);
                        if (decParam != null && !decParam.trim().isEmpty()) {
                            try { sub.setNotaDecimal(Double.parseDouble(decParam.trim())); } catch (NumberFormatException ignored) {}
                        } else if (pctParam != null && !pctParam.trim().isEmpty()) {
                            try { sub.setNotaPercentual(Double.parseDouble(pctParam.trim())); } catch (NumberFormatException ignored) {}
                        }
                    }
                    String novoSubDec = request.getParameter("novo_sub_dec");
                    String novoSubPct = request.getParameter("novo_sub_pct");
                    if ((novoSubDec != null && !novoSubDec.trim().isEmpty())
                            || (novoSubPct != null && !novoSubPct.trim().isEmpty())) {
                        int num = av.getSubAvaliacoes().size() + 1;
                        String subId = "sub-" + UUID.randomUUID().toString().substring(0, 6);
                        SubAvaliacao novaSub = new SubAvaliacao(subId, "A3." + num);
                        if (novoSubDec != null && !novoSubDec.trim().isEmpty()) {
                            try { novaSub.setNotaDecimal(Double.parseDouble(novoSubDec.trim())); } catch (NumberFormatException ignored) {}
                        } else if (novoSubPct != null && !novoSubPct.trim().isEmpty()) {
                            try { novaSub.setNotaPercentual(Double.parseDouble(novoSubPct.trim())); } catch (NumberFormatException ignored) {}
                        }
                        av.getSubAvaliacoes().add(novaSub);
                    }
                    av.setNotaDecimal(null);
                    av.setNotaPercentual(null);
                } else {
                    String decParam = request.getParameter("dec_" + av.getId());
                    String pctParam = request.getParameter("pct_" + av.getId());
                    av.setNotaDecimal(null);
                    av.setNotaPercentual(null);
                    if (decParam != null && !decParam.trim().isEmpty()) {
                        try { av.setNotaDecimal(Double.parseDouble(decParam.trim())); } catch (NumberFormatException ignored) {}
                    } else if (pctParam != null && !pctParam.trim().isEmpty()) {
                        try { av.setNotaPercentual(Double.parseDouble(pctParam.trim())); } catch (NumberFormatException ignored) {}
                    }
                }
            }
            store.atualizarUC(uc);
            response.sendRedirect("dashboard.jsp?msg=media_salva");
            return;
        }

        if ("adicionarSub".equals(action)) {
            Avaliacao av3 = null;
            for (Avaliacao av : uc.getAvaliacoes()) {
                if (av.hasSubAvaliacoes()) {
                    av3 = av;
                    break;
                }
            }
            if (av3 != null) {
                int num = av3.getSubAvaliacoes().size() + 1;
                String subId = "sub-" + UUID.randomUUID().toString().substring(0, 6);
                SubAvaliacao novaSub = new SubAvaliacao(subId, "A3." + num);
                String novoSubDec = request.getParameter("novo_sub_dec");
                String novoSubPct = request.getParameter("novo_sub_pct");
                if (novoSubDec != null && !novoSubDec.trim().isEmpty()) {
                    try { novaSub.setNotaDecimal(Double.parseDouble(novoSubDec.trim())); } catch (NumberFormatException ignored) {}
                } else if (novoSubPct != null && !novoSubPct.trim().isEmpty()) {
                    try { novaSub.setNotaPercentual(Double.parseDouble(novoSubPct.trim())); } catch (NumberFormatException ignored) {}
                }
                av3.getSubAvaliacoes().add(novaSub);
                store.atualizarUC(uc);
            }
            response.sendRedirect("calcular-media.jsp?ucId=" + ucId);
            return;
        }
    }

    List<Avaliacao> avaliacoes = uc.getAvaliacoes();
    Avaliacao avComSub = null;
    java.util.ArrayList<Avaliacao> avSimples = new java.util.ArrayList<>();
    for (Avaliacao av : avaliacoes) {
        if (av.hasSubAvaliacoes()) {
            avComSub = av;
        } else {
            avSimples.add(av);
        }
    }
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Calcular Média - <%= uc.getNome() %></title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body class="dashboard-page">

    <header class="media-page-header">
        <div>
            <div class="uc-titulo"><%= uc.getNome() %></div>
            <div class="uc-semestre"><%= uc.getSemestre() %>º Semestre</div>
        </div>
        <div class="header-right">
            <jsp:include page="includes/logo.jsp"/>
            <a href="logout.jsp" class="btn-sair">Sair</a>
        </div>
    </header>

    <div class="media-content">
        <form method="post" action="calcular-media.jsp?ucId=<%= ucId %>" id="mediaForm">

            <% if (avSimples.size() >= 2) { %>
            <div class="avaliacoes-top-row">
                <% for (int i = 0; i < 2; i++) {
                    Avaliacao av = avSimples.get(i);
                %>
                <div class="avaliacao-card">
                    <h3><%= av.getTitulo() %></h3>
                    <p class="max-pontos">Máximo <%= av.getMaxPontos() %> pontos</p>
                    <div class="nota-inputs-vertical">
                        <div class="nota-field">
                            <label>Nota em percentual:</label>
                            <input type="number" class="input-pill-gray" name="pct_<%= av.getId() %>"
                                   step="1" min="0" max="100"
                                   value="<%= av.getNotaPercentual() != null ? av.getNotaPercentual() : "" %>"
                                   oninput="syncPair('pct_<%= av.getId() %>', 'dec_<%= av.getId() %>', false)">
                        </div>
                        <div class="ou-row">ou</div>
                        <div class="nota-field">
                            <label>Nota em decimal:</label>
                            <input type="number" class="input-pill-gray" name="dec_<%= av.getId() %>"
                                   step="0.1" min="0" max="10"
                                   value="<%= av.getNotaDecimal() != null ? av.getNotaDecimal() : "" %>"
                                   oninput="syncPair('dec_<%= av.getId() %>', 'pct_<%= av.getId() %>', true)">
                        </div>
                    </div>
                </div>
                <% } %>
            </div>
            <% } %>

            <% if (avComSub != null) { %>
            <div class="avaliacao-card avaliacao-card-full">
                <div class="avaliacao-card-inner">
                    <div class="avaliacao-card-left">
                        <h3><%= avComSub.getTitulo() %></h3>
                        <p class="max-pontos">Máximo <%= avComSub.getMaxPontos() %> pontos</p>
                        <table class="sub-table">
                            <thead>
                                <tr>
                                    <th>Avaliação</th>
                                    <th>Nota em decimal</th>
                                    <th>Nota em percentual</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (SubAvaliacao sub : avComSub.getSubAvaliacoes()) { %>
                                <tr>
                                    <td><%= sub.getTitulo() %></td>
                                    <td>
                                        <input type="number" name="sub_dec_<%= sub.getId() %>"
                                               step="0.1" min="0" max="10"
                                               value="<%= sub.getNotaDecimal() != null ? sub.getNotaDecimal() : "" %>"
                                               oninput="syncSubInputs(this, 'sub_pct_<%= sub.getId() %>', true)">
                                    </td>
                                    <td>
                                        <input type="number" name="sub_pct_<%= sub.getId() %>"
                                               step="1" min="0" max="100"
                                               value="<%= sub.getNotaPercentual() != null ? sub.getNotaPercentual() : "" %>"
                                               oninput="syncSubInputs(this, 'sub_dec_<%= sub.getId() %>', false)">
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                    <div class="nota-inputs-side">
                        <div class="nota-field">
                            <label>Nota em percentual:</label>
                            <input type="number" class="input-pill-gray" name="novo_sub_pct" id="novo_sub_pct"
                                   step="1" min="0" max="100"
                                   oninput="syncPair('novo_sub_pct', 'novo_sub_dec', false)">
                        </div>
                        <div class="ou-row">ou</div>
                        <div class="nota-field">
                            <label>Nota em decimal:</label>
                            <input type="number" class="input-pill-gray" name="novo_sub_dec" id="novo_sub_dec"
                                   step="0.1" min="0" max="10"
                                   oninput="syncPair('novo_sub_dec', 'novo_sub_pct', true)">
                        </div>
                        <button type="submit" name="action" value="adicionarSub" class="btn-add-sub">
                            + Adicionar Avaliação
                        </button>
                    </div>
                </div>
            </div>
            <% } %>

            <div class="media-footer">
                <button type="submit" name="action" value="salvar" class="btn-secondary">Salvar</button>
            </div>
        </form>
    </div>

    <script>
        function syncPair(sourceId, targetId, isDecimal) {
            const source = document.getElementById(sourceId) || document.getElementsByName(sourceId)[0];
            const target = document.getElementById(targetId) || document.getElementsByName(targetId)[0];
            if (!source || !target) return;
            const val = parseFloat(source.value);
            if (isNaN(val)) { target.value = ''; return; }
            if (isDecimal) {
                target.value = (val * 10).toFixed(1).replace(/\.0$/, '');
            } else {
                target.value = (val / 10).toFixed(1).replace(/\.0$/, '');
            }
        }

        function syncSubInputs(source, targetName, isDecimal) {
            const target = document.getElementsByName(targetName)[0];
            if (!target) return;
            const val = parseFloat(source.value);
            if (isNaN(val)) { target.value = ''; return; }
            if (isDecimal) {
                target.value = (val * 10).toFixed(1).replace(/\.0$/, '');
            } else {
                target.value = (val / 10).toFixed(1).replace(/\.0$/, '');
            }
        }
    </script>
</body>
</html>
