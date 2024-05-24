import 'dart:convert';
import 'package:http/http.dart' as http;

class GetData {
  getJsonData(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData;
    }
  }
}
