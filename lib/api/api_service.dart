// lib/api/api_service.dart

import 'dart:convert';
import 'dart:io'; // Needed for SocketException
import 'package:http/http.dart' as http;
import '../models/contact.dart';

class ApiService {
  // The base URL should be the root of your domain.
  static const String _baseUrl = "https://card.sarlpro.com";

  /// Fetches the paginated list of validated contacts from the API.
  Future<List<Contact>> getContacts() async {
    final Uri uri = Uri.parse("$_baseUrl/api/contacts");

    try {
      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> contactData = jsonResponse['data'];
        List<Contact> contacts = contactData
            .map((json) => Contact.fromJson(json))
            .toList();
        return contacts;
      } else {
        throw Exception(
          'Failed to load contacts. Status code: ${response.statusCode}\nResponse: ${response.body}',
        );
      }
    } on SocketException {
      throw Exception('No Internet connection. Please check your network.');
    } on FormatException {
      throw Exception('Bad response format from the server.');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Submits the extracted text from OCR to the backend for processing.
  /// This method replaces the old image upload method.
  Future<void> submitExtractedText(String text) async {
    // This now points to the endpoint that accepts raw text.
    final Uri uri = Uri.parse("$_baseUrl/api/process-text");

    try {
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
            },
            // We now send a JSON body with the extracted text.
            body: json.encode({'text': text}),
          )
          .timeout(const Duration(seconds: 15));

      // The backend should respond with 202 Accepted if it successfully
      // queued the job for processing by Mistral AI.
      if (response.statusCode != 202) {
        throw Exception(
          'Failed to submit text for processing. Status code: ${response.statusCode}\nResponse: ${response.body}',
        );
      }
      // If successful, there's nothing to return, the method just completes.
    } on SocketException {
      throw Exception('No Internet connection. Please check your network.');
    } catch (e) {
      throw Exception('An unexpected error occurred while submitting text: $e');
    }
  }

  /// Updates an existing contact with user-corrected values.
  Future<void> updateContact(int contactId, Map<String, dynamic> fields) async {
    final Uri uri = Uri.parse("$_baseUrl/api/contacts/$contactId");
    final Map<String, dynamic> payload = Map<String, dynamic>.from(fields)
      ..removeWhere((key, value) => value == null);

    try {
      final response = await http
          .put(
            uri,
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
            },
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 15));

      if (![200, 201, 202].contains(response.statusCode)) {
        throw Exception(
          'Failed to update contact. Status code: ${response.statusCode}\nResponse: ${response.body}',
        );
      }
    } on SocketException {
      throw Exception('No Internet connection. Please check your network.');
    } catch (e) {
      throw Exception('An unexpected error occurred while updating contact: $e');
    }
  }

  /// Deletes a contact.
  Future<void> deleteContact(int contactId) async {
    final Uri uri = Uri.parse("$_baseUrl/api/contacts/$contactId");

    try {
      final response = await http
          .delete(
            uri,
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 204) {
        throw Exception(
          'Failed to delete contact. Status code: ${response.statusCode}\nResponse: ${response.body}',
        );
      }
    } on SocketException {
      throw Exception('No Internet connection. Please check your network.');
    } catch (e) {
      throw Exception('An unexpected error occurred while deleting contact: $e');
    }
  }
}
