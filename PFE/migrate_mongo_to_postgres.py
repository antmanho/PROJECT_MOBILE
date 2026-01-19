#!/usr/bin/env python3
"""
Script de migration MongoDB vers PostgreSQL
Migre toutes les données de compose-danse-prod (MongoDB) vers PostgreSQL
"""

import os
import sys
from pymongo import MongoClient
import psycopg2
from psycopg2.extras import execute_batch
from datetime import datetime
import json
import re

# Configuration MongoDB
# Connexion au serveur distant compose-danse.art
MONGO_URI_NO_AUTH = "mongodb://compose-danse.art:27017/compose-danse-prod"
MONGO_URI_WITH_AUTH = "mongodb://compose-danse-db-admin:PdJVthxbixNasXyT8gifKDV5UmXjXY@compose-danse.art:27017/compose-danse-prod?authSource=admin"
MONGO_DB = "compose-danse-prod"  # Base de production

# Configuration PostgreSQL
POSTGRES_URI = "postgresql://anthony@localhost:5432/compose_danse_dev_local"

# Fichiers de traductions i18n
TRANSLATIONS_EN_FILE = "v2/languages/en.json"
TRANSLATIONS_FR_FILE = "v2/languages/fr.json"

# Couleurs pour l'affichage
class Colors:
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'

def print_header(text):
    print(f"\n{Colors.HEADER}{Colors.BOLD}{'='*60}{Colors.ENDC}")
    print(f"{Colors.HEADER}{Colors.BOLD}{text}{Colors.ENDC}")
    print(f"{Colors.HEADER}{Colors.BOLD}{'='*60}{Colors.ENDC}\n")

def print_success(text):
    print(f"{Colors.GREEN}✓ {text}{Colors.ENDC}")

def print_info(text):
    print(f"{Colors.CYAN}ℹ {text}{Colors.ENDC}")

def print_warning(text):
    print(f"{Colors.WARNING}⚠ {text}{Colors.ENDC}")

def print_error(text):
    print(f"{Colors.FAIL}✗ {text}{Colors.ENDC}")

def convert_objectid_to_uuid(mongo_conn, pg_cursor, objectid_str):
    """Convertit un ObjectId MongoDB en UUID PostgreSQL en utilisant une table de mapping"""
    if not objectid_str:
        return None
    
    # Créer un UUID déterministe basé sur l'ObjectId
    # On utilise les 32 premiers caractères hexadécimaux
    hex_str = str(objectid_str)
    # Format UUID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    if len(hex_str) == 24:  # ObjectId MongoDB standard
        uuid_str = f"{hex_str[:8]}-{hex_str[8:12]}-{hex_str[12:16]}-{hex_str[16:20]}-{hex_str[20:24]}{'0'*8}"
        return uuid_str
    return None

def create_translation_json(text_fr, text_en=None):
    """Crée un objet JSON pour les traductions"""
    if isinstance(text_fr, dict):
        return json.dumps(text_fr)
    
    translation = {"fr": text_fr or ""}
    if text_en:
        translation["en"] = text_en
    else:
        translation["en"] = text_fr or ""
    
    return json.dumps(translation)

