# LCP WEBFORM

This is the webform for the [lcp] obligation

#### Project Technical Overview

The form is built with the [AngularJS] framework. It also makes use of the excel like spreadsheets library [HandsOnTable].

[Browserify] is used to bundle (most of) the js files into a single bundle.js. The rest js files are loaded through CDN(jQuery, HandsOnTables). Eionet's css stylesheets are loaded directly from eionet, Bootstrap css from CDN, and some custom stylesheet are loaded directly from the project's folder. Also, two image files are loaded directly from the project's folder.

The production folder is dist, where the bundled js file lies. Dist is the folder to upload to the server.

The actual js files are located in the js folder. In the package.json there are scripts that bundle them. You will need [node.js] and npm to build the project.

First make sure you have node and npm installed, cd into the webform folder and run

`npm install`

This will install the required dependencies stated in the package.json.

You can build the bundle.js by hitting

`npm run build-js`

This will build a single file for testing, out of all the js files, based on the configuration of browserify-app.js, which simple requires all the needed js files.For development purposes it uses the -d flag, so source maps are generated.

You may also try to run

`npm run watch-js`

which uses watchify, a plugin that listens for changes in the js files, and updates the bundle.js in the dist folder on the fly, for development purposes. This script also uses the -d flag, so source maps are available.

To build the bundle in the dist folder, you can run

`npm run build-js-prod`

The dist/bundle.js is the file that is mapped to the production environment, so before deployment you should remember to run this script.

To build a minified js on the dist/bundle.min.js you can run

`npm run build-js-min-prod`

which uses browserify-ngannotate, to change the angular annotation to the Inline Array Annotation format, and then uglifyjs to minify the file, without source maps. Usefull for final deployment.

#### Webform local development

The webform needs some inputs, namely the an empty instance of the xml, the actual file to edit, and the labels of the fields. On the production server, these files are converted by the questionnerie service to json, and the webform issues an xhr request for each of these resources. To simulate the same behaviour for local development, in the folder xml, there are these  files with .xml extension, that have actually json content to simulate the conversion by saxxon. Also a sample report of GR is included in xml/lcp_instance_test.xml. You can copy these files in the same folder with the LCP.html, and use some kind of http server to serve the folder. Don't copy these file to dist, because the xmls there are actual xmls that are needed on the production server.

It is suggested that for local development you work with the file webform/lcp.html, and you leave all the content is the dist folder untouched. Copy in the webform directory the file form the /xmls folder, and you have a working directory. The webform will actually complain that a file/info is missing, but this is not a crucial problem, and you can ignore it.

To serve the working directory you can try to

`npm install -g http-server`

for easily serving the whole folder contents, by simply cd-ing into the /webform/ and then running http-server in the command line.



###### README AUTHOR : ARISTOTELIS KATSANAS

   [lcp]: <http://rod.eionet.europa.eu/obligations/9>
   [Browserify]: <http://browserify.org/>
   [node.js]: <http://nodejs.org>
   [AngularJS]: <http://angularjs.org>
   [HandsOnTable]: <http://handsontable.com>
