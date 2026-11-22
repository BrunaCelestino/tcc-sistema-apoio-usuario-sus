# Apoio SUS

Aplicativo para centralizar dados de saúde informados pelo próprio usuário e facilitar o acesso a informações públicas do SUS, como as UPAs de cada município do Estado de São Paulo. Projeto de estudo (TCC).

## Estrutura do repositório

```text
backend/       API Java 21, configuração, migrations MySQL e testes automatizados
frontend/      Aplicativo .NET MAUI (C#, XAML)
README.md      Documentação e instruções do projeto
```

- **Frontend:** .NET MAUI (C#, XAML) com MVVM escrito à mão, sem biblioteca. Roda no Windows.
- **Backend:** Java 21 puro (sem Spring), servidor HTTP do JDK e JDBC, com **MySQL 8 como banco padrão**.

Os dados pessoais são autodeclarados: o app não acessa prontuários oficiais e não faz diagnóstico.

## O que já funciona

| Módulo | Funcionalidades |
| --- | --- |
| Autenticação | Cadastro, login, logout, recuperação e redefinição de senha |
| Conta | Consultar, editar nome/data de nascimento e excluir |
| Perfil de saúde | Peso, altura, tipo sanguíneo, alergias e observações; consultar, atualizar e limpar |
| Vacinas | Cadastrar, listar, consultar, editar e excluir |
| Medicamentos | Cadastrar, listar, consultar, editar e excluir, com abas Em uso e Histórico |
| Unidades de saúde | Selecionar município paulista e consultar UPAs do SUS via CNES; lista e mapa ilustrativo, busca e abertura de rotas |
| Orientações de saúde | Conteúdo fixo em JSON com busca e filtros |
| Análise de sintomas | Regras fixas em JSON; orientações informativas e alertas, sem IA e sem diagnóstico |

**Limitações conhecidas:** mapa ilustrativo (sem marcadores reais); consulta restrita a UPAs do SUS em municípios paulistas; sem UBS, hospitais, campanhas, vacinas pendentes, lembretes, troca de e-mail ou troca de senha autenticada. O código de recuperação é exibido no terminal, sem envio de e-mail. O aplicativo foi executado e testado no Windows.

## Arquitetura

```text
App .NET MAUI (Windows) ──HTTP/JSON──▶ API Java 21 (JDK HttpServer) ──JDBC──▶ MySQL 8
                                                     │
                                                     └──SOAP──▶ CNES, Ministério da Saúde
```

## Requisitos

- Windows 10 ou superior (testado no Windows 11).
- JDK 21.
- .NET SDK 10 e workload MAUI para Windows.
- MySQL Server 8.x.
- Internet para baixar dependências e consultar o CNES.
- Portas 8080 (API) e 3306 (MySQL).

## Configuração do banco

No MySQL Workbench, conectado como administrador, execute:

```sql
CREATE DATABASE IF NOT EXISTS apoio_usuario_sus
  CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

CREATE USER IF NOT EXISTS 'apoio_sus'@'localhost' IDENTIFIED BY 'troque-esta-senha';
GRANT ALL PRIVILEGES ON apoio_usuario_sus.* TO 'apoio_sus'@'localhost';
```

A API cria as tabelas automaticamente na primeira execução, usando as migrations em `backend/src/main/resources/db/migration/mysql/`.

## Configuração da aplicação

As configurações padrão ficam em `backend/src/main/resources/application.properties`. O arquivo é carregado pelo backend Java ao iniciar. Ele reúne porta da API, conexão MySQL para o banco `apoio_usuario_sus`, validade da sessão, validade da recuperação de senha e endereço/credenciais públicas do serviço CNES.

As variáveis de ambiente sobrescrevem os valores do arquivo. A senha do MySQL não fica preenchida no arquivo versionado: informe-a em `DB_SENHA`.

| Propriedade | Variável de ambiente | Padrão |
| --- | --- | --- |
| `api.port` | `API_PORT` | `8080` |
| `database.url` | `DB_URL` | MySQL local, banco `apoio_usuario_sus` |
| `database.username` | `DB_USUARIO` | `apoio_usuario_sus` |
| `database.password` | `DB_SENHA` | Vazia; configure por variável de ambiente |
| `session.hours-validity` | `SESSAO_HORAS_VALIDADE` | `24` |
| `password-recovery.minutes-validity` | `RECUPERACAO_MINUTOS_VALIDADE` | `30` |
| `cnes.url` | `CNES_URL` | Serviço SOAP do CNES |
| `cnes.username` | `CNES_USUARIO` | Credencial pública do CNES |
| `cnes.password` | `CNES_SENHA` | Credencial pública do CNES |

## Executar

Abra dois terminais PowerShell na raiz do repositório.

### 1. API

No primeiro terminal:

```powershell
cd backend
$env:DB_SENHA = "sua-senha-do-mysql"
.mvnw.cmd exec:java
```

Para um ambiente diferente, também é possível sobrescrever `DB_URL`, `DB_USUARIO` ou `API_PORT`. Verifique `http://localhost:8080/api/ping`, que deve responder `{"status":"ok"}`.

Não versione nem compartilhe sua senha real.

### 2. Aplicativo

No segundo terminal:

```powershell
cd frontend\ApoioSus
dotnet build -f net10.0-windows10.0.19041.0
.\bin\Debug\net10.0-windows10.0.19041.0\win-x64\ApoioSus.exe
```

O aplicativo se conecta a `http://localhost:8080`. Feche-o antes de recompilar.

## Testes automatizados do backend

Os testes usam MySQL para validar a mesma tecnologia de banco usada na aplicação. Crie um banco separado e exclusivo:

```sql
CREATE DATABASE IF NOT EXISTS apoio_usuario_sus_teste
  CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
GRANT ALL PRIVILEGES ON apoio_usuario_sus_teste.* TO 'apoio_sus'@'localhost';
```

Execute em um terminal na raiz do repositório:

```powershell
cd backend
$env:TESTE_MYSQL_URL = "jdbc:mysql://localhost:3306/apoio_usuario_sus_teste?user=apoio_sus&password=sua-senha-do-mysql&useUnicode=true&characterEncoding=utf8&connectionTimeZone=LOCAL"
.\mvnw.cmd test
```

**Atenção:** a suíte apaga e recria as tabelas do banco informado em `TESTE_MYSQL_URL`. Use somente o banco `apoio_usuario_sus_teste`, nunca o banco da aplicação. Para usar SQLite temporário nos testes, configure `TESTE_SQLITE=true`.

## Segurança e limitações

- Senhas armazenadas com hash PBKDF2-HMAC-SHA256 e salt individual.
- Tokens aleatórios; o banco mantém apenas o hash SHA-256.
- Usuários acessam somente seus próprios registros.
- Credenciais do MySQL configuradas por variável de ambiente.
- HTTP sem TLS e sem limite de tentativas de login/recuperação: uso acadêmico/desenvolvimento, não produção.
- Código de recuperação exibido no log do backend, sem envio de e-mail.

## Endpoints

Prefixo `/api`; rotas protegidas exigem `Authorization: Bearer <token>`.

| Rota | Métodos |
| --- | --- |
| `/ping` | GET |
| `/auth/cadastro`, `/auth/login` | POST |
| `/auth/logout`, `/auth/recuperar-senha`, `/auth/redefinir-senha` | POST |
| `/usuarios/me` | GET, PUT, DELETE |
| `/perfil` | GET, PUT, DELETE |
| `/vacinas` | GET, POST |
| `/vacinas/{id}` | GET, PUT, DELETE |
| `/medicamentos` | GET, POST |
| `/medicamentos/{id}` | GET, PUT, DELETE |
| `/unidades-saude/municipios` | GET |
| `/unidades-saude/upas?municipio=&inicio=` | GET |
| `/orientacoes` | GET |
| `/sintomas/analise` | POST |
