import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:novella_app/component/book_detail.dart';
import 'package:novella_app/firebase_options.dart';
import 'package:novella_app/pages/home/home_page.dart';
import 'package:novella_app/pages/home/novel_detail_page.dart';
import 'package:novella_app/pages/home/novel_reader_page.dart';
import 'package:novella_app/pages/library/library_page.dart';
import 'package:novella_app/pages/master_page.dart';
import 'package:novella_app/pages/notification/notification_page.dart';
import 'package:novella_app/pages/search/search_page.dart';
import 'package:novella_app/pages/writing/writing_or_upload.dart';
import 'package:novella_app/routing_tpl.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  routes: <RouteBase>[
    ShellRoute(
      navigatorKey: GlobalKey<NavigatorState>(),
      builder: (context, state, child) => MasterPage(child: child),
      routes: <RouteBase>[
        GoRoute(
          path: Routes.initial,
          builder: (context, state) => HomePage(),
        ),
        GoRoute(
          path: Routes.home,
          builder: (context, state) => HomePage(),
        ),
        GoRoute(
          path: Routes.search,
          builder: (context, state) => const SearchPage(),
        ),
        GoRoute(
          path: Routes.writing_or_upload,
          builder: (context, state) => const WritingOrUpload(),
        ),
        GoRoute(
          path: Routes.library,
          builder: (context, state) => LibraryPage(),
        ),
        GoRoute(
          path: Routes.notification,
          builder: (context, state) => const NotificationPage(),
        ),
        GoRoute(
          path: '/novel/:id',
          builder: (context, state) {
            final novel = state.extra as Map<String, dynamic>;
            return NovelDetailPage(novel: novel);
          },
        ),
        GoRoute(
          path: Routes.reader,
          builder: (context, state) {
            final pdfPath = state.extra as String;
            return NovelReaderPage(pdfPath: pdfPath);
          },
        ),
      ],
    ),
    // GoRoute(
    //   parentNavigatorKey: _rootNavigatorKey,
    //   path: '/bookDetail/:title',
    //   builder: (context, state) {
    //     final String title = state.pathParameters['title']!;
    //     return BookDetailPage(title: title);
    //   },
    // ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: Routes.bookDetail,
      builder: (context, state) {
        // final String title = state.pathParameters['title']!;
        return BookDetailPage();
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      routerConfig: _router,
    );
  }
}
