//-----------------------------------------------------------------------------------
//     ___ _  _ ___ _____ ____  __ ___ ___  ___  _    _____      ___   ___ ___
//    |_ _| \| |_ _|_   _/ /  \/  |_ _|   \|   \| |  | __\ \    / /_\ | _ \ __|
//     | || .` || |  | |/ /| |\/| || || |) | |) | |__| _| \ \/\/ / _ \|   / _|
//    |___|_|\_|___| |_/_/ |_|  |_|___|___/|___/|____|___| \_/\_/_/ \_\_|_\___|
//
//-----------------------------------------------------------------------------------
const mysql = require('mysql');

//const db = mysql.createConnection({
//    host: 'localhost',
//    user: 'root',
//    password: 'root',
//    database: 'BDR',
//    socketPath: '../../../../../../../Applications/MAMP/tmp/mysql/mysql.sock'
//});
// Configuration de la connexion à la base de données MySQL
const db = mysql.createConnection({
    host: 'localhost',
    user: 'admin',
    password: 'fiorio',
    database: 'BDR',
    socketPath: '../../../../var/run/mysqld/mysqld.sock'
});
// Connectez-vous à la base de données
db.connect((err) => {
    if (err) {
        console.error('Erreur de connexion à la base de données:', err);
        return;
    }
    console.log('Connexion à la base de données réussie');
});

module.exports = db;

