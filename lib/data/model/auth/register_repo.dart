import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:play_lab/constants/api.dart';
import 'package:play_lab/data/model/auth/registration_response_model.dart';

class RegisterRepo {
  Future<RegistrationResponseModel> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final Map<String, String> body = {
      'firstname': firstName,
      'lastname': lastName,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'agree': 'true', // Required by your backend
    };

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.registerEndpoint),
        body: body,
        headers: {
          'Accept': 'application/json',
        },
      );

      final jsonResponse = jsonDecode(response.body);
      return RegistrationResponseModel.fromJson(jsonResponse);
    } catch (e) {
      return RegistrationResponseModel(
        status: "error",
        // message: Message(error: ['e']),
      );
    }
  }
}
