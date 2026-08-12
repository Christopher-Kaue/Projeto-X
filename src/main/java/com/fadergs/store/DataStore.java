package com.fadergs.store;

import com.fadergs.model.Aluno;
import com.fadergs.model.Avaliacao;
import com.fadergs.model.SubAvaliacao;
import com.fadergs.model.UC;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * Armazenamento em memória do protótipo de oficina.
 * ATENÇÃO: dados perdidos ao reiniciar o servidor — não usar em produção.
 * Futuramente: substituir por DAO + banco de dados (JDBC/JPA).
 */
public class DataStore {
    private static DataStore instance;
    private final Map<String, Aluno> alunos = new HashMap<>();
    private final Map<String, List<UC>> ucsPorAluno = new HashMap<>();

    private DataStore() {
        inicializarDadosExemplo();
    }

    public static synchronized DataStore getInstance() {
        if (instance == null) {
            instance = new DataStore();
        }
        return instance;
    }

  private void inicializarDadosExemplo() {
        Aluno fulano = new Aluno("123456", "Fulano", "senha123", "Análise e Desenvolvimento de Sistemas");
        alunos.put(fulano.getRa(), fulano);

        List<UC> ucs = new ArrayList<>();

        // 4º Semestre — conforme imagem de referência do dashboard
        UC eng = new UC("uc3", "Engenharia de Software", 4, fulano.getRa());
        definirNotaUC(eng, 50);
        ucs.add(eng);

        UC web = new UC("uc4", "Desenvolvimento Web", 4, fulano.getRa());
        definirNotaUC(web, 50);
        ucs.add(web);

        // 3º Semestre
        UC bd = new UC("uc1", "Banco de Dados", 3, fulano.getRa());
        definirNotaUC(bd, 0);
        ucs.add(bd);

        UC gqs = new UC("uc5", "Garantia da Qualidade de Software", 3, fulano.getRa());
        definirNotaUC(gqs, 50);
        ucs.add(gqs);

        UC mca = new UC("uc6", "Matemática Computacional Aplicada", 3, fulano.getRa());
        definirNotaUC(mca, 100);
        ucs.add(mca);

        ucsPorAluno.put(fulano.getRa(), ucs);
    }

    /** Define nota ilustrativa (0–100) para dados de exemplo do protótipo. */
    private void definirNotaUC(UC uc, int percentual) {
        uc.inicializarAvaliacoesPadrao();
        if (percentual <= 0) {
            return;
        }
        double notaDecimal = percentual / 10.0;
        for (Avaliacao av : uc.getAvaliacoes()) {
            if (av.hasSubAvaliacoes()) {
                for (SubAvaliacao sub : av.getSubAvaliacoes()) {
                    sub.setNotaDecimal(notaDecimal);
                }
            } else {
                av.setNotaDecimal(notaDecimal);
            }
        }
    }

    public Aluno buscarAluno(String ra) {
        return alunos.get(ra);
    }

    public boolean autenticar(String ra, String senha) {
        Aluno aluno = alunos.get(ra);
        return aluno != null && aluno.getSenha().equals(senha);
    }

    public boolean raExiste(String ra) {
        return alunos.containsKey(ra);
    }

    public void cadastrarAluno(Aluno aluno) {
        alunos.put(aluno.getRa(), aluno);
        ucsPorAluno.put(aluno.getRa(), new ArrayList<>());
    }

    public void atualizarAluno(Aluno aluno) {
        alunos.put(aluno.getRa(), aluno);
    }

    public List<UC> getUCsPorAluno(String ra) {
        return ucsPorAluno.getOrDefault(ra, new ArrayList<>());
    }

    public UC buscarUC(String ra, String ucId) {
        return getUCsPorAluno(ra).stream()
                .filter(uc -> uc.getId().equals(ucId))
                .findFirst()
                .orElse(null);
    }

    public void adicionarUC(UC uc) {
        ucsPorAluno.computeIfAbsent(uc.getAlunoRa(), k -> new ArrayList<>()).add(uc);
    }

    public void atualizarUC(UC ucAtualizada) {
        List<UC> ucs = ucsPorAluno.get(ucAtualizada.getAlunoRa());
        if (ucs != null) {
            for (int i = 0; i < ucs.size(); i++) {
                if (ucs.get(i).getId().equals(ucAtualizada.getId())) {
                    ucs.set(i, ucAtualizada);
                    return;
                }
            }
        }
    }

    public void removerUC(String ra, String ucId) {
        List<UC> ucs = ucsPorAluno.get(ra);
        if (ucs != null) {
            ucs.removeIf(uc -> uc.getId().equals(ucId));
        }
    }

    public UC criarNovaUC(String nome, int semestre, String alunoRa) {
        String id = "uc-" + UUID.randomUUID().toString().substring(0, 8);
        UC uc = new UC(id, nome, semestre, alunoRa);
        uc.inicializarAvaliacoesPadrao();
        adicionarUC(uc);
        return uc;
    }

    /** Agrupa UCs por semestre para exibição no dashboard. */
    public Map<Integer, List<UC>> agruparPorSemestre(String ra) {
        return getUCsPorAluno(ra).stream()
                .collect(Collectors.groupingBy(UC::getSemestre));
    }
}
