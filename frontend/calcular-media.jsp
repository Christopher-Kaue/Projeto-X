<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.fadergs.store.DataStore" %>
<%@ page import="com.fadergs.model.UC" %>
<%@ page import="com.fadergs.model.Avaliacao" %>
<%@ page import="com.fadergs.model.SubAvaliacao" %>
<%@ page import="java.util.UUID" %>
<%@ page import="java.util.List" %>
<%!
    private static String formatNum(double v) {
        if (v == (long) v) {
            return String.valueOf((long) v);
        }
        return String.valueOf(v);
    }

    private static double somaMaxSubs(Avaliacao av) {
        double soma = 0;
        if (av == null || av.getSubAvaliacoes() == null) {
            return 0;
        }
        for (SubAvaliacao s : av.getSubAvaliacoes()) {
            soma += s.getMaxPontos();
        }
        return soma;
    }
%>
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

    String actionParam = request.getParameter("action");
    String erroMsg = null;

    if ("removerSub".equals(actionParam)) {
        String subId = request.getParameter("subId");
        if (subId != null) {
            for (Avaliacao av : uc.getAvaliacoes()) {
                if (av.isComposta()) {
                    List<SubAvaliacao> subs = av.getSubAvaliacoes();
                    for (int i = subs.size() - 1; i >= 0; i--) {
                        if (subs.get(i).getId().equals(subId)) {
                            subs.remove(i);
                            break;
                        }
                    }
                    int n = 1;
                    for (SubAvaliacao s : subs) {
                        s.setTitulo("A3." + n++);
                    }
                    break;
                }
            }
            store.atualizarUC(uc);
        }
        response.sendRedirect("calcular-media.jsp?ucId=" + ucId);
        return;
    }

    if ("POST".equalsIgnoreCase(request.getMethod()) && actionParam != null) {

        if ("salvar".equals(actionParam)) {
            for (Avaliacao av : uc.getAvaliacoes()) {
                if (av.isComposta()) {
                    String novoSubMax = request.getParameter("novo_sub_max");
                    String novoSubDec = request.getParameter("novo_sub_dec");
                    String novoSubPct = request.getParameter("novo_sub_pct");
                    boolean temNota = (novoSubDec != null && !novoSubDec.trim().isEmpty())
                            || (novoSubPct != null && !novoSubPct.trim().isEmpty());
                    boolean temMax = novoSubMax != null && !novoSubMax.trim().isEmpty();
                    if (temNota || temMax) {
                        double maxPts = 10.0;
                        if (temMax) {
                            try { maxPts = Double.parseDouble(novoSubMax.trim()); } catch (NumberFormatException ignored) {}
                        }
                        double somaAtual = somaMaxSubs(av);
                        if (somaAtual + maxPts > av.getMaxPontos() + 1e-9) {
                            response.sendRedirect("calcular-media.jsp?ucId=" + ucId + "&erro=max_a3");
                            return;
                        }
                        int num = av.getSubAvaliacoes().size() + 1;
                        String subId = "sub-" + UUID.randomUUID().toString().substring(0, 6);
                        SubAvaliacao novaSub = new SubAvaliacao(subId, "A3." + num, maxPts);
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

        if ("adicionarSub".equals(actionParam)) {
            Avaliacao av3 = null;
            for (Avaliacao av : uc.getAvaliacoes()) {
                if (av.isComposta()) {
                    av3 = av;
                    break;
                }
            }
            if (av3 != null) {
                double maxPts = 10.0;
                String novoSubMax = request.getParameter("novo_sub_max");
                if (novoSubMax != null && !novoSubMax.trim().isEmpty()) {
                    try { maxPts = Double.parseDouble(novoSubMax.trim()); } catch (NumberFormatException ignored) {}
                }
                if (maxPts <= 0) {
                    maxPts = 10.0;
                }
                double somaAtual = somaMaxSubs(av3);
                if (somaAtual + maxPts > av3.getMaxPontos() + 1e-9) {
                    response.sendRedirect("calcular-media.jsp?ucId=" + ucId + "&erro=max_a3");
                    return;
                }
                int num = av3.getSubAvaliacoes().size() + 1;
                String subId = "sub-" + UUID.randomUUID().toString().substring(0, 6);
                SubAvaliacao novaSub = new SubAvaliacao(subId, "A3." + num, maxPts);
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

    if ("max_a3".equals(request.getParameter("erro"))) {
        erroMsg = "Não é possível adicionar esta avaliação: a soma das notas máximas da A3 não pode ultrapassar 40 pontos.";
    }

    List<Avaliacao> avaliacoes = uc.getAvaliacoes();
    Avaliacao avComSub = null;
    java.util.ArrayList<Avaliacao> avSimples = new java.util.ArrayList<>();
    for (Avaliacao av : avaliacoes) {
        if (av.isComposta()) {
            avComSub = av;
        } else {
            avSimples.add(av);
        }
    }

    double somaMaxA3 = somaMaxSubs(avComSub);
    int limiteA3 = avComSub != null ? avComSub.getMaxPontos() : 40;
    double restanteA3 = Math.max(0, limiteA3 - somaMaxA3);
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Calcular Média - <%= uc.getNome() %></title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/extras.css">
    <link rel="stylesheet" href="css/media-extras.css">
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
        <% if (erroMsg != null) { %>
        <div class="toast-error" id="toastErro"><%= erroMsg %></div>
        <% } %>

        <form method="post" action="calcular-media.jsp?ucId=<%= ucId %>" id="mediaForm"
              onsubmit="return validarAntesDeAdicionar(event)">

            <% if (avSimples.size() >= 2) { %>
            <div class="avaliacoes-top-row">
                <% for (int i = 0; i < 2; i++) {
                    Avaliacao av = avSimples.get(i);
                    int maxPts = av.getMaxPontos();
                %>
                <div class="avaliacao-card">
                    <h3><%= av.getTitulo() %></h3>
                    <p class="max-pontos">Máximo <%= maxPts %> pontos</p>
                    <div class="nota-inputs-vertical">
                        <div class="nota-field nota-field-clear">
                            <label>Nota em percentual:</label>
                            <div class="input-with-clear">
                                <input type="number" class="input-pill-gray" name="pct_<%= av.getId() %>"
                                       id="pct_<%= av.getId() %>"
                                       step="1" min="0" max="100"
                                       value="<%= av.getNotaPercentual() != null ? av.getNotaPercentual() : "" %>"
                                       oninput="syncPair('pct_<%= av.getId() %>', 'dec_<%= av.getId() %>', false, <%= maxPts %>)">
                                <button type="button" class="btn-remove-sub" title="Limpar nota"
                                        onclick="limparNota('pct_<%= av.getId() %>','dec_<%= av.getId() %>')">×</button>
                            </div>
                        </div>
                        <div class="ou-row">ou</div>
                        <div class="nota-field nota-field-clear">
                            <label>Nota em decimal:</label>
                            <div class="input-with-clear">
                                <input type="number" class="input-pill-gray" name="dec_<%= av.getId() %>"
                                       id="dec_<%= av.getId() %>"
                                       step="0.1" min="0" max="<%= maxPts %>"
                                       value="<%= av.getNotaDecimal() != null ? av.getNotaDecimal() : "" %>"
                                       oninput="syncPair('dec_<%= av.getId() %>', 'pct_<%= av.getId() %>', true, <%= maxPts %>)">
                                <button type="button" class="btn-remove-sub" title="Limpar nota"
                                        onclick="limparNota('dec_<%= av.getId() %>','pct_<%= av.getId() %>')">×</button>
                            </div>
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
                        <p class="max-pontos">Máximo <%= limiteA3 %> pontos · Usados <%= formatNum(somaMaxA3) %> · Restante <%= formatNum(restanteA3) %></p>
                        <table class="sub-table">
                            <thead>
                                <tr>
                                    <th>Avaliação</th>
                                    <th>Nota máxima</th>
                                    <th>Nota em decimal</th>
                                    <th>Nota em percentual</th>
                                    <th></th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (SubAvaliacao sub : avComSub.getSubAvaliacoes()) {
                                    String maxVal = formatNum(sub.getMaxPontos());
                                    String notaDecExibida = "";
                                    String notaPctExibida = "";
                                    if (sub.getNotaDecimal() != null) {
                                        notaDecExibida = formatNum(sub.getNotaDecimal());
                                        if (sub.getMaxPontos() > 0) {
                                            notaPctExibida = formatNum(sub.getNotaDecimal() / sub.getMaxPontos() * 100.0);
                                        }
                                    } else if (sub.getNotaPercentual() != null) {
                                        notaPctExibida = formatNum(sub.getNotaPercentual());
                                        if (sub.getMaxPontos() > 0) {
                                            notaDecExibida = formatNum(sub.getNotaPercentual() / 100.0 * sub.getMaxPontos());
                                        }
                                    }
                                %>
                                <tr>
                                    <td><%= sub.getTitulo() %></td>
                                    <td><%= maxVal %></td>
                                    <td><%= notaDecExibida.isEmpty() ? "—" : notaDecExibida %></td>
                                    <td><%= notaPctExibida.isEmpty() ? "—" : notaPctExibida %></td>
                                    <td>
                                        <a href="calcular-media.jsp?ucId=<%= ucId %>&action=removerSub&subId=<%= sub.getId() %>"
                                           class="btn-remove-sub" title="Remover avaliação"
                                           onclick="return confirm('Remover esta avaliação?');">×</a>
                                    </td>
                                </tr>
                                <% } %>
                                <% if (avComSub.getSubAvaliacoes().isEmpty()) { %>
                                <tr>
                                    <td colspan="5" class="sub-table-empty">Nenhuma avaliação adicionada.</td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                    <div class="nota-inputs-side">
                        <div class="nota-field">
                            <label>Nota máxima:</label>
                            <input type="number" class="input-pill-gray" name="novo_sub_max" id="novo_sub_max"
                                   step="0.1" min="0.1" max="<%= formatNum(Math.max(restanteA3, 0.1)) %>"
                                   value="<%= restanteA3 > 0 ? formatNum(Math.min(10, restanteA3)) : "0" %>"
                                   <%= restanteA3 <= 0 ? "disabled" : "" %>
                                   oninput="onNovoSubMaxChange()">
                        </div>
                        <div class="nota-field">
                            <label>Nota em percentual:</label>
                            <input type="number" class="input-pill-gray" name="novo_sub_pct" id="novo_sub_pct"
                                   step="1" min="0" max="100"
                                   <%= restanteA3 <= 0 ? "disabled" : "" %>
                                   oninput="syncNovoSub(false)">
                        </div>
                        <div class="ou-row">ou</div>
                        <div class="nota-field">
                            <label>Nota em decimal:</label>
                            <input type="number" class="input-pill-gray" name="novo_sub_dec" id="novo_sub_dec"
                                   step="0.1" min="0"
                                   max="<%= restanteA3 > 0 ? formatNum(Math.min(10, restanteA3)) : "0" %>"
                                   <%= restanteA3 <= 0 ? "disabled" : "" %>
                                   oninput="syncNovoSub(true)">
                        </div>
                        <button type="submit" name="action" value="adicionarSub" class="btn-add-sub"
                                <%= restanteA3 <= 0 ? "disabled" : "" %>>
                            + Adicionar Avaliação
                        </button>
                        <% if (restanteA3 <= 0) { %>
                        <p class="a3-limit-hint">Limite de 40 pontos da A3 já atingido.</p>
                        <% } %>
                    </div>
                </div>
            </div>
            <% } %>

            <div class="media-footer">
                <a href="dashboard.jsp" class="btn-voltar">Voltar</a>
                <button type="submit" name="action" value="salvar" class="btn-secondary">Salvar</button>
            </div>
        </form>
    </div>

    <script>
        var LIMITE_A3 = <%= limiteA3 %>;
        var SOMA_MAX_A3 = <%= somaMaxA3 %>;

        function limparNota(id1, id2) {
            var a = document.getElementById(id1);
            var b = document.getElementById(id2);
            if (a) a.value = '';
            if (b) b.value = '';
        }

        function formatNota(val) {
            return val.toFixed(1).replace(/\.0$/, '');
        }

        function syncPair(sourceId, targetId, isDecimal, maxPontos) {
            const source = document.getElementById(sourceId) || document.getElementsByName(sourceId)[0];
            const target = document.getElementById(targetId) || document.getElementsByName(targetId)[0];
            if (!source || !target) return;
            const val = parseFloat(source.value);
            if (isNaN(val) || !maxPontos) { target.value = ''; return; }
            if (isDecimal) {
                target.value = formatNota((val / maxPontos) * 100);
            } else {
                target.value = formatNota((val / 100) * maxPontos);
            }
        }

        function getNovoMax() {
            const maxInput = document.getElementById('novo_sub_max');
            const max = maxInput ? parseFloat(maxInput.value) : NaN;
            return (!isNaN(max) && max > 0) ? max : 0;
        }

        function syncNovoSub(isDecimal) {
            const max = getNovoMax();
            const dec = document.getElementById('novo_sub_dec');
            const pct = document.getElementById('novo_sub_pct');
            if (!dec || !pct || max <= 0) return;
            dec.max = max;
            if (isDecimal) {
                const val = parseFloat(dec.value);
                if (isNaN(val)) { pct.value = ''; return; }
                pct.value = formatNota((val / max) * 100);
            } else {
                const val = parseFloat(pct.value);
                if (isNaN(val)) { dec.value = ''; return; }
                dec.value = formatNota((val / 100) * max);
            }
        }

        function onNovoSubMaxChange() {
            const max = getNovoMax();
            const dec = document.getElementById('novo_sub_dec');
            if (dec) dec.max = max > 0 ? max : 0;
            if (dec && dec.value !== '') {
                syncNovoSub(true);
            } else {
                const pct = document.getElementById('novo_sub_pct');
                if (pct && pct.value !== '') {
                    syncNovoSub(false);
                }
            }
        }

        function validarAntesDeAdicionar(event) {
            var submitter = event.submitter;
            if (!submitter || submitter.value !== 'adicionarSub') {
                return true;
            }
            var maxNovo = getNovoMax();
            if (maxNovo <= 0) {
                alert('Informe uma nota máxima válida.');
                return false;
            }
            if (SOMA_MAX_A3 + maxNovo > LIMITE_A3 + 1e-9) {
                alert('Não é possível adicionar esta avaliação: a soma das notas máximas da A3 não pode ultrapassar 40 pontos.');
                return false;
            }
            return true;
        }

        (function () {
            var toast = document.getElementById('toastErro');
            if (toast) {
                setTimeout(function () { toast.style.opacity = '0'; }, 5000);
            }
        })();
    </script>
</body>
</html>
