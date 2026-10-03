import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/services/ai_service.dart';

final aiServiceProvider = Provider<AiService>((ref) {
  return AiService();
});