def migrate_users(mongo_db, pg_conn, pg_cursor):
    """Migre les utilisateurs"""
    print_header("Migration des utilisateurs")
    
    users = list(mongo_db.users.find())
    print_info(f"Trouvé {len(users)} utilisateurs dans MongoDB")
    
    user_mapping = {}
    migrated = 0
    skipped = 0
    
    for user in users:
        try:
            mongo_id = str(user['_id'])
            user_uuid = convert_objectid_to_uuid(mongo_db, pg_cursor, user['_id'])
            
            # Vérifier si l'utilisateur existe déjà
            pg_cursor.execute("""
                SELECT id FROM "User" WHERE email = %s
            """, (user.get('email', f'user_{mongo_id}@migrate.local'),))
            
            existing = pg_cursor.fetchone()
            if existing:
                user_mapping[mongo_id] = existing[0]
                skipped += 1
                continue
            
            pg_cursor.execute("""
                INSERT INTO "User" (
                    id, "isBlocked", email, "passwordHash", "resetPasswordToken",
                    firstname, lastname, "isAdmin", "isDummy", "createdAt", 
                    "updatedAt", username
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                ON CONFLICT (email) DO NOTHING
                RETURNING id
            """, (
                user_uuid,
                user.get('blocked', False),
                user.get('email', f'user_{mongo_id}@migrate.local'),
                user.get('passwordHash', ''),
                user.get('resetPasswordToken'),
                user.get('firstname'),
                user.get('lastname'),
                False,  # isAdmin
                False,  # isDummy
                user.get('createdAt', datetime.now()),
                datetime.now(),
                user.get('username', f'user_{mongo_id}')
            ))
            
            result = pg_cursor.fetchone()
            if result:
                user_mapping[mongo_id] = result[0]
                migrated += 1
            
            # Commit après chaque utilisateur pour éviter les erreurs de transaction
            pg_conn.commit()
                
        except Exception as e:
            print_error(f"Erreur lors de la migration de l'utilisateur {mongo_id}: {e}")
            pg_conn.rollback()
    
    if skipped > 0:
        print_info(f"{skipped} utilisateurs existants conservés")
    print_success(f"{migrated}/{len(users)} nouveaux utilisateurs migrés")
    return user_mapping

def migrate_quotes(mongo_db, pg_conn, pg_cursor):
    """Migre les citations avec traductions anglaises"""
    print_header("Migration des citations")
    
    quotes = list(mongo_db.quotes.find())
    print_info(f"Trouvé {len(quotes)} citations dans MongoDB")
    
    # Charger les traductions anglaises depuis le fichier i18n EN
    translations = {}
    if os.path.exists(TRANSLATIONS_EN_FILE):
        try:
            with open(TRANSLATIONS_EN_FILE, 'r', encoding='utf-8') as f:
                en_data = json.load(f)
                # Créer un mapping id -> text depuis le fichier EN
                if 'quotes' in en_data:
                    for quote in en_data['quotes']:
                        translations[quote['id']] = quote['text']
            print_info(f"Chargé {len(translations)} traductions anglaises depuis {TRANSLATIONS_EN_FILE}")
        except Exception as e:
            print_warning(f"Impossible de charger les traductions: {e}")
    
    # D'abord, supprimer les citations qui ne proviennent pas de MongoDB
    # (citations de test ou ajoutées manuellement)
    print_info("Nettoyage des citations existantes...")
    
    # Récupérer tous les IDS MongoDB convertis
    mongo_quote_ids = []
    for quote in quotes:
        quote_uuid = convert_objectid_to_uuid(mongo_db, pg_cursor, quote['_id'])
        mongo_quote_ids.append(quote_uuid)
    
    # Supprimer les citations qui ne sont pas dans la liste MongoDB
    if mongo_quote_ids:
        pg_cursor.execute("""
            DELETE FROM "Quote" 
            WHERE id NOT IN %s
        """, (tuple(mongo_quote_ids),))
        deleted = pg_cursor.rowcount
        if deleted > 0:
            print_warning(f"{deleted} citation(s) non-MongoDB supprimée(s)")
    
    migrated = 0
    updated = 0
    
    for quote in quotes:
        try:
            mongo_id = str(quote['_id'])
            quote_uuid = convert_objectid_to_uuid(mongo_db, pg_cursor, quote['_id'])
            
            # Créer l'objet de traduction
            text_fr = quote.get('text', '')
            # Utiliser la traduction depuis le fichier EN ou le français par défaut
            text_en = translations.get(quote_uuid, text_fr)
            
            text_json = json.dumps({
                "fr": text_fr,
                "en": text_en
            }, ensure_ascii=False)
            
            # Vérifier si la citation existe déjà
            pg_cursor.execute("""
                SELECT id FROM "Quote" WHERE id = %s
            """, (quote_uuid,))
            
            exists = pg_cursor.fetchone()
            
            if exists:
                # Mettre à jour si elle existe
                pg_cursor.execute("""
                    UPDATE "Quote" 
                    SET author = %s, text = %s, "updatedAt" = %s
                    WHERE id = %s
                """, (
                    quote.get('author', ''),
                    text_json,
                    datetime.now(),
                    quote_uuid
                ))
                updated += 1
            else:
                # Insérer si elle n'existe pas
                pg_cursor.execute("""
                    INSERT INTO "Quote" (id, author, text, "createdAt", "updatedAt")
                    VALUES (%s, %s, %s, %s, %s)
                """, (
                    quote_uuid,
                    quote.get('author', ''),
                    text_json,
                    datetime.now(),
                    datetime.now()
                ))
                migrated += 1
            
        except Exception as e:
            print_error(f"Erreur lors de la migration de la citation: {e}")
    
    pg_conn.commit()
    
    if updated > 0:
        print_info(f"{updated} citation(s) mise(s) à jour")
    print_success(f"{migrated}/{len(quotes)} nouvelles citations migrées")
    
    # Synchroniser avec les fichiers i18n
    sync_quotes_to_i18n(pg_cursor)

