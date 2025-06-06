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

for (let i = 0; i < dirs.length; i++) {
  const dir = dirs[i];
  fs.readdir(path + dir, (err, files) => {
    if (err) throw err;
    console.log("Files in %s : %s", dir, files);
  });
}


// Prepare some stuff before serving the site

// Get content lists for each directory