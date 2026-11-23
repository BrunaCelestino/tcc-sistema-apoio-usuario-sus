# Apoio SUS

Aplicativo multiplataforma desenvolvido como Trabalho de Conclusão de Curso. O Apoio SUS reúne recursos para que o cidadão organize informações pessoais relacionadas à saúde e consulte informações sobre unidades públicas de atendimento.

## Sobre o projeto

O sistema é composto por um aplicativo desenvolvido com .NET MAUI e um backend em Java. O aplicativo se comunica com uma API própria, que aplica as regras de negócio, armazena os dados pessoais no MySQL e consulta o Cadastro Nacional de Estabelecimentos de Saúde (CNES) por meio de um serviço SOAP.

O objetivo é oferecer um espaço de organização pessoal e consulta informativa. O sistema não acessa prontuários oficiais, não se integra aos sistemas internos do SUS e não substitui a avaliação de profissionais de saúde.

## Funcionalidades

### Conta e autenticação

- Cadastro de usuário com nome, e-mail, senha e data de nascimento opcional.
- Login e encerramento da sessão.
- Consulta e atualização do nome e da data de nascimento da conta.
- Exclusão da conta.
- Recuperação e redefinição de senha por código temporário.

**Observação sobre a recuperação de senha:** no ambiente acadêmico, o código é exibido no log do backend. O sistema não envia e-mail. O código expira conforme o tempo configurado no backend.

### Perfil de saúde

O perfil é criado automaticamente junto com a conta. O usuário pode consultar, atualizar ou limpar seus dados pessoais de saúde:

- Peso e altura.
- Tipo sanguíneo.
- Alergias.
- Observações médicas.

Essas informações são mantidas para consulta pessoal do usuário. Não são enviadas a profissionais de saúde nem incorporadas a prontuários do SUS.

### Histórico de vacinação

O usuário pode cadastrar, consultar, atualizar e excluir seus próprios registros de vacinação. Cada registro pode conter nome da vacina, data de aplicação, lote e local de aplicação.

O aplicativo não consulta a caderneta nacional de vacinação, não compara os registros com o calendário oficial e não identifica automaticamente vacinas pendentes.

### Medicamentos

O usuário pode cadastrar, consultar, atualizar e excluir medicamentos, registrando nome, dosagem, frequência e período de utilização. A interface organiza os registros em medicamentos em uso e histórico, conforme as datas informadas.

Não há envio de lembretes, notificações ou controle automático de horários e doses.

### Consulta de unidades de saúde

O usuário seleciona manualmente um município do Estado de São Paulo. O backend consulta o serviço SOAP do CNES e retorna estabelecimentos identificados como integrantes do SUS.

A consulta solicita quatro categorias de estabelecimento:

- **02:** Centro de Saúde / Unidade Básica de Saúde.
- **73:** Pronto Atendimento.
- **05:** Hospital Geral.
- **07:** Hospital Especializado.

Os resultados são apresentados em uma lista, com informações de identificação, endereço e contato quando disponíveis. É possível pesquisar pelo nome ou endereço e abrir o endereço no Google Maps, em um serviço externo.

**Limitações da localização:** a aplicação não utiliza GPS, não calcula distância, não determina automaticamente as unidades mais próximas e não posiciona marcadores em um mapa dinâmico. A visualização denominada Mapa utiliza uma imagem ilustrativa estática. A lista também não oferece filtro por distância ou categoria.

A rota da API usada para essa consulta mantém o nome `/api/unidades-saude/upas` por compatibilidade com a implementação, embora os resultados incluam as quatro categorias descritas acima.

### Orientações de saúde

O aplicativo disponibiliza conteúdos gerais sobre prevenção, doenças e hábitos saudáveis. Os textos ficam no arquivo `backend/src/main/resources/orientacoes.json`, são carregados pelo backend na inicialização e enviados ao aplicativo pela API.

O usuário pode pesquisar os conteúdos e filtrar por categoria. As orientações não são geradas por inteligência artificial nem consultadas dinamicamente em uma fonte externa.

### Apoio informativo baseado em sintomas

O usuário pode descrever sintomas em um campo de texto. O backend compara o texto com regras e palavras-chave previamente definidas em `backend/src/main/resources/sintomas.json` e retorna correspondências, orientações gerais e alertas para possíveis sinais de urgência.

Esse recurso:

- Utiliza correspondência de palavras-chave e regras fixas; não utiliza inteligência artificial.
- Não realiza diagnóstico, triagem clínica, classificação de risco ou prescrição.
- Não recomenda automaticamente uma unidade específica para o sintoma informado.
- Não salva o texto digitado nem o resultado como histórico de análises.

