#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import { loadThemeFromParts, writeTheme } from './lib/theme-builder.mjs';

function parseArgs(argv) {
  const args = { dir: 'Theme', out: 'Theme.json', check: false, quiet: false };
  for (let i = 2; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--dir') { args.dir = argv[++i]; continue; }
    if (a === '--out') { args.out = argv[++i]; continue; }
    if (a === '--check') { args.check = true; continue; }
    if (a === '--quiet') { args.quiet = true; continue; }
  }
  return args;
}

function main() {
  const args = parseArgs(process.argv);
  const { theme, files } = loadThemeFromParts({ partsDir: args.dir });
  const pretty = JSON.stringify(theme, null, 2) + '\n';
  const outPath = path.resolve(args.out);

  if (args.check) {
    let existing = '';
    if (fs.existsSync(outPath)) {
      existing = fs.readFileSync(outPath, 'utf8');
    }
    if (existing !== pretty) {
      console.error(`Theme output ${path.relative(process.cwd(), outPath)} is out of date. Run this tool without --check to update it.`);
      process.exitCode = 1;
      return;
    }
    if (!args.quiet) {
      console.log(`Theme output ${path.relative(process.cwd(), outPath)} is up to date (${files.length} parts).`);
    }
    return;
  }

  writeTheme(outPath, theme);
  if (!args.quiet) {
    console.log(`Wrote ${path.relative(process.cwd(), outPath)} from ${files.length} theme part(s).`);
  }
}

main();
