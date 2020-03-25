#!/bin/bash
echo "Creating a node project boilerplate..."

read -p "Enter the project name: " project
echo "Building folder structure for '${project}'."
mkdir ${project}
cd ${project}

mkdir view
mkdir src
mkdir src/css && touch src/css/app.scss
mkdir src/js && touch src/js/app.js
mkdir build && mkdir build/css && mkdir build/js
echo "import './css/app.scss';
import './js/app.js';" > src/entry.js
echo "Initializing node project."
npm init

echo "Installing dev-dependencies."
npm install --save-dev @babel/cli @babel/core @babel/node @babel/preset-env autoprefixer babel-cli babel-loader babel-plugin-transform-object-assign clean-css clean-webpack-plugin css-loader extract-loader file-loader html-webpack-plugin materialize-css mini-css-extract-plugin node-sass nodemon postcss-loader rimraf sass sass-loader style-loader webpack webpack-cli webpack-dev-server

echo "Installing dependencies."
npm install --save dotenv finalhandler mithril router 

echo "All dependencies installed."

echo "Configuring webpack..."
echo "Creating webpack configuration file."
echo "const autoprefixer = require('autoprefixer');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

module.exports = {
    entry: {
      app: __dirname + '/src/entry.js'
    },
    output: {
      path: __dirname + '/build',
      filename: 'js/[name].js',
    },
    plugins: [
        new MiniCssExtractPlugin({
          filename: 'css/[name].css'
        }),
    ],
    module: {
        rules: [
          {
            test: /\.js$/,
            exclude: /node_modules/,
            use: {
              loader: 'babel-loader',
              options: {
                presets: ['@babel/preset-env']
              }
            }
          },
          {
            test: /\.scss$/,
            use: [
              {
                loader: 'file-loader',
              },
              {loader: 'extract-loader'},
              {
                loader: MiniCssExtractPlugin.loader
              },
              {loader: 'css-loader?url=false'},
              {
                loader: 'postcss-loader',
                options: {
                  plugins: () => [autoprefixer()]
                }
              },
              {
                loader: 'sass-loader',
                options: {
                  // Prefer Dart Sass
                  implementation: require('sass'),
                  sassOptions: {
                    includePaths: ['./node_modules'],
                  },
                },
              },
            ],
          },
          {
            test: /\.css$/,
            use: [{ loader: 'style-loader' }, { loader: 'css-loader' }],
          },
          {
            test: /\.(png|jpg|gif)$/,
            use: [
              {
                loader: 'file-loader',
                options: {
                  name: 'img/[name].[ext]',
                },
              },
              
            ],
          },
        ]
    },
    devServer: {
        contentBase: './dist',
        open: true
    },
};" > webpack.config.js
echo "Creating minify-css.js"

echo "const fs = require('fs');
const path = require('path');
const cleanCSS = require('clean-css');

const css_dir = './build/css';
const css_files = fs.readdirSync(css_dir);

css_files.forEach(file => {
    if (path.extname(file) === '.css') {
        const css_file_path = css_dir + '/' + file;
        const input = fs.readFileSync(css_file_path);
        const options = {
            returnPromise: true
        }
        const output = new cleanCSS(options)
                        .minify(input)
                        .then(minifile => {
                            fs.writeFileSync(css_file_path, minifile.styles);
                            // console.log(minifile.styles)
                        })
                        .catch(error => {
                            console.log('Error occurred with file:', file, error)
                        });
    }
});" > minify-css.js

echo "Creating .env"

echo "PORT=8000" > .env

echo "Creating server file > server.js"

echo "'use strict';
import dotenv from 'dotenv';
import fs from 'fs';
import https from 'https';
import route from './route';

dotenv.config();

const credentials = {
    key: fs.readFileSync('server.key'),
    cert: fs.readFileSync('server.crt')
};
const server = https.createServer(credentials);

server.on('request', function (request, response) {
    route(request, response);
});

server.listen(process.env.PORT);

console.log('Notekeeper is on air!');
console.log('Serving on https://localhost:' + process.env.PORT);" > app.js

echo "Creating route.js"

echo "'use strict';

import Router from 'router';
import fs from 'fs';
import fh from 'finalhandler';
import path from 'path';

const router = new Router();

const dir = {
    'html': 'view',
    'css': './build/css',
    'js': './build/js',
    'img': './build/img'
};
const pattern = {
    'css': /css\/\w+\.css/,
    'js': /js\/[\w.-]+\.js/,
    'img': /img\/[\w\.\-]+\.(ico|png|jpg|jpeg|svg)/
};
const header = {
    'html': {'Content-Type': 'text/html'},
    'css': {'Content-Type': 'text/css'},
    'js': {'Content-Type': 'text/javascript'},
};

const template_path = dir['html'];
const template = {
    '/': template_path + '/index.html',
};

function staticResponder(url, type, response) {
    const file = path.basename(url);
    response.writeHead(200, header[type]);
    fs.createReadStream(dir[type] + '/' + file).pipe(response);
}

router.get('/', (request, response) => {
    response.writeHead(200, header['html']);
    fs.createReadStream(template['/']).pipe(response);
});

router.get(pattern['css'], (request, response) => {
    staticResponder(request.url, 'css', response);
});

router.get(pattern['js'], (request, response) => {
    staticResponder(request.url, 'js', response);
});
router.get(pattern['img'], (request, response) => {
    // const file = path.basename(request.url);
    // const ext = path.extname(file);
    staticResponder(request.url, 'img', response);
})
function route (request, response) {
    router(request, response, fh(request, response));
};

export default route;" > route.js

echo "Setting up nodemon..."
echo "Creating .babelrc"
echo "{
    \"presets\": [
        \"@babel/preset-env\"
    ]
}" > .babelrc

echo "Installing jq to configure package.json"
sudo apt install jq -y
package=`cat package.json`
main='"app.js"'
scripts='{
    "nodemon": "nodemon --exec babel-node app.js",
   "build": "webpack --mode production && npm run minify",
    "dev": "webpack -d --watch",
    "minify": "node minify-css.js",
    "start": "npm run nodemon",
    "test": "echo \"Error: no test specified\" && exit 1"
}'
echo $package | jq ".main=${main}" <<< $package > package.json
echo $package | jq ".scripts=${scripts}" <<< $package > package.json

echo "Creating index.html"

echo '<!DOCTYPE html>
<!--[if lt IE 7]>      <html class="no-js lt-ie9 lt-ie8 lt-ie7"> <![endif]-->
<!--[if IE 7]>         <html class="no-js lt-ie9 lt-ie8"> <![endif]-->
<!--[if IE 8]>         <html class="no-js lt-ie9"> <![endif]-->
<!--[if gt IE 8]><!--> <html class="no-js"> <!--<![endif]-->
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <title>NoteKeeper!</title>
        <meta name="description" content="">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link rel="stylesheet" href="css/app.css">
        <link rel="shortcut icon" href="" type="image/x-icon">
    </head>
    <body>
        <!--[if lt IE 7]>
            <p class="browsehappy">You are using an <strong>outdated</strong> browser. Please <a href="#">upgrade your browser</a> to improve your experience.</p>
        <![endif]-->
        <center><h1>Hello, world!</h1></center>
        <script src="js/app.js" async defer></script>
    </body>
</html>' > view/index.html

echo "Generating server.key and server.cert for https server..."
openssl genrsa -out server.key && openssl req -new -key server.key -out server.csr && openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt

echo "Setup complete."

echo "Building webpack."
npm run build

echo "Starting app."
npm start