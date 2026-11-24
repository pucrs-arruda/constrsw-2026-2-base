import { spawn } from 'node:child_process';
import { mkdtempSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

const html = process.argv[2];
const port = 9555;
const chrome = spawn('google-chrome-stable', [
  '--headless=new', '--no-sandbox', '--disable-gpu', `--remote-debugging-port=${port}`,
  `--user-data-dir=${mkdtempSync(join(tmpdir(), 'cdp-'))}`, 'about:blank',
], { stdio: 'ignore' });

const sleep = ms => new Promise(r => setTimeout(r, ms));
let targets;
for (let i = 0; i < 50; i++) {
  try { targets = await (await fetch(`http://127.0.0.1:${port}/json`)).json(); break; } catch { await sleep(200); }
}
const page = targets.find(t => t.type === 'page');
const ws = new WebSocket(page.webSocketDebuggerUrl);
await new Promise(r => ws.addEventListener('open', r));
let id = 0; const pending = new Map();
ws.addEventListener('message', e => { const m = JSON.parse(e.data); pending.get(m.id)?.(m); });
const send = (method, params = {}) => new Promise(r => { const i = ++id; pending.set(i, r); ws.send(JSON.stringify({ id: i, method, params })); });
const ev = async expr => (await send('Runtime.evaluate', { expression: expr, returnByValue: true, awaitPromise: true })).result.result.value;
const key = async k => {
  await send('Input.dispatchKeyEvent', { type: 'keyDown', key: k, code: k, windowsVirtualKeyCode: k === 'Escape' ? 27 : 0 });
  await send('Input.dispatchKeyEvent', { type: 'keyUp', key: k, code: k });
};
const viewport = (w, h) => send('Emulation.setDeviceMetricsOverride', { width: w, height: h, deviceScaleFactor: 1, mobile: false });
const go = async hash => { await send('Page.navigate', { url: `file://${html}${hash}` }); await sleep(600); };

const results = [];
const check = (name, ok, detail = '') => { results.push(ok); console.log(`${ok ? 'PASS' : 'FAIL'}  ${name}${detail ? '  — ' + detail : ''}`); };

await viewport(360, 800);
await go('#/salas');
check('compact: tabela oculta, lista visível',
  await ev(`getComputedStyle(document.querySelector('.card table')).display === 'none' && getComputedStyle(document.querySelector('.card .list')).display === 'block'`));
check('compact: sem scroll horizontal na página', await ev(`document.documentElement.scrollWidth <= innerWidth`),
  await ev(`document.documentElement.scrollWidth + 'px'`));
check('compact: nome do usuário oculto, Sair visível',
  await ev(`getComputedStyle(document.querySelector('.user-name')).display === 'none' && [...document.querySelectorAll('.appbar .btn')].some(b => b.textContent.trim() === 'Sair' && b.offsetWidth > 0)`));
check('compact: CTA Nova sala na toolbar em linha inteira',
  await ev(`(() => { const b = document.querySelector('.toolbar-cta'); const t = document.querySelector('.toolbar'); return b.offsetWidth > 0 && b.offsetWidth >= t.clientWidth - 24 - 1; })()`));
check('botões mantêm 40px visuais', await ev(`[...document.querySelectorAll('.btn, .icon-btn')].filter(b => b.offsetWidth).every(b => b.offsetHeight === 40)`));

await ev(`document.getElementById('menu-btn').click()`); await sleep(300);
check('hambúrguer abre a folha', await ev(`document.body.classList.contains('nav-open')`));
check('foco vai para o 1º item da folha', await ev(`document.activeElement.classList.contains('nav-item')`));
await key('Escape'); await sleep(300);
check('Esc fecha a folha', await ev(`!document.body.classList.contains('nav-open')`));
check('foco volta ao hambúrguer', await ev(`document.activeElement.id === 'menu-btn'`));

await ev(`document.querySelector('.list .icon-btn').click()`); await sleep(100);
check('"Mais ações" abre menu Editar/Excluir', await ev(`[...document.querySelectorAll('.menu button')].map(b => b.textContent.trim()).join('|') === 'editEditar|deleteExcluir' || document.querySelectorAll('.menu button').length === 2`));
await key('Escape'); await sleep(100);
check('Esc fecha o menu de ações', await ev(`!document.querySelector('.menu')`));

await ev(`document.querySelector('.list li .li-body').click()`); await sleep(400);
check('toque no item abre o detalhe', await ev(`location.hash === '#/salas/b201'`));

await go('#/turmas/se-a?aba=reservas');
check('compact: grade de ocupação visível e rolável na horizontal',
  await ev(`(() => { const w = document.querySelector('.grid-wrap'); return w.offsetHeight > 100 && w.scrollWidth > w.clientWidth; })()`));
check('compact: abas presentes', await ev(`document.querySelectorAll('.tab').length === 3`));

await go('#/salas?dialog=nova');
check('compact: dialog em tela cheia', await ev(`(() => { const r = document.querySelector('.dialog').getBoundingClientRect(); return r.width === innerWidth && r.height === innerHeight; })()`));

await viewport(768, 1024);
await go('#/salas');
check('medium: tabela visível com colunas de baixa prioridade ocultas',
  await ev(`getComputedStyle(document.querySelector('.card table')).display !== 'none' && getComputedStyle(document.querySelector('th.col-low')).display === 'none'`));
check('medium: drawer fechado por padrão', await ev(`getComputedStyle(document.getElementById('drawer')).visibility === 'hidden'`));
await go('#/salas/b201');
check('medium: master-detail empilhado', await ev(`getComputedStyle(document.querySelector('.md')).gridTemplateColumns.split(' ').length === 1`));

await viewport(1280, 800);
await go('#/salas');
check('expanded: drawer fixo visível', await ev(`getComputedStyle(document.getElementById('drawer')).visibility === 'visible' && document.getElementById('drawer').getBoundingClientRect().left === 0`));
check('expanded: todas as colunas', await ev(`getComputedStyle(document.querySelector('th.col-low')).display !== 'none'`));
check('expanded: item ativo marcado', await ev(`document.querySelector('[aria-current="page"]').textContent.includes('Salas de Aula')`));
await go('#/salas/b201');
check('expanded: master-detail em 2 colunas', await ev(`getComputedStyle(document.querySelector('.md')).gridTemplateColumns.split(' ').length === 2`));

ws.close(); chrome.kill();
const failed = results.filter(r => !r).length;
console.log(`\n${results.length - failed}/${results.length} verificações passaram`);
process.exit(failed ? 1 : 0);
