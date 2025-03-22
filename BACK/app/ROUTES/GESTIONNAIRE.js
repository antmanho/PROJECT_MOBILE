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

const destinationPath = path.join(__dirname, '../RESSOURCES/IMAGE');
console.log("Dossier d'enregistrement :", destinationPath);

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, destinationPath);
    },
    filename: (req, file, cb) => {
        cb(null, Date.now() + path.extname(file.originalname));
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
   
    router.put('/api/stock/:id/toggle-vente', (req, res) => {
        const { id } = req.params;
        const { est_en_vente } = req.body;

        const query = 'UPDATE Stock SET est_en_vente = ? WHERE id_stock = ?';
        db.query(query, [est_en_vente, id], (err, result) => {
            if (err) {
                console.error('Erreur lors de la mise à jour de est_en_vente:', err);
                return res.status(500).json({ message: 'Erreur interne du serveur' });
            }

            res.status(200).json({ message: 'Statut de vente mis à jour avec succès' });
        });
    });
    
    
    // Route pour obtenir les informations de l'utilisateur connecte
    router.get('/api/user-info', (req, res) => {
        if (req.session.email_connecte) {
            // Recuperation de l'email de la session
            const email = req.session.email_connecte;

            // Requête à la base de donnees pour verifier si l'utilisateur existe dans la table Users
            db.query('SELECT role FROM Users WHERE email = ?', [email], (err, results) => {
                if (err) {
                    console.error('Erreur lors de la recuperation du rôle:', err);
                    return res.status(500).json({ message: 'Erreur interne du serveur' });
                }

                if (results.length === 0) {
                    // Si l'utilisateur n'existe pas dans la table Users, verifier dans la table role_preinscription
                    db.query('SELECT Role FROM role_preinscription WHERE Email = ?', [email], (err, resultsPreinscription) => {
                        if (err) {
                            console.error('Erreur lors de la recuperation du rôle de preinscription:', err);
                            return res.status(500).json({ message: 'Erreur interne du serveur' });
                        }

                        if (resultsPreinscription.length === 0) {
                            // Aucun rôle trouve dans les deux tables
                            return res.status(200).json({ email: email, role: null });
                        }

                        // Rôle trouve dans la table role_preinscription
                        const rolePreinscription = resultsPreinscription[0].Role;
                        return res.status(200).json({ email: email, role: rolePreinscription });
                    });
                } else {
                    // Si l'utilisateur est trouve dans la table Users, renvoyer le rôle associe
                    const role = results[0].role;
                    return res.status(200).json({ email: email, role: role });
                }
            });
        } else {
            // L'utilisateur n'est pas connecte
            res.status(200).json({ email: null, role: null });
        }
    });


      // Route pour les détails d'un jeu
    router.get('/api/detail/:id', (req, res) => {
        console.log("*** /detail/:id ***");

        const { id } = req.params; // Récupérer l'id depuis les paramètres de l'URL

        const query = `
            SELECT
                Stock.id_stock,
                Stock.nom_jeu,
                Stock.Prix_unit,
                Stock.photo_path,
                Stock.editeur,
                Stock.description,
                Session.Frais_depot_fixe,
                Session.Frais_depot_percent,
                Stock.Prix_unit AS prix_final,
                Stock.est_en_vente
            FROM Stock
            JOIN Session ON Stock.numero_session_actuelle = Session.id_session
            WHERE Stock.id_stock = ?`; // Utilisation de paramètre préparé pour éviter les injections SQL
        
        db.query(query, [id], (err, results) => {
            if (err) {
                console.error('Erreur lors de la récupération des détails du jeu:', err);
                return res.status(500).json({ message: 'Erreur interne du serveur' });
            }
            if (results.length === 0) {
                return res.status(404).json({ message: 'Jeu non trouvé' }); // Gestion du cas où aucun jeu n'est trouvé
            }
            res.status(200).json(results[0]); // Renvoie uniquement le premier résultat (il devrait y avoir qu'un seul jeu avec cet id)
        });
    });

    router.get('/get_info_sess/:id', async (req, res) => {
        const id_session = req.params.id;

        try {
            const sql = 'SELECT * FROM Session WHERE id_session = ?';
            const [session] = await query(sql, [id_session]); // Récupérer une seule ligne

            if (!session) {
                return res.status(404).send({ message: 'Session non trouvée' });
            }

            res.status(200).send(session);
        } catch (error) {
            console.error('Erreur lors de la récupération de la session:', error);
            res.status(500).send({ message: 'Erreur lors de la récupération de la session' });
        }
    });


    router.get('/get_all_sessions', async (req, res) => {
      try {
        const sql = 'SELECT * FROM Session';
        const sessions = await query(sql);
        res.status(200).send(sessions);
      } catch (error) {
        console.error('Erreur lors de la récupération des sessions:', error);
        res.status(500).send({ message: 'Erreur lors de la récupération des sessions' });
      }
    });

    router.post('/depot', upload.single('image'), async (req, res) => {
        console.log("*** /depot ***");
        if (req.file) {
            console.log("Fichier re      u : ", req.file);
        } else {
            console.log("Aucun fichier re      u.");
        }

        // V      rification des donn      es re      ues
        const { email_vendeur, nom_jeu, prix_unit, quantite_deposee, est_en_vente, editeur, description, num_session } = req.body;

        let x = (est_en_vente === "true" || est_en_vente === true) ? 1 : 0;

        try {
            let imagePath = "/IMAGE/pas_photo.JPG"; // Valeur par d      faut
            if (req.file) {
                imagePath = `/IMAGE/${req.file.filename}`; // Utiliser le nom du fichier g      n      r       par multer
            }

            const sql = `
                INSERT INTO Stock
                (email_vendeur, nom_jeu, Prix_unit, numero_session_actuelle, Quantite_actuelle, est_en_vente, photo_path)
                VALUES (?, ?, ?, ?, ?, ?, ?)
            `;
            const values = [email_vendeur, nom_jeu, prix_unit, num_session, quantite_deposee, x, imagePath];

            await query(sql, values);
            res.status(200).send({ message: 'Jeu ajout       avec succ      s', imagePath });
        } catch (error) {
            console.error('Erreur lors de l\'ajout du jeu:', error);
            res.status(500).send({ message: 'Erreur lors de l\'ajout du jeu' });
        }
    });

    // Route pour gerer les requêtes GET pour le bilan
    router.post('/bilan', (req, res) => {
        const { bilanParticulier, sessionParticuliere, emailParticulier, numeroSession, chargesFixes } = req.body;
        console.log('Requête reçue avec paramètres:', { bilanParticulier, sessionParticuliere, emailParticulier, numeroSession, chargesFixes });
        

        let venteQuery, depotQuery;
        const venteQueryParams = [];
        const depotQueryParams = [];

        // Definition des requêtes en fonction des cas
        if (bilanParticulier && sessionParticuliere) {
            console.log('Cas 1 : Bilan particulier, Session particulière');
            venteQuery = `
                SELECT id_vente, Quantite_vendu, Prix_unit
                FROM Historique_Vente
                WHERE numero_session_vente = ? AND email_vendeur = ?
                ORDER BY id_vente ASC
            `;
            venteQueryParams.push(numeroSession, emailParticulier);
            
            depotQuery = `
                SELECT SUM(Quantite_depose) AS totalQuantiteDeposee
                FROM Historique_Depot
                WHERE numero_session_depot = ? AND email_vendeur = ?
            `;
            depotQueryParams.push(numeroSession, emailParticulier);
        } else if (bilanParticulier && !sessionParticuliere) {
            console.log('Cas 2 : Bilan particulier, Toutes les sessions');
            venteQuery = `
                SELECT id_vente, Quantite_vendu, Prix_unit
                FROM Historique_Vente
                WHERE email_vendeur = ?
                ORDER BY id_vente ASC
            `;
            venteQueryParams.push(emailParticulier);
            
            depotQuery = `
                SELECT SUM(Quantite_depose) AS totalQuantiteDeposee
                FROM Historique_Depot
                WHERE email_vendeur = ?
            `;
            depotQueryParams.push(emailParticulier);
        } else if (!bilanParticulier && sessionParticuliere) {
            console.log('Cas 3 : Bilan general, Session particulière');
            venteQuery = `
                SELECT id_vente, Quantite_vendu, Prix_unit, Frais_depot_percent, Frais_depot_fixe
                FROM Historique_Vente
                JOIN Session ON numero_session_vente = id_session
                WHERE numero_session_vente = ?
                ORDER BY id_vente ASC
            `;
            venteQueryParams.push(numeroSession);

            depotQuery = `
                SELECT SUM(Quantite_depose) AS totalQuantiteDeposee
                FROM Historique_Depot
                WHERE numero_session_depot = ?
            `;
            depotQueryParams.push(numeroSession);
        } else {
            console.log('Cas 4 : Bilan general, Toutes les sessions');
            venteQuery = `
                SELECT id_vente, Quantite_vendu, Prix_unit, Frais_depot_percent, Frais_depot_fixe
                FROM Historique_Vente
                JOIN Session ON numero_session_vente = id_session
                ORDER BY id_vente ASC
            `;

            depotQuery = `
                SELECT SUM(Quantite_depose) AS totalQuantiteDeposee
                FROM Historique_Depot
            `;
        }

        console.log('Requête SQL pour les ventes:', venteQuery);
        console.log('Requête SQL pour les depôts:', depotQuery);

        db.query(venteQuery, venteQueryParams, (err, venteResults) => {
            if (err) {
                console.error('Erreur lors de la recuperation des donnees de vente:', err);
                return res.status(500).json({ message: 'Erreur lors de la recuperation des donnees de vente' });
            }

            console.log('Resultats de vente:', venteResults);
            if (venteResults.length === 0) {
                console.log('Aucun resultat de vente trouve.');
                return res.json({ message: 'Aucun graphe ne peut être effectue, aucune vente realisee pour cette situation' });
            }

            // Si des resultats de vente sont trouves, continuez avec la requête de depôt
            db.query(depotQuery, depotQueryParams, (err, depotResults) => {
                if (err) {
                    console.error('Erreur lors de la recuperation des donnees de depôt:', err);
                    return res.status(500).json({ message: 'Erreur lors de la recuperation des donnees de depôt' });
                }

                console.log('Resultats de depôt:', depotResults);

                // Renvoyer les resultats au client
                res.json({
                    bilanParticulier,
                    sessionParticuliere,
                    emailParticulier,
                    numeroSession,
                    chargesFixes
                });
            });
        });
    });


        router.get('/bilan-graphe', (req, res) => {
            const { bilanParticulier, sessionParticuliere, emailParticulier, numeroSession, chargesFixes } = req.query;

            // Transformer les paramètres en booleens
            const isBilanParticulier = bilanParticulier === 'true';
            const isSessionParticuliere = sessionParticuliere === 'true';

            console.log('Requête reçue avec paramètres:', { isBilanParticulier, isSessionParticuliere, emailParticulier, numeroSession, chargesFixes });

            let venteQuery, depotQuery;
            const venteQueryParams = [];
            const depotQueryParams = [];

            // Configuration des requêtes SQL selon les paramètres
            if (isBilanParticulier && isSessionParticuliere) {
                console.log('Cas 1 : Bilan particulier, Session particulière');
                venteQuery = `
                    SELECT id_vente, Quantite_vendu, Prix_unit
                    FROM Historique_Vente
                    WHERE numero_session_vente = ? AND email_vendeur = ?
                    ORDER BY id_vente ASC
                `;
                venteQueryParams.push(numeroSession, emailParticulier);

                depotQuery = `
                    SELECT SUM(Quantite_depose) AS totalQuantiteDeposee
                    FROM Historique_Depot
                    WHERE numero_session_depot = ? AND email_vendeur = ?
                `;
                depotQueryParams.push(numeroSession, emailParticulier);
            } else if (isBilanParticulier) {
                console.log('Cas 2 : Bilan particulier, Toutes les sessions');
                venteQuery = `
                    SELECT id_vente, Quantite_vendu, Prix_unit
                    FROM Historique_Vente
                    WHERE email_vendeur = ?
                    ORDER BY id_vente ASC
                `;
                venteQueryParams.push(emailParticulier);

                depotQuery = `
                    SELECT SUM(Quantite_depose) AS totalQuantiteDeposee
                    FROM Historique_Depot
                    WHERE email_vendeur = ?
                `;
                depotQueryParams.push(emailParticulier);
            } else if (isSessionParticuliere) {
                console.log('Cas 3 : Bilan general, Session particulière');
                venteQuery = `
                    SELECT id_vente, Quantite_vendu, Prix_unit, Frais_depot_percent, Frais_depot_fixe
                    FROM Historique_Vente
                    JOIN Session ON numero_session_vente = id_session
                    WHERE numero_session_vente = ?
                    ORDER BY id_vente ASC
                `;
                venteQueryParams.push(numeroSession);

                depotQuery = `
                    SELECT SUM(Quantite_depose) AS totalQuantiteDeposee
                    FROM Historique_Depot
                    WHERE numero_session_depot = ?
                `;
                depotQueryParams.push(numeroSession);
            } else {
                console.log('Cas 4 : Bilan general, Toutes les sessions');
                venteQuery = `
                    SELECT id_vente, Quantite_vendu, Prix_unit, Frais_depot_percent, Frais_depot_fixe
                    FROM Historique_Vente
                    JOIN Session ON numero_session_vente = id_session
                    ORDER BY id_vente ASC
                `;

                depotQuery = `
                    SELECT SUM(Quantite_depose) AS totalQuantiteDeposee
                    FROM Historique_Depot
                `;
            }

            console.log('Requête SQL pour les ventes:', venteQuery);
            console.log('Requête SQL pour les depôts:', depotQuery);

            db.query(venteQuery, venteQueryParams, (err, venteResults) => {
                if (err) {
                    console.error('Erreur lors de la recuperation des donnees de vente:', err);
                    return res.status(500).json({ message: 'Erreur lors de la recuperation des donnees de vente' });
                }

                console.log('Resultats de vente:', venteResults);
                if (venteResults.length === 0) {
                    console.log('Aucun resultat trouve.');
                    return res.json({ message: 'Aucun graphe ne peut être effectue, aucune vente realisee pour cette situation' });
                }

                db.query(depotQuery, depotQueryParams, (err, depotResults) => {
                    if (err) {
                        console.error('Erreur lors de la recuperation des donnees de depôt:', err);
                        return res.status(500).json({ message: 'Erreur lors de la recuperation des donnees de depôt' });
                    }

                    const totalQuantiteDeposee = depotResults[0]?.totalQuantiteDeposee || 0;
                    console.log('Quantite deposee totale:', totalQuantiteDeposee);

                    const listeX = [];
                    let a = 1;

                    // Liste Y : Prix unitaires selon la quantite vendue
                    const listeY = venteResults.flatMap(row => {
                        const prixUnitaire = row.Prix_unit+row.Prix_unit * (row.Frais_depot_percent / 100) + row.Frais_depot_fixe;
                        const yElements = Array(row.Quantite_vendu).fill(prixUnitaire);
                        yElements.forEach(() => {
                            listeX.push(a);
                            a += 1;
                        });
                        return yElements;
                    });

                    // Liste Y2 : Prix unitaires avec frais
                    const listeY2 = venteResults.flatMap(row => {
                        const prixAvecFrais = row.Prix_unit * (row.Frais_depot_percent / 100) + row.Frais_depot_fixe;
                        const y2Elements = Array(row.Quantite_vendu).fill(prixAvecFrais);
                        return y2Elements;
                    });

                    // Liste Y3 : Prix unitaires
                    const listeY3 = venteResults.flatMap(row => {
                        const prix = row.Prix_unit;
                        const y3Elements = Array(row.Quantite_vendu).fill(prix);
                        return y3Elements;
                    });
           
                    // Fonction pour calculer la somme successive
                    function sommeSuccessive(liste) {
                        const sommeListe = [];
                        let somme = 0;
                        liste.forEach(valeur => {
                            somme += valeur;
                            sommeListe.push(somme);
                        });
                        return sommeListe;
                    }

                    const listeYSomme = sommeSuccessive(listeY);
                    const listeY2Somme = sommeSuccessive(listeY2);
                    const listeY3Somme = sommeSuccessive(listeY3);
                    const totalQuantiteVendu = listeY.length;
                    console.log('Liste y creee :', listeYSomme);
                    console.log('Liste y2 creee :', listeY2Somme);
                    console.log('Liste y3 creee :', listeY3Somme); // Afficher la liste Y3
                    console.log('Liste x creee :', listeX);
                    console.log('Quantite totale vendue :', totalQuantiteVendu);
                    res.json({ listeYSomme, listeY2Somme, listeY3Somme, listeX, totalQuantiteDeposee, totalQuantiteVendu, chargesFixes });
                });
            });
        });
    router.get('/retrait-liste/:email', async (req, res) => {
        console.log('Route /retrait-liste atteinte');
        const email_vendeur = req.params.email;
        console.log('Email vendeur reçu :', email_vendeur);

        try {
            // Verification du rôle de l'utilisateur
            const emailConnecte = req.session.email_connecte;
            console.log('Email connecte (session) :', emailConnecte);

            // Verifie le rôle recupere
            const userQuery = 'SELECT role FROM Users WHERE email = ?';
            const [user] = await query(userQuery, [emailConnecte]);
            console.log('Utilisateur trouve dans Users :', user);

            // Requête pour recuperer les jeux du vendeur avec l'ID et la quantite
            const sql = 'SELECT id_stock, nom_jeu, Prix_unit, Quantite_actuelle FROM Stock WHERE email_vendeur = ?';
            console.log('Requête SQL pour les jeux :', sql);

            let games = await query(sql, [email_vendeur]);
            console.log('Jeux recuperes :', games);

            // Duplication des jeux en fonction de Quantite_actuelle
            games = games.flatMap(game => {
                return Array.from({ length: game.Quantite_actuelle }, (_, index) => ({
                    ...game,
                    Quantite_actuelle: 1 // Fixer la quantite à 1 pour chaque copie
                }));
            });

            console.log('Jeux après duplication :', games);
            res.status(200).send(games);
        } catch (error) {
            console.error('Erreur lors de la recuperation des jeux:', error);
            res.status(500).send({ message: 'Erreur lors de la recuperation des jeux' });
        }
    });


    // Route pour traiter la requête de retrait
    router.post('/retrait', (req, res) => {
        const { id_stock, nombre_checkbox_selectionne_cet_id } = req.body;
        console.log("nbr check box selectionne:", nombre_checkbox_selectionne_cet_id);

        const selectQuery = 'SELECT Quantite_actuelle FROM Stock WHERE id_stock = ?';
        db.query(selectQuery, [id_stock], (err, results) => {
            if (err) {
                console.error('Erreur lors de la recuperation de la quantite actuelle :', err);
                return res.status(500).json({ message: 'Erreur de serveur' }); // Retourner une reponse JSON
            }

            const quantiteActuelle = results[0].Quantite_actuelle;

            if (nombre_checkbox_selectionne_cet_id === quantiteActuelle) {
                const deleteQuery = 'DELETE FROM Stock WHERE id_stock = ?';
                db.query(deleteQuery, [id_stock], (err) => {
                    if (err) {
                        console.error('Erreur lors de la suppression du jeu :', err);
                        return res.status(500).json({ message: 'Erreur de serveur' });
                    } else {
                        return res.status(200).json({ message: 'Jeu supprime avec succès' }); // Reponse JSON
                    }
                });
            } else if (nombre_checkbox_selectionne_cet_id < quantiteActuelle) {
                const updateQuery =
                    'UPDATE Stock SET Quantite_actuelle = Quantite_actuelle - ? WHERE id_stock = ?';
                db.query(updateQuery, [nombre_checkbox_selectionne_cet_id, id_stock], (err) => {
                    if (err) {
                        console.error('Erreur lors de la mise à jour de la quantite :', err);
                        return res.status(500).json({ message: 'Erreur de serveur' });
                    } else {
                        return res.status(200).json({ message: 'Quantite mise à jour avec succès' }); // Reponse JSON
                    }
                });
            } else {
                return res.status(400).json({ message: 'Quantite invalide' }); // Reponse JSON
            }
        });
    });
    
    router.post('/enregistrer-achat', (req, res) => {
      console.log("------------------E-achat----------------------------");
      const { id_stock, quantite_vendu } = req.body;
      console.log(id_stock, quantite_vendu);

      // Rechercher le jeu dans la table Stock
      const selectQuery = 'SELECT email_vendeur, nom_jeu, Prix_unit, photo_path, numero_session_actuelle, Quantite_actuelle FROM Stock WHERE id_stock = ?';
      db.query(selectQuery, [id_stock], (err, results) => {
        if (err) {
          return res.status(500).send('Erreur lors de la récupération du jeu');
        }

        if (results.length === 0) {
          return res.status(404).send('Jeu non trouvé');
        }

        const { email_vendeur, nom_jeu, Prix_unit, photo_path, numero_session_actuelle, Quantite_actuelle } = results[0];
        console.log(email_vendeur, nom_jeu, Prix_unit, photo_path, numero_session_actuelle);

        // Ajouter une ligne dans Historique_Vente
        const insertQuery = 'INSERT INTO Historique_Vente (email_vendeur, nom_jeu, Prix_unit, photo_path, numero_session_vente, Quantite_vendu, vendeur_paye) VALUES (?, ?, ?, ?, ?, ?, ?)';
        const vendeurPaye = false; // Changez cela selon votre logique
        db.query(insertQuery, [email_vendeur, nom_jeu, Prix_unit, photo_path, numero_session_actuelle, quantite_vendu, vendeurPaye], (err) => {
          if (err) {
            return res.status(500).send('Erreur lors de l’enregistrement de la vente');
          }
          console.log("achat enregistré");

          // Mise à jour ou suppression de la ligne dans Stock
          if (Quantite_actuelle === quantite_vendu) {
            // Supprimer la ligne si les quantités sont égales
            const deleteQuery = 'DELETE FROM Stock WHERE id_stock = ?';
            db.query(deleteQuery, [id_stock], (err) => {
              if (err) {
                return res.status(500).send('Erreur lors de la suppression du jeu');
              }
              console.log("Ligne supprimée de Stock");
              res.json({ message: 'Achat enregistré avec succès et jeu retiré du stock' });
            });
          } else {
            // Mettre à jour la quantité actuelle
            const nouvelleQuantite = Quantite_actuelle - quantite_vendu;
            const updateQuery = 'UPDATE Stock SET Quantite_actuelle = ? WHERE id_stock = ?';
            db.query(updateQuery, [nouvelleQuantite, id_stock], (err) => {
              if (err) {
                return res.status(500).send('Erreur lors de la mise à jour de la quantité');
              }
              console.log("Quantité mise à jour dans Stock");
              res.json({ message: 'Achat enregistré avec succès et quantité mise à jour' });
            });
          }
        });
      });
    });

    router.get('/historique-vente/:email', (req, res) => {
        const emailVendeur = req.params.email;
        const query = `
            SELECT
                nom_jeu,
                Quantite_vendu,
                Prix_unit,
                vendeur_paye,
                @somme_total := @somme_total + (CASE WHEN vendeur_paye = false THEN Prix_unit * Quantite_vendu ELSE 0 END) AS Somme_total_du
            FROM
                Historique_Vente, (SELECT @somme_total := 0) AS init
            WHERE
                email_vendeur = ?
            ORDER BY
                id_vente ASC; -- Assurez-vous d'avoir une colonne d'identifiant unique pour garantir l'ordre
        `;
        db.query(query, [emailVendeur], (err, results) => {
            if (err) {
                return res.status(500).json({ error: err.message });
            }
            res.json(results);
        });
    });




    router.post('/payer-vendeur-liste', (req, res) => {
        const emailVendeur = req.body.email; // Assurez-vous d'envoyer l'email dans le corps de la requête
        const updateQuery = 'UPDATE Historique_Vente SET vendeur_paye = TRUE WHERE email_vendeur = ?';

        db.query(updateQuery, [emailVendeur], (err) => {
            if (err) {
                return res.status(500).send('Erreur lors de la mise à jour du vendeur');
            }
            // Envoyez une réponse de succès
            res.send({ message: 'Vendeur payé mis à jour avec succès', refresh: true });
        });
    });

   
    router.get('/api/catalogue', (req, res) => {
        console.log("*** /catalogue ***");

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
        `;
        
    

        db.query(query, (err, results) => {
            if (err) {
                console.error('Erreur lors de la récupération du catalogue:', err);
                return res.status(500).json({ message: 'Erreur interne du serveur' });
            }
            res.status(200).json({results});
        });
    });
    router.get('/api/envente', (req, res) => {
        console.log("*** /catalogue ***");

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
        WHERE est_en_vente = 1
        `;
        
    

        db.query(query, (err, results) => {
            if (err) {
                console.error('Erreur lors de la récupération du catalogue:', err);
                return res.status(500).json({ message: 'Erreur interne du serveur' });
            }
            res.status(200).json({results});
        });
    });
    return router;
};

