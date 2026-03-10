// lib/api/api_service.dart

import 'dart:convert';
import 'dart:io'; // Needed for SocketException
import 'package:http/http.dart' as http;
import '../models/contact.dart';

class ApiService {
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://card.sarlpro.com',
  );

  // class ApiService {
  //   static const String _baseUrl = String.fromEnvironment(
  //     'API_BASE_URL',
  //     defaultValue: 'http://192.168.100.11/',
  //   );

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

  /// Uploads a compressed business card image to the backend for processing.
  Future<void> submitCardImage(File imageFile, {String? extractedText}) async {
    final Uri uri = Uri.parse("$_baseUrl/api/process-card");

    try {
      final request = http.MultipartRequest('POST', uri)
        ..headers['Accept'] = 'application/json'
        ..fields.addAll({
          if (extractedText != null && extractedText.trim().isNotEmpty)
            'text': extractedText.trim(),
        })
        ..files.add(
          await http.MultipartFile.fromPath('card_image', imageFile.path),
        );

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 202) {
        throw Exception(
          'Failed to upload card image. Status code: ${response.statusCode}\nResponse: ${response.body}',
        );
      }
    } on SocketException {
      throw Exception('No Internet connection. Please check your network.');
    } catch (e) {
      throw Exception(
        'An unexpected error occurred while uploading the card image: $e',
      );
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
      throw Exception(
        'An unexpected error occurred while updating contact: $e',
      );
    }
  }

  /// Deletes a contact.
  Future<void> deleteContact(int contactId) async {
    final Uri uri = Uri.parse("$_baseUrl/api/contacts/$contactId");

    try {
      final response = await http
          .delete(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 204) {
        throw Exception(
          'Failed to delete contact. Status code: ${response.statusCode}\nResponse: ${response.body}',
        );
      }
    } on SocketException {
      throw Exception('No Internet connection. Please check your network.');
    } catch (e) {
      throw Exception(
        'An unexpected error occurred while deleting contact: $e',
      );
    }
  }
}
