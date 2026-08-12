package com.fadergs.model;

public class SubAvaliacao {
    private String id;
    private String titulo;
    private double maxPontos = 10.0;
    private Double notaDecimal;
    private Double notaPercentual;

    public SubAvaliacao(String id, String titulo) {
        this(id, titulo, 10.0);
    }

    public SubAvaliacao(String id, String titulo, double maxPontos) {
        this.id = id;
        this.titulo = titulo;
        this.maxPontos = maxPontos > 0 ? maxPontos : 10.0;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getTitulo() { return titulo; }
    public void setTitulo(String titulo) { this.titulo = titulo; }

    public double getMaxPontos() { return maxPontos; }
    public void setMaxPontos(double maxPontos) {
        this.maxPontos = maxPontos > 0 ? maxPontos : 10.0;
    }

    public Double getNotaDecimal() { return notaDecimal; }
    public void setNotaDecimal(Double notaDecimal) { this.notaDecimal = notaDecimal; }

    public Double getNotaPercentual() { return notaPercentual; }
    public void setNotaPercentual(Double notaPercentual) { this.notaPercentual = notaPercentual; }

    /** Retorna a nota normalizada de 0 a 1 (nota máxima da sub = 100%). */
    public double getNotaNormalizada() {
        if (notaDecimal != null) {
            return maxPontos > 0 ? notaDecimal / maxPontos : 0.0;
        }
        if (notaPercentual != null) {
            return notaPercentual / 100.0;
        }
        return 0.0;
    }
}
