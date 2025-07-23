import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/model_manager.dart';
import 'services/chat_service.dart';
import 'services/image_service.dart';
import 'screens/chat_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ModelManager(),
        ),
        Provider(
          create: (context) => ImageService(),
        ),
        ChangeNotifierProxyProvider2<ModelManager, ImageService, ChatService>(
          create: (context) => ChatService(
            context.read<ModelManager>(), 
            context.read<ImageService>(),
          ),
          update: (context, modelManager, imageService, chatService) => 
              chatService ?? ChatService(modelManager, imageService),
        ),
      ],
      child: MaterialApp(
        title: 'Gemma AI Assistant',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const ChatScreen(),
      ),
    );
  }
}
