import 'package:intl/intl.dart';


class DtUtils {
static String humanDate(DateTime dt) {
return DateFormat('EEE, d MMM yyyy • HH:mm').format(dt);
}
}