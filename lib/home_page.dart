import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:news_flutter/widgets/news_article.dart';
import 'package:news_flutter/widgets/rss_service.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  final dynamic title; // Title of the app bar

  const HomePage({super.key, required this.title});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List _newsArticles = []; // List to store all fetched news articles
  List _filteredNewsArticles = []; // List to store filtered news articles
  final RssService _rssService =
      RssService(); // Instance of RssService to fetch RSS feed
  final TextEditingController _searchController =
      TextEditingController(); // Controller for the search bar

  @override
  void initState() {
    super.initState();
    _fetchNews(); // Fetch news articles when the widget is initialized
  }

  // Method to fetch news articles from the RSS feed
  Future _fetchNews() async {
    const rssUrl =
        'http://rss.nytimes.com/services/xml/rss/nyt/World.xml'; // Example RSS feed URL

    final items = await _rssService.fetchRssFeed(
      rssUrl,
    ); // Fetch RSS feed items

    setState(() {
      // Map RSS feed items to NewsArticle objects and store them in _newsArticles
      _newsArticles = items.map((item) => NewsArticle.fromJson(item)).toList();
      // Initialize filtered list with all articles
      _filteredNewsArticles = _newsArticles;
    });
  }

  // Method to filter news articles based on the search query
  void _filterNewsArticles(String query) {
    setState(() {
      // Filter articles where the title or description contains the search query (case-insensitive)
      _filteredNewsArticles =
          _newsArticles
              .where(
                (article) =>
                    article.title.toLowerCase().contains(query.toLowerCase()) ||
                    article.description.toLowerCase().contains(
                      query.toLowerCase(),
                    ),
              )
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(widget.title),
        ), // Display the app title in the center
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(
            60.0,
          ), // Set the height of the search bar
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _searchController, // Controller for the search bar
              decoration: InputDecoration(
                hintText:
                    'Search news...', // Placeholder text for the search bar
                filled: true,
                fillColor: Colors.white, // Background color of the search bar
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    8.0,
                  ), // Rounded corners for the search bar
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear), // Clear button icon
                  onPressed: () {
                    _searchController.clear(); // Clear the search bar text
                    _filterNewsArticles(
                      '',
                    ); // Reset the filtered list to show all articles
                  },
                ),
              ),
              onChanged:
                  _filterNewsArticles, // Trigger filtering when the search text changes
            ),
          ),
        ),
      ),
      body:
          _newsArticles.isEmpty
              ? Center(
                child: CircularProgressIndicator(),
              ) // Show loading indicator if articles are not fetched yet
              : _filteredNewsArticles.isEmpty
              ? Center(
                child: Text('No matching news found.'),
              ) // Show message if no articles match the search query
              : ListView.builder(
                itemCount:
                    _filteredNewsArticles.length, // Number of filtered articles
                itemBuilder: (context, index) {
                  final article =
                      _filteredNewsArticles[index]; // Get the current article
                  return Card(
                    margin: EdgeInsets.all(8.0), // Margin around the card
                    elevation: 4.0, // Add elevation for a shadow effect
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        8.0,
                      ), // Rounded corners for the card
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.0), // Padding inside the card
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start, // Align content to the start
                        children: [
                          Text(
                            article.title, // Display the article title
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                          SizedBox(
                            height: 8.0,
                          ), // Add spacing between title and description
                          // If RSS contains HTML, use FlutterHtml widget to render it
                          Html(data: article.description),
                          SizedBox(
                            height: 8.0,
                          ), // Add spacing between description and publication date
                          Text(
                            'Published: ${article.pubDate}', // Display the publication date
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 12.0,
                            ),
                          ),
                          SizedBox(
                            height: 8.0,
                          ), // Add spacing between publication date and button
                          TextButton(
                            onPressed: () async {
                              final Uri url = Uri.parse(
                                article.link,
                              ); // Parse the article link
                              if (await launchUrl(url)) {
                                // Launch the URL in a browser
                              } else {
                                throw Exception(
                                  'Could not launch ${article.link}', // Throw an error if the URL cannot be launched
                                );
                              }
                            },
                            child: Text('Read More'), // Button text
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