As informações são exclusivamente educativas e não substituem avaliação profissional. Em uma situação de urgência, o usuário deve procurar atendimento imediatamente ou acionar o serviço de emergência indicado no aplicativo.

## Tecnologias utilizadas

| Camada | Tecnologia |
| --- | --- |
| Aplicativo | C#, .NET MAUI 10 e XAML |
| Organização da interface | MVVM |
| Backend | Java 21, servidor HTTP do JDK (`HttpServer`) e JDBC |
| API | HTTP e JSON |
| Banco de dados principal | MySQL 8 |
| Banco utilizado em testes locais | SQLite, opcional |
| Integração externa | Serviço SOAP do CNES |
| Testes automatizados do backend | JUnit Jupiter 6.1.3 |
| Gerenciamento de dependências Java | Maven, com Maven Wrapper |

O backend não utiliza Spring Boot. Os componentes de controller, service, repository e model são organizados diretamente no projeto Java.

## Arquitetura

```text
Aplicativo .NET MAUI
        |
        | HTTP / JSON
        | Authorization: Bearer <token>
        v
Backend Java 21 (JDK HttpServer)
        |                         |
        | JDBC                    | SOAP
        v                         v
     MySQL 8                 Serviço CNES
```

O aplicativo é responsável pelas telas e pela interação com o usuário. O backend autentica as requisições, valida os dados, aplica as regras de negócio e acessa o banco de dados ou o serviço externo do CNES, conforme a funcionalidade solicitada.

## Estrutura do repositório

```text
backend/
  .mvn/wrapper/                 Configuração do Maven Wrapper
  src/main/java/                Código-fonte Java
    .../config/                 Leitura das configurações
    .../controller/             Rotas HTTP da API
    .../dto/                    Objetos de requisição e resposta
    .../integration/             Integração SOAP com o CNES
    .../model/                  Modelos de domínio
    .../repository/             Acesso aos dados
    .../service/                Regras de negócio
  src/main/resources/
    application.properties      Configurações padrão
    db/migration/                Migrations MySQL e SQLite
    municipios-sp.csv            Municípios do Estado de São Paulo
    orientacoes.json             Conteúdos gerais de saúde
    sintomas.json                Regras de análise informativa
  src/test/java/                 Testes automatizados
  requests.http                  Exemplos de chamadas à API
  pom.xml
  mvnw / mvnw.cmd
frontend/
  ApoioSus/
    Models/                      Modelos e DTOs do aplicativo
    Platforms/                   Configurações por plataforma
    Resources/                   Imagens, fontes, ícones e estilos
    Services/                    Comunicação com a API e sessão
    ViewModels/                  Estado e comandos das telas
    Views/                       Interfaces XAML
    ApoioSus.csproj
docs/
  schema_mysql_atual.sql         Esquema consolidado das migrations
README.md
```

## Requisitos para execução

- Windows 10 ou superior para executar o aplicativo Windows.
- JDK 21.
- .NET SDK 10.
- Workload .NET MAUI instalado.
- MySQL Server 8.
- Conexão com a internet para restaurar dependências e consultar o CNES.

Para conferir a instalação do .NET MAUI, execute:

```powershell
dotnet workload list
```

Se o workload MAUI ainda não estiver instalado:

```powershell
dotnet workload install maui
```

## Configuração do banco de dados

Com o MySQL em execução, crie o banco e um usuário para a aplicação. Substitua a senha de exemplo por uma senha local:

```sql
CREATE DATABASE IF NOT EXISTS apoio_usuario_sus
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'apoio_sus'@'localhost'
    IDENTIFIED BY 'sua-senha-local';

GRANT ALL PRIVILEGES ON apoio_usuario_sus.*
    TO 'apoio_sus'@'localhost';
```

Se o usuário já existir e for necessário trocar a senha, utilize `ALTER USER` no MySQL.

Na primeira inicialização, o backend executa automaticamente as migrations V1, V2 e V3. Não é necessário criar manualmente as tabelas. A tabela `schema_migracao` registra quais migrations já foram aplicadas.

O arquivo `docs/schema_mysql_atual.sql` é uma representação consolidada do esquema MySQL correspondente às migrations. Ele serve como referência; a inicialização normal da aplicação deve utilizar as migrations.

### Tabelas e persistência

As migrations incluem tabelas para usuários, perfil de saúde, vacinas, medicamentos, unidades de saúde, campanhas de vacinação, orientações, análises de sintomas, sessões e recuperação de senha.

Nem todas essas tabelas são utilizadas pelos fluxos atuais do aplicativo:

