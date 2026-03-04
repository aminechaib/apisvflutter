// lib/providers/contact_provider.dart

import 'package:flutter/material.dart'; // <-- FIX: This import is crucial
import '../api/api_service.dart';
import '../models/contact.dart';

// An enum to represent the different states of our data fetching
enum DataState { initial, loading, loaded, error }

class ContactProvider with ChangeNotifier {
  // <-- FIX: 'with ChangeNotifier' is correct
  final ApiService _apiService = ApiService();

  List<Contact> _contacts = [];
  DataState _state = DataState.initial;
  String _errorMessage = '';

  List<Contact> get contacts => _contacts;
  DataState get state => _state;
  String get errorMessage => _errorMessage;

  Future<void> fetchContacts() async {
    if (_state == DataState.loading) return;
    _state = DataState.loading;
    notifyListeners();

    try {
      _contacts = await _apiService.getContacts();
      _state = DataState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = DataState.error;
    }
    notifyListeners();
  }

  Future<void> submitTextAndRefresh(String ocrText) async {
    try {
      await _apiService.submitExtractedText(ocrText);
      await Future.delayed(const Duration(seconds: 5));
      await fetchContacts();
    } catch (e) {
      _errorMessage = e.toString();
      _state = DataState.error;
      notifyListeners();
    }
  }

  Future<void> updateContact({
    required int contactId,
    required Map<String, dynamic> fields,
  }) async {
    try {
      await _apiService.updateContact(contactId, fields);
      await fetchContacts();
    } catch (e) {
      _errorMessage = e.toString();
      _state = DataState.error;
      notifyListeners();
      rethrow;
    }
  }
}
