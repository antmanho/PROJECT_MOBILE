const session = require('express-session');
const MemoryStore = require('memorystore')(session); // Meilleur stockage de session

const sessionMiddleware = session({
    secret: 'super_secret_key', // Clé secrète (change-la en prod)
    resave: false,
    saveUninitialized: true, // Forcer l'enregistrement des nouvelles sessions
    store: new MemoryStore({ checkPeriod: 86400000 }), // Nettoyage des sessions toutes les 24h
    cookie: {
        maxAge: 7200000, // 2 heures
        httpOnly: true,  // Sécurise le cookie contre JavaScript
        secure: false,   // Devrait être `true` en production avec HTTPS
        sameSite: 'Lax'  // Autorise les cookies sans contexte inter-domaine strict
    }
});

// Middleware pour initialiser la session
const sessionInitMiddleware = (req, res, next) => {
    if (!req.session.email_connecte) {
        req.session.email_connecte = 'invite@example.com'; // Email par défaut
    }
    next();
};

// Middleware de vérification de session
const sessionCheckMiddleware = (req, res, next) => {
    const originalEmailConnecte = req.session.email_connecte;

    res.on('finish', () => {
        console.log('🟢 Session après requête :');
        console.log('   ➡ SessionID:', req.sessionID);
        console.log('   ➡ Email connecté:', req.session.email_connecte);

        if (req.session.email_connecte !== originalEmailConnecte) {
            console.log("🔄 Modification de la session détectée !");
        }
    });

    next();
};

module.exports = { sessionMiddleware, sessionInitMiddleware, sessionCheckMiddleware };


 ___  ___   _   ___ ___  _      _   _  _ ___
| _ )/ _ \ /_\ | _ \   \| |    /_\ | \| |   \
| _ \ (_) / _ \|   / |) | |__ / _ \| .` | |) |
|___/\___/_/ \_\_|_\___/|____/_/ \_\_|\_|___/

