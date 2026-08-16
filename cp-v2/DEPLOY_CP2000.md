# CP Automotive Knowledge Platform — cp2000.pt

## Estado pretendido
- Domínio canónico: https://cp2000.pt
- Aplicação: CP V2.1 Registo Mestre
- Autenticação: desativada por defeito (`CP_AUTH_ENABLED=false`)
- OTP: código preservado e reativável sem alterar o domínio
- Indexação: bloqueada (`robots.txt` + `X-Robots-Tag`)
- HTTPS: obrigatório

## Arquitetura
1. Repositório GitHub `armindogyf-cmyk/armindo`
2. Root Directory de deployment: `cp-v2`
3. Produção ligada à branch `main`
4. Cada merge/commit em `main` gera nova versão sem alterar `https://cp2000.pt`
5. Rollback através do histórico de deployments/commits

## Registo do domínio
O domínio `.pt` deve ser registado num registrar acreditado para .PT. O registrar é apenas responsável pelo domínio/DNS; a aplicação pode continuar alojada na Vercel.

## DNS
Depois de criar o projeto de produção e adicionar `cp2000.pt`, usar exatamente os registos DNS apresentados pela plataforma de hosting. Não fixar IPs neste documento porque podem mudar.
- Apex: `cp2000.pt` → destino indicado pelo hosting
- `www.cp2000.pt` → destino indicado pelo hosting
- Definir redirect permanente `www` → apex ou inverso; preferência CP: apex `cp2000.pt`.

## Variáveis de ambiente
### Agora
`CP_AUTH_ENABLED=false`

### Quando OTP for ativado
`CP_AUTH_ENABLED=true`
`CP_ALLOWED_PHONES=+351...,+351...`
`CP_SESSION_SECRET=<segredo longo aleatório>`
`TWILIO_ACCOUNT_SID=<segredo>`
`TWILIO_AUTH_TOKEN=<segredo>`
`TWILIO_VERIFY_SERVICE_SID=<segredo>`

Nunca colocar segredos no GitHub.

## Verificação de produção
1. `https://cp2000.pt/` responde 200 e abre Registo Mestre.
2. `https://cp2000.pt/api/health` responde `{ok:true}`.
3. Navegação mobile e desktop funcional.
4. Peças: 315 registos carregados.
5. Diagnóstico, Oficina, Consulta, Dossier e Engenharia funcionais.
6. VIN integral não exposto na versão partilhável.
7. `robots.txt` bloqueia indexação.
8. HTTPS válido.
9. Link abre diretamente no browser a partir do WhatsApp.
10. Novo deployment não altera o URL público.

## Atualização contínua
- Produção é atualizada no mesmo domínio.
- Alterações relevantes devem incrementar a versão visível (2.1.x / 2.2).
- Dados técnicos não confirmados mantêm estado PENDENTE/QUARENTENA.
- Antes de alterações estruturais, preservar um commit/deployment estável para rollback.

## Política de acesso atual
O acesso é por link. Qualquer pessoa que obtenha o URL poderá abrir a aplicação. Não expor dados pessoais, VIN integral, credenciais, documentos privados ou evidência sensível nesta camada. Quando necessário, ativar `CP_AUTH_ENABLED=true` e configurar OTP.