def sync_quotes_to_i18n(pg_cursor):
    """Synchronise les citations de PostgreSQL vers les fichiers i18n"""
    print_info("Synchronisation des citations vers les fichiers i18n...")
    
    try:
        # Récupérer toutes les citations
        pg_cursor.execute("""
            SELECT id, author, text->>'fr' as text_fr, text->>'en' as text_en
            FROM "Quote"
            ORDER BY author
        """)
        quotes = pg_cursor.fetchall()
        
        # Préparer les objets de traduction
        quotes_fr = []
        quotes_en = []
        
        for quote_id, author, text_fr, text_en in quotes:
            quotes_fr.append({
                "id": quote_id,
                "author": author,
                "text": text_fr
            })
            quotes_en.append({
                "id": quote_id,
                "author": author,
                "text": text_en
            })
        
        # Charger et mettre à jour le fichier FR
        if os.path.exists(TRANSLATIONS_FR_FILE):
            with open(TRANSLATIONS_FR_FILE, 'r', encoding='utf-8') as f:
                fr_data = json.load(f)
            fr_data['quotes'] = quotes_fr
            with open(TRANSLATIONS_FR_FILE, 'w', encoding='utf-8') as f:
                json.dump(fr_data, f, ensure_ascii=False, indent=2)
            print_success(f"Fichier {TRANSLATIONS_FR_FILE} mis à jour ({len(quotes_fr)} citations)")
        
        # Charger et mettre à jour le fichier EN
        if os.path.exists(TRANSLATIONS_EN_FILE):
            with open(TRANSLATIONS_EN_FILE, 'r', encoding='utf-8') as f:
                en_data = json.load(f)
            en_data['quotes'] = quotes_en
            with open(TRANSLATIONS_EN_FILE, 'w', encoding='utf-8') as f:
                json.dump(en_data, f, ensure_ascii=False, indent=2)
            print_success(f"Fichier {TRANSLATIONS_EN_FILE} mis à jour ({len(quotes_en)} citations)")
            
    except Exception as e:
        print_warning(f"Impossible de synchroniser les citations vers i18n: {e}")

def migrate_series(mongo_db, pg_conn, pg_cursor):
    """Migre les séries"""
    print_header("Migration des séries")
    
    series = list(mongo_db.series.find())
    print_info(f"Trouvé {len(series)} séries dans MongoDB")
    
    series_mapping = {}
    migrated = 0
    
    for serie in series:
        try:
            mongo_id = str(serie['_id'])
            serie_uuid = convert_objectid_to_uuid(mongo_db, pg_cursor, serie['_id'])
            
            name_json = create_translation_json(serie.get('name', ''))
            desc_json = create_translation_json(serie.get('description', ''))
            
            pg_cursor.execute("""
                INSERT INTO "Series" (id, name, description, "createdAt", "updatedAt")
                VALUES (%s, %s, %s, %s, %s)
                ON CONFLICT (id) DO NOTHING
                RETURNING id
            """, (
                serie_uuid,
                name_json,
                desc_json,
                datetime.now(),
                datetime.now()
            ))
            
            result = pg_cursor.fetchone()
            if result:
                series_mapping[mongo_id] = result[0]
                migrated += 1
                
        except Exception as e:
            print_error(f"Erreur lors de la migration de la série: {e}")
    
    pg_conn.commit()
    print_success(f"{migrated}/{len(series)} séries migrées")
    return series_mapping

