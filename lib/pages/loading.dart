import 'package:flutter/material.dart';

class LoadingPage extends StatelessWidget {
  LoadingPage(
    Future<dynamic> Function() load, {
    super.key,
    void Function(dynamic)? onLoad,
    this.appBar,
  }) {
    load().then((value) => onLoad != null ? onLoad(value) : null);
  }

  final AppBar? appBar;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: appBar ??
            AppBar(
              leading: Row(
                children: const [
                  Padding(
                    padding: EdgeInsets.only(left: 17.5),
                    child: SizedBox(
                      width: 25,
                      height: 25,
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ],
              ),
              title: const Text("Loading"),
            ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                "Loading...",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30),
              ),
              Padding(padding: EdgeInsets.all(10.0)),
              CircularProgressIndicator()
            ],
          ),
        ),
      ),
      onWillPop: () async {
        return false;
      },
    );
  }
}