- Os dados de unidades são consultados diretamente no CNES e não são persistidos na tabela `unidade_saude`.
- Os conteúdos de orientações são carregados de `orientacoes.json`, não da tabela `orientacao_saude`.
- As regras de sintomas são carregadas de `sintomas.json`; os textos e resultados das análises não são gravados na tabela `analise_sintoma`.
- A consulta de campanhas de vacinação ainda não está implementada; a tabela `campanha_vacinacao` permanece prevista no esquema.
- As tabelas `sessao` e `recuperacao_senha` são utilizadas pela autenticação e recuperação de senha.

## Configuração do backend

As configurações padrão estão em `backend/src/main/resources/application.properties`. As variáveis de ambiente, quando informadas, substituem os valores do arquivo.

| Configuração | Variável de ambiente | Valor padrão |
| --- | --- | --- |
| Porta da API | `API_PORT` | `8080` |
| URL JDBC do banco | `DB_URL` | `jdbc:mysql://localhost:3306/apoio_usuario_sus?useUnicode=true&characterEncoding=utf8&connectionTimeZone=LOCAL` |
| Usuário do banco | `DB_USUARIO` | `apoio_sus` |
| Senha do banco | `DB_SENHA` | Vazia no arquivo; deve ser informada no ambiente |
| Validade da sessão, em horas | `SESSAO_HORAS_VALIDADE` | `24` |
| Validade do código de recuperação, em minutos | `RECUPERACAO_MINUTOS_VALIDADE` | `30` |
| URL do CNES | `CNES_URL` | Endpoint SOAP configurado em `application.properties` |
| Usuário do CNES | `CNES_USUARIO` | Valor definido em `application.properties` |
| Senha do CNES | `CNES_SENHA` | Valor definido em `application.properties` |

Para uma configuração local, informe ao menos a senha do MySQL. Não grave senhas pessoais ou credenciais próprias no repositório.

## Como executar

Abra dois terminais PowerShell na pasta raiz do repositório. O banco MySQL deve estar ativo antes de iniciar o backend.

### 1. Iniciar o backend

No primeiro terminal:

```powershell
cd backend
$env:DB_SENHA = "sua-senha-local"
.\mvnw.cmd clean compile exec:java
```

Na primeira execução, o Maven Wrapper poderá baixar a distribuição do Maven e as dependências do projeto. Após a inicialização, o backend informa o endereço da API no terminal.

Verifique se a API está ativa acessando:

```text
http://localhost:8080/api/ping
```

Resposta esperada:

```json
{
  "status": "ok"
}
```

### 2. Iniciar o aplicativo no Windows

No segundo terminal:

```powershell
cd frontend\ApoioSus
dotnet restore
dotnet build -t:Run -f net10.0-windows10.0.19041.0
```

O aplicativo Windows está configurado para acessar o backend em `http://localhost:8080`. Mantenha o backend em execução enquanto utiliza o aplicativo.

### 3. Executar no Android

O projeto também possui o alvo `net10.0-android`. Com o Android SDK, o workload MAUI e um emulador configurados, execute:

```powershell
cd frontend\ApoioSus
dotnet build -t:Run -f net10.0-android
```

No Android, a aplicação utiliza `http://10.0.2.2:8080`, endereço que permite ao emulador Android acessar o backend executado no computador host.

Para executar em um aparelho físico, será necessário ajustar `ApiService.BaseUrl`, em `frontend/ApoioSus/Services/Api/ApiService.cs`, para o endereço IP local do computador que hospeda o backend. O aparelho e o computador devem estar na mesma rede, e a porta 8080 deve estar liberada no firewall.

## Testes automatizados

O backend contém 100 métodos de teste com JUnit Jupiter 6.1.3, cobrindo rotas da API, autenticação, conta, perfil de saúde, vacinas, medicamentos, migrations, municípios, CNES, orientações e análise de sintomas.

Os testes utilizam MySQL por padrão. **O banco informado em `TESTE_MYSQL_URL` é esvaziado antes da execução. Nunca utilize o banco de dados da aplicação ou um banco com informações importantes.**

### Opção A — MySQL exclusivo para testes

Crie um banco separado:

```sql
CREATE DATABASE IF NOT EXISTS apoio_usuario_sus_teste
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'apoio_sus_teste'@'localhost'
    IDENTIFIED BY 'senha-de-teste';

GRANT ALL PRIVILEGES ON apoio_usuario_sus_teste.*
    TO 'apoio_sus_teste'@'localhost';
```

No PowerShell:

