// lib/data/model/auth/login_response_model.dart

import 'package:play_lab/data/model/global/global_user_model.dart';
import 'package:play_lab/data/model/global/global_meassage.dart';

class LoginResponseModel {
  String? remark;
  String? status;
  Message? message;
  Data? data;

  LoginResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      remark: json['remark']?.toString(),
      status: json['status']?.toString(),
      message:
          json['message'] != null ? Message.fromJson(json['message']) : null,
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'remark': remark,
      'status': status,
      'message': message?.toJson(),
      'data': data?.toJson(),
    };
  }
}

class Data {
  GlobalUser? user;
  String? accessToken;
  String? tokenType;

  Data({
    this.user,
    this.accessToken,
    this.tokenType,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      user: json['user'] != null ? GlobalUser.fromJson(json['user']) : null,
      accessToken: json['access_token']?.toString(),
      tokenType: json['token_type']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user?.toJson(),
      'access_token': accessToken,
      'token_type': tokenType,
    };
  }
}
