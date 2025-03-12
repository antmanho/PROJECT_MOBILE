//-----------------------------------------------------------------------------------
//
//                        _ _   ___           _
//    __ _ __ __ ___ _  _(_) | / / |___  __ _(_)_ _
//   / _` / _/ _/ -_) || | | |/ /| / _ \/ _` | | ' \ _ _ _
//   \__,_\__\__\___|\_,_|_|_/_/ |_\___/\__, |_|_||_(_|_|_)
//                                       |___/
//-----------------------------------------------------------------------------------



//deeb etant ma base de donne
const express = require('express');
const path = require('path');
const nodemailer = require('nodemailer');
const { v4: uuid } = require('uuid');
const multer = require('multer');
const fs = require('fs');
// Vérifier si le répertoire 'IMAGE' existe et le créer si nécessaire
const directoryPath = path.join(__dirname, 'RESSOURCES/IMAGE');
if (!fs.existsSync(directoryPath)) {
    fs.mkdirSync(directoryPath, { recursive: true });
}

// Configuration de multer
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'RESSOURCES/IMAGE'); // Répertoire de destination
    },
    filename: (req, file, cb) => {
        cb(null, Date.now() + path.extname(file.originalname)); // Renommer le fichier pour éviter les collisions
    }
});

const upload = multer({ storage });

module.exports = (db) => {
    const router = express.Router();
    //----------------------------------------------------------------------
    //----------------------------------- /INSCRIPTION --------------------
    //----------------------------------------------------------------------
    
    // Promisify the db.query method
    const util = require('util');
    const query = util.promisify(db.query).bind(db);
 
    router.post('/creer-session', (req, res) => {
        console.log("creeer-session");

        const {
            Nom_session,
            adresse_session,
            date_debut,
            date_fin,
            Frais_depot_fixe,
            Frais_depot_percent,
            Description
        } = req.body;

        const query = `
            INSERT INTO Session (Nom_session, adresse_session, date_debut, date_fin, Frais_depot_fixe, Frais_depot_percent, Description)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        `;

        db.query(query, [Nom_session, adresse_session, date_debut, date_fin, Frais_depot_fixe, Frais_depot_percent, Description], (error, result) => {
            if (error) {
                console.error('Erreur lors de l\'insertion : ', error);
            } else {
                res.status(200).send({ message: 'Session créée avec succès', sessionId: result.insertId });
            }
        });
    });
    
    // Route pour ajouter une préinscription
    router.post('/preinscription', (req, res) => {
        const { email, role } = req.body;

        if (!email || !role) {
            return res.status(400).json({ status: 'error', message: 'Email et rôle sont requis' });
        }

        const query = 'INSERT INTO role_preinscription (Email, Role) VALUES (?, ?)';
        db.query(query, [email, role], (err, result) => {
            if (err) {
                console.error('Erreur lors de l\'insertion:', err);
                return res.status(500).json({ status: 'error', message: 'Erreur serveur' });
            }
            res.json({ status: 'success', message: 'Préinscription ajoutée avec succès' });
        });
    });
   
  
    // Récupérer toutes les sessions, triées par ID décroissant pour afficher les plus récentes en premier
    router.get('/api/sessions', (req, res) => {
        console.log("getttt");
        db.query('SELECT * FROM Session ORDER BY id_session DESC', (err, results) => {
            if (err) {
                return res.status(500).send('Erreur lors de la récupération des sessions');
            }
            res.json(results);
        });
    });


    // Modifier plusieurs sessions
    // Route pour mettre à jour les sessions
    // Modifier plusieurs sessions
    // Exemple de test de réponse du backend pour /api/sessions
    router.put('/api/sessions', (req, res) => {
      const sessions = req.body;
      
      console.log("Sessions reçues pour mise à jour :", sessions);  // Voir ce qui est reçu côté serveur

      // Utilisation de promesses pour traiter plusieurs mises à jour
      const updatePromises = sessions.map(session => {
        const { id_session, Nom_session, adresse_session, date_debut, date_fin, Charge_totale, Frais_depot_fixe, Frais_depot_percent, Description } = session;

        const query = `
          UPDATE Session
          SET Nom_session = ?, adresse_session = ?, date_debut = ?, date_fin = ?, Charge_totale = ?, Frais_depot_fixe = ?, Frais_depot_percent = ?, Description = ?
          WHERE id_session = ?
        `;

        return new Promise((resolve, reject) => {
          db.query(query, [Nom_session, adresse_session, date_debut, date_fin, Charge_totale, Frais_depot_fixe, Frais_depot_percent, Description, id_session], (err, result) => {
            if (err) {
              console.error("Erreur dans la mise à jour de la session:", err);  // Affichage de l'erreur dans la console
              reject(err);
            } else {
              resolve(result);
            }
          });
        });
      });

      // Attente de toutes les mises à jour
      Promise.all(updatePromises)
        .then(() => {
          console.log("Sessions mises à jour avec succès");
          res.send({ message: 'Sessions mises à jour avec succès', status: 'success' });
        })
        .catch((err) => {
          console.error("Erreur lors de la mise à jour des sessions:", err);
          res.status(500).send({ message: 'Erreur lors de la mise à jour des sessions', status: 'error' });
        });
    });

    router.get('/api/users', (req, res) => {
      db.query('SELECT * FROM Users ORDER BY id_users DESC', (err, results) => {
        if (err) {
          return res.status(500).send('Erreur lors de la récupération des utilisateurs');
        }
        res.json(results);
      });
    });

    // Mettre à jour plusieurs utilisateurs
    router.put('/api/users', (req, res) => {
      const users = req.body;

      // Utilisation de promesses pour traiter plusieurs mises à jour
      const updatePromises = users.map(user => {
        const { id_users, email, mdp, nom, telephone, adresse, role } = user;

        const query = `
          UPDATE Users
          SET email = ?, mdp = ?, nom = ?, telephone = ?, adresse = ?, role = ?
          WHERE id_users = ?
        `;

        return new Promise((resolve, reject) => {
          db.query(query, [email, mdp, nom, telephone, adresse, role, id_users], (err, result) => {
            if (err) {
              reject(err);
            } else {
              resolve(result);
            }
          });
        });
      });

      // Attente de toutes les mises à jour
      Promise.all(updatePromises)
        .then(() => {
            res.send({ message: 'Utilisateurs mis à jour avec succès', status: 'success' });

        })
        .catch((err) => {
          res.status(500).send('Erreur lors de la mise à jour des utilisateurs');
        });
    });

    
    return router;
};

