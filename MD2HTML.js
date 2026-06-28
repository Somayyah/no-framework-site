const showdown  = require('showdown')
const fs = require('fs')
const path = require('path');

converter = new showdown.Converter()

const file = process.argv[2]
const base = path.basename(file)
const DEST = process.argv[3]
const data = fs.readFileSync(file, "utf8");

const html = converter.makeHtml(data);

const outputFile = DEST + base.replace('.md', '.html');
console.log(outputFile)
fs.writeFileSync(outputFile, html);
