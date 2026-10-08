# Confirmação de presença · 4º Pelotão

26/10/2026 · Clube LED · Cordeiros-BA.

O formulário é público, sem login para os policiais. O painel é exclusivo de `rapha11novais@gmail.com`, autenticado pelo Supabase. Matrícula única, edição por link pessoal com token aleatório, nomes de todos os convidados obrigatórios, Excel com três abas e PDF com paginação. Não existe prazo de encerramento.

## Configuração do Supabase

1. Aplicar `supabase/migrations/202610080001_confirmations.sql` ao projeto escolhido. A migração cria somente a tabela `rsvp_4p_2026` e as funções `rsvp_4p_load` e `rsvp_4p_save`, sem alterar dados de formulários antigos.
2. Configurar `public/config.js` com a URL do projeto e a chave **publishable** (ou anon). Nunca colocar `service_role`, chave secreta, senha de banco ou token administrativo neste arquivo ou no GitHub.
3. Habilitar o provedor de e-mail no Supabase Auth. O primeiro acesso verifica o e-mail `rapha11novais@gmail.com` e permite criar essa conta pelo Supabase Auth. Somente esse e-mail tem acesso aos dados por RLS.
4. Em Authentication → URL Configuration, incluir a URL exata publicada pelo GitHub Pages (com a barra final) como Site URL e Redirect URL. O painel é acessado em `#admin`. Também é possível copiar o link de confirmação recebido e colá-lo no painel; a aplicação verifica diretamente o token com o Supabase, mesmo sem redirecionamento configurado.
5. Verificar as políticas: `anon` não tem acesso direto à tabela; `authenticated` só tem leitura das colunas do relatório, condicionada ao e-mail do organizador. A tabela não permite INSERT, UPDATE ou DELETE diretos por esses papéis.

As funções públicas permitem apenas criar uma resposta e consultar/editar a resposta correspondente a um token pessoal de 256 bits. O banco guarda somente o SHA-256 do token. Matrícula, presença, nomes, quantidade e versão são validados também no servidor. Atualizações com versão antiga são recusadas.

## Build e GitHub Pages

```sh
npm ci
npm run build
```

O resultado está em `dist/`. Todos os caminhos são relativos para funcionar no subdiretório do repositório. Para o Pages já existente com publicação pela raiz de `main`, publicar o conteúdo de `dist/` na raiz, mantendo também este projeto em `source/`. Não incluir dados reais nem tokens de edição no repositório.

## Verificação antes da liberação

- Submissão com e sem convidados e ausência.
- Recusa de convidados sem nomes, duplicidade de matrícula e atualização com versão antiga.
- Link pessoal em outro dispositivo recupera somente sua própria resposta.
- Chave pública sem login não consulta o relatório nem a tabela.
- Conta autenticada diferente da conta do organizador não lê dados.
- Conta autorizada vê totais, filtros e exporta Excel/PDF.

Os arquivos estáticos do GitHub Pages são públicos; a exclusividade dos dados é imposta pelo Supabase Auth e pelo PostgreSQL, conforme solicitado para o painel administrativo.

