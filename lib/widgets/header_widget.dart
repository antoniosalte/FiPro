import 'package:flutter/material.dart';

import 'package:fipro/providers/auth_provider.dart';
import 'package:provider/provider.dart';

import 'logo_widget.dart';

class HeaderWidget extends StatefulWidget implements PreferredSizeWidget {
  HeaderWidget({Key? key})
      : preferredSize = Size.fromHeight(80.0),
        super(key: key);

  @override
  final Size preferredSize;

  @override
  _HeaderWidgetState createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  void openSettings() {}

  void logout() async {
    AuthProvider auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary,
      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: AppBar(
        title: LogoWidget(fontSize: 48, alternative: true),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          // HeaderButton(
          //   title: 'Home',
          //   onPressed: null,
          // ),
          HeaderButton(
            title: 'Settings',
            onPressed: openSettings,
          ),
          HeaderButton(
            title: 'Logout',
            onPressed: logout,
          ),
        ],
      ),
    );
  }
}

class HeaderButton extends StatelessWidget {
  const HeaderButton({Key? key, required this.title, this.onPressed})
      : super(key: key);

  final String title;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: TextButton(
        child: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
