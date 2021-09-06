// 拷贝demo到沙盒
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert' as convert;
import 'package:path/path.dart' as path;

Future<void> copyDemoToSandBox() async {
  // 获取cache目录，
  Directory cache = await getTemporaryDirectory();
  print(cache.path);

  final manifestContent = await rootBundle.loadString('AssetManifest.json');
  final Map<String, dynamic> manifestMap = convert.json.decode(manifestContent);

  manifestMap.keys
      .where((key) => (!key.contains('.DS_')) && key.contains('sources'))
      .forEach((element) async {
    // 读取数据
    ByteData data = await rootBundle.load(element);
    Uint8List bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    String dataPath = path.join(cache.path, element);
    File file = File(dataPath);
    await file.create(recursive: true);
    await file.writeAsBytes(bytes);
  });
}
