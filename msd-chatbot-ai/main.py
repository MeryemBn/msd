import os
import json
import logging
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from google import genai
from dotenv import load_dotenv

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

load_dotenv(override=True)

app = FastAPI(title="MSD Chatbot AI Service")

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
client = genai.Client(api_key=GEMINI_API_KEY)

# Modèle spécifié par l'utilisateur
MODEL_NAME = "models/gemini-3.1-flash-lite"

try:
    with open('knowledge_base.json', 'r', encoding='utf-8') as f:
        kb = json.load(f)
except Exception as e:
    logger.error(f"Erreur KB: {e}")
    kb = {"features": [], "medical_disclaimer": ""}

class ChatRequest(BaseModel):
    message: str
    language: str = "fr"

@app.post("/chat")
async def chat(request: ChatRequest):
    logger.info(f"Requête: {request.message}")

    features_list = "\n".join([f"- {f['intent']}: {f['response']} (Route: {f['route']})" for f in kb['features']])

    system_prompt = (
        f"Tu es l'assistant médical intelligent officiel de l'application MSD (Medical Service Delivery).\n"
        f"Ton rôle est double : fournir une assistance médicale de premier niveau et guider l'utilisateur techniquement dans l'application.\n\n"

        f"--- CONSIGNES MÉDICALES (ESSENTIEL) ---\n"
        f"Si l'utilisateur décrit des symptômes ou une douleur :\n"
        f"1. ANALYSE : Identifie la pathologie probable (ex: migraine, gastro-entérite, grippe).\n"
        f"2. CONSEIL : Propose des solutions simples pour calmer la douleur (ex: Doliprane 1g, hydratation, repos).\n"
        f"3. ORIENTATION : Suggère impérativement la spécialité médicale appropriée (ex: Gastro-entérologue, Cardiologue, Généraliste).\n"
        f"4. ACTION MSD : Rappelle-lui qu'il peut demander une consultation à domicile ou une téléconsultation immédiatement via l'écran d'Accueil.\n\n"

        f"--- MANUEL DE L'APPLICATION MSD (TECHNIQUE) ---\n"
        f"{features_list}\n\n"

        f"--- RÈGLES DE RÉPONSE ---\n"
        f"- LANGUE : Réponds toujours en {request.language.upper()}.\n"
        f"- STYLE : Chaleureux, empathique et rassurant. Utilise des paragraphes et du gras (**texte**).\n"
        f"- TECHNIQUE : Utilise strictement le manuel pour les questions sur le mode sombre, le paiement, le suivi GPS, ou le planning des médicaments.\n"
        f"- DISCLAIMER : NE PAS ajouter de clause de non-responsabilité à la fin, elle est déjà gérée par l'interface.\n\n"

        f"FORMAT DE RÉPONSE (JSON UNIQUEMENT) :\n"
        f"{{\"text\": \"ton message formaté en Markdown\", \"route\": \"/chemin_si_besoin\"}}"
    )

    try:
        response = client.models.generate_content(
            model=MODEL_NAME,
            config=genai.types.GenerateContentConfig(
                system_instruction=system_prompt,
                response_mime_type="application/json"
            ),
            contents=request.message
        )

        return json.loads(response.text)
    except Exception as e:
        logger.error(f"Erreur: {e}")
        return {
            "text": "Désolé, je rencontre une petite difficulté technique. Veuillez réessayer.",
            "route": None
        }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
