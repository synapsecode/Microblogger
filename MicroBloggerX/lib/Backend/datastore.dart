import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'server.dart';

Map currentUser = {};
Map currentPallete = {};
String serverURL = "https://b3c5b524413d.ngrok.io";

saveUserLoginInfo(username) async {
  if (!Platform.isWindows) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('logged_in_username', username);
  }
  currentUser = await loadMyProfile(username);
  print("Saved User Login Info");
}

logoutSavedUser() async {
  if (!Platform.isWindows) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('logged_in_username', "");
  }
  currentUser = {};
  print("Logged Out User");
}

setServerURL(url) {
  serverURL = url;
}

loadSavedUsername() async {
  if (!Platform.isWindows) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = (prefs.getString('logged_in_username') ?? "");
    if (username == "") return "";
    currentUser = await loadMyProfile(username);
    if (currentUser.containsKey('message')) {
      if (currentUser['code'] == 'E2') {
        print("Error while connecting to user");
        await prefs.setString('logged_in_username', "");
        return "";
      }
    }
    return username;
  }
  return "";
}

applyColourPallete() async {
  if (!Platform.isWindows) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = (prefs.getString('colourpallete')) ?? "LIGHT";
    ThemeData theme;
    switch (key) {
      case "LIGHT":
        theme = ThemeData(
            primarySwatch: Colors.red,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            brightness: Brightness.light,
            appBarTheme: AppBarTheme(color: Colors.black12),
            bottomAppBarTheme: BottomAppBarTheme(color: Colors.black12),
            backgroundColor: Colors.white);
        break;
      case "DARK":
        break;
    }
    return theme;
  }
}

toggleColourPallete(String key) async {
  if (!Platform.isWindows) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    switch (key) {
      case "LIGHT":
        await prefs.setString('colourpallete', 'DARK');
        break;
      case "DARK":
        await prefs.setString('colourpallete', 'LIGHT');
        break;
      default:
        break;
    }
  }
}

getColourPalette() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String themeOP = (prefs.getString('palette') ?? "DARK");
  return themeOP;
}

setColourPalette(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (key == "LIGHT") await prefs.setString('palette', 'DARK');
  if (key == "DARK") await prefs.setString('palette', 'LIGHT');
}
