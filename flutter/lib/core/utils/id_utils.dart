import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// 生成唯一 id（对照 H5 的 crypto.randomUUID）。
String uid() => _uuid.v4();
