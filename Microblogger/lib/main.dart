import 'dart:async';
import 'dart:io';
import 'package:MicroBlogger/palette.dart';
import 'package:MicroBlogger/Backend/datastore.dart';
import 'package:MicroBlogger/Components/Global/globalcomponents.dart';
import 'package:MicroBlogger/Composers/blogComposer.dart';
import 'package:MicroBlogger/Composers/carouselComposer.dart';
import 'package:MicroBlogger/Composers/microblogComposer.dart';
import 'package:MicroBlogger/Composers/pollComposer.dart';
import 'package:MicroBlogger/Composers/shareableComposer.dart';
import 'package:MicroBlogger/Composers/timelineComposer.dart';
import 'package:MicroBlogger/Screens/about.dart';
import 'package:MicroBlogger/Screens/bookmarks.dart';
import 'package:MicroBlogger/Screens/editprofile.dart';
import 'package:MicroBlogger/Screens/explorepage.dart';
import 'package:MicroBlogger/Screens/homepage.dart';
import 'package:MicroBlogger/Screens/login.dart';
import 'package:MicroBlogger/Screens/newsfeedpage.dart';
import 'package:MicroBlogger/Screens/notifications.dart';
import 'package:MicroBlogger/Screens/profile.dart';
import 'package:MicroBlogger/Screens/register.dart';
import 'package:MicroBlogger/Screens/setting.dart';
import 'package:MicroBlogger/origin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shake/shake.dart';

import 'Backend/server.dart';
import 'Screens/Stories/storymaker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(Application());
  });
}

class Application extends StatelessWidget {
  Application();

  @override
  Widget build(BuildContext context) {
    return Origin(
      builder: (context) {
        return MaterialApp(
          routes: routes,
          title: 'MicroBlogger',
          debugShowCheckedModeBanner: false,
          theme: CurrentTheme,
          home: MainApp(),
        );
      },
    );
  }
}

class MainApp extends StatefulWidget {
  MainApp();

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  Widget payload = Container(
    color: CurrentPalette['primaryBackgroundColor'],
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(image: AssetImage('assets/env.png')),
          SizedBox(
            height: 10.0,
          ),
          CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
            backgroundColor: Color.fromARGB(200, 220, 20, 60),
          )
        ],
      ),
    ),
  );

  String user_id = "";

  @override
  void initState() {
    super.initState();
    getTheme().then((x) {
      CurrentPalette = x == "LIGHT" ? lightThemePalette : darkThemePalette;
      CurrentTheme = x == "LIGHT" ? CustomLightThemeData : CustomDarkThemeData;
      Origin.of(context).rebuild();
      setState(() {});
    });
    loadUser();
    if (Platform.isAndroid) startShakeDetectorService();
  }

  void startShakeDetectorService() async {
    ShakeDetector.autoStart(
      shakeThresholdGravity: 4.5,
      onPhoneShake: () {
        print("Shook");
        Timer.run(
          () {
            showDialog(
              builder: (context) {
                return BugReporterDialog();
              },
              context: context,
            );
          },
        );
      },
    );
  }

  void loadUser() async {
    Widget servErrorPage = Scaffold(
      appBar: AppBar(
        title: Text("Server Error"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/env.png'),
            Text(
              "Fatal Server Side Error",
              style: TextStyle(
                fontSize: 21.0,
                color: Origin.of(context).isCurrentPaletteDarkTheme
                    ? Colors.white38
                    : Colors.black54,
              ),
            ),
            Text(
              "Couldn't establish a connection",
              style: TextStyle(
                color: Origin.of(context).isCurrentPaletteDarkTheme
                    ? Colors.white12
                    : Colors.black38,
              ),
            )
          ],
        ),
      ),
    );
    final servCheck = await serverCheckRequest();
    if (servCheck == null) {
      payload = servErrorPage;
      setState(() {
        payload = payload;
        user_id = "";
      });
    } else {
      String x = await loadSavedUsername();
      if (x == null) {
        payload = servErrorPage;
        setState(() {
          payload = payload;
          user_id = "";
        });
      } else {
        setState(() {
          payload = (x == "") ? LoginPage() : HomePage();
          user_id = x;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return payload;
  }
}

Map<String, WidgetBuilder> routes = {
  //General Screens
  '/About': (BuildContext context) => new AboutPage(),
  '/NewsFeed': (BuildContext context) => new NewsFeedPage(),
  '/Login': (BuildContext context) => new LoginPage(),
  '/Register': (BuildContext context) => new RegisterPage(),
  '/Settings': (BuildContext context) => new Settings(),
  '/Explore': (BuildContext context) => new ExplorePage(),

  //User screens
  '/HomePage': (BuildContext context) => new HomePage(),
  '/ProfilePage': (BuildContext context) =>
      new ProfilePage(currentUser['user']['username']),
  '/Bookmarks': (BuildContext context) => new BookmarksPage(),
  '/EditProfile': (BuildContext context) => new EditProfilePage(),
  '/Notifications': (BuildContext context) => new NotificationsPage(),

  //Composers
  '/MicroBlogComposer': (BuildContext context) => new MicroBlogComposer(
        isEditing: false,
        preExistingState: {'content': '', 'isFact': false},
      ),
  '/ShareableComposer': (BuildContext context) => new ShareableComposer(
        isEditing: false,
        preExistingState: {
          'content': '',
          'link': '',
          'name': '',
        },
      ),
  '/BlogComposer': (BuildContext context) => new BlogComposer(
        isEditing: false,
        preExistingState: {
          'content': "",
          'blogName': "",
          'cover': "",
        },
      ),
  '/PollComposer': (BuildContext context) => new PollComposer(),
  '/TimelineComposer': (BuildContext context) => new TimelineComposer(
        isEditing: false,
        preExistingState: {
          'timelineTitle': "",
          'events': [],
          'cover': "",
        },
      ),
  '/MediaComposer': (BuildContext context) => new CarouselComposer(
        isEditing: false,
        preExistingState: {'content': "", 'images': []},
      ),
  '/StoryMaker': (BuildContext context) => new StoryMaker(),
};
