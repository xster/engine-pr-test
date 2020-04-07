import 'package:json_annotation/json_annotation.dart';

part 'data.g.dart';

@JsonSerializable(nullable: false)
class PrsThatDay {
  PrsThatDay();

  int totalPrs = 0;
  int iosPrs = 0;
  int androidPrs = 0;
  int enginePrs = 0;
  int totalPrsWithTest = 0;
  int iosPrsWithTest = 0;
  int androidPrsWithTest = 0;
  List<String> untestedPrs = <String>[];

  factory PrsThatDay.fromJson(Map<String, dynamic> json) => _$PrsThatDayFromJson(json);

  Map<String, dynamic> toJson() => _$PrsThatDayToJson(this);

  @override
  String toString() {
    return '$totalPrsWithTest/$enginePrs/$totalPrs tested. $androidPrsWithTest/$androidPrs android. $iosPrsWithTest/$iosPrs ios.';
  }
}

@JsonSerializable(nullable: false)
class Histogram {
  Histogram() : dates = <DateTime, PrsThatDay>{};

  Map<DateTime, PrsThatDay> dates;

  PrsThatDay operator [](DateTime i) {
    if (!dates.containsKey(i)) {
      dates[i] = PrsThatDay();
    }
    return dates[i];
  }

  factory Histogram.fromJson(Map<String, dynamic> json) => _$HistogramFromJson(json);

  Map<String, dynamic> toJson() => _$HistogramToJson(this);

  @override
  String toString() {
    return dates.keys.map((e) => '${e.toString().split(' ')[0]}: ${dates[e].toString()}').toList().join('\n');
  }
}
