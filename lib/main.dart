import 'package:amplify_core/amplify_core.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:material_ui/material_ui.dart';
import 'amplify_config.dart';
import 'amplify_config_dev.dart';
import 'login.dart';
import 'wakeon.dart';
import 'app_states.dart';
import 'device_connectivity.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Amplify.addPlugin(
      AmplifyAuthCognito(),
    );

    await Amplify.configure(amplifyConfigDev);

    runApp(const MyApp());
  } on AmplifyException catch (error) {
    debugPrint('Amplify init fail: ${error.message}');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SelectableText(
              'Failed to initialize Amplify.\n\n$error',
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notificatdoor',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Future<bool> _authState;

  @override
  void initState() {
    super.initState();
    _authState = AppStates.isSignedIn();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _authState,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: SelectableText(
                'Failed to check authentication status\n\n'
                '${snapshot.error}',
              ),
            ),
          );
        }

        if (snapshot.data == true) {
          return Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                WakeOn(),
                DeviceConnectivityIndicator(),
              ],
            ),
          );
        }

        return Login();
      },
    );
  }
}

