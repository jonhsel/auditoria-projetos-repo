#!/usr/bin/env node
'use strict';

// Instala a skill "auditoria-projetos" para o Claude Code.
// Copia a pasta da skill para ~/.claude/skills/ (ou ./.claude/skills/ com --projeto).
// Nunca sobrescreve nada sem perguntar.

const fs = require('fs');
const os = require('os');
const path = require('path');
const readline = require('readline');

const NOME = 'auditoria-projetos';
const args = process.argv.slice(2);

if (args.includes('--ajuda') || args.includes('-h') || args.includes('--help')) {
  console.log(`Uso: npx ${NOME} [opções]

  (sem opções)   instala em ~/.claude/skills/${NOME} (vale para todos os projetos)
  --projeto      instala em ./.claude/skills/${NOME} (vale só para a pasta atual)
  --ajuda        mostra esta mensagem

Se a skill já existir, o instalador pergunta antes de substituir.`);
  process.exit(0);
}

const origem = path.join(__dirname, '..', NOME);
const base = args.includes('--projeto')
  ? path.join(process.cwd(), '.claude', 'skills')
  : path.join(os.homedir(), '.claude', 'skills');
const destino = path.join(base, NOME);

function perguntar(texto) {
  return new Promise((resolve) => {
    const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
    rl.question(texto, (r) => { rl.close(); resolve(r.trim().toLowerCase()); });
  });
}

async function main() {
  if (!fs.existsSync(path.join(origem, 'SKILL.md'))) {
    console.error('Erro: pacote incompleto (SKILL.md não encontrado).');
    process.exit(1);
  }

  if (fs.existsSync(destino)) {
    if (!process.stdin.isTTY) {
      console.error(`Já existe uma instalação em ${destino}.\nNada foi alterado. Rode em um terminal interativo para confirmar a substituição.`);
      process.exit(1);
    }
    const r = await perguntar(`Já existe uma skill em ${destino}.\nSubstituir pela versão deste pacote? [s/N] `);
    if (r !== 's' && r !== 'sim') {
      console.log('Nada foi alterado.');
      return;
    }
    fs.rmSync(destino, { recursive: true, force: true });
  }

  fs.mkdirSync(base, { recursive: true });
  fs.cpSync(origem, destino, { recursive: true });

  console.log(`Skill instalada em: ${destino}`);
  console.log('Reinicie o Claude Code e peça: "audite este projeto".');
}

main().catch((e) => { console.error('Erro:', e.message); process.exit(1); });
