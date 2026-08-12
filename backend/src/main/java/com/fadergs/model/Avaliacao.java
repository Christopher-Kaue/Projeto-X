package com.fadergs.model;

import java.util.ArrayList;
import java.util.List;

public class Avaliacao {
    private String id;
    private String titulo;
    private int maxPontos;
    private Double notaDecimal;
    private Double notaPercentual;
    private List<SubAvaliacao> subAvaliacoes = new ArrayList<>();

    public Avaliacao(String id, String titulo, int maxPontos) {
        this.id = id;
        this.titulo = titulo;
        this.maxPontos = maxPontos;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getTitulo() { return titulo; }
    public void setTitulo(String titulo) { this.titulo = titulo; }

    public int getMaxPontos() { return maxPontos; }
    public void setMaxPontos(int maxPontos) { this.maxPontos = maxPontos; }

    public Double getNotaDecimal() { return notaDecimal; }
    public void setNotaDecimal(Double notaDecimal) { this.notaDecimal = notaDecimal; }

    public Double getNotaPercentual() { return notaPercentual; }
    public void setNotaPercentual(Double notaPercentual) { this.notaPercentual = notaPercentual; }

    public List<SubAvaliacao> getSubAvaliacoes() { return subAvaliacoes; }
    public void setSubAvaliacoes(List<SubAvaliacao> subAvaliacoes) { this.subAvaliacoes = subAvaliacoes; }

    public boolean hasSubAvaliacoes() {
        return subAvaliacoes != null && !subAvaliacoes.isEmpty();
    }

    /** A3 é composta (pode ter A3.1, A3.2, …) mesmo com a lista vazia. */
    public boolean isComposta() {
        return "av3".equals(id) || "A3".equals(titulo);
    }

    /** Retorna a nota normalizada de 0 a 1 para esta avaliação. */
    public double getNotaNormalizada() {
        if (isComposta()) {
            if (!hasSubAvaliacoes()) {
                return 0.0;
            }
            // Média ponderada pelos pesos (nota máxima) de cada subavaliação
            double somaPonderada = 0;
            double somaPesos = 0;
            for (SubAvaliacao sub : subAvaliacoes) {
                double peso = sub.getMaxPontos();
                if (peso <= 0) {
                    continue;
                }
                somaPonderada += sub.getNotaNormalizada() * peso;
                somaPesos += peso;
            }
            return somaPesos > 0 ? somaPonderada / somaPesos : 0.0;
        }
        if (notaDecimal != null) {
            return maxPontos > 0 ? notaDecimal / maxPontos : 0.0;
        }
        if (notaPercentual != null) {
            return notaPercentual / 100.0;
        }
        return 0.0;
    }

    /** Pontos obtidos nesta avaliação (ponderados pelo maxPontos). */
    public double getPontosObtidos() {
        return getNotaNormalizada() * maxPontos;
    }
}