def migrate_accessories(mongo_db, pg_conn, pg_cursor):
    """Migre les matériaux (accessories)"""
    print_header("Migration des accessoires/matériaux")
    
    materials = list(mongo_db.materials.find())
    print_info(f"Trouvé {len(materials)} matériaux dans MongoDB")
    
    accessory_mapping = {}
    migrated = 0
    
    for material in materials:
        try:
            mongo_id = str(material['_id'])
            accessory_uuid = convert_objectid_to_uuid(mongo_db, pg_cursor, material['_id'])
            
            name_json = create_translation_json(material.get('name', ''))
            
            pg_cursor.execute("""
                INSERT INTO "Accessory" (id, name, "createdAt", "updatedAt")
                VALUES (%s, %s, %s, %s)
                ON CONFLICT (id) DO NOTHING
                RETURNING id
            """, (
                accessory_uuid,
                name_json,
                datetime.now(),
                datetime.now()
            ))
            
            result = pg_cursor.fetchone()
            if result:
                accessory_mapping[mongo_id] = result[0]
                migrated += 1
                
        except Exception as e:
            print_error(f"Erreur lors de la migration du matériau: {e}")
    
    pg_conn.commit()
    print_success(f"{migrated}/{len(materials)} accessoires migrés")
    return accessory_mapping

def migrate_rooms(mongo_db, pg_conn, pg_cursor):
    """Migre les espaces (rooms)"""
    print_header("Migration des espaces")
    
    rooms = list(mongo_db.rooms.find())
    print_info(f"Trouvé {len(rooms)} espaces dans MongoDB")
    
    room_mapping = {}
    migrated = 0
    
    for room in rooms:
        try:
            mongo_id = str(room['_id'])
            room_uuid = convert_objectid_to_uuid(mongo_db, pg_cursor, room['_id'])
            
            name_json = create_translation_json(room.get('name', ''))
            
            pg_cursor.execute("""
                INSERT INTO "Room" (id, name, "createdAt", "updatedAt")
                VALUES (%s, %s, %s, %s)
                ON CONFLICT (id) DO NOTHING
                RETURNING id
            """, (
                room_uuid,
                name_json,
                datetime.now(),
                datetime.now()
            ))
            
            result = pg_cursor.fetchone()
            if result:
                room_mapping[mongo_id] = result[0]
                migrated += 1
                
                # Migrer les descriptions de room
                descriptions = room.get('descriptions', [])
                for desc in descriptions:
                    if desc.get('text'):
                        text_json = create_translation_json(desc.get('text', ''))
                        pg_cursor.execute("""
                            INSERT INTO "RoomText" (id, text, "createdAt", "updatedAt", "roomId")
                            VALUES (gen_random_uuid(), %s, %s, %s, %s)
                        """, (
                            text_json,
                            datetime.now(),
                            datetime.now(),
                            room_uuid
                        ))
                
        except Exception as e:
            print_error(f"Erreur lors de la migration de l'espace: {e}")
    
    pg_conn.commit()
    print_success(f"{migrated}/{len(rooms)} espaces migrés")
    return room_mapping

