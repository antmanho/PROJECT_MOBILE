const express = require('express');
const session = require('express-session');
const nodemailer = require('nodemailer');
const bodyParser = require('body-parser');
const axios = require('axios');
const mysql = require('mysql');
const path = require('path');
const { v4: uuid } = require('uuid');
const cors = require('cors'); // Importez cors
const fs = require("fs");
const https = require('https');

const app = express();
const port = 3000;
const { sessionMiddleware, sessionInitMiddleware, sessionCheckMiddleware } = require('./INIT-MIDDLEW/MIDDLE_WARE');
const db = require('./INIT-MIDDLEW/DB');

////HTTPS-------DEBUTT
//const certPath = path.join(__dirname, '../../../../etc/letsencrypt/live/anthonybarbedet.com/fullchain.pem')
//const keyPath = path.join(__dirname, '../../../../etc/letsencrypt/live/anthonybarbedet.com/privkey.pem')
//
//
//    // Lecture des fichiers de certificat et de clé
//const options = {
//      key: fs.readFileSync(keyPath),
//      cert: fs.readFileSync(certPath)
//    };
//
////HTTPS-------FIN

const acceuilLoginRoutes = require('./ROUTES/ACCEUIL-LOGIN')(db);
const Admin = require('./ROUTES/ADMIN')(db);
const Gestionnaire = require('./ROUTES/GESTIONNAIRE.js')(db);
const Vendeur = require('./ROUTES/VENDEUR.js')(db);
const Protection = require('./ROUTES/PROTECTION-ROUTE.js')(db);

// Middleware pour CORS pour permettre les requete POST d'un autre port
app.use(cors({
    origin: 'http://localhost:4200', // Remplacez par l'URL de votre frontend
    credentials: true //cookie session accept
}));// Middleware pour traiter les données JSON
app.use(express.json()); // Utilisez express.json() pour traiter le JSON
app.use(express.static(path.join(__dirname, 'RESSOURCES')));
app.use('/IMAGE', express.static(path.join(__dirname, 'RESSOURCES/IMAGE')));

// Utilisez le middleware de session en premier
app.use(sessionMiddleware);
app.use(sessionInitMiddleware);
// Ensuite, utilisez votre middleware de vérification
app.use(sessionCheckMiddleware);

// ----------Utilisez le routeur pour gérer les routes--------------
app.use('/', Protection);
app.use('/', acceuilLoginRoutes);
app.use('/', Admin);
app.use('/', Gestionnaire);
app.use('/', Vendeur);


app.listen(port, () => {
    console.log(`Serveur démarré sur le port ${port}`);
});
////HTTPS
//const server = https.createServer(options, app);
//server.listen(port, () => {
//                  console.log(`Serveur démarré sur le port ${port}`);
//              });

//-----------------------------------------------------------------------------------
//     _____ ___ _   _
//    |  ___|_ _| \ | |
//    | |_   | ||  \| |
//    |  _|  | || |\  |
//    |_|   |___|_| \_|
//
//-----------------------------------------------------------------------------------
//                                /T /I
//                               / |/ | .-~/
//                           T\ Y  I  |/  /  _
//          /T               | \I  |  I  Y.-~/
//         I l   /I       T\ |  |  l  |  T  /
//      T\ |  \ Y l  /T   | \I  l   \ `  l Y
//  __  | \l   \l  \I l __l  l   \   `  _. |
//  \ ~-l  `\   `\  \  \ ~\  \   `. .-~   |
//   \   ~-. "-.  `  \  ^._ ^. "-.  /  \   |
// .--~-._  ~-  `  _  ~-_.-"-." ._ /._ ." ./
//  >--.  ~-.   ._  ~>-"    "\   7   7   ]
// ^.___~"--._    ~-{  .-~ .  `\ Y . /    |
//  <__ ~"-.  ~       /_/   \   \I  Y   : |
//    ^-.__           ~(_/   \   >;._:   | l______
//        ^--.,___.-~"  /_/   !  `-.~"--l_ /     ~"-.
//               (_/ .  ~(   /'     "~"--,Y   -=b-. _)
//                (_/ .  \  :           / l      c"~o \
//                 \ /    `.    .     .^   \_.-~"~--.  )
//                  (_/ .   `  /     /       !       )/
//                   / / _.   '.   .':      /        '
//                   ~(_/ .   /    _  `  .-<_
//                     /_/ . ' .-~" `.  / \  \          ,z=.
//                     ~( /   '  :   | K   "-.~-.______//
//                       "-,.    l   I/ \_    __{--->;._(==.
//                        //(     \  <    ~"~"     //
//                       /' /\     \  \     ,v=.  ((
//                     .^. / /\     "  }__ //===-  `
//                    / / ' '  "-.,__ {---(==-
//                  .^ '       :  T  ~"   ll
//                 / .  .  . : | :!        \
//                (_/  /   | | j-"          ~^
//                  ~-<_(_.^-~"
//
//-----------------------------------------------------------------------------------
//     ___           _            _     _       _       _   _
//    | _ ) __ _ _ _| |__  ___ __| |___| |_    /_\  _ _| |_| |_  ___ _ _ _  _
//    | _ \/ _` | '_| '_ \/ -_) _` / -_)  _|  / _ \| ' \  _| ' \/ _ \ ' \ || |
//    |___/\__,_|_| |_.__/\___\__,_\___|\__| /_/ \_\_||_\__|_||_\___/_||_\_, |
//                                                                        |__/
//-----------------------------------------------------------------------------------
