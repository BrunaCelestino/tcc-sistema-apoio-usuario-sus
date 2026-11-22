# Apoio SUS

Aplicativo multiplataforma para organizar dados pessoais relacionados à saúde e facilitar a consulta a informações públicas do Sistema Único de Saúde (SUS). Projeto desenvolvido como Trabalho de Conclusão de Curso.

## Visão geral

- **Aplicativo:** .NET MAUI, C# e XAML, com organização MVVM.
- **Backend:** Java 21, servidor HTTP do JDK e JDBC, sem Spring Boot.
- **Banco principal:** MySQL 8.
- **Fonte externa:** serviço SOAP do Cadastro Nacional de Estabelecimentos de Saúde (CNES).
- **Testes do backend:** JUnit 5; a suíte contém 100 testes automatizados.

O usuário cadastra seus próprios dados. O aplicativo não consulta prontuários oficiais, não realiza diagnóstico e não substitui o atendimento de profissionais de saúde.

## Funcionalidades implementadas

| Módulo | O que está disponível |
| --- | --- |
| Autenticação | Cadastro, login, logout, recuperação e redefinição de senha. A tela de cadastro exige a confirmação de leitura dos Termos de Uso e da Política de Privacidade. |
| Conta | Consultar dados da conta, atualizar nome e data de nascimento e excluir a conta. |
| Perfil de saúde | Consultar, atualizar e limpar peso, altura, tipo sanguíneo, alergias e observações. |
| Vacinas | Cadastrar, listar, consultar, editar e excluir registros pessoais de vacinação. |
| Medicamentos | Cadastrar, listar, consultar, editar e excluir medicamentos, com separação entre Em uso e Histórico. |
| Unidades de saúde | Selecionar um município do Estado de São Paulo e consultar estabelecimentos do SUS no CNES. A requisição solicita os tipos 02, 73, 05 e 07. A lista permite busca textual e abertura do endereço no Google Maps. |
| Orientações de saúde | Consultar conteúdos gerais de prevenção, doenças e hábitos, carregados de `orientacoes.json`, com busca e filtro por categoria. |
| Análise de sintomas | Informar sintomas em texto livre e receber orientações e alertas com base em regras e palavras-chave de `sintomas.json`. Não utiliza IA, não diagnostica e não armazena o texto informado. |

### Limitações conhecidas

- A consulta de unidades é feita pela seleção manual de município e está limitada aos municípios do Estado de São Paulo.
- O backend envia ao CNES os códigos de tipo de estabelecimento **02 (Centro de Saúde/Unidade Básica), 73 (Pronto Atendimento), 05 (Hospital Geral) e 07 (Hospital Especializado)** e mantém apenas os estabelecimentos identificados como integrantes do SUS.
- A tela ainda utiliza uma imagem ilustrativa no lugar de um mapa geográfico. Não usa GPS, não calcula distância e não identifica automaticamente as unidades mais próximas.
- A API retorna a descrição do tipo de estabelecimento, mas a tela atual não disponibiliza filtro visual por categoria nem exibe a distância.
- Campanhas públicas de vacinação, consulta pública de medicamentos e cálculo de vacinas pendentes não estão implementados.
- Orientações e regras de análise de sintomas são conteúdos locais em arquivos JSON, não dados consultados dinamicamente de uma API.
- As análises de sintomas não são salvas como histórico.
- Não há lembretes de medicamentos. Essa funcionalidade complementar foi deixada fora do escopo.
- A recuperação de senha não envia e-mail: o código temporário é apresentado no log do backend para uso no ambiente acadêmico.
- A aplicação foi executada e testada no Windows. O projeto também contém alvo Android, mas a execução nesse ambiente deve ser validada separadamente.

## Estrutura do repositório

```text
backend/
  src/main/java/       API Java: controllers, services, repositories, models e integrações
  src/main/resources/  application.properties, migrations, municipios-sp.csv,
                       orientacoes.json e sintomas.json
  src/test/java/       testes automatizados do backend
  pom.xml
  mvnw.cmd
frontend/
  ApoioSus/
    Views/             telas XAML
    ViewModels/        estado e comandos das telas
    Models/            modelos de dados e DTOs
    Services/          consumo da API, sessão, datas e utilitários
    Platforms/         configurações específicas das plataformas
docs/
  schema_mysql_atual.sql  representação consolidada do esquema MySQL atual
README.md
```

## Arquitetura

