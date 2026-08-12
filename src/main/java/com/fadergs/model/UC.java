package com.fadergs.model;

import java.util.ArrayList;
import java.util.List;

public class UC {
    private String id;
    private String nome;
    private int semestre;
    private String alunoRa;
    private List<Avaliacao> avaliacoes = new ArrayList<>();

    public UC(String id, String nome, int semestre, String alunoRa) {
        this.id = id;
        this.nome = nome;
        this.semestre = semestre;
        this.alunoRa = alunoRa;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getNome() { return nome; }
    public void setNome(String nome) { this.nome = nome; }

    public int getSemestre() { return semestre; }
    public void setSemestre(int semestre) { this.semestre = semestre; }

    public String getAlunoRa() { return alunoRa; }
    public void setAlunoRa(String alunoRa) { this.alunoRa = alunoRa; }

    public List<Avaliacao> getAvaliacoes() { return avaliacoes; }
    public void setAvaliacoes(List<Avaliacao> avaliacoes) { this.avaliacoes = avaliacoes; }

    /** Nota final ponderada de 0 a 100. */
    public double getNotaFinal() {
        double total = 0;
        for (Avaliacao av : avaliacoes) {
            total += av.getPontosObtidos();
        }
        return total;
    }

    public int getNotaPercentual() {
        return (int) Math.round(getNotaFinal());
    }

    public String getNotaFormatada() {
        return String.format("%.0f/100", getNotaFinal());
    }

    /** Inicializa a estrutura padrão de avaliações (30+30+40 = 100 pts). */
    public void inicializarAvaliacoesPadrao() {
        avaliacoes.clear();
        Avaliacao av1 = new Avaliacao("av1", "A1", 30);
        Avaliacao av2 = new Avaliacao("av2", "A2", 30);
        Avaliacao av3 = new Avaliacao("av3", "A3", 40);
        av3.getSubAvaliacoes().add(new SubAvaliacao("sub1", "A3.1"));
        av3.getSubAvaliacoes().add(new SubAvaliacao("sub2", "A3.2"));
        avaliacoes.add(av1);
        avaliacoes.add(av2);
        avaliacoes.add(av3);
    }
}
