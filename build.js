const fs = require('fs');

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

// Prepare some stuff before serving the site

// Get content lists for each directory