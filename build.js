const fs = require("fs");

const path = "src/html/content/";

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
	console.log("%s : %s\n", dir , files[dir])
	if (completed === dirs.length) {
		// This way I won't need promises or awaits
    }
  });
}