const fs = require("fs");
const pug = require('pug');
const path = "src/html/content/";
const dist = "public/";
const dirs = ["posts", "portal", "projects", "side-ventures", "tags"];

let files = {
	"posts" : [], 
	"portal" : [],
	"projects" : [],
	"side-ventures" : [],
	"tags" : []
};

let completed = 0;

for (let i = 0; i < dirs.length; i++) {
  const dir = dirs[i];
  //Read from public instead of src
  fs.readdir(dist + dir, (err, files_list) => {
    if (err) {
      console.warn(`Warning: ${dist + dir} not found`);
      files[dir] = [];
    } else {
      for(let j = 0; j < files_list.length; j++) {
        // Only add .html files, exclude the listing page itself
        if (files_list[j].endsWith('.html') && files_list[j] != dir + ".html") {
          files[dir].push(files_list[j]);
        }
      }
      files[dir].sort().reverse();
    }
    
    completed++;
    
    if (completed === dirs.length) {
      // Render listing pages
      for (let k = 0; k < dirs.length; k++) {
        const html = pug.renderFile(
          path + dirs[k] + '/' + dirs[k] + ".pug", 
          { list: files[dirs[k]] }
        );
        
        fs.mkdirSync(dist + dirs[k], { recursive: true });
        fs.writeFileSync(dist + dirs[k] + '/' + dirs[k] + ".html", html);
        console.log(`✓ Generated ${dirs[k]} listing`);
      }
    }
  });
}
