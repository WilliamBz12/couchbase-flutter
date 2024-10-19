import 'package:cbl_flutter/cbl_flutter.dart';
import 'package:flutter/material.dart';

import 'app/app_widget.dart';

Future<void> main() async {
  // Initialize Flutter before Couchbase Lite.
  WidgetsFlutterBinding.ensureInitialized();

  // Now initialize Couchbase Lite.
  await CouchbaseLiteFlutter.init();

  // Finally, start running the app.
  runApp(const MyApp());
}
