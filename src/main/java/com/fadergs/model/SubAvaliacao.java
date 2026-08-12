package com.fadergs.model;

public class SubAvaliacao {
    private String id;
    private String titulo;
    private Double notaDecimal;
    private Double notaPercentual;

    public SubAvaliacao(String id, String titulo) {
        this.id = id;
        this.titulo = titulo;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getTitulo() { return titulo; }
    public void setTitulo(String titulo) { this.titulo = titulo; }

    public Double getNotaDecimal() { return notaDecimal; }
    public void setNotaDecimal(Double notaDecimal) { this.notaDecimal = notaDecimal; }

    public Double getNotaPercentual() { return notaPercentual; }
    public void setNotaPercentual(Double notaPercentual) { this.notaPercentual = notaPercentual; }

    /** Retorna a nota normalizada de 0 a 1 (base 10 ou percentual). */
    public double getNotaNormalizada() {
        if (notaDecimal != null) {
            return notaDecimal / 10.0;
        }
        if (notaPercentual != null) {
            return notaPercentual / 100.0;
        }
        return 0.0;
    }
}
