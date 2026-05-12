import 'package:get/get.dart';
import 'package:mindpath/core/translations/en_US.dart';
import 'package:mindpath/core/translations/ur_PK.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS,
        'ur_PK': urPK,
      };
}

