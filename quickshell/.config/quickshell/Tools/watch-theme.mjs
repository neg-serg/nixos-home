#!/usr/bin/env node
/**
 * watch-theme.mjs — rebuild Theme.json whenever files in Theme/ change.
 * Usage: node Tools/watch-theme.mjs [--dir Theme] [--out Theme.json] [--debounce 200]
 */
import fs from 'node:fs';
import path from 'node:path';
import process from 'node:process';
import { loadThemeFromParts, writeTheme } from './lib/theme-builder.mjs';

function parseArgs(argv) {
  const args = { dir: 'Theme', out: 'Theme.json', debounce: 250 };
  for (let i = 2; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--dir') { args.dir = argv[++i]; continue; }
    if (a === '--out') { args.out = argv[++i]; continue; }
    if (a === '--debounce') { args.debounce = Number(argv[++i]) || args.debounce; continue; }
  }
  return args;
}

function log(prefix, ...msg) {
  console[prefix === 'err' ? 'error' : 'log']('[theme-watch]', ...msg);
}

async function buildOnce(partsDir, outPath, reason) {
  const start = Date.now();
  try {
    const { theme, files } = loadThemeFromParts({ partsDir });
    writeTheme(outPath, theme);
    log('log', `rebuilt ${path.relative(process.cwd(), outPath)} (${files.length} parts) in ${Date.now() - start}ms (trigger: ${reason})`);
  } catch (err) {
    log('err', `build failed (${reason}): ${err.message}`);
  }
}

function main() {
  const args = parseArgs(process.argv);
  const partsDir = path.resolve(args.dir);
  const outPath = path.resolve(args.out);
  const debounceMs = Math.max(50, Number(args.debounce) || 250);

  if (!fs.existsSync(partsDir)) {
    log('err', 'Theme directory not found:', partsDir);
    process.exit(1);
    return;
  }

  let timer = null;
  let pendingReason = null;
  let building = false;
  let rerunReason = null;

  async function run(reason) {
    if (building) {
      rerunReason = reason;
      return;
    }
    building = true;
    await buildOnce(partsDir, outPath, reason);
    building = false;
    if (rerunReason) {
      const next = rerunReason;
      rerunReason = null;
      await run(next);
    }
  }

  function schedule(reason) {
    pendingReason = reason;
    if (timer) clearTimeout(timer);
    timer = setTimeout(() => {
      timer = null;
      const r = pendingReason || 'change';
      pendingReason = null;
      run(r);
    }, debounceMs);
  }

  // Build immediately so Theme.json exists before user edits
  run('startup');

  const watcher = fs.watch(partsDir, { persistent: true }, (event, file) => {
    const reason = `${event}:${file || 'unknown'}`;
    schedule(reason);
  });

  watcher.on('error', (err) => {
    log('err', 'watcher error:', err.message);
  });

  log('log', `watching ${partsDir} (output ${outPath}); Ctrl+C to stop.`);

  function cleanup() {
    watcher.close();
    log('log', 'stopped');
    process.exit(0);
  }

  process.on('SIGINT', cleanup);
  process.on('SIGTERM', cleanup);
}

main();