```text
Aplicativo .NET MAUI
       |
       | HTTP / JSON (Authorization: Bearer)
       v
Backend Java 21 (JDK HttpServer)
       |                         |
       | JDBC                    | SOAP
       v                         v
MySQL 8                    Serviço CNES
```

O backend concentra as regras de negócio, a autenticação, as consultas ao MySQL e a comunicação com o CNES. O frontend consome os endpoints da API. A busca de unidades depende de conexão com a internet.

## Requisitos

- Windows 10 ou superior (ambiente de execução validado: Windows 11).
- JDK 21.
- .NET SDK 10.
- Workload MAUI para Windows.
- MySQL Server 8.x.
- Acesso à internet para baixar dependências e consultar o CNES.
- Portas disponíveis: **8080** para a API e **3306** para MySQL.

## Configuração do banco de dados

No MySQL Workbench, conectado como administrador, crie o banco e o usuário da aplicação:

```sql
CREATE DATABASE IF NOT EXISTS apoio_usuario_sus
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'apoio_sus'@'localhost'
  IDENTIFIED BY 'troque-esta-senha';

GRANT ALL PRIVILEGES ON apoio_usuario_sus.* TO 'apoio_sus'@'localhost';
```

As migrations em `backend/src/main/resources/db/migration/mysql/` criam e atualizam o esquema de oito tabelas do modelo de dados do TCC: `usuario`, `perfil_saude`, `vacina`, `medicamento`, `unidade_saude`, `campanha_vacinacao`, `orientacao_saude` e `analise_sintoma`. As tabelas `sessao` e `recuperacao_senha` são adicionais, utilizadas pela autenticação. O arquivo `docs/schema_mysql_atual.sql` apresenta o esquema consolidado. A tabela `schema_migracao` é criada pelo inicializador para controlar as migrations aplicadas.

## Configuração da API

As configurações padrão ficam em `backend/src/main/resources/application.properties`. Variáveis de ambiente podem sobrescrever os valores.

| Propriedade | Variável de ambiente | Padrão |
| --- | --- | --- |
| `api.port` | `API_PORT` | `8080` |
| `database.url` | `DB_URL` | MySQL local, banco `apoio_usuario_sus` |
| `database.username` | `DB_USUARIO` | `apoio_sus` |
| `database.password` | `DB_SENHA` | Vazia no arquivo; informar no ambiente |
| `session.hours-validity` | `SESSAO_HORAS_VALIDADE` | `24` horas |
| `password-recovery.minutes-validity` | `RECUPERACAO_MINUTOS_VALIDADE` | `30` minutos |
| `cnes.url` | `CNES_URL` | Endpoint SOAP do CNES |
| `cnes.username` | `CNES_USUARIO` | Credencial pública do serviço |
| `cnes.password` | `CNES_SENHA` | Credencial pública do serviço |

A senha do MySQL não deve ser gravada no arquivo versionado.

## Executar o sistema

Abra dois terminais PowerShell na raiz do repositório.

### 1. Iniciar o backend

No primeiro terminal:

```powershell
cd backend
$env:DB_SENHA = "sua-senha-do-mysql"
.\mvnw.cmd clean compile exec:java
```

Quando o servidor estiver iniciado, acesse:

`http://localhost:8080/api/ping`

A resposta esperada é:

```json
{"status":"ok"}
```

### 2. Iniciar o aplicativo

No segundo terminal:

```powershell
cd frontend\ApoioSus
dotnet run -f net10.0-windows10.0.19041.0
```

O aplicativo Windows utiliza a API em `http://localhost:8080`. Mantenha o backend em execução enquanto utiliza o aplicativo. Feche o aplicativo antes de recompilar.

## Testes automatizados

A suíte do backend contém **100 testes automatizados**, distribuídos entre autenticação, conta, perfil de saúde, vacinas, medicamentos, migrations, municípios, CNES, orientações, sintomas e sessões.

Por padrão, os testes exigem um banco MySQL exclusivo, pois a inicialização da suíte remove as tabelas desse banco antes de executar os casos.

1. Crie um banco de testes separado:

```sql
CREATE DATABASE IF NOT EXISTS apoio_usuario_sus_teste
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

GRANT ALL PRIVILEGES ON apoio_usuario_sus_teste.* TO 'apoio_sus'@'localhost';
```

2. No PowerShell, a partir da raiz do repositório:

