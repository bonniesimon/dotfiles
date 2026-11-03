#!/usr/bin/env node
// Pads markdown table cells so the pipes line up. Touches nothing outside tables or inside code fences.
import { readFileSync, writeFileSync } from 'node:fs'

const width = (s) => [...s].length

function splitRow(line) {
  const cells = []
  let cell = ''
  let inCode = false
  const body = line.trim().replace(/^\|/, '').replace(/\|$/, '')
  for (let i = 0; i < body.length; i++) {
    const ch = body[i]
    if (ch === '`') inCode = !inCode
    if (ch === '\\' && body[i + 1] === '|') { cell += '\\|'; i++; continue }
    if (ch === '|' && !inCode) { cells.push(cell.trim()); cell = ''; continue }
    cell += ch
  }
  cells.push(cell.trim())
  return cells
}

const isSeparator = (cells) => cells.every((c) => /^:?-+:?$/.test(c))

function formatTable(lines) {
  const rows = lines.map(splitRow)
  const cols = Math.max(...rows.map((r) => r.length))
  rows.forEach((r) => { while (r.length < cols) r.push('') })
  const widths = Array.from({ length: cols }, (_, c) =>
    Math.max(3, ...rows.filter((r) => !isSeparator(r)).map((r) => width(r[c]))))
  return rows.map((r) => {
    if (isSeparator(r)) {
      return '| ' + r.map((c, i) => {
        const left = c.startsWith(':'), right = c.endsWith(':')
        return (left ? ':' : '-') + '-'.repeat(widths[i] - 2) + (right ? ':' : '-')
      }).join(' | ') + ' |'
    }
    return '| ' + r.map((c, i) => c + ' '.repeat(widths[i] - width(c))).join(' | ') + ' |'
  })
}

for (const file of process.argv.slice(2)) {
  const out = []
  let block = []
  let inFence = false
  const flush = () => { if (block.length) out.push(...formatTable(block)); block = [] }
  for (const line of readFileSync(file, 'utf8').split('\n')) {
    if (/^\s*(```|~~~)/.test(line)) { flush(); inFence = !inFence; out.push(line); continue }
    if (!inFence && /^\s*\|/.test(line)) { block.push(line); continue }
    flush()
    out.push(line)
  }
  flush()
  writeFileSync(file, out.join('\n'))
}
