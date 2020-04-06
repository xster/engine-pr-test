// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrsThatDay _$PrsThatDayFromJson(Map<String, dynamic> json) {
  return PrsThatDay()
    ..totalPrs = json['totalPrs'] as int
    ..iosPrs = json['iosPrs'] as int
    ..androidPrs = json['androidPrs'] as int
    ..enginePrs = json['enginePrs'] as int
    ..totalPrsWithTest = json['totalPrsWithTest'] as int
    ..iosPrsWithTest = json['iosPrsWithTest'] as int
    ..androidPrsWithTest = json['androidPrsWithTest'] as int;
}

Map<String, dynamic> _$PrsThatDayToJson(PrsThatDay instance) =>
    <String, dynamic>{
      'totalPrs': instance.totalPrs,
      'iosPrs': instance.iosPrs,
      'androidPrs': instance.androidPrs,
      'enginePrs': instance.enginePrs,
      'totalPrsWithTest': instance.totalPrsWithTest,
      'iosPrsWithTest': instance.iosPrsWithTest,
      'androidPrsWithTest': instance.androidPrsWithTest,
    };

Histogram _$HistogramFromJson(Map<String, dynamic> json) {
  return Histogram()
    ..dates = (json['dates'] as Map<String, dynamic>).map(
      (k, e) => MapEntry(
          DateTime.parse(k), PrsThatDay.fromJson(e as Map<String, dynamic>)),
    );
}

Map<String, dynamic> _$HistogramToJson(Histogram instance) => <String, dynamic>{
      'dates': instance.dates.map((k, e) => MapEntry(k.toIso8601String(), e)),
    };
