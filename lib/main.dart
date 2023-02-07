import 'package:flutter/material.dart';
import 'package:flutter_loading_button/flutter_round_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ExamplePage(
        title: 'Example Page',
      ),
    );
  }
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  final RoundedLoadingButtonController _btnSuccessController =
      RoundedLoadingButtonController();
  final RoundedLoadingButtonController _btnErrorController =
      RoundedLoadingButtonController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Form(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: RoundedLoadingButton(
                    controller: _btnSuccessController,
                    successColor: Colors.green,
                    resetAfterDuration: true,
                    width: MediaQuery.of(context).size.width,
                    onPressed: () async => submitSuccess(),
                    child: const Text("Submit success"),
                  ),
                ),
                RoundedLoadingButton(
                  controller: _btnErrorController,
                  resetAfterDuration: true,
                  width: MediaQuery.of(context).size.width,
                  onPressed: () async => submitError(),
                  child: const Text("Submit error"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void submitSuccess() async {
    _btnSuccessController.start();
    await Future.delayed(const Duration(seconds: 3));
    _btnSuccessController.success();
    _btnSuccessController.reset();
  }

  void submitError() async {
    _btnErrorController.start();
    await Future.delayed(const Duration(seconds: 3));
    _btnErrorController.error();
    _btnErrorController.reset();
  }
}