```powershell
cd backend
$env:TESTE_MYSQL_URL = "jdbc:mysql://localhost:3306/apoio_usuario_sus_teste?user=apoio_sus&password=sua-senha-do-mysql&useUnicode=true&characterEncoding=utf8&connectionTimeZone=LOCAL"
.\mvnw.cmd test
```

**Atenção:** a suíte apaga as tabelas do banco informado em `TESTE_MYSQL_URL`. Nunca informe o banco utilizado pelo aplicativo.

Como alternativa local, é possível executar a suíte com bancos SQLite temporários:

```powershell
cd backend
$env:TESTE_SQLITE = "true"
.\mvnw.cmd test
```

O CNES é simulado nos testes de integração; a suíte não precisa consultar o serviço público durante sua execução. A contagem de 100 corresponde aos casos anotados nos testes do repositório; execute o comando acima para confirmar o resultado no ambiente local.

## Roteiro de validação manual

1. **Cadastro:** preencher nome, e-mail, senha, confirmação e data de nascimento opcional; marcar a caixa de aceite dos Termos de Uso e da Política de Privacidade.
2. **Login:** acessar com a conta criada e verificar o redirecionamento para a tela inicial.
3. **Perfil de saúde:** consultar, editar e limpar peso, altura, tipo sanguíneo, alergias e observações.
4. **Vacinas:** cadastrar, editar e excluir um registro; conferir a lista.
5. **Medicamentos:** cadastrar, editar e excluir; verificar a separação entre Em uso e Histórico.
6. **Unidades de saúde:** pesquisar um município paulista, carregar a lista, alternar entre as visualizações disponíveis, pesquisar pelo nome/endereço e abrir uma rota.
7. **Orientações:** testar busca textual e filtros Todas, Prevenção, Doenças e Hábitos.
8. **Sintomas:** testar uma descrição reconhecida, um sinal de alerta (por exemplo, falta de ar) e uma descrição sem palavras reconhecidas.
9. **Conta:** atualizar nome/data de nascimento e testar a exclusão da conta.
10. **Recuperação de senha:** solicitar o código, obtê-lo no log do backend e redefinir a senha. Não há envio de e-mail.

## Endpoints

Prefixo `/api`. As rotas protegidas exigem `Authorization: Bearer <token>`.

| Rota | Método(s) | Finalidade |
| --- | --- | --- |
| `/ping` | GET | Verificar se a API está ativa |
| `/auth/cadastro`, `/auth/login` | POST | Cadastro e autenticação |
| `/auth/logout` | POST | Encerrar a sessão atual |
| `/auth/recuperar-senha`, `/auth/redefinir-senha` | POST | Recuperação de senha |
| `/usuarios/me` | GET, PUT, DELETE | Consultar, atualizar e excluir a conta |
| `/perfil` | GET, PUT, DELETE | Consultar, atualizar e limpar o perfil |
| `/vacinas` | GET, POST | Listar e cadastrar vacinas |
| `/vacinas/{id}` | GET, PUT, DELETE | Consultar, editar e excluir uma vacina |
| `/medicamentos` | GET, POST | Listar e cadastrar medicamentos |
| `/medicamentos/{id}` | GET, PUT, DELETE | Consultar, editar e excluir um medicamento |
| `/unidades-saude/municipios` | GET | Listar municípios de São Paulo |
| `/unidades-saude/upas?municipio=&inicio=` | GET | Consultar estabelecimentos CNES; o caminho mantém o nome legado |
| `/orientacoes` | GET | Consultar orientações locais |
| `/sintomas/analise` | POST | Analisar texto com regras informativas |

## Segurança e limites de uso

- Senhas são armazenadas com hash PBKDF2-HMAC-SHA256 e salt individual.
- O token de sessão é aleatório; o banco armazena seu hash SHA-256, não o token original.
- Sessões têm validade configurável e podem ser revogadas no logout.
- Os endpoints de dados pessoais verificam a sessão e restringem cada registro ao usuário autenticado.
- As credenciais do MySQL são fornecidas por configuração/variáveis de ambiente.
- A comunicação local está configurada em HTTP, sem TLS. Não utilizar a configuração acadêmica como implantação de produção.
- Não há limite de tentativas para login e recuperação de senha.
- O código de recuperação é exibido no log do backend em vez de ser enviado por e-mail.
- O conteúdo informativo e as regras de sintomas necessitam de validação por fontes e profissionais de saúde antes de qualquer uso fora do contexto acadêmico.