def migrate_authors(mongo_db, pg_conn, pg_cursor, user_mapping):
    """Migre les collaborateurs (authors)"""
    print_header("Migration des auteurs/collaborateurs")
    
    collaborators = list(mongo_db.collaborators.find())
    print_info(f"Trouvé {len(collaborators)} collaborateurs dans MongoDB")
    
    author_mapping = {}
    migrated = 0
    
    for collab in collaborators:
        try:
            mongo_id = str(collab['_id'])
            author_uuid = convert_objectid_to_uuid(mongo_db, pg_cursor, collab['_id'])
            
            # Trouver l'utilisateur associé
            user_mongo_id = str(collab.get('user', ''))
            user_id = user_mapping.get(user_mongo_id)
            
            if not user_id:
                # Créer un utilisateur dummy si nécessaire
                pg_cursor.execute("""
                    INSERT INTO "User" (
                        id, "isBlocked", email, "passwordHash", "isAdmin", "isDummy",
                        "createdAt", "updatedAt", username
                    ) VALUES (gen_random_uuid(), false, %s, '', false, true, %s, %s, %s)
                    RETURNING id
                """, (
                    f'author_{mongo_id}@migrate.local',
                    datetime.now(),
                    datetime.now(),
                    f'author_{mongo_id}'
                ))
                user_id = pg_cursor.fetchone()[0]
                user_mapping[user_mongo_id] = user_id
            
            pg_cursor.execute("""
                INSERT INTO "Author" (
                    id, bio, firstname, lastname, link, motivation, picture,
                    "createdAt", "updatedAt", "userId"
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                ON CONFLICT ("userId") DO UPDATE SET
                    bio = EXCLUDED.bio,
                    firstname = EXCLUDED.firstname,
                    lastname = EXCLUDED.lastname
                RETURNING id
            """, (
                author_uuid,
                collab.get('bio', ''),
                collab.get('firstname', ''),
                collab.get('lastname', ''),
                collab.get('link', ''),
                collab.get('motivation', ''),
                collab.get('picture', ''),
                datetime.now(),
                datetime.now(),
                user_id
            ))
            
            result = pg_cursor.fetchone()
            if result:
                author_mapping[mongo_id] = result[0]
                migrated += 1
                
        except Exception as e:
            print_error(f"Erreur lors de la migration du collaborateur: {e}")
    
    pg_conn.commit()
    print_success(f"{migrated}/{len(collaborators)} auteurs migrés")
    return author_mapping

def migrate_collaboration_requests(mongo_db, pg_conn, pg_cursor, user_mapping):
    """Migre les demandes de collaboration"""
    print_header("Migration des demandes de collaboration")
    
    requests = list(mongo_db.collaborationrequests.find())
    print_info(f"Trouvé {len(requests)} demandes dans MongoDB")
    
    migrated = 0
    
    for req in requests:
        try:
            req_uuid = convert_objectid_to_uuid(mongo_db, pg_cursor, req['_id'])
            user_mongo_id = str(req.get('user', ''))
            user_id = user_mapping.get(user_mongo_id)
            
            if not user_id:
                print_warning(f"Utilisateur {user_mongo_id} non trouvé pour la demande")
                continue
            
            pg_cursor.execute("""
                INSERT INTO "CollaborationRequest" (
                    id, firstname, lastname, motivation, validated,
                    "createdAt", "updatedAt", "userId"
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                ON CONFLICT ("userId") DO NOTHING
            """, (
                req_uuid,
                req.get('firstname', ''),
                req.get('lastname', ''),
                req.get('motivation', ''),
                req.get('validated', False),
                req.get('createdAt', datetime.now()),
                datetime.now(),
                user_id
            ))
            migrated += 1
            
        except Exception as e:
            print_error(f"Erreur lors de la migration de la demande: {e}")
    
    pg_conn.commit()
    print_success(f"{migrated}/{len(requests)} demandes de collaboration migrées")

