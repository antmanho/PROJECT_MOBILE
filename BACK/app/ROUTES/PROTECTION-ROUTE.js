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
const fs = require('fs');


module.exports = (db) => {
    const router = express.Router();
    //----------------------------------------------------------------------
    //----------------------------------- /INSCRIPTION --------------------
    //----------------------------------------------------------------------
    
    // Promisify the db.query method
    const util = require('util');
    const query = util.promisify(db.query).bind(db);
   
    router.get('/verification_G_ou_A', (req, res) => {
        console.log("-----------verificationnnn-------------------")
        const emailConnecte = req.session.email_connecte;

        if (!emailConnecte) {
            return res.status(200).send({ valid: false }); // Non connecté
        }

        // Vérification du rôle
        const userQuery = 'SELECT role FROM Users WHERE email = ?';
        query(userQuery, [emailConnecte], (err, results) => {
            if (err || results.length === 0) {
                console.error('Erreur lors de la vérification:', err);
                return res.status(500).send({ valid: false });
            }

            const user = results[0];
            if (user.role === 'admin' || user.role === 'gestionnaire') {
                res.status(200).send({ valid: true }); // Autorisé
            } else {
                res.status(200).send({ valid: false }); // Non autorisé
            }
        });
    });
    router.get('/verification_G_ou_A', (req, res) => {
        console.log("-----------verification_G_ou_A-------------------")
        const emailConnecte = req.session.email_connecte;

        if (!emailConnecte) {
            return res.status(200).send({ valid: false }); // Non connecté
        }

        // Vérification du rôle
        const userQuery = 'SELECT role FROM Users WHERE email = ?';
        query(userQuery, [emailConnecte], (err, results) => {
            if (err || results.length === 0) {
                console.error('Erreur lors de la vérification:', err);
                return res.status(500).send({ valid: false });
            }

            const user = results[0];
            if (user.role === 'admin' || user.role === 'gestionnaire') {
                res.status(200).send({ valid: true }); // Autorisé
            } else {
                res.status(200).send({ valid: false }); // Non autorisé
            }
        });
    });
    router.get('/verification_A', (req, res) => {
        console.log("-----------verification_A-------------------")
        const emailConnecte = req.session.email_connecte;

        if (!emailConnecte) {
            return res.status(200).send({ valid: false }); // Non connecté
        }

        // Vérification du rôle
        const userQuery = 'SELECT role FROM Users WHERE email = ?';
        query(userQuery, [emailConnecte], (err, results) => {
            if (err || results.length === 0) {
                console.error('Erreur lors de la vérification:', err);
                return res.status(500).send({ valid: false });
            }

            const user = results[0];
            if (user.role === 'admin') {
                res.status(200).send({ valid: true }); // Autorisé
            } else {
                res.status(200).send({ valid: false }); // Non autorisé
            }
        });
    });
    router.get('/verification_V', (req, res) => {
        console.log("-----------verification_V-------------------")
        const emailConnecte = req.session.email_connecte;

        if (!emailConnecte) {
            return res.status(200).send({ valid: false }); // Non connecté
        }

        // Vérification du rôle
        const userQuery = 'SELECT role FROM Users WHERE email = ?';
        query(userQuery, [emailConnecte], (err, results) => {
            console.log(results);
            if (err || results.length === 0) {
                console.error('Erreur lors de la vérification:', err);
                return res.status(500).send({ valid: false });
            }

            const user = results[0];
            if (user.role === 'vendeur') {
                res.status(200).send({ valid: true }); // Autorisé
            } else {
                res.status(200).send({ valid: false }); // Non autorisé
            }
        });
    });
    return router;
};

