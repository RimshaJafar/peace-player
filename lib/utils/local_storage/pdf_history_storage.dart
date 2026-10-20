import 'dart:convert';

import 'package:ecommerce_app/features/digital_will/models/pdf_history_record_model.dart';
import 'package:ecommerce_app/utils/constants/pdf_constants.dart';
import 'package:get_storage/get_storage.dart';

/// Manages local PDF history storage using GetStorage.
class PdfHistoryStorage {
  PdfHistoryStorage._();
  static final PdfHistoryStorage instance = PdfHistoryStorage._();

  final GetStorage _storage = GetStorage();

  // ─── Get All History ─────────────────────────────────────────────────
  List<PdfHistoryRecord> getHistory() {
    final dynamic raw = _storage.read(PdfConstants.pdfHistoryStorageKey);
    if (raw == null) return <PdfHistoryRecord>[];

    try {
      final List<dynamic> decoded =
          raw is String ? jsonDecode(raw) as List<dynamic> : raw as List<dynamic>;
      return decoded
          .map((item) =>
              PdfHistoryRecord.fromJson(item as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.generatedAt.compareTo(a.generatedAt));
    } catch (_) {
      return <PdfHistoryRecord>[];
    }
  }

  // ─── Add Record ──────────────────────────────────────────────────────
  Future<void> addRecord(PdfHistoryRecord record) async {
    final List<PdfHistoryRecord> history = getHistory();

    // Remove existing record with same pdfId to avoid duplicates
    history.removeWhere((r) => r.pdfId == record.pdfId);

    // Add new record at the beginning
    history.insert(0, record);

    // Keep only last 50 records
    final List<PdfHistoryRecord> trimmed =
        history.length > 50 ? history.sublist(0, 50) : history;

    await _saveHistory(trimmed);
  }

  // ─── Update Cached Path ──────────────────────────────────────────────
  Future<void> updateCachedPath(String pdfId, String? filePath) async {
    final List<PdfHistoryRecord> history = getHistory();
    final int index = history.indexWhere((r) => r.pdfId == pdfId);
    if (index != -1) {
      history[index].cachedFilePath = filePath;
      await _saveHistory(history);
    }
  }

  // ─── Remove Record ───────────────────────────────────────────────────
  Future<void> removeRecord(String pdfId) async {
    final List<PdfHistoryRecord> history = getHistory();
    history.removeWhere((r) => r.pdfId == pdfId);
    await _saveHistory(history);
  }

  // ─── Clear All History ───────────────────────────────────────────────
  Future<void> clearHistory() async {
    await _storage.remove(PdfConstants.pdfHistoryStorageKey);
  }

  // ─── Get Record by PDF ID ───────────────────────────────────────────
  PdfHistoryRecord? getRecordByPdfId(String pdfId) {
    final List<PdfHistoryRecord> history = getHistory();
    try {
      return history.firstWhere((r) => r.pdfId == pdfId);
    } catch (_) {
      return null;
    }
  }

  // ─── Get Records by Record ID ────────────────────────────────────────
  List<PdfHistoryRecord> getRecordsByRecordId(String recordId) {
    final List<PdfHistoryRecord> history = getHistory();
    return history.where((r) => r.recordId == recordId).toList();
  }

  // ─── Private Save ────────────────────────────────────────────────────
  Future<void> _saveHistory(List<PdfHistoryRecord> history) async {
    final String encoded =
        jsonEncode(history.map((r) => r.toJson()).toList());
    await _storage.write(PdfConstants.pdfHistoryStorageKey, encoded);
  }
}
