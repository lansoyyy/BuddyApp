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

  static const List<String> _shipmentLabels = <String>[
    'bill of lading no',
    'bill of lading',
    'waybill no',
    'waybill number',
    'waybill',
    'shipment no',
    'shipment number',
    'shipment #',
    'tracking no',
    'tracking number',
    'tracking #',
    'awb no',
    'awb',
    'pro no',
    'pro number',
  ];

  static const List<String> _senderLabels = <String>[
    'shipper',
    'shipper name',
    'consignor',
    'sender',
    'from',
  ];

  static const List<String> _consigneeLabels = <String>[
    'consignee',
    'consignee name',
    'receiver',
    'recipient',
    'deliver to',
    'to',
  ];

  static const List<String> _dateLabels = <String>[
    'date',
    'ship date',
    'pickup date',
    'delivery date',
  ];

  static const List<String> _weightLabels = <String>[
    'total weight',
    'gross weight',
    'net weight',
    'weight',
  ];

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

      if (rawText.trim().isEmpty) {
        return null;
      }

      return _parseWaybillText(recognizedText);
    } catch (e) {
      _logger.e('Error processing image for OCR: $e');
      return null;
    }
  }

  WaybillData _parseWaybillText(RecognizedText recognizedText) {
    final lines = recognizedText.blocks
        .expand((block) => block.lines)
        .map((line) => _normalizeLine(line.text))
        .where((line) => line.isNotEmpty)
        .toList();

    final fullText = lines.join('\n');

    final shipmentNumber = _extractShipmentNumber(lines, fullText);
    final senderName = _extractLabeledValue(lines, _senderLabels);
    final consigneeName = _extractLabeledValue(lines, _consigneeLabels);
    final date = _extractDate(lines, fullText);
    final weight = _extractWeight(lines, fullText);

    return WaybillData(
      shipmentNumber: shipmentNumber,
      senderName: senderName,
      consigneeName: consigneeName,
      date: date,
      weight: weight,
      rawText: fullText,
    );
  }

  String _normalizeLine(String text) {
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String? _extractShipmentNumber(List<String> lines, String fullText) {
    final bolRegex = RegExp(
      r'(?:bill of lading no\.?|bill of lading|waybill no\.?|waybill number|waybill|shipment no\.?|shipment number|shipment #|tracking no\.?|tracking number|tracking #|awb no\.?|awb|pro no\.?)\s*[:#-]?\s*([A-Z0-9\-/]{5,})',
      caseSensitive: false,
    );
    final bolMatch = bolRegex.firstMatch(fullText);
    if (bolMatch != null) {
      return _cleanCandidate(bolMatch.group(1));
    }

    final labeled = _extractLabeledValue(lines, _shipmentLabels);
    if (labeled != null) {
      final candidate = RegExp(r'[A-Z0-9][A-Z0-9\-/]{4,}', caseSensitive: false)
          .firstMatch(labeled);
      if (candidate != null) {
        return _cleanCandidate(candidate.group(0));
      }
    }

    for (final line in lines) {
      final candidate = RegExp(
        r'\b([A-Z0-9][A-Z0-9\-/]{5,})\b',
        caseSensitive: false,
      ).firstMatch(line);
      if (candidate == null) {
        continue;
      }

      final value = _cleanCandidate(candidate.group(1));
      if (value == null) {
        continue;
      }

      if (RegExp(r'^\d{1,2}[-/]\d{1,2}[-/]\d{2,4}$').hasMatch(value)) {
        continue;
      }

      if (value.replaceAll(RegExp(r'[^0-9]'), '').isEmpty) {
        continue;
      }

      return value;
    }

    return null;
  }

  String? _extractDate(List<String> lines, String fullText) {
    final labeled = _extractLabeledValue(lines, _dateLabels);
    final labeledDate = _matchDate(labeled ?? '');
    if (labeledDate != null) {
      return labeledDate;
    }

    return _matchDate(fullText);
  }

  String? _extractWeight(List<String> lines, String fullText) {
    final weightRegex = RegExp(
      r'(?:total weight|gross weight|net weight|weight)\s*[:#-]?\s*([\d\.,]+\s*(?:lb|lbs|kg|kgs|kilograms?)?)',
      caseSensitive: false,
    );
    final directMatch = weightRegex.firstMatch(fullText);
    if (directMatch != null) {
      return _cleanWeight(directMatch.group(1));
    }

    final labeled = _extractLabeledValue(lines, _weightLabels);
    if (labeled != null) {
      return _cleanWeight(labeled);
    }

    return null;
  }

  String? _extractLabeledValue(List<String> lines, List<String> labels) {
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lower = line.toLowerCase();

      for (final label in labels) {
        if (!lower.contains(label)) {
          continue;
        }

        final inline = _extractInlineValue(line, label);
        if (inline != null) {
          return inline;
        }

        for (int offset = 1;
            offset <= 2 && i + offset < lines.length;
            offset++) {
          final candidate = _cleanCandidate(lines[i + offset]);
          if (candidate == null || _looksLikeLabel(candidate)) {
            continue;
          }
          return candidate;
        }
      }
    }

    return null;
  }

  String? _extractInlineValue(String line, String label) {
    final match = RegExp(
      '${RegExp.escape(label)}\\s*[:#-]?\\s*(.+)',
      caseSensitive: false,
    ).firstMatch(line);
    if (match == null) {
      return null;
    }

    return _cleanCandidate(match.group(1));
  }

  bool _looksLikeLabel(String value) {
    final normalized = value.toLowerCase();
    final allLabels = <String>{
      ..._shipmentLabels,
      ..._senderLabels,
      ..._consigneeLabels,
      ..._dateLabels,
      ..._weightLabels,
      'name',
      'address',
      'phone',
    };

    return allLabels.any(
        (label) => normalized == label || normalized.startsWith('$label '));
  }

  String? _cleanCandidate(String? value) {
    if (value == null) {
      return null;
    }

    final cleaned = value
        .replaceAll(RegExp(r'^[\s:;#\-]+'), '')
        .replaceAll(RegExp(r'[\s:;#\-]+$'), '')
        .trim();

    if (cleaned.isEmpty) {
      return null;
    }

    return cleaned;
  }

  String? _matchDate(String text) {
    final dateRegex = RegExp(
      r'\b(?:\d{1,4}[-/]\d{1,2}[-/]\d{1,4}|(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Sept|Oct|Nov|Dec)[a-z]*\s+\d{1,2},?\s+\d{2,4})\b',
      caseSensitive: false,
    );
    return dateRegex.firstMatch(text)?.group(0);
  }

  String? _cleanWeight(String? value) {
    final cleaned = _cleanCandidate(value);
    if (cleaned == null) {
      return null;
    }

    final match = RegExp(
      r'([\d\.,]+\s*(?:lb|lbs|kg|kgs|kilograms?)?)',
      caseSensitive: false,
    ).firstMatch(cleaned);
    return match?.group(1)?.trim() ?? cleaned;
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
