import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:miru_app/models/extension.dart';

part 'favorite.g.dart';

@collection
@JsonSerializable()
class Favorite {
  Id id = Isar.autoIncrement;
  @Index(composite: [CompositeIndex('url')])
  @Index(name: 'package_url', composite: [CompositeIndex('url')])
  late String package;
  late String url;
  @Enumerated(EnumType.name)
  late ExtensionType type;
  late String title;
  String? cover;
  DateTime date = DateTime.now();
  Favorite();
  factory Favorite.fromJson(Map<String, dynamic> json) =>
      _$FavoriteFromJson(json);

  Map<String, dynamic> toJson() => _$FavoriteToJson(this);
}
