import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:logger/logger.dart';

// Waybill Data for Incoming Shipments
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

// Worksheet Data for Worksheet OCR
class WorksheetOCRData {
  final String? worksheetNumber;
  final String? jobName;
  final String? component;
  final String? quantity;
  final String? description;
  final String? status;
  final String? priority;
  final String? assignedTo;
  final String? dueDate;
  final String rawText;

  WorksheetOCRData({
    this.worksheetNumber,
    this.jobName,
    this.component,
    this.quantity,
    this.description,
    this.status,
    this.priority,
    this.assignedTo,
    this.dueDate,
    required this.rawText,
  });

  @override
  String toString() {
    return 'WorksheetOCRData(worksheetNumber: $worksheetNumber, jobName: $jobName, component: $component, quantity: $quantity)';
  }

  Map<String, dynamic> toMap() {
    return {
      'worksheetNumber': worksheetNumber,
      'jobName': jobName,
      'component': component,
      'quantity': quantity,
      'description': description,
      'status': status,
      'priority': priority,
      'assignedTo': assignedTo,
      'dueDate': dueDate,
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
    final bolRegex = RegExp(
        r'(?:BILL OF LADING NO\.|WAYBILL|SHIPMENT #|TRACKING NO\.?|PRO NO\.?)\s*[:#-]?\s*([A-Z0-9]+)',
        caseSensitive: false);
    final bolMatch = bolRegex.firstMatch(fullText);
    if (bolMatch != null && bolMatch.groupCount >= 1) {
      shipmentNumber = bolMatch.group(1);
    }

    // 2. Try to find Date
    final dateRegex = RegExp(
        r'\b(?:\d{1,2}[-/]\d{1,2}[-/]\d{2,4}|\b(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]* \d{1,2},? \d{4})\b',
        caseSensitive: false);
    final dateMatch = dateRegex.firstMatch(fullText);
    if (dateMatch != null) {
      date = dateMatch.group(0);
    }

    // 3. Try to find Weight
    final weightRegex = RegExp(
        r'(?:TOTAL WEIGHT|WEIGHT)\s*[:#-]?\s*([\d\.,]+\s*(?:LBS|KG|KGS))',
        caseSensitive: false);
    final weightMatch = weightRegex.firstMatch(fullText);
    if (weightMatch != null && weightMatch.groupCount >= 1) {
      weight = weightMatch.group(1);
    }

    // 4. Try to find Shipper/Consignor and Consignee
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].toUpperCase();

      // Look for Shipper
      if (senderName == null &&
          (line.contains('SHIPPER') || line.contains('CONSIGNOR'))) {
        // Assume the next non-empty line might be the name
        int j = i + 1;
        while (j < lines.length && j < i + 4) {
          // Look ahead up to 3 lines
          String nextLine = lines[j].trim();
          if (nextLine.isNotEmpty &&
              !nextLine.toUpperCase().contains('NAME') &&
              !nextLine.toUpperCase().contains('ADDRESS')) {
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
          if (nextLine.isNotEmpty &&
              !nextLine.toUpperCase().contains('NAME') &&
              !nextLine.toUpperCase().contains('ADDRESS')) {
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

  Future<WorksheetOCRData?> processWorksheetImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      String rawText = recognizedText.text;
      _logger.i('Extracted Worksheet OCR Text length: ${rawText.length}');

      return _parseWorksheetText(recognizedText);
    } catch (e) {
      _logger.e('Error processing worksheet image for OCR: $e');
      return null;
    }
  }

  WorksheetOCRData _parseWorksheetText(RecognizedText recognizedText) {
    String? worksheetNumber;
    String? jobName;
    String? component;
    String? quantity;
    String? description;
    String? status;
    String? priority;
    String? assignedTo;
    String? dueDate;

    // Simple line-by-line heuristic parsing based on typical worksheet structures
    List<String> lines = recognizedText.blocks
        .expand((block) => block.lines)
        .map((line) => line.text)
        .toList();

    String fullText = recognizedText.text;

    // 1. Try to find Worksheet Number
    final worksheetRegex = RegExp(
        r'(?:WORKSHEET|JOB SHEET|SHEET|WS|JOB #)\s*[:#-]?\s*([A-Z0-9\-]+)',
        caseSensitive: false);
    final worksheetMatch = worksheetRegex.firstMatch(fullText);
    if (worksheetMatch != null && worksheetMatch.groupCount >= 1) {
      worksheetNumber = worksheetMatch.group(1);
    }

    // 2. Try to find Job Name
    final jobRegex = RegExp(
        r'(?:JOB NAME|PROJECT|JOB TITLE)\s*[:#-]?\s*([^\n]+)',
        caseSensitive: false);
    final jobMatch = jobRegex.firstMatch(fullText);
    if (jobMatch != null && jobMatch.groupCount >= 1) {
      jobName = jobMatch.group(1)?.trim();
    }

    // 3. Try to find Component
    final componentRegex = RegExp(
        r'(?:COMPONENT|PART|ITEM)\s*[:#-]?\s*([^\n]+)',
        caseSensitive: false);
    final componentMatch = componentRegex.firstMatch(fullText);
    if (componentMatch != null && componentMatch.groupCount >= 1) {
      component = componentMatch.group(1)?.trim();
    }

    // 4. Try to find Quantity
    final quantityRegex = RegExp(r'(?:QTY|QUANTITY|COUNT)\s*[:#-]?\s*(\d+)',
        caseSensitive: false);
    final quantityMatch = quantityRegex.firstMatch(fullText);
    if (quantityMatch != null && quantityMatch.groupCount >= 1) {
      quantity = quantityMatch.group(1);
    }

    // 5. Try to find Description
    final descRegex = RegExp(
        r'(?:DESCRIPTION|DETAILS|NOTES)\s*[:#-]?\s*([^\n]+)',
        caseSensitive: false);
    final descMatch = descRegex.firstMatch(fullText);
    if (descMatch != null && descMatch.groupCount >= 1) {
      description = descMatch.group(1)?.trim();
    }

    // 6. Try to find Status
    final statusRegex =
        RegExp(r'(?:STATUS|STATE)\s*[:#-]?\s*([^\n]+)', caseSensitive: false);
    final statusMatch = statusRegex.firstMatch(fullText);
    if (statusMatch != null && statusMatch.groupCount >= 1) {
      status = statusMatch.group(1)?.trim();
    }

    // 7. Try to find Priority
    final priorityRegex = RegExp(r'(?:PRIORITY|URGENCY)\s*[:#-]?\s*([^\n]+)',
        caseSensitive: false);
    final priorityMatch = priorityRegex.firstMatch(fullText);
    if (priorityMatch != null && priorityMatch.groupCount >= 1) {
      priority = priorityMatch.group(1)?.trim();
    }

    // 8. Try to find Assigned To
    final assignedRegex = RegExp(
        r'(?:ASSIGNED|ASSIGNED TO|OPERATOR)\s*[:#-]?\s*([^\n]+)',
        caseSensitive: false);
    final assignedMatch = assignedRegex.firstMatch(fullText);
    if (assignedMatch != null && assignedMatch.groupCount >= 1) {
      assignedTo = assignedMatch.group(1)?.trim();
    }

    // 9. Try to find Due Date
    final dateRegex = RegExp(
        r'(?:DUE DATE|DEADLINE|DATE DUE)\s*[:#-]?\s*([^\n]+)',
        caseSensitive: false);
    final dateMatch = dateRegex.firstMatch(fullText);
    if (dateMatch != null && dateMatch.groupCount >= 1) {
      dueDate = dateMatch.group(1)?.trim();
    }

    // Alternative parsing: Look for patterns like "Worksheet: WS-123" without labels
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();

      // Try to extract worksheet number from lines containing "WS" or "Worksheet"
      if (worksheetNumber == null &&
          (line.contains('WS') || line.contains('Worksheet'))) {
        final wsMatch = RegExp(r'(?:WS|Worksheet)?\s*[:#-]?\s*([A-Z0-9\-]+)',
                caseSensitive: false)
            .firstMatch(line);
        if (wsMatch != null && wsMatch.groupCount >= 1) {
          final extracted = wsMatch.group(1);
          if (extracted != null && extracted.length > 2) {
            worksheetNumber = extracted;
          }
        }
      }
    }

    return WorksheetOCRData(
      worksheetNumber: worksheetNumber,
      jobName: jobName,
      component: component,
      quantity: quantity,
      description: description,
      status: status,
      priority: priority,
      assignedTo: assignedTo,
      dueDate: dueDate,
      rawText: fullText,
    );
  }

  void dispose() {
    _textRecognizer.close();
  }
}
