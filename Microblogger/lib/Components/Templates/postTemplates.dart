import 'dart:ui';

import 'package:MicroBlogger/Backend/server.dart';
import 'package:MicroBlogger/Components/Global/globalcomponents.dart';
import 'package:MicroBlogger/Components/Templates/nativeVideoPlayer.dart';
import 'package:MicroBlogger/Screens/profile.dart';
import 'package:MicroBlogger/Views/blog_viewer.dart';
import 'package:MicroBlogger/Views/shareableWebViewer.dart';
import 'package:MicroBlogger/Views/timeline_viewer.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'basetemplate.dart';
import '../../Backend/datastore.dart';

class MicroBlogPost extends StatelessWidget {
  final postObject;
  final isInViewMode;
  final bool isHosted;
  const MicroBlogPost(
      {Key key,
      this.postObject,
      this.isHosted = false,
      this.isInViewMode = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasicTemplate(
        postObject: postObject,
        isHosted: isHosted,
        isInViewMode: isInViewMode,
        widgetComponent:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          HashTagEnabledUserTaggableTextDisplay(postObject['content']),
        ]));
  }
}

class CarouselPost extends StatefulWidget {
  final postObject;
  final isInViewMode;
  final bool isHosted;
  const CarouselPost(
      {Key key,
      this.postObject,
      this.isHosted = false,
      this.isInViewMode = false})
      : super(key: key);

  @override
  _CarouselPostState createState() => _CarouselPostState();
}

class _CarouselPostState extends State<CarouselPost> {
  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return BasicTemplate(
        postObject: widget.postObject,
        isHosted: widget.isHosted,
        isInViewMode: widget.isInViewMode,
        widgetComponent: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            HashTagEnabledUserTaggableTextDisplay(widget.postObject['content']),
            SizedBox(
              height: 15,
            ),
            ImageCarousel(
              imagesSrcList: widget.postObject['images'],
            )
          ],
        ));
  }
}

class LevelOneComment extends StatelessWidget {
  final commentObject;
  const LevelOneComment({Key key, this.commentObject}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasicTemplate(
        postObject: commentObject,
        widgetComponent:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          HashTagEnabledUserTaggableTextDisplay(commentObject['content']),
        ]));
  }
}

class PollPost extends StatefulWidget {
  final postObject;
  const PollPost({Key key, this.postObject}) : super(key: key);

  @override
  _PollPostState createState() => _PollPostState();
}

class _PollPostState extends State<PollPost> {
  int votedFor;
  @override
  void initState() {
    super.initState();
    votedFor = widget.postObject['votedFor'];
  }

  @override
  Widget build(BuildContext context) {
    int c = -1;
    return BasicTemplate(
        postObject: widget.postObject,
        widgetComponent:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          HashTagEnabledUserTaggableTextDisplay(widget.postObject['content']),
          SizedBox(
            height: 10.0,
          ),
          Column(
            children: [...widget.postObject['options']].map((x) {
              c += 1;
              return Row(children: <Widget>[
                Expanded(
                    child: RaisedButton(
                  color: (votedFor == c) ? Colors.green : Colors.black,
                  onPressed: () {
                    print("Clicked on option (${x['name']}) in Poll");
                    if (votedFor == -1) {
                      submitVote(widget.postObject['id'],
                          widget.postObject['options'].indexOf(x).toString());
                      setState(() {
                        votedFor = widget.postObject['options'].indexOf(x);
                        x['count']++;
                      });
                      widget.postObject['votedFor'] = votedFor;
                    } else
                      Fluttertoast.showToast(
                          msg: "Already Voted",
                          backgroundColor: Color.fromARGB(200, 220, 20, 60));
                  },
                  child: (votedFor != -1)
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("${x['name']}"),
                            Text(
                              " (${x['count']})",
                              style: TextStyle(color: Colors.white30),
                            )
                          ],
                        )
                      : Text("${x['name']}"),
                ))
              ]);
            }).toList(),
          ),
        ]));
  }
}

