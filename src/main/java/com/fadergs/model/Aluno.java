package com.fadergs.model;

/**
 * Representa um aluno cadastrado no protótipo.
 * ATENÇÃO: senha armazenada em texto puro — apenas para fins didáticos.
 * Em produção, usar hash (bcrypt/argon2) e persistência em banco de dados.
 */
public class Aluno {
    private String ra;
    private String nome;
    private String senha;
    private String curso;

    public Aluno(String ra, String nome, String senha, String curso) {
        this.ra = ra;
        this.nome = nome;
        this.senha = senha;
        this.curso = curso;
    }

    public String getRa() { return ra; }
    public void setRa(String ra) { this.ra = ra; }

    public String getNome() { return nome; }
    public void setNome(String nome) { this.nome = nome; }

    public String getSenha() { return senha; }
    public void setSenha(String senha) { this.senha = senha; }

    public String getCurso() { return curso; }
    public void setCurso(String curso) { this.curso = curso; }
}
