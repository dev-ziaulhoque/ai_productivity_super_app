import 'package:ai_productivity_super_app/share/services/fcm_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'feature/chat_bot/presentation/pages/chat_page.dart';
import 'feature/notes/bloc/notes_bloc.dart';
import 'feature/notes/data/datasources/notes_local_datasource.dart';
import 'feature/notes/data/datasources/notes_remote_datasource.dart';
import 'feature/notes/domain/repositories/notes_repository_impl.dart';
import 'feature/notes/presentation/pages/notes_page.dart';
import 'feature/tasks/bloc/tasks_bloc.dart';
import 'feature/tasks/data/datasources/tasks_local_datasource.dart';
import 'feature/tasks/data/datasources/tasks_remote_datasource.dart';
import 'feature/tasks/domain/repositories/tasks_repository_impl.dart';
import 'feature/tasks/presentation/pages/tasks_page.dart';


import 'package:ai_productivity_super_app/share/services/database_service.dart';
import 'package:ai_productivity_super_app/share/services/ai_service.dart';
import 'package:ai_productivity_super_app/share/services/notification_service.dart';

import 'feature/tools/presentation/pages/tools_page.dart';
import 'firebase_options.dart';


Future<void> main() async {
  /*INITIALIZE FLUTTER BINDING*/
  WidgetsFlutterBinding.ensureInitialized();

  /*INITIALIZE FIREBASE*/
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /*INITIALIZE TIME ZONE*/
  tz.initializeTimeZones();

  /*INITIALIZE DOTENV*/
  await dotenv.load(fileName: '.env');

  /*INITIALIZE HYDRATED BLOC*/
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );

  /*INITIALIZE DATABASE SERVICE*/
  await DatabaseService.instance.init();

  /*FCM SERVICE*/
  final fcmService = FCMService();
  await fcmService.initialize();

  /*INITIALIZE NOTIFICATION SERVICE*/
  final notificationService = NotificationService();
  try {
    await notificationService.initialize();
  } catch (e) {
    print('Failed to initialize notification service: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NotesBloc>(
          create: (_) {
            final localDs = NotesLocalDataSource();
            final remoteDs = NotesRemoteDataSource(aiService: AiService(localDataSource: localDs));
            final repo = NotesRepositoryImpl(localDataSource: localDs, remoteDataSource: remoteDs);
            return NotesBloc(repo)..add(const LoadNotesEvent());
          },
        ),
        BlocProvider<TasksBloc>(
          create: (_) {
            final localDs = TasksLocalDataSource();
            final remoteDs = TasksRemoteDataSource();
            final repo = TasksRepositoryImpl(localDataSource: localDs, remoteDataSource: remoteDs);
            return TasksBloc(repo)..add(const LoadTasksEvent());
          },
        ),
      ],
      child: MaterialApp(
        title: 'AI Productivity Super App',
        theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)),
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  static const List<Widget> _pages = <Widget>[
    NotesPage(),
    TasksPage(),
    ChatPage(), // New
    ToolsPage(), // Added Tools
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Notes'),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chatbot'), // New
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Tools'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}