```powershell
cd backend
$env:TESTE_MYSQL_URL = "jdbc:mysql://localhost:3306/apoio_usuario_sus_teste?user=apoio_sus_teste&password=senha-de-teste&useUnicode=true&characterEncoding=utf8&connectionTimeZone=LOCAL"
.\mvnw.cmd test
```

### Opção B — SQLite temporário

Para executar os testes sem configurar um MySQL de testes, selecione explicitamente SQLite:

```powershell
cd backend
$env:TESTE_SQLITE = "true"
.\mvnw.cmd test
```

Nessa opção, os testes criam arquivos SQLite temporários dentro de `backend/target/testes`. Os testes de integração com o CNES utilizam um servidor simulado (`CnesFalso`), não dependendo de uma chamada real ao serviço público.

## Endpoints da API

Todas as rotas utilizam o prefixo `/api`. As rotas protegidas exigem o cabeçalho `Authorization: Bearer <token>`, obtido após o login.

| Método | Rota | Descrição | Autenticação |
| --- | --- | --- | --- |
| `GET` | `/api/ping` | Verifica se a API está ativa | Não |
| `POST` | `/api/auth/cadastro` | Cadastra um usuário | Não |
| `POST` | `/api/auth/login` | Autentica o usuário | Não |
| `POST` | `/api/auth/logout` | Encerra a sessão atual | Sim |
| `POST` | `/api/auth/recuperar-senha` | Solicita código de recuperação | Não |
| `POST` | `/api/auth/redefinir-senha` | Redefine a senha com o código recebido | Não |
| `GET`, `PUT`, `DELETE` | `/api/usuarios/me` | Consulta, atualiza ou exclui a conta | Sim |
| `GET`, `PUT`, `DELETE` | `/api/perfil` | Consulta, atualiza ou limpa o perfil de saúde | Sim |
| `GET`, `POST` | `/api/vacinas` | Lista ou cadastra vacinas | Sim |
| `GET`, `PUT`, `DELETE` | `/api/vacinas/{id}` | Consulta, atualiza ou exclui um registro de vacina | Sim |
| `GET`, `POST` | `/api/medicamentos` | Lista ou cadastra medicamentos | Sim |
| `GET`, `PUT`, `DELETE` | `/api/medicamentos/{id}` | Consulta, atualiza ou exclui um medicamento | Sim |
| `GET` | `/api/unidades-saude/municipios` | Lista os municípios de São Paulo | Sim |
| `GET` | `/api/unidades-saude/upas?municipio={codigo}&inicio={registro}` | Consulta estabelecimentos no CNES; nome da rota legado | Sim |
| `GET` | `/api/orientacoes` | Retorna os conteúdos de orientação do arquivo JSON | Sim |
| `POST` | `/api/sintomas/analise` | Analisa o texto informado com regras locais | Sim |

Exemplos de requisições HTTP estão disponíveis em `backend/requests.http`.

## Segurança e privacidade

- As senhas são armazenadas com hash PBKDF2-HMAC-SHA256 e salt aleatório individual.
- Os tokens de sessão são gerados aleatoriamente; o banco armazena o hash SHA-256 do token, não o valor original.
- As sessões possuem validade configurável e podem ser revogadas pelo logout.
- As rotas de dados pessoais verificam a sessão e associam as operações ao usuário autenticado.
- O código de recuperação também é armazenado no banco como hash, mas é exibido em texto no log do backend para viabilizar o fluxo acadêmico.
- A configuração padrão utiliza HTTP, sem TLS. Não exponha a aplicação diretamente à internet nem utilize essa configuração como implantação de produção.

## Limitações e escopo

O projeto foi desenvolvido em contexto acadêmico. Não estão implementados:

- Integração com prontuários, cadastros internos ou sistemas privados do SUS.
- Agendamento de consultas ou exames.
- Consulta e gerenciamento de campanhas públicas de vacinação.
- Sincronização com a caderneta nacional de vacinação ou identificação automática de doses pendentes.
- Lembretes e notificações de medicamentos.
- Geolocalização, cálculo de distância ou mapa com marcadores dinâmicos.
- Geração de orientações por inteligência artificial ou diagnóstico automatizado.
- Histórico persistente das análises de sintomas.
- Envio de código de recuperação de senha por e-mail.

Os conteúdos de orientação e as regras de sintomas são materiais informativos estáticos e devem ser tratados como apoio educativo, não como aconselhamento médico.

## Licença e finalidade

Este repositório foi desenvolvido para fins acadêmicos como Trabalho de Conclusão do Curso Técnico em Desenvolvimento de Sistemas. Não é um produto médico nem substitui sistemas oficiais ou serviços profissionais de saúde.