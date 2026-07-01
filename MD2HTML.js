const showdown = require('showdown');
const pug = require('pug');
const fs = require('fs');
const path = require('path');
const matter = require('gray-matter');

const converter = new showdown.Converter();
const file = process.argv[2];
const DEST = process.argv[3];

const base = path.basename(file, '.md');
const fileContent = fs.readFileSync(file, 'utf8');

// Parse frontmatter and body
const { data: frontmatter, content: mdContent } = matter(fileContent);

// Only convert the body MD to HTML
const htmlContent = converter.makeHtml(mdContent);

// Extract frontmatter data
const title = frontmatter.title || base.replace(/_/g, ' ');
const date = frontmatter.date || '';
const description = frontmatter.description || '';

// Extract category from DEST path
const destParts = DEST.split('/');
const category = destParts[destParts.length - 2];

// Create wrapper Pug template
const pugContent = `extends ../../../layout.pug
block vars
  - var title = "${title.replace(/"/g, '\\"')}"
  - var date = "${date}"
  - var description = "${description.replace(/"/g, '\\"')}"
block content
  article.post
    h1= title
    .meta
      span.date Published: #{date}
    p.description= description
    .post-body
      != contentHtml
`;

// Render pug
const html = pug.render(pugContent, {
  title: title,
  date: date,
  description: description,
  contentHtml: htmlContent,
  filename: path.resolve(`src/html/content/${category}/${base}.pug`) 
});

fs.mkdirSync(DEST, { recursive: true });
const outputFile = path.join(DEST, `${base}.html`);
fs.writeFileSync(outputFile, html);
