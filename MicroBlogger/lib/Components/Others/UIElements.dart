import 'package:flutter/material.dart';

class BottomNavigator extends StatelessWidget {
  const BottomNavigator({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home), title: Text('')),
        BottomNavigationBarItem(icon: Icon(Icons.search), title: Text('')),
        // BottomNavigationBarItem(icon: Icon(Icons.trending_up), title: Text('')),
        BottomNavigationBarItem(
            icon: Icon(Icons.notifications), title: Text('')),
        BottomNavigationBarItem(
            icon: Icon(Icons.perm_identity), title: Text('')),
      ],
      selectedItemColor: Colors.white,
      backgroundColor: Colors.black87,
      unselectedItemColor: Colors.white,
      onTap: (int x) {
        switch (x) {
          case 0:
            Navigator.of(context).pushNamed('/HomePage');
            break;
          case 1:
            Navigator.of(context).pushNamed('/Explore');
            break;
          case 2:
            Navigator.of(context).pushNamed('/Notifications');
            break;
          case 3:
            Navigator.of(context).pushNamed('/Profile');
            break;
        }
      },
    );
  }
}

class MainAppDrawer extends StatelessWidget {
  final currentUser;
  const MainAppDrawer({Key key, this.currentUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.black54,
        child: new ListView(
          children: <Widget>[
            new SizedBox(
              height: 270.0,
              child: UserAccountsDrawerHeader(
                currentAccountPicture: CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage("${currentUser['dpURL']}")),
                accountName: Text("${currentUser['name']}",
                    style: TextStyle(
                      fontSize: 20.0,
                    )),
                accountEmail: Text("${currentUser['email']}"),
                decoration: new BoxDecoration(
                    image: new DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage("${currentUser['bgURL']}")
                        //NetworkImage('https://www.wallpaperup.com/uploads/wallpapers/2015/01/29/604388/cff1fdb8cae21be0110304941e33130d-700.jpg')
                        )),
              ),
            ),
            new ListTile(
              title: Text(
                "Settings",
                style: TextStyle(color: Colors.white),
              ),
              trailing: Icon(
                Icons.settings,
                color: Colors.white,
              ),
              onTap: () => Navigator.of(context).pushNamed('/Settings'),
            ),
            new ListTile(
              title: Text(
                "Bookmarks",
                style: TextStyle(color: Colors.white),
              ),
              trailing: Icon(
                Icons.bookmark,
                color: Colors.white,
              ),
              onTap: () => Navigator.of(context).pushNamed('/Bookmarks'),
            ),
            new ListTile(
              title: Text(
                "Trending",
                style: TextStyle(color: Colors.white),
              ),
              trailing: Icon(
                Icons.trending_up,
                color: Colors.white,
              ),
              onTap: () => Navigator.of(context).pushNamed('/Trending'),
            ),
            new ListTile(
              title: Text(
                "News",
                style: TextStyle(color: Colors.white),
              ),
              trailing: Icon(
                Icons.wifi,
                color: Colors.white,
              ),
              onTap: () => Navigator.of(context).pushNamed('/NewsFeed'),
            ),
            new ListTile(
              onTap: () => Navigator.of(context).pushNamed('/About'),
              title: Text(
                "About",
                style: TextStyle(color: Colors.white),
              ),
              trailing: Icon(
                Icons.account_box,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final String actionText;
  final icon;
  final Function event;

  //Constructor
  ActionButton(this.actionText, this.icon, this.event);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        FloatingActionButton(
          backgroundColor: Colors.white10,
          foregroundColor: Colors.white,
          child: Icon(icon),
          onPressed: event,
        ),
        Padding(padding: EdgeInsets.only(bottom: 10.0)),
        Text(actionText)
      ],
    );
  }
}

class AddOptionsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250.0,
      color: Colors.black,
      padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 20.0),
      child: OrientationBuilder(builder: (context, orientation) {
        return GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          children: <Widget>[
            ActionButton('MicroBlog', Icons.image, () {
              Navigator.of(context).pushNamed('/MicroBlogComposer');
            }),
            ActionButton('Shareable', Icons.link, () {
              Navigator.of(context).pushNamed('/ShareableComposer');
            }),
            ActionButton('Blog', Icons.create, () {
              Navigator.of(context).pushNamed('/BlogComposer');
            }),
            ActionButton('Poll', Icons.poll, () {
              Navigator.of(context).pushNamed('/PollComposer');
            }),
            ActionButton('Timeline', Icons.check_box, () {
              Navigator.of(context).pushNamed('/TimelineComposer');
            }),
            ActionButton('Media', Icons.devices, () {
              print('Clicked Wiki Entry');
            }),
            // ActionButton('ChatRoom', Icons.device_hub, () {
            //   print('Clicked ChatRoom');
            // }),
            // ActionButton('Ask Question', Icons.question_answer, () {
            //   print('Clicked QA');
            // }),
            // ActionButton('All Drafts', Icons.drafts, () {
            //   print('Clicked Drafts');
            // }),
          ],
        );
      }),
    );
  }
}

// [['Image', 'Link', 'Function'], ['Image', 'Link', 'Function'], ['Image', 'Link', 'Function']]

class FloatingCircleButton extends StatefulWidget {
  @override
  _FloatingCircleButtonState createState() => new _FloatingCircleButtonState();
}

class _FloatingCircleButtonState extends State<FloatingCircleButton> {
  void openActionSheet() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (builder) {
          return AddOptionsWidget();
        });
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: openActionSheet,
      child: new Icon(Icons.add),
      tooltip: "Create Content",
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    );
  }
}