class ShareablePost extends StatelessWidget {
  final postObject;
  final bool isHosted;
  const ShareablePost({Key key, this.postObject, this.isHosted = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasicTemplate(
        isHosted: isHosted,
        postObject: postObject,
        widgetComponent:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          HashTagEnabledUserTaggableTextDisplay(postObject['content']),
          SizedBox(
            height: 10.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RaisedButton.icon(
                  color: Color.fromARGB(200, 220, 20, 60),
                  onPressed: () {
                    print("Visiting ${postObject['link']}");
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ShareableWebView(
                                  link: postObject['link'],
                                )));
                  },
                  icon: Icon(Icons.link),
                  label: Text("Visit ${postObject['name']}"))
            ],
          )
        ]));
  }
}

class SimpleReshare extends StatelessWidget {
  final postObject;
  SimpleReshare({Key key, this.postObject}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 5.0),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "Reshared By ",
                style: TextStyle(color: Colors.white30),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfilePage(
                                postObject['author']['username'],
                              )));
                },
                child: Text(
                  "@${postObject['author']['username']}",
                  style: TextStyle(color: Colors.pink),
                ),
              )
            ],
          ),
          if (postObject['child']['type'] == "microblog") ...[
            MicroBlogPost(
              postObject: postObject['child'],
            )
          ] else if (postObject['child']['type'] == "shareable") ...[
            ShareablePost(
              postObject: postObject['child'],
            )
          ] else if (postObject['child']['type'] == "blog") ...[
            BlogPost(
              postObject['child'],
            )
          ] else if (postObject['child']['type'] == "timeline") ...[
            Timeline(
              postObject['child'],
            )
          ] else if (postObject['child']['type'] == "carousel") ...[
            CarouselPost(
              postObject: postObject['child'],
            )
          ],
        ],
      ),
    );
  }
}

class BlogPost extends StatelessWidget {
  final postObject;
  final isHosted;
  BlogPost(this.postObject, {this.isHosted = false});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BlogViewer(postObject: postObject))),
      child: Padding(
          padding: (isHosted)
              ? EdgeInsets.zero
              : EdgeInsets.symmetric(vertical: 5.0),
          child: Container(
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
                border: Border.all(
              width: 1.0,
              color: Colors.white38,
            )),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: Container(
                    constraints: new BoxConstraints.expand(
                      height: 250.0,
                    ),
                    padding: new EdgeInsets.only(left: 16.0, bottom: 8.0),
                    decoration: new BoxDecoration(
                      image: new DecorationImage(
                          image: NetworkImage("${postObject['background']}"),
                          fit: BoxFit.cover),
                    ),
                    child: new Stack(
                      children: <Widget>[
                        new Positioned(
                            left: 0.0,
                            top: 20.0,
                            child: Row(
                              children: <Widget>[
                                CircleAvatar(
                                  radius: 24.0,
                                  backgroundImage: NetworkImage(
                                      "${postObject['author']['icon']}"),
                                ),
                                SizedBox(width: 10.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${postObject['author']['name']}",
                                      style: TextStyle(
                                          fontSize: 20.0, color: Colors.white),
                                    ),
                                    Text(
                                      "@${postObject['author']['username']}",
                                      style: TextStyle(color: Colors.blue),
                                    )
                                  ],
                                )
                              ],
                            )),
                        new Positioned(
                          left: 0.0,
                          bottom: 20.0,
                          child: Container(
                            width: 300.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Writeup",
                                    style: new TextStyle(
                                        fontSize: 40.0, color: Colors.white)),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Text("${postObject['blog_name']}",
                                    style: new TextStyle(
                                        fontSize: 20.0, color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ))),
          )),
    );
  }
}

