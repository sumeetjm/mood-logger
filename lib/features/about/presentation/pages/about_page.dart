import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Help'),
          ),
          Divider(
            thickness: 1,
            height: 3,
          ),
          ListTile(
            title: Text('Contact Support'),
          ),
          Divider(
            thickness: 1,
            height: 3,
          ),
          ListTile(
            title: Text('Terms of use'),
            onTap: () {
              _launchInBrowser(
                  'https://www.termsfeed.com/live/752c73a9-4811-41f4-b796-78166fadcf0e');
            },
          ),
          Divider(
            thickness: 1,
            height: 3,
          ),
          ListTile(
            title: Text('Privacy Policy'),
            onTap: () {
              _launchInBrowser(
                  'https://www.privacypolicies.com/live/cb686bf9-4119-4534-9729-9bc69ba9e245');
            },
          ),
          Divider(
            thickness: 1,
            height: 3,
          ),
          ListTile(
            title: Text('Attributions'),
            onTap: () {
              showLicensePage(context: context, useRootNavigator: true);
            },
          ),
          Divider(
            thickness: 1,
            height: 3,
          ),
          ListTile(
            title: Text('About'),
            onTap: () {
              showAboutDialog(context: context, useRootNavigator: true);
            },
          ),
          Divider(
            thickness: 1,
            height: 3,
          ),
        ],
      ),
    );
  }

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }
}
