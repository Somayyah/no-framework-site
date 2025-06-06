const fs = require("fs");
const pug = require('pug');

const path = "src/html/content/";
const dist = "public/"
const dirs = ["not-yet-released", "posts", "portal", "projects", "side-ventures", "tags"];

let	files = {
	"not-yet-released" : [],
	"posts" : [], 
	"portal" : [],
	"projects" : [],
	"side-ventures" : [],
	"tags" : []
};

let completed = 0;

for (let i = 0; i < dirs.length; i++) {
  const dir = dirs[i];
  fs.readdir(path + dir, (err, files_list) => {
    if (err) throw err;
	for(let j = 0; j < files_list.length; j++)
	{
		if (files_list[j] != dir+".pug")
			files[dir].push(files_list[j].replace(".pug", ".html"));
	}
	completed++;
	if (completed === dirs.length) {
		// This way I won't need promises or awaits
		for (let k = 0; k < dirs.length ; k ++)
		{
			const html = pug.renderFile(
				path + dirs[k] + '/' + dirs[k] + ".pug", 
				{ list: files[dirs[k]]}
			);
			
			fs.mkdirSync(dist + dirs[k], { recursive: true });
			fs.writeFileSync(dist +  dirs[k] + '/' + dirs[k] + ".html", html);
		}
    }
  });
}