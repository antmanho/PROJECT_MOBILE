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

module.exports = (db) => {
    const router = express.Router();
    router.get('/api/catalogue-vendeur', (req, res) => {
        console.log("*** /catalogue-vendeur ***");

        const query = `
            SELECT
                Stock.id_stock,
                Stock.nom_jeu,
                Stock.Prix_unit,
                Stock.photo_path,
                Session.Frais_depot_fixe,
                Session.Frais_depot_percent,
                Stock.Prix_unit AS prix_final,
                Stock.est_en_vente
            FROM Stock
            JOIN Session ON Stock.numero_session_actuelle = Session.id_session
            WHERE Stock.email_vendeur = ?
        `;
        
        // Récupération de l'email de l'utilisateur connecté
        const emailConnecte = req.session.email_connecte;

        db.query(query, [emailConnecte], (err, results) => {
            if (err) {
                console.error('Erreur lors de la récupération du catalogue:', err);
                return res.status(500).json({ message: 'Erreur interne du serveur' });
            }
            res.status(200).json({ results, email_connecte: emailConnecte });
        });
    });

    // Route pour les jeux vendus
    router.get('/api/vendus', (req, res) => {
        console.log("*** /vendus ***");

        // Assurez-vous que l'email du vendeur connecté est disponible dans la session
        const emailVendeur = req.session.email_connecte;

        if (!emailVendeur) {
            return res.status(400).json({ message: 'Utilisateur non connecté' });
        }

        // La requête SQL avec le filtre sur email_vendeur
        const query = `
            SELECT
                Historique_Vente.nom_jeu,
                Historique_Vente.Prix_unit,
                Historique_Vente.photo_path,
                Historique_Vente.Quantite_vendu
            FROM Historique_Vente
            WHERE Historique_Vente.email_vendeur = ?
        `;

        // Exécution de la requête avec le filtre sur l'email du vendeur
        db.query(query, [emailVendeur], (err, results) => {
            if (err) {
                console.error('Erreur lors de la récupération des jeux vendus:', err);
                return res.status(500).json({ message: 'Erreur interne du serveur' });
            }
            res.status(200).json(results);
        });
    });


    return router;
};

