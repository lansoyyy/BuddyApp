import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:logger/logger.dart';

class WaybillData {
  final String? shipmentNumber;
  final String? senderName;
  final String? consigneeName;
  final String? date;
  final String? weight;
  final String rawText;

  WaybillData({
    this.shipmentNumber,
    this.senderName,
    this.consigneeName,
    this.date,
    this.weight,
    required this.rawText,
  });

  @override
  String toString() {
    return 'WaybillData(shipmentNumber: $shipmentNumber, senderName: $senderName, consigneeName: $consigneeName, date: $date, weight: $weight)';
  }

  Map<String, dynamic> toMap() {
    return {
      'shipmentNumber': shipmentNumber,
      'senderName': senderName,
      'consigneeName': consigneeName,
      'date': date,
      'weight': weight,
      'rawText': rawText,
    };
  }
}

class OcrService {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final _logger = Logger();

  static OcrService? _instance;
  
  OcrService._();

  static OcrService get instance {
    _instance ??= OcrService._();
    return _instance!;
  }

  Future<WaybillData?> processWaybillImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      String rawText = recognizedText.text;
      _logger.i('Extracted OCR Text length: ${rawText.length}');
      
      return _parseWaybillText(recognizedText);
    } catch (e) {
      _logger.e('Error processing image for OCR: $e');
      return null;
    }
  }

  WaybillData _parseWaybillText(RecognizedText recognizedText) {
    String? shipmentNumber;
    String? senderName;
    String? consigneeName;
    String? date;
    String? weight;
    
    // Simple line-by-line heuristic parsing based on typical waybill structures
    List<String> lines = recognizedText.blocks
        .expand((block) => block.lines)
        .map((line) => line.text)
        .toList();

    String fullText = recognizedText.text;

    // 1. Try to find Shipment / Bill of Lading Number
    final bolRegex = RegExp(r'(?:BILL OF LADING NO\.|WAYBILL|SHIPMENT #|TRACKING NO\.?|PRO NO\.?)\s*[:#-]?\s*([A-Z0-9]+)', caseSensitive: false);
    final bolMatch = bolRegex.firstMatch(fullText);
    if (bolMatch != null && bolMatch.groupCount >= 1) {
      shipmentNumber = bolMatch.group(1);
    }

    // 2. Try to find Date
    final dateRegex = RegExp(r'\b(?:\d{1,2}[-/]\d{1,2}[-/]\d{2,4}|\b(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]* \d{1,2},? \d{4})\b', caseSensitive: false);
    final dateMatch = dateRegex.firstMatch(fullText);
    if (dateMatch != null) {
      date = dateMatch.group(0);
    }

    // 3. Try to find Weight
    final weightRegex = RegExp(r'(?:TOTAL WEIGHT|WEIGHT)\s*[:#-]?\s*([\d\.,]+\s*(?:LBS|KG|KGS))', caseSensitive: false);
    final weightMatch = weightRegex.firstMatch(fullText);
    if (weightMatch != null && weightMatch.groupCount >= 1) {
      weight = weightMatch.group(1);
    }

    // 4. Try to find Shipper/Consignor and Consignee
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].toUpperCase();
      
      // Look for Shipper
      if (senderName == null && (line.contains('SHIPPER') || line.contains('CONSIGNOR'))) {
        // Assume the next non-empty line might be the name
        int j = i + 1;
        while (j < lines.length && j < i + 4) { // Look ahead up to 3 lines
          String nextLine = lines[j].trim();
          if (nextLine.isNotEmpty && !nextLine.toUpperCase().contains('NAME') && !nextLine.toUpperCase().contains('ADDRESS')) {
            senderName = nextLine;
            break;
          }
          j++;
        }
      }

      // Look for Consignee
      if (consigneeName == null && line.contains('CONSIGNEE')) {
        int j = i + 1;
        while (j < lines.length && j < i + 4) {
          String nextLine = lines[j].trim();
          if (nextLine.isNotEmpty && !nextLine.toUpperCase().contains('NAME') && !nextLine.toUpperCase().contains('ADDRESS')) {
            consigneeName = nextLine;
            break;
          }
          j++;
        }
      }
    }

    return WaybillData(
      shipmentNumber: shipmentNumber,
      senderName: senderName,
      consigneeName: consigneeName,
      date: date,
      weight: weight,
      rawText: fullText,
    );
  }

  void dispose() {
    _textRecognizer.close();
  }
}