def migrate_scenarios(mongo_db, pg_conn, pg_cursor, author_mapping, series_mapping, accessory_mapping, room_mapping):
    """Migre les recettes (scenarios)"""
    print_header("Migration des scénarios/recettes")
    
    recipes = list(mongo_db.recipes.find())
    print_info(f"Trouvé {len(recipes)} recettes dans MongoDB")
    
    scenario_mapping = {}
    migrated = 0
    
    for recipe in recipes:
        mongo_id = str(recipe['_id'])
        try:
            scenario_uuid = convert_objectid_to_uuid(mongo_db, pg_cursor, recipe['_id'])
            
            # Pour les scénarios, stocker directement les chaînes (uniquement en français)
            title_str = recipe.get('title', '')
            desc_str = recipe.get('description', '')
            statement_str = recipe.get('statement', '')
            inspiration_str = recipe.get('inspiration', '')
            audio_str = recipe.get('audio', '')
            
            # Convertir le tableau de nombres
            participant_numbers = recipe.get('number', [])
            if participant_numbers:
                # Convertir ['1', '2', '3_10'] en ['1', '2', '3-10']
                participant_numbers = [n.replace('_', '-') for n in participant_numbers]
            
            pg_cursor.execute("""
                INSERT INTO "Scenario" (
                    id, title, description, statement, inspiration, comment, audio,
                    draft, participants, "participantNumbers", validated, voice,
                    "publishedNumber", "submittedAt", "publishedAt",
                    "createdAt", "updatedAt"
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                ON CONFLICT (id) DO NOTHING
                RETURNING id
            """, (
                scenario_uuid,
                title_str,
                desc_str,
                statement_str,
                inspiration_str,
                recipe.get('comment', ''),
                audio_str,
                recipe.get('draft', False),
                recipe.get('participants', '') or '',  # Assurer qu'il n'est jamais NULL
                participant_numbers,
                recipe.get('validated', False),
                recipe.get('voice', '') or '',  # Assurer qu'il n'est jamais NULL
                recipe.get('publishedNumber', None),
                recipe.get('createdAt', datetime.now()) if not recipe.get('draft', False) else None,
                recipe.get('publishedAt', None),
                recipe.get('createdAt', datetime.now()),
                datetime.now()
            ))
            
            result = pg_cursor.fetchone()
            if result:
                scenario_mapping[mongo_id] = result[0]
                migrated += 1
                
                # Lier les auteurs
                for collab_id in recipe.get('collaborators', []):
                    collab_mongo_id = str(collab_id)
                    author_id = author_mapping.get(collab_mongo_id)
                    if author_id:
                        try:
                            pg_cursor.execute("""
                                INSERT INTO "_AuthorToScenario" ("A", "B")
                                VALUES (%s, %s)
                                ON CONFLICT DO NOTHING
                            """, (author_id, scenario_uuid))
                        except:
                            pass
                
                # Lier les séries
                for serie_id in recipe.get('series', []):
                    serie_mongo_id = str(serie_id)
                    series_id = series_mapping.get(serie_mongo_id)
                    if series_id:
                        try:
                            pg_cursor.execute("""
                                INSERT INTO "_ScenarioToSeries" ("A", "B")
                                VALUES (%s, %s)
                                ON CONFLICT DO NOTHING
                            """, (scenario_uuid, series_id))
                        except:
                            pass
                
                # Lier les accessoires
                for material_id in recipe.get('materials', []):
                    material_mongo_id = str(material_id)
                    accessory_id = accessory_mapping.get(material_mongo_id)
                    if accessory_id:
                        try:
                            pg_cursor.execute("""
                                INSERT INTO "_AccessoryToScenario" ("A", "B")
                                VALUES (%s, %s)
                                ON CONFLICT DO NOTHING
                            """, (accessory_id, scenario_uuid))
                        except:
                            pass
                
                # Lier les rooms
                for room_id in recipe.get('rooms', []):
                    room_mongo_id = str(room_id)
                    room_uuid_val = room_mapping.get(room_mongo_id)
                    if room_uuid_val:
                        try:
                            pg_cursor.execute("""
                                INSERT INTO "_RoomToScenario" ("A", "B")
                                VALUES (%s, %s)
                                ON CONFLICT DO NOTHING
                            """, (room_uuid_val, scenario_uuid))
                        except:
                            pass
                
                # Migrer les références
                for ref in recipe.get('references', []):
                    if isinstance(ref, dict):
                        try:
                            pg_cursor.execute("""
                                INSERT INTO "Reference" (id, "from", link, "createdAt", "updatedAt", "scenarioId")
                                VALUES (gen_random_uuid(), %s, %s, %s, %s, %s)
                            """, (
                                ref.get('title', ''),
                                ref.get('link', ''),
                                datetime.now(),
                                datetime.now(),
                                scenario_uuid
                            ))
                        except:
                            pass
            
            # Commit après chaque scénario pour éviter les erreurs de transaction
            pg_conn.commit()
                
        except Exception as e:
            print_error(f"Erreur lors de la migration du scénario {mongo_id}: {e}")
            pg_conn.rollback()
    
    print_success(f"{migrated}/{len(recipes)} scénarios migrés")
    return scenario_mapping

