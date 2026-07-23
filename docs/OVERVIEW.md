# Visão geral

Template de ambiente de dev baseado em [code-server](https://github.com/coder/code-server), com
Claude Code CLI, `ai-jail` e Docker-out-of-Docker já configurados. Tudo mora dentro de
`.code-server/` (não polui a raiz do monorepo que usar este template) e é controlado por dois
executáveis: `setup` (escolhe as stacks de tecnologia que entram na imagem) e `start` (sobe o
ambiente numa janela nativa).

O design completo — decisões tomadas, estrutura de `core/`/`stacks/`, formato do manifest, bugs já
encontrados e corrigidos — está em [`.code-server/docs/OVERVIEW.md`](../.code-server/docs/OVERVIEW.md).
Este documento aqui é só o resumo de "como usar".

## Como iniciar o ambiente

Pré-requisitos no host: `jq`, `whiptail`, `docker` (pro `setup`); Rust/`cargo` + as libs do Tauri
pra Linux (pro `start` — ver `.code-server/docs/OVERVIEW.md` pros pacotes exatos por distro).

1. **Builda a imagem** (escolhe as stacks do monorepo, gera o Dockerfile e builda):
   ```bash
   .code-server/setup
   ```
   Reroda o `setup` sempre que quiser adicionar ou remover uma stack.

2. **Builda o app que abre o ambiente** (só precisa fazer isso uma vez, ou de novo se o
   `main.rs`/`Cargo.toml` mudar):
   ```bash
   cd .code-server/start
   cargo build --release
   ```

3. **Sobe o ambiente**:
   ```bash
   .code-server/start/target/release/start
   ```
   Na primeira vez cria o container (`docker run`, com o workspace montado); nas próximas só
   garante que ele está rodando (`docker start`) e abre a janela. Não precisa passar nenhuma env
   var pra rodar de dentro da própria estrutura do repo — nome de imagem/container e
   `START_WORKSPACE_DIR` têm default derivado automaticamente.
