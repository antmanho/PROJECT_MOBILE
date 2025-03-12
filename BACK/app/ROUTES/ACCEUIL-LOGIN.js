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
    //----------------------------------------------------------------------
    //----------------------------------- /INSCRIPTION --------------------
    //----------------------------------------------------------------------
    
    // Promisify the db.query method
    const util = require('util');
    const query = util.promisify(db.query).bind(db);
    router.post('/deconnexion', (req, res) => {

        console.log("-----------/deconnexion-----------------");
  
            // Si x == "deconnexion", réinitialiser la session pour un utilisateur invité
            req.session.email_connecte = "invite@example.com";
            console.log("Session réinitialisée à un utilisateur invité.");
            return res.json({ message: 'Déconnexion réussie, utilisateur réinitialisé à invité.' });
      
    });
    router.get('/root', (req, res) => {

        console.log("-----------/root-----------------");
  
            // Sinon, vérifier si la session n'existe pas
            if (!req.session.email_connecte) {
                // Initialiser les valeurs de session si elles ne sont pas déjà définies
                req.session.email_connecte = 'invite@example.com';
                console.log("Session initialisée avec email_connecte:", req.session.email_connecte);
            } else {
                console.log("Session déjà initialisée avec email_connecte:", req.session.email_connecte);
            }

            // Répondre avec les informations de session
            res.json({
                message: 'Session traitée',
                email_connecte: req.session.email_connecte,
                sessionID: req.session.id // Renvoie l'ID de session
            });
    });

    
   
    
    router.post('/api/inscription', async (req, res) => {
        console.log("*** /inscription ***");

        // Extraction des donnees du corps de la requête
        const { email, password, confirmPassword } = req.body;

        try {
            // Verification si les mots de passe correspondent
            if (password !== confirmPassword) {
                console.log('Les mots de passe ne correspondent pas.');
                return res.status(400).json({ message: 'Les mots de passe ne correspondent pas.' });
            }

            console.log('Verification si l\'email existe dejà...');
            // Utilisation de requêtes preparees pour eviter les injections SQL
            const existingUser = await query('SELECT * FROM Users WHERE email = ?', [email]);

            // Verification si l'utilisateur existe dejà
            if (existingUser.length > 0) {
                console.log('Cet email est dejà utilise.');
                return res.status(400).json({ message: 'Cet email est dejà utilise.' });
            }

            console.log('Insertion dans la table verification_mail...');

            // Generation du code à 6 chiffres
            const verificationCode = Math.floor(100000 + Math.random() * 900000);

            // Insertion de l'email, du code et du mot de passe dans la table verification_mail
            await query('INSERT INTO Verification_mail (Email, Code, Password) VALUES (?, ?, ?)', [email, verificationCode, password]);

            console.log("*** Envoi du code de verification par email ***");

            // Configuration du transporteur nodemailer pour envoyer un email
            let transporter = nodemailer.createTransport({
                host: 'smtp.gmail.com',
                port: 587,
                secure: false, // true pour port 465, false pour les autres ports
                auth: {
                    user: 'barbedetanthony@gmail.com',
                    pass: 'dmunpyeuzmkuebqc' // Remplacez par votre mot de passe ou cle d'application
                }
            });

            // Definition des options de l'email
            let mailOptions = {
                from: '"Anthony" <barbedetanthony@gmail.com>',
                to: email,
                subject: 'Verification de votre inscription',
                html: `
                    <p>Bonjour,</p>
                    <p>Merci de vous être inscrit. Voici votre code de verification :</p>
                    <h2>${verificationCode}</h2>
                    <p>Veuillez entrer ce code sur notre site pour completer votre inscription.</p>
                    <p>Cordialement,</p>
                    <p>L'equipe de 'Boardland'</p>
                `
            };

            // Envoi de l'email
            transporter.sendMail(mailOptions, (error, info) => {
                if (error) {
                    console.error('Erreur lors de l\'envoi de l\'email :', error);
                    return res.status(500).send('Erreur lors de l\'envoi de l\'email.');
                } else {
                    console.log('Email envoye :', info.response);
                    res.status(200).json({ message: 'Un code de verification a ete envoye à votre email.' });
                }
            });

        } catch (error) {
            console.error('Erreur lors de l\'inscription:', error);
            res.status(500).json({ message: 'Erreur lors de l\'inscription.' });
        }
    });
    
    // Route pour verifier le code et ajouter l'utilisateur
    // Route pour verifier le code et ajouter l'utilisateur
    router.post('/verification-email', async (req, res) => {
        console.log("*** /verification-email ***");

        const { email, code_recu } = req.body;
        console.log("email:", email);
        console.log("code:", code_recu);
        let role = 'd';  // Valeur par defaut du rôle

        try {
            // 1. Verification si l'utilisateur existe dejà dans la table Users
            const existingUser = await query('SELECT * FROM Users WHERE email = ?', [email]);

            if (existingUser.length > 0) {
                console.log('Email dejà verifie.');
                return res.status(400).json({ message: 'Email dejà verifie.' });
            }

            // 2. Verification dans la table role_preinscription
            console.log('Verification du rôle...');
            const rolePreinscription = await query('SELECT role FROM role_preinscription WHERE email = ?', [email]);

            if (rolePreinscription.length > 0) {
                role = rolePreinscription[0].role;
                console.log('Rôle trouve dans role_preinscription:', role);
            } else {
                console.log('Aucun rôle trouve dans role_preinscription, rôle par defaut:', role);
            }

            // 3. Verification du code dans la table Verification_mail
            console.log('Verification du code et recuperation du mot de passe...');
            const verificationMail = await query('SELECT * FROM Verification_mail WHERE Email = ? AND Code = ?', [email, code_recu]);

            if (verificationMail.length === 0) {
                console.log('Code de verification invalide.');
                return res.status(400).json({ message: 'Code de verification invalide.' });
            }

            const password = verificationMail[0].Password;

            // 4. Ajout de l'utilisateur dans la table Users
            console.log('Ajout de l\'utilisateur dans la table Users...');
            await query('INSERT INTO Users (email, mdp, nom, telephone, adresse, role) VALUES (?, ?, ?, ?, ?, ?)',
                [email, password, "d", "d", "d", role]);

            console.log('Utilisateur ajoute avec succès.');

            // Enregistrer l'email dans la session
            req.session.email_connecte = email;
            console.log('Email enregistre dans la session:', req.session.email_connecte);

            res.status(200).json({ message: 'Votre email a ete verifie et votre compte a ete cree avec succès.' });

        } catch (error) {
            console.error('Erreur lors de la verification du mail:', error);
            res.status(500).json({ message: 'Erreur lors de la verification du mail.' });
        }
    });




    // Route de connexion
    router.post('/api/connexion', (req, res) => {
        console.log("Tentative de connexion");

        const { email, password } = req.body;
        console.log('Email:', email);
        console.log('Mot de passe:', password);

        // Verification si les champs sont vides
        if (!email || !password) {
            return res.status(400).json({ message: 'Veuillez remplir tous les champs correctement.', success: false });
        }

        // Requête pour verifier si l'utilisateur existe avec l'email et mot de passe fournis
        db.query('SELECT * FROM Users WHERE email = ? AND mdp = ?', [email, password], (err, results) => {
            if (err) {
                console.error('Erreur lors de la verification de l\'utilisateur :', err);
                return res.status(500).json({ message: 'Erreur interne du serveur.', success: false });
            }

            // Si aucun compte trouve, on renvoie un succès avec message, mais pas d'erreur
            if (results.length === 0) {
                console.log("Compte non trouve pour l'email:", email);
                return res.status(200).json({ message: 'Compte non trouve. Verifiez vos identifiants.', success: false });
            }

            // Authentification reussie
            req.session.email_connecte = email;

            // Redirection vers /menu si l'utilisateur existe
            res.status(200).json({ redirectUrl: '/menu', success: true });
        });
    });


    router.post('/mdp_oublie', (req, res) => {
        console.log("post");
        const { email } = req.body;
        console.log(email);
        db.query('SELECT * FROM Users WHERE email=?', [email], (err, results) => {
            if (err) {
                console.error('Erreur lors de la verification de l\'utilisateur :', err);
                res.status(500).send('Erreur lors de la verification de l\'utilisateur.');
                return;
            }

            if (results.length > 0) {
                req.session.email_connecte = email;

                let transporter = nodemailer.createTransport({
                    host: 'smtp.gmail.com',
                    port: 587,
                    secure: false,
                    auth: {
                        user: 'barbedetanthony@gmail.com',
                        pass: 'dmunpyeuzmkuebqc'
                    }
                });

                let mailOptions = {
                    from: '"Anthony" <barbedetanthony@gmail.com>',
                    to: email,
                    subject: 'Reinitialisation de votre mot de passe',
                    html: `
                        <p>Bonjour,</p>
                        <p>Vous avez demande à reinitialiser votre mot de passe. Cliquez sur le lien ci-dessous pour reinitialiser votre mot de passe :</p>
                        <a href="http://localhost:4200/changer-mdp/${encodeURIComponent(email)}">Reinitialiser le mot de passe</a>
                        <p>Si vous n'avez pas demande cette reinitialisation, veuillez ignorer cet email.</p>
                        <p>Cordialement,</p>
                        <p>L'equipe de 'Boardland'</p>
                    `
                };

                transporter.sendMail(mailOptions, (error, info) => {
                    if (error) {
                        console.error('Erreur lors de l\'envoi de l\'email :', error);
                        res.status(500).send('Erreur lors de l\'envoi de l\'email.');
                    } else {
                        console.log('Email envoye :', info.response);
                        res.render('mot_passe_oublie', {  error: false , message : "Un lien de renitialisation mot de passe a ete envoye ."});
                    }
                });
                
            } else {
                console.log("pas de compte");
                res.render('mot_passe_oublie', { error: "aucun compte associe à ce mail ", message : false });
            }
        });
    });

    // Route pour changer le mot de passe
    router.post('/changer_mdp/:email', (req, res) => {
        const email_mdp = req.params.email; // Recuperer l'email depuis les paramètres de la route
        const { new_password, confirm_password } = req.body;

        // Verifier si les mots de passe correspondent
        if (new_password !== confirm_password) {
            res.render('page_change_mdp', { email_qui_veut_changer_mdp: email_mdp, error: 'Les mots de passe ne correspondent pas.'});
            return;
        }

        // Mettre à jour le mot de passe dans la base de donnees
        db.query('UPDATE UTILISATEUR SET mot_de_passe = ? WHERE email = ?', [new_password, email_mdp], (err, result) => {
            if (err) {
                console.error('Erreur lors de la mise à jour du mot de passe :', err);
                res.status(500).send('Erreur lors de la mise à jour du mot de passe.');
                return;
            }
            console.log("Mot de passe change avec succès.");

            // Envoi de l'email de confirmation
            const mailOptions = {
                from: 'votre_email@gmail.com', // Remplacez par votre email
                to: email_mdp,
                subject: 'Changement de mot de passe',
                text: 'Votre mot de passe a ete change avec succès.'
            };

            transporter.sendMail(mailOptions, (error, info) => {
                if (error) {
                    console.error('Erreur lors de l\'envoi de l\'email :', error);
                    res.status(500).send('Erreur lors de l\'envoi de l\'email.');
                    return;
                }
                console.log('Email envoye : ' + info.response);
                // Rediriger après l'envoi
               
            });
        });
    });
    

    return router;
};