def migrate_comments(mongo_db, pg_conn, pg_cursor, user_mapping, scenario_mapping):
    """Migre les commentaires"""
    print_header("Migration des commentaires")
    
    comments = list(mongo_db.comments.find())
    print_info(f"Trouvé {len(comments)} commentaires dans MongoDB")
    
    migrated = 0
    
    for comment in comments:
        try:
            user_mongo_id = str(comment.get('user', ''))
            recipe_mongo_id = str(comment.get('recipe', ''))
            
            user_id = user_mapping.get(user_mongo_id)
            scenario_id = scenario_mapping.get(recipe_mongo_id)
            
            if not user_id or not scenario_id:
                continue
            
            pg_cursor.execute("""
                INSERT INTO "Comment" (
                    id, "userId", "scenarioId", text, "isPublic",
                    "createdAt", "updatedAt"
                ) VALUES (gen_random_uuid(), %s, %s, %s, %s, %s, %s)
            """, (
                user_id,
                scenario_id,
                comment.get('text', ''),
                comment.get('public', False),
                comment.get('createdAt', datetime.now()),
                datetime.now()
            ))
            migrated += 1
            
        except Exception as e:
            print_error(f"Erreur lors de la migration du commentaire: {e}")
    
    pg_conn.commit()
    print_success(f"{migrated}/{len(comments)} commentaires migrés")

def migrate_messages(mongo_db, pg_conn, pg_cursor):
    """Migre les messages"""
    print_header("Migration des messages")
    
    mails = list(mongo_db.mails.find())
    print_info(f"Trouvé {len(mails)} messages dans MongoDB")
    
    migrated = 0
    
    for mail in mails:
        try:
            pg_cursor.execute("""
                INSERT INTO "Message" (id, email, name, topic, message, "createdAt")
                VALUES (gen_random_uuid(), %s, %s, %s, %s, %s)
            """, (
                mail.get('email', ''),
                mail.get('name', ''),
                mail.get('sujet', ''),
                mail.get('message', ''),
                mail.get('createdAt', datetime.now())
            ))
            migrated += 1
            
        except Exception as e:
            print_error(f"Erreur lors de la migration du message: {e}")
    
    pg_conn.commit()
    print_success(f"{migrated}/{len(mails)} messages migrés")

def migrate_blog_posts(mongo_db, pg_conn, pg_cursor):
    """Migre les articles de blog"""
    print_header("Migration des articles de blog")
    
    posts = list(mongo_db.blogposts.find())
    print_info(f"Trouvé {len(posts)} articles dans MongoDB")
    
    migrated = 0
    
    for post in posts:
        try:
            pg_cursor.execute("""
                INSERT INTO "BlogPost" (id, title, preview, text, "createdAt", "updatedAt")
                VALUES (gen_random_uuid(), %s, %s, %s, %s, %s)
            """, (
                post.get('title', ''),
                post.get('preview', ''),
                post.get('text', ''),
                post.get('createdAt', datetime.now()),
                datetime.now()
            ))
            migrated += 1
            
        except Exception as e:
            print_error(f"Erreur lors de la migration de l'article: {e}")
    
    pg_conn.commit()
    print_success(f"{migrated}/{len(posts)} articles de blog migrés")

def migrate_videos(mongo_db, pg_conn, pg_cursor):
    """Migre les vidéos"""
    print_header("Migration des vidéos")
    
    videos = list(mongo_db.hotvideos.find())
    print_info(f"Trouvé {len(videos)} vidéos dans MongoDB")
    
    migrated = 0
    
    for video in videos:
        try:
            pg_cursor.execute("""
                INSERT INTO "Video" (id, title, "youtubeLink", "createdAt", "updatedAt")
                VALUES (gen_random_uuid(), %s, %s, %s, %s)
            """, (
                video.get('title', ''),
                video.get('youtube_link', ''),
                datetime.now(),
                datetime.now()
            ))
            migrated += 1
            
        except Exception as e:
            print_error(f"Erreur lors de la migration de la vidéo: {e}")
    
    pg_conn.commit()
    print_success(f"{migrated}/{len(videos)} vidéos migrées")

