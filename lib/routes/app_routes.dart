import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/landing_page/landing_page.dart';
import '../presentation/species_identification_results/species_identification_results.dart';
import '../presentation/treatment_protocols/treatment_protocols.dart';
import '../presentation/chat_assistant/chat_assistant.dart';
import '../presentation/identification_history/identification_history.dart';
import '../presentation/camera_capture/camera_capture.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splashScreen = '/splash-screen';
  static const String landingPage = '/landing-page';
  static const String speciesIdentificationResults =
      '/species-identification-results';
  static const String treatmentProtocols = '/treatment-protocols';
  static const String chatAssistant = '/chat-assistant';
  static const String identificationHistory = '/identification-history';
  static const String cameraCapture = '/camera-capture';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splashScreen: (context) => const SplashScreen(),
    landingPage: (context) => const LandingPage(),
    speciesIdentificationResults: (context) =>
        const SpeciesIdentificationResults(),
    treatmentProtocols: (context) => const TreatmentProtocols(),
    chatAssistant: (context) => const ChatAssistant(),
    identificationHistory: (context) => const IdentificationHistory(),
    cameraCapture: (context) => const CameraCapture(),
    // TODO: Add your other routes here
  };
}
