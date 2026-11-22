package br.com.apoiosus.config;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

/**
 * Carrega as configurações padrão de application.properties.
 * Variáveis de ambiente, quando informadas, têm prioridade sobre o arquivo.
 */
public record Configuracao(
        int apiPorta,
        String databaseUrl,
        String databaseUsuario,
        String databaseSenha,
        long sessaoHorasValidade,
        long recuperacaoMinutosValidade,
        String cnesUrl,
        String cnesUsuario,
        String cnesSenha) {

    private static final String ARQUIVO = "application.properties";

    public static Configuracao carregar() throws IOException {
        Properties propriedades = new Properties();

        try (InputStream recurso = Configuracao.class.getClassLoader().getResourceAsStream(ARQUIVO)) {
            if (recurso == null) {
                throw new IllegalStateException(
                        "Arquivo " + ARQUIVO + " não encontrado no classpath do backend.");
            }
            propriedades.load(recurso);
        }

        return new Configuracao(
                inteiro(propriedades, "api.port", "API_PORT"),
                texto(propriedades, "database.url", "DB_URL"),
                texto(propriedades, "database.username", "DB_USUARIO"),
                textoOpcional(propriedades, "database.password", "DB_SENHA"),
                longo(propriedades, "session.hours-validity", "SESSAO_HORAS_VALIDADE"),
                longo(propriedades, "password-recovery.minutes-validity", "RECUPERACAO_MINUTOS_VALIDADE"),
                texto(propriedades, "cnes.url", "CNES_URL"),
                texto(propriedades, "cnes.username", "CNES_USUARIO"),
                texto(propriedades, "cnes.password", "CNES_SENHA"));
    }

    private static int inteiro(Properties propriedades, String chave, String variavelAmbiente) {
        try {
            return Integer.parseInt(texto(propriedades, chave, variavelAmbiente));
        } catch (NumberFormatException e) {
            throw new IllegalStateException("Configuração inválida: " + chave + " deve ser um número inteiro.", e);
        }
    }

    private static long longo(Properties propriedades, String chave, String variavelAmbiente) {
        try {
            return Long.parseLong(texto(propriedades, chave, variavelAmbiente));
        } catch (NumberFormatException e) {
            throw new IllegalStateException("Configuração inválida: " + chave + " deve ser um número inteiro.", e);
        }
    }

    private static String texto(Properties propriedades, String chave, String variavelAmbiente) {
        String valorAmbiente = System.getenv(variavelAmbiente);
        if (valorAmbiente != null && !valorAmbiente.isBlank()) {
            return valorAmbiente.trim();
        }

        String valorArquivo = propriedades.getProperty(chave);
        if (valorArquivo == null || valorArquivo.isBlank()) {
            throw new IllegalStateException("Configuração obrigatória ausente: " + chave);
        }
        return valorArquivo.trim();
    }

    private static String textoOpcional(Properties propriedades, String chave, String variavelAmbiente) {
        String valorAmbiente = System.getenv(variavelAmbiente);
        if (valorAmbiente != null && !valorAmbiente.isBlank()) {
            return valorAmbiente.trim();
        }
        return propriedades.getProperty(chave, "").trim();
    }
}
