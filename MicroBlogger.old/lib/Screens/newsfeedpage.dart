import 'package:MicroBlogger/Components/Others/UIElements.dart';
import 'package:MicroBlogger/Data/datafetcher.dart';
import 'package:MicroBlogger/Data/fetcher.dart';
import 'package:flutter/material.dart';
import '../Components/PostTemplates/news.dart';

//590b8ff1c78d4c0e8088535f3cf54122
//http://newsapi.org/v2/everything?q=bitcoin&from=2020-06-21&sortBy=publishedAt&apiKey=590b8ff1c78d4c0e8088535f3cf54122

class NewsFeedPage extends StatelessWidget {
  const NewsFeedPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List newsFeed = DataFetcher().newsArticles;
    newsFeed.shuffle();
    return Scaffold(
      appBar: AppBar(
        title: Text("News Feed"),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop()),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10.0),
        child: Container(
          child: FutureBuilder(
              future: getNewsArticles(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      return new NewsItem(
                        newsObject: snapshot.data[index],
                      );
                    },
                  );
                } else {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [CircularProgressIndicator()],
                    ),
                  );
                }
              }),
          // child: ListView.builder(
          //   shrinkWrap: true,
          //   physics: NeverScrollableScrollPhysics(),
          //   itemCount: newsFeed.length,
          //   itemBuilder: (context, index) {
          //     return new NewsItem(
          //       newsObject: newsFeed[index],
          //     );
          //   },
          // ),
        ),
      ),
      bottomNavigationBar: BottomNavigator(),
    );
  }
}