def migrate_scans(mongo_db, pg_conn, pg_cursor, scenario_mapping):
    """Migre les scans"""
    print_header("Migration des scans")
    
    scans = list(mongo_db.scans.find())
    print_info(f"Trouvé {len(scans)} scans dans MongoDB")
    
    migrated = 0
    
    for scan in scans:
        try:
            recipe_mongo_id = str(scan.get('recipe', ''))
            scenario_id = scenario_mapping.get(recipe_mongo_id)
            
            if not scenario_id:
                continue
            
            pg_cursor.execute("""
                INSERT INTO "Scan" (id, "scenarioId", "createdAt")
                VALUES (gen_random_uuid(), %s, %s)
            """, (
                scenario_id,
                scan.get('createdAt', datetime.now())
            ))
            migrated += 1
            
        except Exception as e:
            print_error(f"Erreur lors de la migration du scan: {e}")
    
    pg_conn.commit()
    print_success(f"{migrated}/{len(scans)} scans migrés")

def main():
    print_header("MIGRATION MONGODB → POSTGRESQL")
    print_info("Connexion à MongoDB...")
    
    try:
        # Essayer d'abord avec authentification pour le serveur distant
        try:
            mongo_client = MongoClient(MONGO_URI_WITH_AUTH, serverSelectionTimeoutMS=5000)
            mongo_client.server_info()
            print_success("Connecté à MongoDB (avec authentification)")
        except:
            # Si ça échoue, essayer sans authentification
            print_info("Essai sans authentification...")
            mongo_client = MongoClient(MONGO_URI_NO_AUTH)
            mongo_client.server_info()
            print_success("Connecté à MongoDB (sans authentification)")
        
        mongo_db = mongo_client[MONGO_DB]
        
    except Exception as e:
        print_error(f"Impossible de se connecter à MongoDB: {e}")
        sys.exit(1)
    
    print_info("Connexion à PostgreSQL...")
    
    try:
        # Connexion à PostgreSQL
        pg_conn = psycopg2.connect(POSTGRES_URI)
        pg_cursor = pg_conn.cursor()
        
        # Test de connexion
        pg_cursor.execute("SELECT version();")
        print_success("Connecté à PostgreSQL")
        
    except Exception as e:
        print_error(f"Impossible de se connecter à PostgreSQL: {e}")
        sys.exit(1)
    
    try:
        # Migration dans l'ordre des dépendances
        user_mapping = migrate_users(mongo_db, pg_conn, pg_cursor)
        
        migrate_quotes(mongo_db, pg_conn, pg_cursor)
        
        series_mapping = migrate_series(mongo_db, pg_conn, pg_cursor)
        accessory_mapping = migrate_accessories(mongo_db, pg_conn, pg_cursor)
        room_mapping = migrate_rooms(mongo_db, pg_conn, pg_cursor)
        
        author_mapping = migrate_authors(mongo_db, pg_conn, pg_cursor, user_mapping)
        
        migrate_collaboration_requests(mongo_db, pg_conn, pg_cursor, user_mapping)
        
        scenario_mapping = migrate_scenarios(
            mongo_db, pg_conn, pg_cursor,
            author_mapping, series_mapping, accessory_mapping, room_mapping
        )
        
        migrate_comments(mongo_db, pg_conn, pg_cursor, user_mapping, scenario_mapping)
        
        migrate_messages(mongo_db, pg_conn, pg_cursor)
        migrate_blog_posts(mongo_db, pg_conn, pg_cursor)
        migrate_videos(mongo_db, pg_conn, pg_cursor)
        
        migrate_scans(mongo_db, pg_conn, pg_cursor, scenario_mapping)
        
        print_header("MIGRATION TERMINÉE AVEC SUCCÈS !")
        
    except Exception as e:
        print_error(f"Erreur pendant la migration: {e}")
        import traceback
        traceback.print_exc()
        pg_conn.rollback()
        sys.exit(1)
        
    finally:
        pg_cursor.close()
        pg_conn.close()
        mongo_client.close()
        print_info("Connexions fermées")

if __name__ == "__main__":
    main()
