import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:intl/intl.dart';

class OcrResult {
  final bool success;
  final String? extractedText;
  final String? errorMessage;
  final String structuredReport;
  final Map<String, String> data;

  OcrResult({
    required this.success,
    this.extractedText,
    this.errorMessage,
    required this.structuredReport,
    this.data = const {},
  });
}

class OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<OcrResult> processDocument({
    required File imageFile,
    required String docType,
    required String userFirstName,
    required String userLastName,
    String? expectedSpecialty,
  }) async {
    final InputImage inputImage = InputImage.fromFile(imageFile);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
    final String text = recognizedText.text;
    final String lowerText = text.toLowerCase();

    // 1. Vérification d'identité
    bool firstNameMatch = lowerText.contains(userFirstName.toLowerCase());
    bool lastNameMatch = lowerText.contains(userLastName.toLowerCase());
    
    List<String> errors = [];
    if (!firstNameMatch) errors.add("Prénom '$userFirstName' non détecté");
    if (!lastNameMatch) errors.add("Nom '$userLastName' non détecté");

    String report = "📋 RAPPORT D'ANALYSE OCR\n";
    report += "--------------------------\n";
    report += "👤 IDENTITÉ : ${firstNameMatch && lastNameMatch ? '✅ MATCH COMPLET' : firstNameMatch || lastNameMatch ? '⚠️ MATCH PARTIEL' : '❌ NON DÉTECTÉE'}\n";
    report += "   Nom attendu : $userLastName\n";
    report += "   Prénom attendu : $userFirstName\n\n";

    OcrResult typeResult;
    String docNameLabel = "";
    
    switch (docType) {
      case 'CNI_FRONT':
        docNameLabel = "CARTE D'IDENTITÉ (RECTO)";
        typeResult = _verifyCNIFront(lowerText);
        break;
      case 'CNI_BACK':
        docNameLabel = "CARTE D'IDENTITÉ (VERSO)";
        typeResult = _verifyCNIBack(lowerText);
        break;
      case 'DIPLOMA':
        docNameLabel = "DIPLÔME";
        typeResult = _verifyDiploma(lowerText, expectedSpecialty);
        break;
      case 'AUTHORIZATION':
        docNameLabel = "AUTORISATION D'EXERCER";
        typeResult = _verifyAuthorization(lowerText);
        break;
      case 'VEHICLE_REGISTRATION':
        docNameLabel = "CARTE GRISE";
        typeResult = _verifyVehicleRegistration(lowerText);
        break;
      case 'TRANSPORT_AUTHORIZATION':
        docNameLabel = "AUTORISATION DE TRANSPORT";
        typeResult = _verifyTransportAuth(lowerText);
        break;
      default:
        docNameLabel = "DOCUMENT COMPLÉMENTAIRE";
        typeResult = OcrResult(success: true, structuredReport: '', extractedText: text);
    }

    report += "🪪 TYPE : $docNameLabel\n";
    if (typeResult.errorMessage != null) {
      errors.add(typeResult.errorMessage!);
    }

    if (docType == 'CNI_FRONT' && typeResult.data.containsKey('cin')) {
      report += "   Numéro CIN : ${typeResult.data['cin']}\n";
    }
    
    if (docType == 'DIPLOMA') {
      report += "   Spécialité : ${expectedSpecialty ?? 'N/A'}\n";
      report += "   Vérif. Spécialité : ${typeResult.success ? '✅ TROUVÉE' : '❌ NON TROUVÉE'}\n";
    }

    report += "\n🔍 TEXTE BRUT EXTRAIT :\n$text";

    bool finalSuccess = firstNameMatch && lastNameMatch && typeResult.success;

    return OcrResult(
      success: finalSuccess,
      errorMessage: errors.isNotEmpty ? errors.join(", ") : null,
      structuredReport: report,
      extractedText: text,
      data: {...typeResult.data, 'firstNameMatch': firstNameMatch.toString(), 'lastNameMatch': lastNameMatch.toString()},
    );
  }

  OcrResult _verifyCNIFront(String text) {
    bool isCni = text.contains('carte nationale') || text.contains('royaume du maroc') || text.contains('identity card');
    RegExp cinRegex = RegExp(r'[a-z]{1,2}\s?\d{5,7}');
    String? cin = cinRegex.stringMatch(text);
    
    if (!isCni) return OcrResult(success: false, errorMessage: "Le document ne semble pas être une Carte d'Identité (Recto)", structuredReport: "");
    return OcrResult(
      success: true, 
      structuredReport: '', 
      data: {'cin': cin?.toUpperCase() ?? 'Non détecté'}
    );
  }

  OcrResult _verifyCNIBack(String text) {
    // Le verso contient souvent des zones MRZ ou des infos d'adresse
    bool isCniBack = text.contains('adresse') || text.contains('<<') || text.contains('naissance');
    if (!isCniBack) return OcrResult(success: false, errorMessage: "Le document ne semble pas être le Verso de la CNI", structuredReport: "");
    return OcrResult(success: true, structuredReport: "");
  }

  OcrResult _verifyDiploma(String text, String? specialty) {
    bool isDiploma = text.contains('diplôme') || text.contains('diplome') || text.contains('attestation') || text.contains('certificat') || text.contains('universit');
    if (!isDiploma) return OcrResult(success: false, errorMessage: "Le document ne semble pas être un Diplôme", structuredReport: "");
    
    bool hasSpecialty = specialty == null || text.contains(specialty.toLowerCase());
    if (!hasSpecialty) return OcrResult(success: false, errorMessage: "La spécialité '$specialty' n'a pas été trouvée sur le diplôme", structuredReport: "");
    
    return OcrResult(success: true, structuredReport: '');
  }

  OcrResult _verifyAuthorization(String text) {
    bool hasAuth = text.contains('autorisation') || text.contains('autorise') || text.contains('decision') || text.contains('ordre');
    if (!hasAuth) return OcrResult(success: false, errorMessage: "Le document ne semble pas être une Autorisation d'Exercer", structuredReport: "");
    return OcrResult(success: true, structuredReport: '');
  }

  OcrResult _verifyVehicleRegistration(String text) {
    bool isGrayCard = text.contains('carte grise') || text.contains('certificat d\'immatriculation') || text.contains('maroc');
    if (!isGrayCard) return OcrResult(success: false, errorMessage: "Le document ne semble pas être une Carte Grise", structuredReport: "");
    return OcrResult(success: true, structuredReport: '');
  }

  OcrResult _verifyTransportAuth(String text) {
    bool isTransportAuth = text.contains('transport') || text.contains('marchandises') || text.contains('sanitaire');
    if (!isTransportAuth) return OcrResult(success: false, errorMessage: "Le document ne semble pas être une Autorisation de Transport", structuredReport: "");
    return OcrResult(success: true, structuredReport: '');
  }

  void dispose() {
    _textRecognizer.close();
  }
}

final ocrService = OcrService();