class Timeline extends StatelessWidget {
  final isHosted;
  final postObject;
  Timeline(this.postObject, {this.isHosted = false});
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TimelineViewer(postObject: postObject))),
        child: Padding(
          padding: (isHosted)
              ? EdgeInsets.zero
              : EdgeInsets.symmetric(vertical: 5.0),
          child: Container(
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
                border: Border.all(
              width: 1.0,
              color: Colors.white38,
            )),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: Container(
                    constraints: new BoxConstraints.expand(
                      height: 250.0,
                    ),
                    padding: new EdgeInsets.only(left: 16.0, bottom: 8.0),
                    decoration: new BoxDecoration(
                      image: new DecorationImage(
                          image: NetworkImage("${postObject['background']}"),
                          fit: BoxFit.cover),
                    ),
                    child: new Stack(
                      children: <Widget>[
                        new Positioned(
                            left: 0.0,
                            top: 20.0,
                            child: Row(
                              children: <Widget>[
                                CircleAvatar(
                                  radius: 24.0,
                                  backgroundImage: NetworkImage(
                                      "${postObject['author']['icon']}"),
                                ),
                                SizedBox(width: 10.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${postObject['author']['name']}",
                                      style: TextStyle(
                                          fontSize: 20.0, color: Colors.white),
                                    ),
                                    Text(
                                      "@${postObject['author']['username']}",
                                      style: TextStyle(color: Colors.blue),
                                    )
                                  ],
                                )
                              ],
                            )),
                        new Positioned(
                          left: 0.0,
                          bottom: 20.0,
                          child: Container(
                            width: 300.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Timeline",
                                    style: new TextStyle(
                                        fontSize: 40.0, color: Colors.white)),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Text("${postObject['timeline_name']}",
                                    style: new TextStyle(
                                        fontSize: 20.0, color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ))),
          ),
        ));
  }
}

class ReshareWithComment extends StatelessWidget {
  final postObject;
  final isInViewMode;
  ReshareWithComment({this.postObject, this.isInViewMode = false});

  @override
  Widget build(BuildContext context) {
    Widget hostChild = Container();

    if (postObject['child']['type'] == "blog") {
      hostChild = BlogPost(
        postObject['child'],
        isHosted: true,
      );
    } else if (postObject['child']['type'] == "timeline") {
      hostChild = Timeline(
        postObject['child'],
        isHosted: true,
      );
    } else if (postObject['child']['type'] == "microblog") {
      hostChild = MicroBlogPost(
        postObject: postObject['child'],
        isHosted: true,
      );
    } else if (postObject['child']['type'] == "shareable") {
      hostChild = ShareablePost(
        postObject: postObject['child'],
        isHosted: true,
      );
    } else if (postObject['child']['type'] == "carousel") {
      hostChild = CarouselPost(
        postObject: postObject['child'],
      );
    }
    return BasicTemplate(
        postObject: postObject,
        isInViewMode: isInViewMode,
        widgetComponent: hostChild);
  }
}

class VideoCarouselPost extends StatefulWidget {
  final postObject;
  // final isInViewMode;
  // final bool isHosted;
  const VideoCarouselPost({
    Key key,
    this.postObject,
    // this.isHosted = false,
    // this.isInViewMode = false
  }) : super(key: key);

  @override
  _VideoCarouselPostState createState() => _VideoCarouselPostState();
}

class _VideoCarouselPostState extends State<VideoCarouselPost> {
  PageController _controller = new PageController();
  @override
  Widget build(BuildContext context) {
    return BasicTemplate(
        postObject: widget.postObject,
        isHosted: false,
        isInViewMode: false,
        widgetComponent:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          HashTagEnabledUserTaggableTextDisplay(widget.postObject['content']),
          SizedBox(
            height: 5.0,
          ),
          Container(child: NativeVideoPlayer(widget.postObject['videoURLs'][0])

              // PageView(
              //   controller: _controller,
              //   children: [
              //     widget.postObject['videoURLs'].forEach((e) {
              //       return NativeVideoPlayer(e);
              //     })
              //   ],
              // ),
              )
        ]));
  }
}
