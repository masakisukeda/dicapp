#!/usr/bin/env node
const fs = require('fs');
const path = require('path');

const root = path.resolve(__dirname, '..');
const baseUrl = 'https://drsp.cc/dic/';
const indexPath = path.join(root, 'data', 'articles', 'index.json');
const sitemapPath = path.join(root, 'sitemap.xml');
const robotsPath = path.join(root, 'robots.txt');
const llmsPath = path.join(root, 'llms.txt');

function readJson(file) {
  return JSON.parse(fs.readFileSync(file, 'utf8'));
}

function escapeXml(value) {
  return String(value || '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&apos;');
}

function buildSitemap(index) {
  const urls = [
    { loc: baseUrl, priority: '1.0' },
    { loc: `${baseUrl}?view=glossary`, priority: '0.8' },
    { loc: `${baseUrl}?view=requests`, priority: '0.6' },
  ];

  index.forEach((item) => {
    urls.push({
      loc: `${baseUrl}?view=article&id=${encodeURIComponent(item.id)}`,
      lastmod: item.updatedAt || item.updated_at || '',
      priority: '0.7',
    });
  });

  const lines = ['<?xml version="1.0" encoding="UTF-8"?>', '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'];
  urls.forEach((url) => {
    lines.push('  <url>');
    lines.push(`    <loc>${escapeXml(url.loc)}</loc>`);
    if (url.lastmod) lines.push(`    <lastmod>${escapeXml(url.lastmod)}</lastmod>`);
    lines.push(`    <priority>${url.priority}</priority>`);
    lines.push('  </url>');
  });
  lines.push('</urlset>');
  return `${lines.join('\n')}\n`;
}

function buildRobots() {
  return 'User-agent: *\nAllow: /\n\nSitemap: https://drsp.cc/dic/sitemap.xml\n';
}

function buildLlms(index) {
  const lines = [
    '# 辞書.app',
    '',
    '> ディレクション実務の用語・進め方・ツール活用を学べる日本語辞書アプリです。',
    '',
    '## Site',
    `- Home: ${baseUrl}`,
    `- Glossary: ${baseUrl}?view=glossary`,
    `- Requests: ${baseUrl}?view=requests`,
    `- Sitemap: ${baseUrl}sitemap.xml`,
    '',
    '## Focus',
    '- ディレクション実務の基礎用語',
    '- 要件定義、進行管理、品質管理、情報設計',
    '- AI時代の制作・運用・評価基準',
    '- Web制作ツール、AIツール、共同編集ツール',
    '',
    '## High-value article URLs',
  ];

  index.slice(0, 40).forEach((item) => {
    lines.push(`- ${item.title}: ${baseUrl}?view=article&id=${encodeURIComponent(item.id)}`);
  });

  lines.push('');
  lines.push('## Notes');
  lines.push('- 各記事は日本語で書かれています。');
  lines.push('- URLパラメータ `view=article&id=...` で個別記事に直接アクセスできます。');
  lines.push(`- 用語集は ${baseUrl}?view=glossary で一覧できます。`);
  return `${lines.join('\n')}\n`;
}

function main() {
  const index = readJson(indexPath);
  fs.writeFileSync(sitemapPath, buildSitemap(index));
  fs.writeFileSync(robotsPath, buildRobots());
  fs.writeFileSync(llmsPath, buildLlms(index));
  console.log(`Generated search assets from ${index.length} articles.`);
}

main();
