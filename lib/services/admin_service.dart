import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

import '../constants/api_path.dart';
import '../models/business.dart';
import 'api_service.dart';

Future<Business> updateBusinessApproval(String token, String businessId, bool approved, String note) async {
  Response response = await sendPostRequest(subRoute: businessAdminApproval, token: token, data: {
    "approved": approved,
    "note": note,
    'business_id': businessId,
  });

  if (response.statusCode! > 300) {
    throw Exception('Failed to update business approval. $response');
  }

  return Business.fromMap(token, response.data);
}

Future<List<Business>> getUnapprovedBusinesses(String token, {bool getImages = true}) async {
  Response response = await sendGetRequest(subRoute: businessAdminUnapproved + "?get_images=$getImages", token: token);

  if (response.statusCode! > 300) {
    throw Exception('Failed to get business unapproved. $response');
  }

  List<Business> businesses = (response.data as List<dynamic>).map((e) => Business.fromMap(null, e)).toList();
  if (getImages) {
    Directory path = Directory((await getTemporaryDirectory()).path + "/business_ids");
    if (!(await path.exists())) path.create();
    for (var business in businesses) {
      if (business.ownerId == null) continue;
      File file = File("${path.path}/${business.businessId.hexString}.png");
      file.writeAsBytes(base64Decode(business.ownerId!));
    }
  }
  return businesses;
}

Future<Uint8List> getOwnerIdImageFromBusinessId(String businessId) async {
  Directory dir = Directory((await getTemporaryDirectory()).path + "/business_ids");
  return File('${dir.path}/$businessId.png').readAsBytes();
}

Stream<MapEntry<String, Future<Uint8List>>> getOwnerIdImagesFromBusinessIds(List<String> businessIds) async* {
  Directory dir = Directory((await getTemporaryDirectory()).path + "/business_ids");

  for (var id in businessIds) {
    String path = '${dir.path}/$id.png';
    yield MapEntry(id, File(path).readAsBytes());
  }
}
