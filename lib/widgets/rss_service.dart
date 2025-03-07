import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:xml2json/xml2json.dart';

class RssService {
  final Xml2Json xml2json =
      Xml2Json(); // Create an instance of Xml2Json for XML to JSON conversion

  // Method to fetch and parse an RSS feed from a given URL
  Future<List<Map>> fetchRssFeed(String url) async {
    try {
      // Make an HTTP GET request to the RSS feed URL
      final response = await http.get(Uri.parse(url));

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // Parse the XML response body using the Xml2Json instance
        xml2json.parse(response.body);

        // Convert the parsed XML to JSON using the Parker format
        var jsonString = xml2json.toParker();

        // Decode the JSON string into a Dart Map
        final jsonData = jsonDecode(jsonString);

        // Extract the list of news items from the JSON structure
        // Assumes the RSS feed structure is: rss -> channel -> item
        final items = jsonData['rss']['channel']['item'] as List;

        // Convert each item in the list to a Map and return the list
        return items.map((item) => item as Map).toList();
      } else {
        // Throw an exception if the HTTP request fails (non-200 status code)
        throw Exception(
          'Failed to load RSS feed: Status code ${response.statusCode}',
        );
      }
    } catch (e) {
      // Catch and log any errors that occur during the process
      print('Error fetching RSS feed: $e');
      // Return an empty list in case of an error
      return [];
    }
  }
}
