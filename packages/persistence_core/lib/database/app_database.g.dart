// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CurriculumsTable extends Curriculums
    with TableInfo<$CurriculumsTable, Curriculum> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CurriculumsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
      'version', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _totalVolumesMeta =
      const VerificationMeta('totalVolumes');
  @override
  late final GeneratedColumn<int> totalVolumes = GeneratedColumn<int>(
      'total_volumes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(9));
  static const VerificationMeta _weeklyTargetHoursMeta =
      const VerificationMeta('weeklyTargetHours');
  @override
  late final GeneratedColumn<double> weeklyTargetHours =
      GeneratedColumn<double>('weekly_target_hours', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(13.0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        version,
        description,
        totalVolumes,
        weeklyTargetHours,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'curriculums';
  @override
  VerificationContext validateIntegrity(Insertable<Curriculum> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('total_volumes')) {
      context.handle(
          _totalVolumesMeta,
          totalVolumes.isAcceptableOrUnknown(
              data['total_volumes']!, _totalVolumesMeta));
    }
    if (data.containsKey('weekly_target_hours')) {
      context.handle(
          _weeklyTargetHoursMeta,
          weeklyTargetHours.isAcceptableOrUnknown(
              data['weekly_target_hours']!, _weeklyTargetHoursMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Curriculum map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Curriculum(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}version'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      totalVolumes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_volumes'])!,
      weeklyTargetHours: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}weekly_target_hours'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CurriculumsTable createAlias(String alias) {
    return $CurriculumsTable(attachedDatabase, alias);
  }
}

class Curriculum extends DataClass implements Insertable<Curriculum> {
  final String id;
  final String name;
  final String version;
  final String description;
  final int totalVolumes;
  final double weeklyTargetHours;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Curriculum(
      {required this.id,
      required this.name,
      required this.version,
      required this.description,
      required this.totalVolumes,
      required this.weeklyTargetHours,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['version'] = Variable<String>(version);
    map['description'] = Variable<String>(description);
    map['total_volumes'] = Variable<int>(totalVolumes);
    map['weekly_target_hours'] = Variable<double>(weeklyTargetHours);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CurriculumsCompanion toCompanion(bool nullToAbsent) {
    return CurriculumsCompanion(
      id: Value(id),
      name: Value(name),
      version: Value(version),
      description: Value(description),
      totalVolumes: Value(totalVolumes),
      weeklyTargetHours: Value(weeklyTargetHours),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Curriculum.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Curriculum(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      version: serializer.fromJson<String>(json['version']),
      description: serializer.fromJson<String>(json['description']),
      totalVolumes: serializer.fromJson<int>(json['totalVolumes']),
      weeklyTargetHours: serializer.fromJson<double>(json['weeklyTargetHours']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'version': serializer.toJson<String>(version),
      'description': serializer.toJson<String>(description),
      'totalVolumes': serializer.toJson<int>(totalVolumes),
      'weeklyTargetHours': serializer.toJson<double>(weeklyTargetHours),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Curriculum copyWith(
          {String? id,
          String? name,
          String? version,
          String? description,
          int? totalVolumes,
          double? weeklyTargetHours,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Curriculum(
        id: id ?? this.id,
        name: name ?? this.name,
        version: version ?? this.version,
        description: description ?? this.description,
        totalVolumes: totalVolumes ?? this.totalVolumes,
        weeklyTargetHours: weeklyTargetHours ?? this.weeklyTargetHours,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Curriculum copyWithCompanion(CurriculumsCompanion data) {
    return Curriculum(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      version: data.version.present ? data.version.value : this.version,
      description:
          data.description.present ? data.description.value : this.description,
      totalVolumes: data.totalVolumes.present
          ? data.totalVolumes.value
          : this.totalVolumes,
      weeklyTargetHours: data.weeklyTargetHours.present
          ? data.weeklyTargetHours.value
          : this.weeklyTargetHours,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Curriculum(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('version: $version, ')
          ..write('description: $description, ')
          ..write('totalVolumes: $totalVolumes, ')
          ..write('weeklyTargetHours: $weeklyTargetHours, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, version, description, totalVolumes,
      weeklyTargetHours, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Curriculum &&
          other.id == this.id &&
          other.name == this.name &&
          other.version == this.version &&
          other.description == this.description &&
          other.totalVolumes == this.totalVolumes &&
          other.weeklyTargetHours == this.weeklyTargetHours &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CurriculumsCompanion extends UpdateCompanion<Curriculum> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> version;
  final Value<String> description;
  final Value<int> totalVolumes;
  final Value<double> weeklyTargetHours;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CurriculumsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.version = const Value.absent(),
    this.description = const Value.absent(),
    this.totalVolumes = const Value.absent(),
    this.weeklyTargetHours = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CurriculumsCompanion.insert({
    required String id,
    required String name,
    required String version,
    required String description,
    this.totalVolumes = const Value.absent(),
    this.weeklyTargetHours = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        version = Value(version),
        description = Value(description);
  static Insertable<Curriculum> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? version,
    Expression<String>? description,
    Expression<int>? totalVolumes,
    Expression<double>? weeklyTargetHours,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (version != null) 'version': version,
      if (description != null) 'description': description,
      if (totalVolumes != null) 'total_volumes': totalVolumes,
      if (weeklyTargetHours != null) 'weekly_target_hours': weeklyTargetHours,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CurriculumsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? version,
      Value<String>? description,
      Value<int>? totalVolumes,
      Value<double>? weeklyTargetHours,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return CurriculumsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      version: version ?? this.version,
      description: description ?? this.description,
      totalVolumes: totalVolumes ?? this.totalVolumes,
      weeklyTargetHours: weeklyTargetHours ?? this.weeklyTargetHours,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (totalVolumes.present) {
      map['total_volumes'] = Variable<int>(totalVolumes.value);
    }
    if (weeklyTargetHours.present) {
      map['weekly_target_hours'] = Variable<double>(weeklyTargetHours.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CurriculumsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('version: $version, ')
          ..write('description: $description, ')
          ..write('totalVolumes: $totalVolumes, ')
          ..write('weeklyTargetHours: $weeklyTargetHours, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VolumesTable extends Volumes with TableInfo<$VolumesTable, Volume> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VolumesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _curriculumIdMeta =
      const VerificationMeta('curriculumId');
  @override
  late final GeneratedColumn<String> curriculumId = GeneratedColumn<String>(
      'curriculum_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES curriculums (id)'));
  static const VerificationMeta _volumeNumberMeta =
      const VerificationMeta('volumeNumber');
  @override
  late final GeneratedColumn<int> volumeNumber = GeneratedColumn<int>(
      'volume_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _disciplineMeta =
      const VerificationMeta('discipline');
  @override
  late final GeneratedColumn<String> discipline = GeneratedColumn<String>(
      'discipline', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _totalChaptersMeta =
      const VerificationMeta('totalChapters');
  @override
  late final GeneratedColumn<int> totalChapters = GeneratedColumn<int>(
      'total_chapters', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isPrintPreservedMeta =
      const VerificationMeta('isPrintPreserved');
  @override
  late final GeneratedColumn<bool> isPrintPreserved = GeneratedColumn<bool>(
      'is_print_preserved', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_print_preserved" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        curriculumId,
        volumeNumber,
        title,
        discipline,
        description,
        totalChapters,
        isPrintPreserved,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'volumes';
  @override
  VerificationContext validateIntegrity(Insertable<Volume> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('curriculum_id')) {
      context.handle(
          _curriculumIdMeta,
          curriculumId.isAcceptableOrUnknown(
              data['curriculum_id']!, _curriculumIdMeta));
    } else if (isInserting) {
      context.missing(_curriculumIdMeta);
    }
    if (data.containsKey('volume_number')) {
      context.handle(
          _volumeNumberMeta,
          volumeNumber.isAcceptableOrUnknown(
              data['volume_number']!, _volumeNumberMeta));
    } else if (isInserting) {
      context.missing(_volumeNumberMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('discipline')) {
      context.handle(
          _disciplineMeta,
          discipline.isAcceptableOrUnknown(
              data['discipline']!, _disciplineMeta));
    } else if (isInserting) {
      context.missing(_disciplineMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('total_chapters')) {
      context.handle(
          _totalChaptersMeta,
          totalChapters.isAcceptableOrUnknown(
              data['total_chapters']!, _totalChaptersMeta));
    } else if (isInserting) {
      context.missing(_totalChaptersMeta);
    }
    if (data.containsKey('is_print_preserved')) {
      context.handle(
          _isPrintPreservedMeta,
          isPrintPreserved.isAcceptableOrUnknown(
              data['is_print_preserved']!, _isPrintPreservedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Volume map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Volume(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      curriculumId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}curriculum_id'])!,
      volumeNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}volume_number'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      discipline: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}discipline'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      totalChapters: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_chapters'])!,
      isPrintPreserved: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}is_print_preserved'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $VolumesTable createAlias(String alias) {
    return $VolumesTable(attachedDatabase, alias);
  }
}

class Volume extends DataClass implements Insertable<Volume> {
  final String id;
  final String curriculumId;
  final int volumeNumber;
  final String title;
  final String discipline;
  final String description;
  final int totalChapters;
  final bool isPrintPreserved;
  final DateTime createdAt;
  const Volume(
      {required this.id,
      required this.curriculumId,
      required this.volumeNumber,
      required this.title,
      required this.discipline,
      required this.description,
      required this.totalChapters,
      required this.isPrintPreserved,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['curriculum_id'] = Variable<String>(curriculumId);
    map['volume_number'] = Variable<int>(volumeNumber);
    map['title'] = Variable<String>(title);
    map['discipline'] = Variable<String>(discipline);
    map['description'] = Variable<String>(description);
    map['total_chapters'] = Variable<int>(totalChapters);
    map['is_print_preserved'] = Variable<bool>(isPrintPreserved);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  VolumesCompanion toCompanion(bool nullToAbsent) {
    return VolumesCompanion(
      id: Value(id),
      curriculumId: Value(curriculumId),
      volumeNumber: Value(volumeNumber),
      title: Value(title),
      discipline: Value(discipline),
      description: Value(description),
      totalChapters: Value(totalChapters),
      isPrintPreserved: Value(isPrintPreserved),
      createdAt: Value(createdAt),
    );
  }

  factory Volume.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Volume(
      id: serializer.fromJson<String>(json['id']),
      curriculumId: serializer.fromJson<String>(json['curriculumId']),
      volumeNumber: serializer.fromJson<int>(json['volumeNumber']),
      title: serializer.fromJson<String>(json['title']),
      discipline: serializer.fromJson<String>(json['discipline']),
      description: serializer.fromJson<String>(json['description']),
      totalChapters: serializer.fromJson<int>(json['totalChapters']),
      isPrintPreserved: serializer.fromJson<bool>(json['isPrintPreserved']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'curriculumId': serializer.toJson<String>(curriculumId),
      'volumeNumber': serializer.toJson<int>(volumeNumber),
      'title': serializer.toJson<String>(title),
      'discipline': serializer.toJson<String>(discipline),
      'description': serializer.toJson<String>(description),
      'totalChapters': serializer.toJson<int>(totalChapters),
      'isPrintPreserved': serializer.toJson<bool>(isPrintPreserved),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Volume copyWith(
          {String? id,
          String? curriculumId,
          int? volumeNumber,
          String? title,
          String? discipline,
          String? description,
          int? totalChapters,
          bool? isPrintPreserved,
          DateTime? createdAt}) =>
      Volume(
        id: id ?? this.id,
        curriculumId: curriculumId ?? this.curriculumId,
        volumeNumber: volumeNumber ?? this.volumeNumber,
        title: title ?? this.title,
        discipline: discipline ?? this.discipline,
        description: description ?? this.description,
        totalChapters: totalChapters ?? this.totalChapters,
        isPrintPreserved: isPrintPreserved ?? this.isPrintPreserved,
        createdAt: createdAt ?? this.createdAt,
      );
  Volume copyWithCompanion(VolumesCompanion data) {
    return Volume(
      id: data.id.present ? data.id.value : this.id,
      curriculumId: data.curriculumId.present
          ? data.curriculumId.value
          : this.curriculumId,
      volumeNumber: data.volumeNumber.present
          ? data.volumeNumber.value
          : this.volumeNumber,
      title: data.title.present ? data.title.value : this.title,
      discipline:
          data.discipline.present ? data.discipline.value : this.discipline,
      description:
          data.description.present ? data.description.value : this.description,
      totalChapters: data.totalChapters.present
          ? data.totalChapters.value
          : this.totalChapters,
      isPrintPreserved: data.isPrintPreserved.present
          ? data.isPrintPreserved.value
          : this.isPrintPreserved,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Volume(')
          ..write('id: $id, ')
          ..write('curriculumId: $curriculumId, ')
          ..write('volumeNumber: $volumeNumber, ')
          ..write('title: $title, ')
          ..write('discipline: $discipline, ')
          ..write('description: $description, ')
          ..write('totalChapters: $totalChapters, ')
          ..write('isPrintPreserved: $isPrintPreserved, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, curriculumId, volumeNumber, title,
      discipline, description, totalChapters, isPrintPreserved, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Volume &&
          other.id == this.id &&
          other.curriculumId == this.curriculumId &&
          other.volumeNumber == this.volumeNumber &&
          other.title == this.title &&
          other.discipline == this.discipline &&
          other.description == this.description &&
          other.totalChapters == this.totalChapters &&
          other.isPrintPreserved == this.isPrintPreserved &&
          other.createdAt == this.createdAt);
}

class VolumesCompanion extends UpdateCompanion<Volume> {
  final Value<String> id;
  final Value<String> curriculumId;
  final Value<int> volumeNumber;
  final Value<String> title;
  final Value<String> discipline;
  final Value<String> description;
  final Value<int> totalChapters;
  final Value<bool> isPrintPreserved;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const VolumesCompanion({
    this.id = const Value.absent(),
    this.curriculumId = const Value.absent(),
    this.volumeNumber = const Value.absent(),
    this.title = const Value.absent(),
    this.discipline = const Value.absent(),
    this.description = const Value.absent(),
    this.totalChapters = const Value.absent(),
    this.isPrintPreserved = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VolumesCompanion.insert({
    required String id,
    required String curriculumId,
    required int volumeNumber,
    required String title,
    required String discipline,
    required String description,
    required int totalChapters,
    this.isPrintPreserved = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        curriculumId = Value(curriculumId),
        volumeNumber = Value(volumeNumber),
        title = Value(title),
        discipline = Value(discipline),
        description = Value(description),
        totalChapters = Value(totalChapters);
  static Insertable<Volume> custom({
    Expression<String>? id,
    Expression<String>? curriculumId,
    Expression<int>? volumeNumber,
    Expression<String>? title,
    Expression<String>? discipline,
    Expression<String>? description,
    Expression<int>? totalChapters,
    Expression<bool>? isPrintPreserved,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (curriculumId != null) 'curriculum_id': curriculumId,
      if (volumeNumber != null) 'volume_number': volumeNumber,
      if (title != null) 'title': title,
      if (discipline != null) 'discipline': discipline,
      if (description != null) 'description': description,
      if (totalChapters != null) 'total_chapters': totalChapters,
      if (isPrintPreserved != null) 'is_print_preserved': isPrintPreserved,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VolumesCompanion copyWith(
      {Value<String>? id,
      Value<String>? curriculumId,
      Value<int>? volumeNumber,
      Value<String>? title,
      Value<String>? discipline,
      Value<String>? description,
      Value<int>? totalChapters,
      Value<bool>? isPrintPreserved,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return VolumesCompanion(
      id: id ?? this.id,
      curriculumId: curriculumId ?? this.curriculumId,
      volumeNumber: volumeNumber ?? this.volumeNumber,
      title: title ?? this.title,
      discipline: discipline ?? this.discipline,
      description: description ?? this.description,
      totalChapters: totalChapters ?? this.totalChapters,
      isPrintPreserved: isPrintPreserved ?? this.isPrintPreserved,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (curriculumId.present) {
      map['curriculum_id'] = Variable<String>(curriculumId.value);
    }
    if (volumeNumber.present) {
      map['volume_number'] = Variable<int>(volumeNumber.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (discipline.present) {
      map['discipline'] = Variable<String>(discipline.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (totalChapters.present) {
      map['total_chapters'] = Variable<int>(totalChapters.value);
    }
    if (isPrintPreserved.present) {
      map['is_print_preserved'] = Variable<bool>(isPrintPreserved.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VolumesCompanion(')
          ..write('id: $id, ')
          ..write('curriculumId: $curriculumId, ')
          ..write('volumeNumber: $volumeNumber, ')
          ..write('title: $title, ')
          ..write('discipline: $discipline, ')
          ..write('description: $description, ')
          ..write('totalChapters: $totalChapters, ')
          ..write('isPrintPreserved: $isPrintPreserved, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChaptersTable extends Chapters with TableInfo<$ChaptersTable, Chapter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChaptersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _volumeIdMeta =
      const VerificationMeta('volumeId');
  @override
  late final GeneratedColumn<String> volumeId = GeneratedColumn<String>(
      'volume_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES volumes (id)'));
  static const VerificationMeta _chapterNumberMeta =
      const VerificationMeta('chapterNumber');
  @override
  late final GeneratedColumn<int> chapterNumber = GeneratedColumn<int>(
      'chapter_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _editorialStatusMeta =
      const VerificationMeta('editorialStatus');
  @override
  late final GeneratedColumn<String> editorialStatus = GeneratedColumn<String>(
      'editorial_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Planejado'));
  static const VerificationMeta _activeRevisionIdMeta =
      const VerificationMeta('activeRevisionId');
  @override
  late final GeneratedColumn<String> activeRevisionId = GeneratedColumn<String>(
      'active_revision_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _orderIndexMeta =
      const VerificationMeta('orderIndex');
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
      'order_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        volumeId,
        chapterNumber,
        title,
        editorialStatus,
        activeRevisionId,
        orderIndex,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chapters';
  @override
  VerificationContext validateIntegrity(Insertable<Chapter> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('volume_id')) {
      context.handle(_volumeIdMeta,
          volumeId.isAcceptableOrUnknown(data['volume_id']!, _volumeIdMeta));
    } else if (isInserting) {
      context.missing(_volumeIdMeta);
    }
    if (data.containsKey('chapter_number')) {
      context.handle(
          _chapterNumberMeta,
          chapterNumber.isAcceptableOrUnknown(
              data['chapter_number']!, _chapterNumberMeta));
    } else if (isInserting) {
      context.missing(_chapterNumberMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('editorial_status')) {
      context.handle(
          _editorialStatusMeta,
          editorialStatus.isAcceptableOrUnknown(
              data['editorial_status']!, _editorialStatusMeta));
    }
    if (data.containsKey('active_revision_id')) {
      context.handle(
          _activeRevisionIdMeta,
          activeRevisionId.isAcceptableOrUnknown(
              data['active_revision_id']!, _activeRevisionIdMeta));
    }
    if (data.containsKey('order_index')) {
      context.handle(
          _orderIndexMeta,
          orderIndex.isAcceptableOrUnknown(
              data['order_index']!, _orderIndexMeta));
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Chapter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Chapter(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      volumeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}volume_id'])!,
      chapterNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chapter_number'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      editorialStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}editorial_status'])!,
      activeRevisionId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}active_revision_id']),
      orderIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_index'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ChaptersTable createAlias(String alias) {
    return $ChaptersTable(attachedDatabase, alias);
  }
}

class Chapter extends DataClass implements Insertable<Chapter> {
  final String id;
  final String volumeId;
  final int chapterNumber;
  final String title;
  final String editorialStatus;
  final String? activeRevisionId;
  final int orderIndex;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Chapter(
      {required this.id,
      required this.volumeId,
      required this.chapterNumber,
      required this.title,
      required this.editorialStatus,
      this.activeRevisionId,
      required this.orderIndex,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['volume_id'] = Variable<String>(volumeId);
    map['chapter_number'] = Variable<int>(chapterNumber);
    map['title'] = Variable<String>(title);
    map['editorial_status'] = Variable<String>(editorialStatus);
    if (!nullToAbsent || activeRevisionId != null) {
      map['active_revision_id'] = Variable<String>(activeRevisionId);
    }
    map['order_index'] = Variable<int>(orderIndex);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ChaptersCompanion toCompanion(bool nullToAbsent) {
    return ChaptersCompanion(
      id: Value(id),
      volumeId: Value(volumeId),
      chapterNumber: Value(chapterNumber),
      title: Value(title),
      editorialStatus: Value(editorialStatus),
      activeRevisionId: activeRevisionId == null && nullToAbsent
          ? const Value.absent()
          : Value(activeRevisionId),
      orderIndex: Value(orderIndex),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Chapter.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Chapter(
      id: serializer.fromJson<String>(json['id']),
      volumeId: serializer.fromJson<String>(json['volumeId']),
      chapterNumber: serializer.fromJson<int>(json['chapterNumber']),
      title: serializer.fromJson<String>(json['title']),
      editorialStatus: serializer.fromJson<String>(json['editorialStatus']),
      activeRevisionId: serializer.fromJson<String?>(json['activeRevisionId']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'volumeId': serializer.toJson<String>(volumeId),
      'chapterNumber': serializer.toJson<int>(chapterNumber),
      'title': serializer.toJson<String>(title),
      'editorialStatus': serializer.toJson<String>(editorialStatus),
      'activeRevisionId': serializer.toJson<String?>(activeRevisionId),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Chapter copyWith(
          {String? id,
          String? volumeId,
          int? chapterNumber,
          String? title,
          String? editorialStatus,
          Value<String?> activeRevisionId = const Value.absent(),
          int? orderIndex,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Chapter(
        id: id ?? this.id,
        volumeId: volumeId ?? this.volumeId,
        chapterNumber: chapterNumber ?? this.chapterNumber,
        title: title ?? this.title,
        editorialStatus: editorialStatus ?? this.editorialStatus,
        activeRevisionId: activeRevisionId.present
            ? activeRevisionId.value
            : this.activeRevisionId,
        orderIndex: orderIndex ?? this.orderIndex,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Chapter copyWithCompanion(ChaptersCompanion data) {
    return Chapter(
      id: data.id.present ? data.id.value : this.id,
      volumeId: data.volumeId.present ? data.volumeId.value : this.volumeId,
      chapterNumber: data.chapterNumber.present
          ? data.chapterNumber.value
          : this.chapterNumber,
      title: data.title.present ? data.title.value : this.title,
      editorialStatus: data.editorialStatus.present
          ? data.editorialStatus.value
          : this.editorialStatus,
      activeRevisionId: data.activeRevisionId.present
          ? data.activeRevisionId.value
          : this.activeRevisionId,
      orderIndex:
          data.orderIndex.present ? data.orderIndex.value : this.orderIndex,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Chapter(')
          ..write('id: $id, ')
          ..write('volumeId: $volumeId, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('title: $title, ')
          ..write('editorialStatus: $editorialStatus, ')
          ..write('activeRevisionId: $activeRevisionId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, volumeId, chapterNumber, title,
      editorialStatus, activeRevisionId, orderIndex, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Chapter &&
          other.id == this.id &&
          other.volumeId == this.volumeId &&
          other.chapterNumber == this.chapterNumber &&
          other.title == this.title &&
          other.editorialStatus == this.editorialStatus &&
          other.activeRevisionId == this.activeRevisionId &&
          other.orderIndex == this.orderIndex &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ChaptersCompanion extends UpdateCompanion<Chapter> {
  final Value<String> id;
  final Value<String> volumeId;
  final Value<int> chapterNumber;
  final Value<String> title;
  final Value<String> editorialStatus;
  final Value<String?> activeRevisionId;
  final Value<int> orderIndex;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ChaptersCompanion({
    this.id = const Value.absent(),
    this.volumeId = const Value.absent(),
    this.chapterNumber = const Value.absent(),
    this.title = const Value.absent(),
    this.editorialStatus = const Value.absent(),
    this.activeRevisionId = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChaptersCompanion.insert({
    required String id,
    required String volumeId,
    required int chapterNumber,
    required String title,
    this.editorialStatus = const Value.absent(),
    this.activeRevisionId = const Value.absent(),
    required int orderIndex,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        volumeId = Value(volumeId),
        chapterNumber = Value(chapterNumber),
        title = Value(title),
        orderIndex = Value(orderIndex);
  static Insertable<Chapter> custom({
    Expression<String>? id,
    Expression<String>? volumeId,
    Expression<int>? chapterNumber,
    Expression<String>? title,
    Expression<String>? editorialStatus,
    Expression<String>? activeRevisionId,
    Expression<int>? orderIndex,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (volumeId != null) 'volume_id': volumeId,
      if (chapterNumber != null) 'chapter_number': chapterNumber,
      if (title != null) 'title': title,
      if (editorialStatus != null) 'editorial_status': editorialStatus,
      if (activeRevisionId != null) 'active_revision_id': activeRevisionId,
      if (orderIndex != null) 'order_index': orderIndex,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChaptersCompanion copyWith(
      {Value<String>? id,
      Value<String>? volumeId,
      Value<int>? chapterNumber,
      Value<String>? title,
      Value<String>? editorialStatus,
      Value<String?>? activeRevisionId,
      Value<int>? orderIndex,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ChaptersCompanion(
      id: id ?? this.id,
      volumeId: volumeId ?? this.volumeId,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      title: title ?? this.title,
      editorialStatus: editorialStatus ?? this.editorialStatus,
      activeRevisionId: activeRevisionId ?? this.activeRevisionId,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (volumeId.present) {
      map['volume_id'] = Variable<String>(volumeId.value);
    }
    if (chapterNumber.present) {
      map['chapter_number'] = Variable<int>(chapterNumber.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (editorialStatus.present) {
      map['editorial_status'] = Variable<String>(editorialStatus.value);
    }
    if (activeRevisionId.present) {
      map['active_revision_id'] = Variable<String>(activeRevisionId.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChaptersCompanion(')
          ..write('id: $id, ')
          ..write('volumeId: $volumeId, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('title: $title, ')
          ..write('editorialStatus: $editorialStatus, ')
          ..write('activeRevisionId: $activeRevisionId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LessonsTable extends Lessons with TableInfo<$LessonsTable, Lesson> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LessonsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chapterIdMeta =
      const VerificationMeta('chapterId');
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
      'chapter_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES chapters (id)'));
  static const VerificationMeta _lessonNumberMeta =
      const VerificationMeta('lessonNumber');
  @override
  late final GeneratedColumn<int> lessonNumber = GeneratedColumn<int>(
      'lesson_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _stepCountMeta =
      const VerificationMeta('stepCount');
  @override
  late final GeneratedColumn<int> stepCount = GeneratedColumn<int>(
      'step_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(10));
  static const VerificationMeta _estimatedMinutesMeta =
      const VerificationMeta('estimatedMinutes');
  @override
  late final GeneratedColumn<int> estimatedMinutes = GeneratedColumn<int>(
      'estimated_minutes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(30));
  static const VerificationMeta _orderIndexMeta =
      const VerificationMeta('orderIndex');
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
      'order_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        chapterId,
        lessonNumber,
        title,
        stepCount,
        estimatedMinutes,
        orderIndex
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lessons';
  @override
  VerificationContext validateIntegrity(Insertable<Lesson> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(_chapterIdMeta,
          chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta));
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('lesson_number')) {
      context.handle(
          _lessonNumberMeta,
          lessonNumber.isAcceptableOrUnknown(
              data['lesson_number']!, _lessonNumberMeta));
    } else if (isInserting) {
      context.missing(_lessonNumberMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('step_count')) {
      context.handle(_stepCountMeta,
          stepCount.isAcceptableOrUnknown(data['step_count']!, _stepCountMeta));
    }
    if (data.containsKey('estimated_minutes')) {
      context.handle(
          _estimatedMinutesMeta,
          estimatedMinutes.isAcceptableOrUnknown(
              data['estimated_minutes']!, _estimatedMinutesMeta));
    }
    if (data.containsKey('order_index')) {
      context.handle(
          _orderIndexMeta,
          orderIndex.isAcceptableOrUnknown(
              data['order_index']!, _orderIndexMeta));
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Lesson map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Lesson(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      chapterId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chapter_id'])!,
      lessonNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}lesson_number'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      stepCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}step_count'])!,
      estimatedMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}estimated_minutes'])!,
      orderIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_index'])!,
    );
  }

  @override
  $LessonsTable createAlias(String alias) {
    return $LessonsTable(attachedDatabase, alias);
  }
}

class Lesson extends DataClass implements Insertable<Lesson> {
  final String id;
  final String chapterId;
  final int lessonNumber;
  final String title;
  final int stepCount;
  final int estimatedMinutes;
  final int orderIndex;
  const Lesson(
      {required this.id,
      required this.chapterId,
      required this.lessonNumber,
      required this.title,
      required this.stepCount,
      required this.estimatedMinutes,
      required this.orderIndex});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['chapter_id'] = Variable<String>(chapterId);
    map['lesson_number'] = Variable<int>(lessonNumber);
    map['title'] = Variable<String>(title);
    map['step_count'] = Variable<int>(stepCount);
    map['estimated_minutes'] = Variable<int>(estimatedMinutes);
    map['order_index'] = Variable<int>(orderIndex);
    return map;
  }

  LessonsCompanion toCompanion(bool nullToAbsent) {
    return LessonsCompanion(
      id: Value(id),
      chapterId: Value(chapterId),
      lessonNumber: Value(lessonNumber),
      title: Value(title),
      stepCount: Value(stepCount),
      estimatedMinutes: Value(estimatedMinutes),
      orderIndex: Value(orderIndex),
    );
  }

  factory Lesson.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Lesson(
      id: serializer.fromJson<String>(json['id']),
      chapterId: serializer.fromJson<String>(json['chapterId']),
      lessonNumber: serializer.fromJson<int>(json['lessonNumber']),
      title: serializer.fromJson<String>(json['title']),
      stepCount: serializer.fromJson<int>(json['stepCount']),
      estimatedMinutes: serializer.fromJson<int>(json['estimatedMinutes']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'chapterId': serializer.toJson<String>(chapterId),
      'lessonNumber': serializer.toJson<int>(lessonNumber),
      'title': serializer.toJson<String>(title),
      'stepCount': serializer.toJson<int>(stepCount),
      'estimatedMinutes': serializer.toJson<int>(estimatedMinutes),
      'orderIndex': serializer.toJson<int>(orderIndex),
    };
  }

  Lesson copyWith(
          {String? id,
          String? chapterId,
          int? lessonNumber,
          String? title,
          int? stepCount,
          int? estimatedMinutes,
          int? orderIndex}) =>
      Lesson(
        id: id ?? this.id,
        chapterId: chapterId ?? this.chapterId,
        lessonNumber: lessonNumber ?? this.lessonNumber,
        title: title ?? this.title,
        stepCount: stepCount ?? this.stepCount,
        estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
        orderIndex: orderIndex ?? this.orderIndex,
      );
  Lesson copyWithCompanion(LessonsCompanion data) {
    return Lesson(
      id: data.id.present ? data.id.value : this.id,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      lessonNumber: data.lessonNumber.present
          ? data.lessonNumber.value
          : this.lessonNumber,
      title: data.title.present ? data.title.value : this.title,
      stepCount: data.stepCount.present ? data.stepCount.value : this.stepCount,
      estimatedMinutes: data.estimatedMinutes.present
          ? data.estimatedMinutes.value
          : this.estimatedMinutes,
      orderIndex:
          data.orderIndex.present ? data.orderIndex.value : this.orderIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Lesson(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('lessonNumber: $lessonNumber, ')
          ..write('title: $title, ')
          ..write('stepCount: $stepCount, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, chapterId, lessonNumber, title, stepCount,
      estimatedMinutes, orderIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Lesson &&
          other.id == this.id &&
          other.chapterId == this.chapterId &&
          other.lessonNumber == this.lessonNumber &&
          other.title == this.title &&
          other.stepCount == this.stepCount &&
          other.estimatedMinutes == this.estimatedMinutes &&
          other.orderIndex == this.orderIndex);
}

class LessonsCompanion extends UpdateCompanion<Lesson> {
  final Value<String> id;
  final Value<String> chapterId;
  final Value<int> lessonNumber;
  final Value<String> title;
  final Value<int> stepCount;
  final Value<int> estimatedMinutes;
  final Value<int> orderIndex;
  final Value<int> rowid;
  const LessonsCompanion({
    this.id = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.lessonNumber = const Value.absent(),
    this.title = const Value.absent(),
    this.stepCount = const Value.absent(),
    this.estimatedMinutes = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LessonsCompanion.insert({
    required String id,
    required String chapterId,
    required int lessonNumber,
    required String title,
    this.stepCount = const Value.absent(),
    this.estimatedMinutes = const Value.absent(),
    required int orderIndex,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        chapterId = Value(chapterId),
        lessonNumber = Value(lessonNumber),
        title = Value(title),
        orderIndex = Value(orderIndex);
  static Insertable<Lesson> custom({
    Expression<String>? id,
    Expression<String>? chapterId,
    Expression<int>? lessonNumber,
    Expression<String>? title,
    Expression<int>? stepCount,
    Expression<int>? estimatedMinutes,
    Expression<int>? orderIndex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chapterId != null) 'chapter_id': chapterId,
      if (lessonNumber != null) 'lesson_number': lessonNumber,
      if (title != null) 'title': title,
      if (stepCount != null) 'step_count': stepCount,
      if (estimatedMinutes != null) 'estimated_minutes': estimatedMinutes,
      if (orderIndex != null) 'order_index': orderIndex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LessonsCompanion copyWith(
      {Value<String>? id,
      Value<String>? chapterId,
      Value<int>? lessonNumber,
      Value<String>? title,
      Value<int>? stepCount,
      Value<int>? estimatedMinutes,
      Value<int>? orderIndex,
      Value<int>? rowid}) {
    return LessonsCompanion(
      id: id ?? this.id,
      chapterId: chapterId ?? this.chapterId,
      lessonNumber: lessonNumber ?? this.lessonNumber,
      title: title ?? this.title,
      stepCount: stepCount ?? this.stepCount,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      orderIndex: orderIndex ?? this.orderIndex,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (lessonNumber.present) {
      map['lesson_number'] = Variable<int>(lessonNumber.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (stepCount.present) {
      map['step_count'] = Variable<int>(stepCount.value);
    }
    if (estimatedMinutes.present) {
      map['estimated_minutes'] = Variable<int>(estimatedMinutes.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LessonsCompanion(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('lessonNumber: $lessonNumber, ')
          ..write('title: $title, ')
          ..write('stepCount: $stepCount, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LearningObjectivesTable extends LearningObjectives
    with TableInfo<$LearningObjectivesTable, LearningObjective> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LearningObjectivesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chapterIdMeta =
      const VerificationMeta('chapterId');
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
      'chapter_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES chapters (id)'));
  static const VerificationMeta _lessonIdMeta =
      const VerificationMeta('lessonId');
  @override
  late final GeneratedColumn<String> lessonId = GeneratedColumn<String>(
      'lesson_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES lessons (id)'));
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bloomTaxonomyLevelMeta =
      const VerificationMeta('bloomTaxonomyLevel');
  @override
  late final GeneratedColumn<String> bloomTaxonomyLevel =
      GeneratedColumn<String>('bloom_taxonomy_level', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _orderIndexMeta =
      const VerificationMeta('orderIndex');
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
      'order_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, chapterId, lessonId, description, bloomTaxonomyLevel, orderIndex];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'learning_objectives';
  @override
  VerificationContext validateIntegrity(Insertable<LearningObjective> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(_chapterIdMeta,
          chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta));
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('lesson_id')) {
      context.handle(_lessonIdMeta,
          lessonId.isAcceptableOrUnknown(data['lesson_id']!, _lessonIdMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('bloom_taxonomy_level')) {
      context.handle(
          _bloomTaxonomyLevelMeta,
          bloomTaxonomyLevel.isAcceptableOrUnknown(
              data['bloom_taxonomy_level']!, _bloomTaxonomyLevelMeta));
    } else if (isInserting) {
      context.missing(_bloomTaxonomyLevelMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
          _orderIndexMeta,
          orderIndex.isAcceptableOrUnknown(
              data['order_index']!, _orderIndexMeta));
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LearningObjective map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LearningObjective(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      chapterId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chapter_id'])!,
      lessonId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lesson_id']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      bloomTaxonomyLevel: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}bloom_taxonomy_level'])!,
      orderIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_index'])!,
    );
  }

  @override
  $LearningObjectivesTable createAlias(String alias) {
    return $LearningObjectivesTable(attachedDatabase, alias);
  }
}

class LearningObjective extends DataClass
    implements Insertable<LearningObjective> {
  final String id;
  final String chapterId;
  final String? lessonId;
  final String description;
  final String bloomTaxonomyLevel;
  final int orderIndex;
  const LearningObjective(
      {required this.id,
      required this.chapterId,
      this.lessonId,
      required this.description,
      required this.bloomTaxonomyLevel,
      required this.orderIndex});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['chapter_id'] = Variable<String>(chapterId);
    if (!nullToAbsent || lessonId != null) {
      map['lesson_id'] = Variable<String>(lessonId);
    }
    map['description'] = Variable<String>(description);
    map['bloom_taxonomy_level'] = Variable<String>(bloomTaxonomyLevel);
    map['order_index'] = Variable<int>(orderIndex);
    return map;
  }

  LearningObjectivesCompanion toCompanion(bool nullToAbsent) {
    return LearningObjectivesCompanion(
      id: Value(id),
      chapterId: Value(chapterId),
      lessonId: lessonId == null && nullToAbsent
          ? const Value.absent()
          : Value(lessonId),
      description: Value(description),
      bloomTaxonomyLevel: Value(bloomTaxonomyLevel),
      orderIndex: Value(orderIndex),
    );
  }

  factory LearningObjective.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LearningObjective(
      id: serializer.fromJson<String>(json['id']),
      chapterId: serializer.fromJson<String>(json['chapterId']),
      lessonId: serializer.fromJson<String?>(json['lessonId']),
      description: serializer.fromJson<String>(json['description']),
      bloomTaxonomyLevel:
          serializer.fromJson<String>(json['bloomTaxonomyLevel']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'chapterId': serializer.toJson<String>(chapterId),
      'lessonId': serializer.toJson<String?>(lessonId),
      'description': serializer.toJson<String>(description),
      'bloomTaxonomyLevel': serializer.toJson<String>(bloomTaxonomyLevel),
      'orderIndex': serializer.toJson<int>(orderIndex),
    };
  }

  LearningObjective copyWith(
          {String? id,
          String? chapterId,
          Value<String?> lessonId = const Value.absent(),
          String? description,
          String? bloomTaxonomyLevel,
          int? orderIndex}) =>
      LearningObjective(
        id: id ?? this.id,
        chapterId: chapterId ?? this.chapterId,
        lessonId: lessonId.present ? lessonId.value : this.lessonId,
        description: description ?? this.description,
        bloomTaxonomyLevel: bloomTaxonomyLevel ?? this.bloomTaxonomyLevel,
        orderIndex: orderIndex ?? this.orderIndex,
      );
  LearningObjective copyWithCompanion(LearningObjectivesCompanion data) {
    return LearningObjective(
      id: data.id.present ? data.id.value : this.id,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      lessonId: data.lessonId.present ? data.lessonId.value : this.lessonId,
      description:
          data.description.present ? data.description.value : this.description,
      bloomTaxonomyLevel: data.bloomTaxonomyLevel.present
          ? data.bloomTaxonomyLevel.value
          : this.bloomTaxonomyLevel,
      orderIndex:
          data.orderIndex.present ? data.orderIndex.value : this.orderIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LearningObjective(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('lessonId: $lessonId, ')
          ..write('description: $description, ')
          ..write('bloomTaxonomyLevel: $bloomTaxonomyLevel, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, chapterId, lessonId, description, bloomTaxonomyLevel, orderIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LearningObjective &&
          other.id == this.id &&
          other.chapterId == this.chapterId &&
          other.lessonId == this.lessonId &&
          other.description == this.description &&
          other.bloomTaxonomyLevel == this.bloomTaxonomyLevel &&
          other.orderIndex == this.orderIndex);
}

class LearningObjectivesCompanion extends UpdateCompanion<LearningObjective> {
  final Value<String> id;
  final Value<String> chapterId;
  final Value<String?> lessonId;
  final Value<String> description;
  final Value<String> bloomTaxonomyLevel;
  final Value<int> orderIndex;
  final Value<int> rowid;
  const LearningObjectivesCompanion({
    this.id = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.lessonId = const Value.absent(),
    this.description = const Value.absent(),
    this.bloomTaxonomyLevel = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LearningObjectivesCompanion.insert({
    required String id,
    required String chapterId,
    this.lessonId = const Value.absent(),
    required String description,
    required String bloomTaxonomyLevel,
    required int orderIndex,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        chapterId = Value(chapterId),
        description = Value(description),
        bloomTaxonomyLevel = Value(bloomTaxonomyLevel),
        orderIndex = Value(orderIndex);
  static Insertable<LearningObjective> custom({
    Expression<String>? id,
    Expression<String>? chapterId,
    Expression<String>? lessonId,
    Expression<String>? description,
    Expression<String>? bloomTaxonomyLevel,
    Expression<int>? orderIndex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chapterId != null) 'chapter_id': chapterId,
      if (lessonId != null) 'lesson_id': lessonId,
      if (description != null) 'description': description,
      if (bloomTaxonomyLevel != null)
        'bloom_taxonomy_level': bloomTaxonomyLevel,
      if (orderIndex != null) 'order_index': orderIndex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LearningObjectivesCompanion copyWith(
      {Value<String>? id,
      Value<String>? chapterId,
      Value<String?>? lessonId,
      Value<String>? description,
      Value<String>? bloomTaxonomyLevel,
      Value<int>? orderIndex,
      Value<int>? rowid}) {
    return LearningObjectivesCompanion(
      id: id ?? this.id,
      chapterId: chapterId ?? this.chapterId,
      lessonId: lessonId ?? this.lessonId,
      description: description ?? this.description,
      bloomTaxonomyLevel: bloomTaxonomyLevel ?? this.bloomTaxonomyLevel,
      orderIndex: orderIndex ?? this.orderIndex,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (lessonId.present) {
      map['lesson_id'] = Variable<String>(lessonId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (bloomTaxonomyLevel.present) {
      map['bloom_taxonomy_level'] = Variable<String>(bloomTaxonomyLevel.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LearningObjectivesCompanion(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('lessonId: $lessonId, ')
          ..write('description: $description, ')
          ..write('bloomTaxonomyLevel: $bloomTaxonomyLevel, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CompetenciesTable extends Competencies
    with TableInfo<$CompetenciesTable, Competency> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompetenciesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _domainMeta = const VerificationMeta('domain');
  @override
  late final GeneratedColumn<String> domain = GeneratedColumn<String>(
      'domain', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetScoreMeta =
      const VerificationMeta('targetScore');
  @override
  late final GeneratedColumn<double> targetScore = GeneratedColumn<double>(
      'target_score', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.80));
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, code, name, domain, targetScore, description];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'competencies';
  @override
  VerificationContext validateIntegrity(Insertable<Competency> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('domain')) {
      context.handle(_domainMeta,
          domain.isAcceptableOrUnknown(data['domain']!, _domainMeta));
    } else if (isInserting) {
      context.missing(_domainMeta);
    }
    if (data.containsKey('target_score')) {
      context.handle(
          _targetScoreMeta,
          targetScore.isAcceptableOrUnknown(
              data['target_score']!, _targetScoreMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Competency map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Competency(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      domain: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}domain'])!,
      targetScore: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}target_score'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
    );
  }

  @override
  $CompetenciesTable createAlias(String alias) {
    return $CompetenciesTable(attachedDatabase, alias);
  }
}

class Competency extends DataClass implements Insertable<Competency> {
  final String id;
  final String code;
  final String name;
  final String domain;
  final double targetScore;
  final String description;
  const Competency(
      {required this.id,
      required this.code,
      required this.name,
      required this.domain,
      required this.targetScore,
      required this.description});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['domain'] = Variable<String>(domain);
    map['target_score'] = Variable<double>(targetScore);
    map['description'] = Variable<String>(description);
    return map;
  }

  CompetenciesCompanion toCompanion(bool nullToAbsent) {
    return CompetenciesCompanion(
      id: Value(id),
      code: Value(code),
      name: Value(name),
      domain: Value(domain),
      targetScore: Value(targetScore),
      description: Value(description),
    );
  }

  factory Competency.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Competency(
      id: serializer.fromJson<String>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      domain: serializer.fromJson<String>(json['domain']),
      targetScore: serializer.fromJson<double>(json['targetScore']),
      description: serializer.fromJson<String>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'domain': serializer.toJson<String>(domain),
      'targetScore': serializer.toJson<double>(targetScore),
      'description': serializer.toJson<String>(description),
    };
  }

  Competency copyWith(
          {String? id,
          String? code,
          String? name,
          String? domain,
          double? targetScore,
          String? description}) =>
      Competency(
        id: id ?? this.id,
        code: code ?? this.code,
        name: name ?? this.name,
        domain: domain ?? this.domain,
        targetScore: targetScore ?? this.targetScore,
        description: description ?? this.description,
      );
  Competency copyWithCompanion(CompetenciesCompanion data) {
    return Competency(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      domain: data.domain.present ? data.domain.value : this.domain,
      targetScore:
          data.targetScore.present ? data.targetScore.value : this.targetScore,
      description:
          data.description.present ? data.description.value : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Competency(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('domain: $domain, ')
          ..write('targetScore: $targetScore, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, code, name, domain, targetScore, description);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Competency &&
          other.id == this.id &&
          other.code == this.code &&
          other.name == this.name &&
          other.domain == this.domain &&
          other.targetScore == this.targetScore &&
          other.description == this.description);
}

class CompetenciesCompanion extends UpdateCompanion<Competency> {
  final Value<String> id;
  final Value<String> code;
  final Value<String> name;
  final Value<String> domain;
  final Value<double> targetScore;
  final Value<String> description;
  final Value<int> rowid;
  const CompetenciesCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.domain = const Value.absent(),
    this.targetScore = const Value.absent(),
    this.description = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompetenciesCompanion.insert({
    required String id,
    required String code,
    required String name,
    required String domain,
    this.targetScore = const Value.absent(),
    required String description,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        code = Value(code),
        name = Value(name),
        domain = Value(domain),
        description = Value(description);
  static Insertable<Competency> custom({
    Expression<String>? id,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? domain,
    Expression<double>? targetScore,
    Expression<String>? description,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (domain != null) 'domain': domain,
      if (targetScore != null) 'target_score': targetScore,
      if (description != null) 'description': description,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompetenciesCompanion copyWith(
      {Value<String>? id,
      Value<String>? code,
      Value<String>? name,
      Value<String>? domain,
      Value<double>? targetScore,
      Value<String>? description,
      Value<int>? rowid}) {
    return CompetenciesCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      domain: domain ?? this.domain,
      targetScore: targetScore ?? this.targetScore,
      description: description ?? this.description,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (domain.present) {
      map['domain'] = Variable<String>(domain.value);
    }
    if (targetScore.present) {
      map['target_score'] = Variable<double>(targetScore.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompetenciesCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('domain: $domain, ')
          ..write('targetScore: $targetScore, ')
          ..write('description: $description, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExercisesTable extends Exercises
    with TableInfo<$ExercisesTable, Exercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chapterIdMeta =
      const VerificationMeta('chapterId');
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
      'chapter_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES chapters (id)'));
  static const VerificationMeta _lessonIdMeta =
      const VerificationMeta('lessonId');
  @override
  late final GeneratedColumn<String> lessonId = GeneratedColumn<String>(
      'lesson_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES lessons (id)'));
  static const VerificationMeta _exerciseTypeMeta =
      const VerificationMeta('exerciseType');
  @override
  late final GeneratedColumn<String> exerciseType = GeneratedColumn<String>(
      'exercise_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _problemPromptMeta =
      const VerificationMeta('problemPrompt');
  @override
  late final GeneratedColumn<String> problemPrompt = GeneratedColumn<String>(
      'problem_prompt', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _solvedSolutionMeta =
      const VerificationMeta('solvedSolution');
  @override
  late final GeneratedColumn<String> solvedSolution = GeneratedColumn<String>(
      'solved_solution', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _orderIndexMeta =
      const VerificationMeta('orderIndex');
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
      'order_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        chapterId,
        lessonId,
        exerciseType,
        problemPrompt,
        solvedSolution,
        orderIndex
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises';
  @override
  VerificationContext validateIntegrity(Insertable<Exercise> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(_chapterIdMeta,
          chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta));
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('lesson_id')) {
      context.handle(_lessonIdMeta,
          lessonId.isAcceptableOrUnknown(data['lesson_id']!, _lessonIdMeta));
    }
    if (data.containsKey('exercise_type')) {
      context.handle(
          _exerciseTypeMeta,
          exerciseType.isAcceptableOrUnknown(
              data['exercise_type']!, _exerciseTypeMeta));
    } else if (isInserting) {
      context.missing(_exerciseTypeMeta);
    }
    if (data.containsKey('problem_prompt')) {
      context.handle(
          _problemPromptMeta,
          problemPrompt.isAcceptableOrUnknown(
              data['problem_prompt']!, _problemPromptMeta));
    } else if (isInserting) {
      context.missing(_problemPromptMeta);
    }
    if (data.containsKey('solved_solution')) {
      context.handle(
          _solvedSolutionMeta,
          solvedSolution.isAcceptableOrUnknown(
              data['solved_solution']!, _solvedSolutionMeta));
    } else if (isInserting) {
      context.missing(_solvedSolutionMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
          _orderIndexMeta,
          orderIndex.isAcceptableOrUnknown(
              data['order_index']!, _orderIndexMeta));
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Exercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Exercise(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      chapterId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chapter_id'])!,
      lessonId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lesson_id']),
      exerciseType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}exercise_type'])!,
      problemPrompt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}problem_prompt'])!,
      solvedSolution: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}solved_solution'])!,
      orderIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_index'])!,
    );
  }

  @override
  $ExercisesTable createAlias(String alias) {
    return $ExercisesTable(attachedDatabase, alias);
  }
}

class Exercise extends DataClass implements Insertable<Exercise> {
  final String id;
  final String chapterId;
  final String? lessonId;
  final String exerciseType;
  final String problemPrompt;
  final String solvedSolution;
  final int orderIndex;
  const Exercise(
      {required this.id,
      required this.chapterId,
      this.lessonId,
      required this.exerciseType,
      required this.problemPrompt,
      required this.solvedSolution,
      required this.orderIndex});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['chapter_id'] = Variable<String>(chapterId);
    if (!nullToAbsent || lessonId != null) {
      map['lesson_id'] = Variable<String>(lessonId);
    }
    map['exercise_type'] = Variable<String>(exerciseType);
    map['problem_prompt'] = Variable<String>(problemPrompt);
    map['solved_solution'] = Variable<String>(solvedSolution);
    map['order_index'] = Variable<int>(orderIndex);
    return map;
  }

  ExercisesCompanion toCompanion(bool nullToAbsent) {
    return ExercisesCompanion(
      id: Value(id),
      chapterId: Value(chapterId),
      lessonId: lessonId == null && nullToAbsent
          ? const Value.absent()
          : Value(lessonId),
      exerciseType: Value(exerciseType),
      problemPrompt: Value(problemPrompt),
      solvedSolution: Value(solvedSolution),
      orderIndex: Value(orderIndex),
    );
  }

  factory Exercise.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Exercise(
      id: serializer.fromJson<String>(json['id']),
      chapterId: serializer.fromJson<String>(json['chapterId']),
      lessonId: serializer.fromJson<String?>(json['lessonId']),
      exerciseType: serializer.fromJson<String>(json['exerciseType']),
      problemPrompt: serializer.fromJson<String>(json['problemPrompt']),
      solvedSolution: serializer.fromJson<String>(json['solvedSolution']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'chapterId': serializer.toJson<String>(chapterId),
      'lessonId': serializer.toJson<String?>(lessonId),
      'exerciseType': serializer.toJson<String>(exerciseType),
      'problemPrompt': serializer.toJson<String>(problemPrompt),
      'solvedSolution': serializer.toJson<String>(solvedSolution),
      'orderIndex': serializer.toJson<int>(orderIndex),
    };
  }

  Exercise copyWith(
          {String? id,
          String? chapterId,
          Value<String?> lessonId = const Value.absent(),
          String? exerciseType,
          String? problemPrompt,
          String? solvedSolution,
          int? orderIndex}) =>
      Exercise(
        id: id ?? this.id,
        chapterId: chapterId ?? this.chapterId,
        lessonId: lessonId.present ? lessonId.value : this.lessonId,
        exerciseType: exerciseType ?? this.exerciseType,
        problemPrompt: problemPrompt ?? this.problemPrompt,
        solvedSolution: solvedSolution ?? this.solvedSolution,
        orderIndex: orderIndex ?? this.orderIndex,
      );
  Exercise copyWithCompanion(ExercisesCompanion data) {
    return Exercise(
      id: data.id.present ? data.id.value : this.id,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      lessonId: data.lessonId.present ? data.lessonId.value : this.lessonId,
      exerciseType: data.exerciseType.present
          ? data.exerciseType.value
          : this.exerciseType,
      problemPrompt: data.problemPrompt.present
          ? data.problemPrompt.value
          : this.problemPrompt,
      solvedSolution: data.solvedSolution.present
          ? data.solvedSolution.value
          : this.solvedSolution,
      orderIndex:
          data.orderIndex.present ? data.orderIndex.value : this.orderIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Exercise(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('lessonId: $lessonId, ')
          ..write('exerciseType: $exerciseType, ')
          ..write('problemPrompt: $problemPrompt, ')
          ..write('solvedSolution: $solvedSolution, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, chapterId, lessonId, exerciseType,
      problemPrompt, solvedSolution, orderIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Exercise &&
          other.id == this.id &&
          other.chapterId == this.chapterId &&
          other.lessonId == this.lessonId &&
          other.exerciseType == this.exerciseType &&
          other.problemPrompt == this.problemPrompt &&
          other.solvedSolution == this.solvedSolution &&
          other.orderIndex == this.orderIndex);
}

class ExercisesCompanion extends UpdateCompanion<Exercise> {
  final Value<String> id;
  final Value<String> chapterId;
  final Value<String?> lessonId;
  final Value<String> exerciseType;
  final Value<String> problemPrompt;
  final Value<String> solvedSolution;
  final Value<int> orderIndex;
  final Value<int> rowid;
  const ExercisesCompanion({
    this.id = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.lessonId = const Value.absent(),
    this.exerciseType = const Value.absent(),
    this.problemPrompt = const Value.absent(),
    this.solvedSolution = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExercisesCompanion.insert({
    required String id,
    required String chapterId,
    this.lessonId = const Value.absent(),
    required String exerciseType,
    required String problemPrompt,
    required String solvedSolution,
    required int orderIndex,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        chapterId = Value(chapterId),
        exerciseType = Value(exerciseType),
        problemPrompt = Value(problemPrompt),
        solvedSolution = Value(solvedSolution),
        orderIndex = Value(orderIndex);
  static Insertable<Exercise> custom({
    Expression<String>? id,
    Expression<String>? chapterId,
    Expression<String>? lessonId,
    Expression<String>? exerciseType,
    Expression<String>? problemPrompt,
    Expression<String>? solvedSolution,
    Expression<int>? orderIndex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chapterId != null) 'chapter_id': chapterId,
      if (lessonId != null) 'lesson_id': lessonId,
      if (exerciseType != null) 'exercise_type': exerciseType,
      if (problemPrompt != null) 'problem_prompt': problemPrompt,
      if (solvedSolution != null) 'solved_solution': solvedSolution,
      if (orderIndex != null) 'order_index': orderIndex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExercisesCompanion copyWith(
      {Value<String>? id,
      Value<String>? chapterId,
      Value<String?>? lessonId,
      Value<String>? exerciseType,
      Value<String>? problemPrompt,
      Value<String>? solvedSolution,
      Value<int>? orderIndex,
      Value<int>? rowid}) {
    return ExercisesCompanion(
      id: id ?? this.id,
      chapterId: chapterId ?? this.chapterId,
      lessonId: lessonId ?? this.lessonId,
      exerciseType: exerciseType ?? this.exerciseType,
      problemPrompt: problemPrompt ?? this.problemPrompt,
      solvedSolution: solvedSolution ?? this.solvedSolution,
      orderIndex: orderIndex ?? this.orderIndex,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (lessonId.present) {
      map['lesson_id'] = Variable<String>(lessonId.value);
    }
    if (exerciseType.present) {
      map['exercise_type'] = Variable<String>(exerciseType.value);
    }
    if (problemPrompt.present) {
      map['problem_prompt'] = Variable<String>(problemPrompt.value);
    }
    if (solvedSolution.present) {
      map['solved_solution'] = Variable<String>(solvedSolution.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExercisesCompanion(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('lessonId: $lessonId, ')
          ..write('exerciseType: $exerciseType, ')
          ..write('problemPrompt: $problemPrompt, ')
          ..write('solvedSolution: $solvedSolution, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssessmentsTable extends Assessments
    with TableInfo<$AssessmentsTable, Assessment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssessmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chapterIdMeta =
      const VerificationMeta('chapterId');
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
      'chapter_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES chapters (id)'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _passingBenchmarkMeta =
      const VerificationMeta('passingBenchmark');
  @override
  late final GeneratedColumn<double> passingBenchmark = GeneratedColumn<double>(
      'passing_benchmark', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.80));
  static const VerificationMeta _questionDataJsonMeta =
      const VerificationMeta('questionDataJson');
  @override
  late final GeneratedColumn<String> questionDataJson = GeneratedColumn<String>(
      'question_data_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _totalQuestionsMeta =
      const VerificationMeta('totalQuestions');
  @override
  late final GeneratedColumn<int> totalQuestions = GeneratedColumn<int>(
      'total_questions', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        chapterId,
        title,
        passingBenchmark,
        questionDataJson,
        totalQuestions,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assessments';
  @override
  VerificationContext validateIntegrity(Insertable<Assessment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(_chapterIdMeta,
          chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta));
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('passing_benchmark')) {
      context.handle(
          _passingBenchmarkMeta,
          passingBenchmark.isAcceptableOrUnknown(
              data['passing_benchmark']!, _passingBenchmarkMeta));
    }
    if (data.containsKey('question_data_json')) {
      context.handle(
          _questionDataJsonMeta,
          questionDataJson.isAcceptableOrUnknown(
              data['question_data_json']!, _questionDataJsonMeta));
    } else if (isInserting) {
      context.missing(_questionDataJsonMeta);
    }
    if (data.containsKey('total_questions')) {
      context.handle(
          _totalQuestionsMeta,
          totalQuestions.isAcceptableOrUnknown(
              data['total_questions']!, _totalQuestionsMeta));
    } else if (isInserting) {
      context.missing(_totalQuestionsMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Assessment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Assessment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      chapterId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chapter_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      passingBenchmark: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}passing_benchmark'])!,
      questionDataJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}question_data_json'])!,
      totalQuestions: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_questions'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $AssessmentsTable createAlias(String alias) {
    return $AssessmentsTable(attachedDatabase, alias);
  }
}

class Assessment extends DataClass implements Insertable<Assessment> {
  final String id;
  final String chapterId;
  final String title;
  final double passingBenchmark;
  final String questionDataJson;
  final int totalQuestions;
  final DateTime createdAt;
  const Assessment(
      {required this.id,
      required this.chapterId,
      required this.title,
      required this.passingBenchmark,
      required this.questionDataJson,
      required this.totalQuestions,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['chapter_id'] = Variable<String>(chapterId);
    map['title'] = Variable<String>(title);
    map['passing_benchmark'] = Variable<double>(passingBenchmark);
    map['question_data_json'] = Variable<String>(questionDataJson);
    map['total_questions'] = Variable<int>(totalQuestions);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AssessmentsCompanion toCompanion(bool nullToAbsent) {
    return AssessmentsCompanion(
      id: Value(id),
      chapterId: Value(chapterId),
      title: Value(title),
      passingBenchmark: Value(passingBenchmark),
      questionDataJson: Value(questionDataJson),
      totalQuestions: Value(totalQuestions),
      createdAt: Value(createdAt),
    );
  }

  factory Assessment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Assessment(
      id: serializer.fromJson<String>(json['id']),
      chapterId: serializer.fromJson<String>(json['chapterId']),
      title: serializer.fromJson<String>(json['title']),
      passingBenchmark: serializer.fromJson<double>(json['passingBenchmark']),
      questionDataJson: serializer.fromJson<String>(json['questionDataJson']),
      totalQuestions: serializer.fromJson<int>(json['totalQuestions']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'chapterId': serializer.toJson<String>(chapterId),
      'title': serializer.toJson<String>(title),
      'passingBenchmark': serializer.toJson<double>(passingBenchmark),
      'questionDataJson': serializer.toJson<String>(questionDataJson),
      'totalQuestions': serializer.toJson<int>(totalQuestions),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Assessment copyWith(
          {String? id,
          String? chapterId,
          String? title,
          double? passingBenchmark,
          String? questionDataJson,
          int? totalQuestions,
          DateTime? createdAt}) =>
      Assessment(
        id: id ?? this.id,
        chapterId: chapterId ?? this.chapterId,
        title: title ?? this.title,
        passingBenchmark: passingBenchmark ?? this.passingBenchmark,
        questionDataJson: questionDataJson ?? this.questionDataJson,
        totalQuestions: totalQuestions ?? this.totalQuestions,
        createdAt: createdAt ?? this.createdAt,
      );
  Assessment copyWithCompanion(AssessmentsCompanion data) {
    return Assessment(
      id: data.id.present ? data.id.value : this.id,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      title: data.title.present ? data.title.value : this.title,
      passingBenchmark: data.passingBenchmark.present
          ? data.passingBenchmark.value
          : this.passingBenchmark,
      questionDataJson: data.questionDataJson.present
          ? data.questionDataJson.value
          : this.questionDataJson,
      totalQuestions: data.totalQuestions.present
          ? data.totalQuestions.value
          : this.totalQuestions,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Assessment(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('title: $title, ')
          ..write('passingBenchmark: $passingBenchmark, ')
          ..write('questionDataJson: $questionDataJson, ')
          ..write('totalQuestions: $totalQuestions, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, chapterId, title, passingBenchmark,
      questionDataJson, totalQuestions, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Assessment &&
          other.id == this.id &&
          other.chapterId == this.chapterId &&
          other.title == this.title &&
          other.passingBenchmark == this.passingBenchmark &&
          other.questionDataJson == this.questionDataJson &&
          other.totalQuestions == this.totalQuestions &&
          other.createdAt == this.createdAt);
}

class AssessmentsCompanion extends UpdateCompanion<Assessment> {
  final Value<String> id;
  final Value<String> chapterId;
  final Value<String> title;
  final Value<double> passingBenchmark;
  final Value<String> questionDataJson;
  final Value<int> totalQuestions;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AssessmentsCompanion({
    this.id = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.title = const Value.absent(),
    this.passingBenchmark = const Value.absent(),
    this.questionDataJson = const Value.absent(),
    this.totalQuestions = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssessmentsCompanion.insert({
    required String id,
    required String chapterId,
    required String title,
    this.passingBenchmark = const Value.absent(),
    required String questionDataJson,
    required int totalQuestions,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        chapterId = Value(chapterId),
        title = Value(title),
        questionDataJson = Value(questionDataJson),
        totalQuestions = Value(totalQuestions);
  static Insertable<Assessment> custom({
    Expression<String>? id,
    Expression<String>? chapterId,
    Expression<String>? title,
    Expression<double>? passingBenchmark,
    Expression<String>? questionDataJson,
    Expression<int>? totalQuestions,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chapterId != null) 'chapter_id': chapterId,
      if (title != null) 'title': title,
      if (passingBenchmark != null) 'passing_benchmark': passingBenchmark,
      if (questionDataJson != null) 'question_data_json': questionDataJson,
      if (totalQuestions != null) 'total_questions': totalQuestions,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssessmentsCompanion copyWith(
      {Value<String>? id,
      Value<String>? chapterId,
      Value<String>? title,
      Value<double>? passingBenchmark,
      Value<String>? questionDataJson,
      Value<int>? totalQuestions,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return AssessmentsCompanion(
      id: id ?? this.id,
      chapterId: chapterId ?? this.chapterId,
      title: title ?? this.title,
      passingBenchmark: passingBenchmark ?? this.passingBenchmark,
      questionDataJson: questionDataJson ?? this.questionDataJson,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (passingBenchmark.present) {
      map['passing_benchmark'] = Variable<double>(passingBenchmark.value);
    }
    if (questionDataJson.present) {
      map['question_data_json'] = Variable<String>(questionDataJson.value);
    }
    if (totalQuestions.present) {
      map['total_questions'] = Variable<int>(totalQuestions.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssessmentsCompanion(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('title: $title, ')
          ..write('passingBenchmark: $passingBenchmark, ')
          ..write('questionDataJson: $questionDataJson, ')
          ..write('totalQuestions: $totalQuestions, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssessmentAttemptsTable extends AssessmentAttempts
    with TableInfo<$AssessmentAttemptsTable, AssessmentAttempt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssessmentAttemptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _assessmentIdMeta =
      const VerificationMeta('assessmentId');
  @override
  late final GeneratedColumn<String> assessmentId = GeneratedColumn<String>(
      'assessment_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES assessments (id)'));
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<double> score = GeneratedColumn<double>(
      'score', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _passedMeta = const VerificationMeta('passed');
  @override
  late final GeneratedColumn<bool> passed = GeneratedColumn<bool>(
      'passed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("passed" IN (0, 1))'));
  static const VerificationMeta _responsesJsonMeta =
      const VerificationMeta('responsesJson');
  @override
  late final GeneratedColumn<String> responsesJson = GeneratedColumn<String>(
      'responses_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _discursiveFeedbackMeta =
      const VerificationMeta('discursiveFeedback');
  @override
  late final GeneratedColumn<String> discursiveFeedback =
      GeneratedColumn<String>('discursive_feedback', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _durationSecondsMeta =
      const VerificationMeta('durationSeconds');
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
      'duration_seconds', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        assessmentId,
        timestamp,
        score,
        passed,
        responsesJson,
        discursiveFeedback,
        durationSeconds
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assessment_attempts';
  @override
  VerificationContext validateIntegrity(Insertable<AssessmentAttempt> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('assessment_id')) {
      context.handle(
          _assessmentIdMeta,
          assessmentId.isAcceptableOrUnknown(
              data['assessment_id']!, _assessmentIdMeta));
    } else if (isInserting) {
      context.missing(_assessmentIdMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    }
    if (data.containsKey('score')) {
      context.handle(
          _scoreMeta, score.isAcceptableOrUnknown(data['score']!, _scoreMeta));
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('passed')) {
      context.handle(_passedMeta,
          passed.isAcceptableOrUnknown(data['passed']!, _passedMeta));
    } else if (isInserting) {
      context.missing(_passedMeta);
    }
    if (data.containsKey('responses_json')) {
      context.handle(
          _responsesJsonMeta,
          responsesJson.isAcceptableOrUnknown(
              data['responses_json']!, _responsesJsonMeta));
    } else if (isInserting) {
      context.missing(_responsesJsonMeta);
    }
    if (data.containsKey('discursive_feedback')) {
      context.handle(
          _discursiveFeedbackMeta,
          discursiveFeedback.isAcceptableOrUnknown(
              data['discursive_feedback']!, _discursiveFeedbackMeta));
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
          _durationSecondsMeta,
          durationSeconds.isAcceptableOrUnknown(
              data['duration_seconds']!, _durationSecondsMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AssessmentAttempt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssessmentAttempt(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      assessmentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}assessment_id'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      score: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}score'])!,
      passed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}passed'])!,
      responsesJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}responses_json'])!,
      discursiveFeedback: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}discursive_feedback']),
      durationSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_seconds'])!,
    );
  }

  @override
  $AssessmentAttemptsTable createAlias(String alias) {
    return $AssessmentAttemptsTable(attachedDatabase, alias);
  }
}

class AssessmentAttempt extends DataClass
    implements Insertable<AssessmentAttempt> {
  final String id;
  final String assessmentId;
  final DateTime timestamp;
  final double score;
  final bool passed;
  final String responsesJson;
  final String? discursiveFeedback;
  final int durationSeconds;
  const AssessmentAttempt(
      {required this.id,
      required this.assessmentId,
      required this.timestamp,
      required this.score,
      required this.passed,
      required this.responsesJson,
      this.discursiveFeedback,
      required this.durationSeconds});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['assessment_id'] = Variable<String>(assessmentId);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['score'] = Variable<double>(score);
    map['passed'] = Variable<bool>(passed);
    map['responses_json'] = Variable<String>(responsesJson);
    if (!nullToAbsent || discursiveFeedback != null) {
      map['discursive_feedback'] = Variable<String>(discursiveFeedback);
    }
    map['duration_seconds'] = Variable<int>(durationSeconds);
    return map;
  }

  AssessmentAttemptsCompanion toCompanion(bool nullToAbsent) {
    return AssessmentAttemptsCompanion(
      id: Value(id),
      assessmentId: Value(assessmentId),
      timestamp: Value(timestamp),
      score: Value(score),
      passed: Value(passed),
      responsesJson: Value(responsesJson),
      discursiveFeedback: discursiveFeedback == null && nullToAbsent
          ? const Value.absent()
          : Value(discursiveFeedback),
      durationSeconds: Value(durationSeconds),
    );
  }

  factory AssessmentAttempt.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssessmentAttempt(
      id: serializer.fromJson<String>(json['id']),
      assessmentId: serializer.fromJson<String>(json['assessmentId']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      score: serializer.fromJson<double>(json['score']),
      passed: serializer.fromJson<bool>(json['passed']),
      responsesJson: serializer.fromJson<String>(json['responsesJson']),
      discursiveFeedback:
          serializer.fromJson<String?>(json['discursiveFeedback']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'assessmentId': serializer.toJson<String>(assessmentId),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'score': serializer.toJson<double>(score),
      'passed': serializer.toJson<bool>(passed),
      'responsesJson': serializer.toJson<String>(responsesJson),
      'discursiveFeedback': serializer.toJson<String?>(discursiveFeedback),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
    };
  }

  AssessmentAttempt copyWith(
          {String? id,
          String? assessmentId,
          DateTime? timestamp,
          double? score,
          bool? passed,
          String? responsesJson,
          Value<String?> discursiveFeedback = const Value.absent(),
          int? durationSeconds}) =>
      AssessmentAttempt(
        id: id ?? this.id,
        assessmentId: assessmentId ?? this.assessmentId,
        timestamp: timestamp ?? this.timestamp,
        score: score ?? this.score,
        passed: passed ?? this.passed,
        responsesJson: responsesJson ?? this.responsesJson,
        discursiveFeedback: discursiveFeedback.present
            ? discursiveFeedback.value
            : this.discursiveFeedback,
        durationSeconds: durationSeconds ?? this.durationSeconds,
      );
  AssessmentAttempt copyWithCompanion(AssessmentAttemptsCompanion data) {
    return AssessmentAttempt(
      id: data.id.present ? data.id.value : this.id,
      assessmentId: data.assessmentId.present
          ? data.assessmentId.value
          : this.assessmentId,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      score: data.score.present ? data.score.value : this.score,
      passed: data.passed.present ? data.passed.value : this.passed,
      responsesJson: data.responsesJson.present
          ? data.responsesJson.value
          : this.responsesJson,
      discursiveFeedback: data.discursiveFeedback.present
          ? data.discursiveFeedback.value
          : this.discursiveFeedback,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssessmentAttempt(')
          ..write('id: $id, ')
          ..write('assessmentId: $assessmentId, ')
          ..write('timestamp: $timestamp, ')
          ..write('score: $score, ')
          ..write('passed: $passed, ')
          ..write('responsesJson: $responsesJson, ')
          ..write('discursiveFeedback: $discursiveFeedback, ')
          ..write('durationSeconds: $durationSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, assessmentId, timestamp, score, passed,
      responsesJson, discursiveFeedback, durationSeconds);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssessmentAttempt &&
          other.id == this.id &&
          other.assessmentId == this.assessmentId &&
          other.timestamp == this.timestamp &&
          other.score == this.score &&
          other.passed == this.passed &&
          other.responsesJson == this.responsesJson &&
          other.discursiveFeedback == this.discursiveFeedback &&
          other.durationSeconds == this.durationSeconds);
}

class AssessmentAttemptsCompanion extends UpdateCompanion<AssessmentAttempt> {
  final Value<String> id;
  final Value<String> assessmentId;
  final Value<DateTime> timestamp;
  final Value<double> score;
  final Value<bool> passed;
  final Value<String> responsesJson;
  final Value<String?> discursiveFeedback;
  final Value<int> durationSeconds;
  final Value<int> rowid;
  const AssessmentAttemptsCompanion({
    this.id = const Value.absent(),
    this.assessmentId = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.score = const Value.absent(),
    this.passed = const Value.absent(),
    this.responsesJson = const Value.absent(),
    this.discursiveFeedback = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssessmentAttemptsCompanion.insert({
    required String id,
    required String assessmentId,
    this.timestamp = const Value.absent(),
    required double score,
    required bool passed,
    required String responsesJson,
    this.discursiveFeedback = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        assessmentId = Value(assessmentId),
        score = Value(score),
        passed = Value(passed),
        responsesJson = Value(responsesJson);
  static Insertable<AssessmentAttempt> custom({
    Expression<String>? id,
    Expression<String>? assessmentId,
    Expression<DateTime>? timestamp,
    Expression<double>? score,
    Expression<bool>? passed,
    Expression<String>? responsesJson,
    Expression<String>? discursiveFeedback,
    Expression<int>? durationSeconds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (assessmentId != null) 'assessment_id': assessmentId,
      if (timestamp != null) 'timestamp': timestamp,
      if (score != null) 'score': score,
      if (passed != null) 'passed': passed,
      if (responsesJson != null) 'responses_json': responsesJson,
      if (discursiveFeedback != null) 'discursive_feedback': discursiveFeedback,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssessmentAttemptsCompanion copyWith(
      {Value<String>? id,
      Value<String>? assessmentId,
      Value<DateTime>? timestamp,
      Value<double>? score,
      Value<bool>? passed,
      Value<String>? responsesJson,
      Value<String?>? discursiveFeedback,
      Value<int>? durationSeconds,
      Value<int>? rowid}) {
    return AssessmentAttemptsCompanion(
      id: id ?? this.id,
      assessmentId: assessmentId ?? this.assessmentId,
      timestamp: timestamp ?? this.timestamp,
      score: score ?? this.score,
      passed: passed ?? this.passed,
      responsesJson: responsesJson ?? this.responsesJson,
      discursiveFeedback: discursiveFeedback ?? this.discursiveFeedback,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (assessmentId.present) {
      map['assessment_id'] = Variable<String>(assessmentId.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (score.present) {
      map['score'] = Variable<double>(score.value);
    }
    if (passed.present) {
      map['passed'] = Variable<bool>(passed.value);
    }
    if (responsesJson.present) {
      map['responses_json'] = Variable<String>(responsesJson.value);
    }
    if (discursiveFeedback.present) {
      map['discursive_feedback'] = Variable<String>(discursiveFeedback.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssessmentAttemptsCompanion(')
          ..write('id: $id, ')
          ..write('assessmentId: $assessmentId, ')
          ..write('timestamp: $timestamp, ')
          ..write('score: $score, ')
          ..write('passed: $passed, ')
          ..write('responsesJson: $responsesJson, ')
          ..write('discursiveFeedback: $discursiveFeedback, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LaboratoriesTable extends Laboratories
    with TableInfo<$LaboratoriesTable, Laboratory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LaboratoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chapterIdMeta =
      const VerificationMeta('chapterId');
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
      'chapter_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES chapters (id)'));
  static const VerificationMeta _domainMeta = const VerificationMeta('domain');
  @override
  late final GeneratedColumn<String> domain = GeneratedColumn<String>(
      'domain', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _environmentTypeMeta =
      const VerificationMeta('environmentType');
  @override
  late final GeneratedColumn<String> environmentType = GeneratedColumn<String>(
      'environment_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _initialDatasetPathMeta =
      const VerificationMeta('initialDatasetPath');
  @override
  late final GeneratedColumn<String> initialDatasetPath =
      GeneratedColumn<String>('initial_dataset_path', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _instructionsMarkdownMeta =
      const VerificationMeta('instructionsMarkdown');
  @override
  late final GeneratedColumn<String> instructionsMarkdown =
      GeneratedColumn<String>('instructions_markdown', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _verificationRubricJsonMeta =
      const VerificationMeta('verificationRubricJson');
  @override
  late final GeneratedColumn<String> verificationRubricJson =
      GeneratedColumn<String>('verification_rubric_json', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        chapterId,
        domain,
        title,
        environmentType,
        initialDatasetPath,
        instructionsMarkdown,
        verificationRubricJson
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'laboratories';
  @override
  VerificationContext validateIntegrity(Insertable<Laboratory> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(_chapterIdMeta,
          chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta));
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('domain')) {
      context.handle(_domainMeta,
          domain.isAcceptableOrUnknown(data['domain']!, _domainMeta));
    } else if (isInserting) {
      context.missing(_domainMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('environment_type')) {
      context.handle(
          _environmentTypeMeta,
          environmentType.isAcceptableOrUnknown(
              data['environment_type']!, _environmentTypeMeta));
    } else if (isInserting) {
      context.missing(_environmentTypeMeta);
    }
    if (data.containsKey('initial_dataset_path')) {
      context.handle(
          _initialDatasetPathMeta,
          initialDatasetPath.isAcceptableOrUnknown(
              data['initial_dataset_path']!, _initialDatasetPathMeta));
    }
    if (data.containsKey('instructions_markdown')) {
      context.handle(
          _instructionsMarkdownMeta,
          instructionsMarkdown.isAcceptableOrUnknown(
              data['instructions_markdown']!, _instructionsMarkdownMeta));
    } else if (isInserting) {
      context.missing(_instructionsMarkdownMeta);
    }
    if (data.containsKey('verification_rubric_json')) {
      context.handle(
          _verificationRubricJsonMeta,
          verificationRubricJson.isAcceptableOrUnknown(
              data['verification_rubric_json']!, _verificationRubricJsonMeta));
    } else if (isInserting) {
      context.missing(_verificationRubricJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Laboratory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Laboratory(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      chapterId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chapter_id'])!,
      domain: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}domain'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      environmentType: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}environment_type'])!,
      initialDatasetPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}initial_dataset_path']),
      instructionsMarkdown: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}instructions_markdown'])!,
      verificationRubricJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}verification_rubric_json'])!,
    );
  }

  @override
  $LaboratoriesTable createAlias(String alias) {
    return $LaboratoriesTable(attachedDatabase, alias);
  }
}

class Laboratory extends DataClass implements Insertable<Laboratory> {
  final String id;
  final String chapterId;
  final String domain;
  final String title;
  final String environmentType;
  final String? initialDatasetPath;
  final String instructionsMarkdown;
  final String verificationRubricJson;
  const Laboratory(
      {required this.id,
      required this.chapterId,
      required this.domain,
      required this.title,
      required this.environmentType,
      this.initialDatasetPath,
      required this.instructionsMarkdown,
      required this.verificationRubricJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['chapter_id'] = Variable<String>(chapterId);
    map['domain'] = Variable<String>(domain);
    map['title'] = Variable<String>(title);
    map['environment_type'] = Variable<String>(environmentType);
    if (!nullToAbsent || initialDatasetPath != null) {
      map['initial_dataset_path'] = Variable<String>(initialDatasetPath);
    }
    map['instructions_markdown'] = Variable<String>(instructionsMarkdown);
    map['verification_rubric_json'] = Variable<String>(verificationRubricJson);
    return map;
  }

  LaboratoriesCompanion toCompanion(bool nullToAbsent) {
    return LaboratoriesCompanion(
      id: Value(id),
      chapterId: Value(chapterId),
      domain: Value(domain),
      title: Value(title),
      environmentType: Value(environmentType),
      initialDatasetPath: initialDatasetPath == null && nullToAbsent
          ? const Value.absent()
          : Value(initialDatasetPath),
      instructionsMarkdown: Value(instructionsMarkdown),
      verificationRubricJson: Value(verificationRubricJson),
    );
  }

  factory Laboratory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Laboratory(
      id: serializer.fromJson<String>(json['id']),
      chapterId: serializer.fromJson<String>(json['chapterId']),
      domain: serializer.fromJson<String>(json['domain']),
      title: serializer.fromJson<String>(json['title']),
      environmentType: serializer.fromJson<String>(json['environmentType']),
      initialDatasetPath:
          serializer.fromJson<String?>(json['initialDatasetPath']),
      instructionsMarkdown:
          serializer.fromJson<String>(json['instructionsMarkdown']),
      verificationRubricJson:
          serializer.fromJson<String>(json['verificationRubricJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'chapterId': serializer.toJson<String>(chapterId),
      'domain': serializer.toJson<String>(domain),
      'title': serializer.toJson<String>(title),
      'environmentType': serializer.toJson<String>(environmentType),
      'initialDatasetPath': serializer.toJson<String?>(initialDatasetPath),
      'instructionsMarkdown': serializer.toJson<String>(instructionsMarkdown),
      'verificationRubricJson':
          serializer.toJson<String>(verificationRubricJson),
    };
  }

  Laboratory copyWith(
          {String? id,
          String? chapterId,
          String? domain,
          String? title,
          String? environmentType,
          Value<String?> initialDatasetPath = const Value.absent(),
          String? instructionsMarkdown,
          String? verificationRubricJson}) =>
      Laboratory(
        id: id ?? this.id,
        chapterId: chapterId ?? this.chapterId,
        domain: domain ?? this.domain,
        title: title ?? this.title,
        environmentType: environmentType ?? this.environmentType,
        initialDatasetPath: initialDatasetPath.present
            ? initialDatasetPath.value
            : this.initialDatasetPath,
        instructionsMarkdown: instructionsMarkdown ?? this.instructionsMarkdown,
        verificationRubricJson:
            verificationRubricJson ?? this.verificationRubricJson,
      );
  Laboratory copyWithCompanion(LaboratoriesCompanion data) {
    return Laboratory(
      id: data.id.present ? data.id.value : this.id,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      domain: data.domain.present ? data.domain.value : this.domain,
      title: data.title.present ? data.title.value : this.title,
      environmentType: data.environmentType.present
          ? data.environmentType.value
          : this.environmentType,
      initialDatasetPath: data.initialDatasetPath.present
          ? data.initialDatasetPath.value
          : this.initialDatasetPath,
      instructionsMarkdown: data.instructionsMarkdown.present
          ? data.instructionsMarkdown.value
          : this.instructionsMarkdown,
      verificationRubricJson: data.verificationRubricJson.present
          ? data.verificationRubricJson.value
          : this.verificationRubricJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Laboratory(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('domain: $domain, ')
          ..write('title: $title, ')
          ..write('environmentType: $environmentType, ')
          ..write('initialDatasetPath: $initialDatasetPath, ')
          ..write('instructionsMarkdown: $instructionsMarkdown, ')
          ..write('verificationRubricJson: $verificationRubricJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, chapterId, domain, title, environmentType,
      initialDatasetPath, instructionsMarkdown, verificationRubricJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Laboratory &&
          other.id == this.id &&
          other.chapterId == this.chapterId &&
          other.domain == this.domain &&
          other.title == this.title &&
          other.environmentType == this.environmentType &&
          other.initialDatasetPath == this.initialDatasetPath &&
          other.instructionsMarkdown == this.instructionsMarkdown &&
          other.verificationRubricJson == this.verificationRubricJson);
}

class LaboratoriesCompanion extends UpdateCompanion<Laboratory> {
  final Value<String> id;
  final Value<String> chapterId;
  final Value<String> domain;
  final Value<String> title;
  final Value<String> environmentType;
  final Value<String?> initialDatasetPath;
  final Value<String> instructionsMarkdown;
  final Value<String> verificationRubricJson;
  final Value<int> rowid;
  const LaboratoriesCompanion({
    this.id = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.domain = const Value.absent(),
    this.title = const Value.absent(),
    this.environmentType = const Value.absent(),
    this.initialDatasetPath = const Value.absent(),
    this.instructionsMarkdown = const Value.absent(),
    this.verificationRubricJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LaboratoriesCompanion.insert({
    required String id,
    required String chapterId,
    required String domain,
    required String title,
    required String environmentType,
    this.initialDatasetPath = const Value.absent(),
    required String instructionsMarkdown,
    required String verificationRubricJson,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        chapterId = Value(chapterId),
        domain = Value(domain),
        title = Value(title),
        environmentType = Value(environmentType),
        instructionsMarkdown = Value(instructionsMarkdown),
        verificationRubricJson = Value(verificationRubricJson);
  static Insertable<Laboratory> custom({
    Expression<String>? id,
    Expression<String>? chapterId,
    Expression<String>? domain,
    Expression<String>? title,
    Expression<String>? environmentType,
    Expression<String>? initialDatasetPath,
    Expression<String>? instructionsMarkdown,
    Expression<String>? verificationRubricJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chapterId != null) 'chapter_id': chapterId,
      if (domain != null) 'domain': domain,
      if (title != null) 'title': title,
      if (environmentType != null) 'environment_type': environmentType,
      if (initialDatasetPath != null)
        'initial_dataset_path': initialDatasetPath,
      if (instructionsMarkdown != null)
        'instructions_markdown': instructionsMarkdown,
      if (verificationRubricJson != null)
        'verification_rubric_json': verificationRubricJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LaboratoriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? chapterId,
      Value<String>? domain,
      Value<String>? title,
      Value<String>? environmentType,
      Value<String?>? initialDatasetPath,
      Value<String>? instructionsMarkdown,
      Value<String>? verificationRubricJson,
      Value<int>? rowid}) {
    return LaboratoriesCompanion(
      id: id ?? this.id,
      chapterId: chapterId ?? this.chapterId,
      domain: domain ?? this.domain,
      title: title ?? this.title,
      environmentType: environmentType ?? this.environmentType,
      initialDatasetPath: initialDatasetPath ?? this.initialDatasetPath,
      instructionsMarkdown: instructionsMarkdown ?? this.instructionsMarkdown,
      verificationRubricJson:
          verificationRubricJson ?? this.verificationRubricJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (domain.present) {
      map['domain'] = Variable<String>(domain.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (environmentType.present) {
      map['environment_type'] = Variable<String>(environmentType.value);
    }
    if (initialDatasetPath.present) {
      map['initial_dataset_path'] = Variable<String>(initialDatasetPath.value);
    }
    if (instructionsMarkdown.present) {
      map['instructions_markdown'] =
          Variable<String>(instructionsMarkdown.value);
    }
    if (verificationRubricJson.present) {
      map['verification_rubric_json'] =
          Variable<String>(verificationRubricJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LaboratoriesCompanion(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('domain: $domain, ')
          ..write('title: $title, ')
          ..write('environmentType: $environmentType, ')
          ..write('initialDatasetPath: $initialDatasetPath, ')
          ..write('instructionsMarkdown: $instructionsMarkdown, ')
          ..write('verificationRubricJson: $verificationRubricJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LaboratoryRunsTable extends LaboratoryRuns
    with TableInfo<$LaboratoryRunsTable, LaboratoryRun> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LaboratoryRunsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _laboratoryIdMeta =
      const VerificationMeta('laboratoryId');
  @override
  late final GeneratedColumn<String> laboratoryId = GeneratedColumn<String>(
      'laboratory_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES laboratories (id)'));
  static const VerificationMeta _executedAtMeta =
      const VerificationMeta('executedAt');
  @override
  late final GeneratedColumn<DateTime> executedAt = GeneratedColumn<DateTime>(
      'executed_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _commandsExecutedJsonMeta =
      const VerificationMeta('commandsExecutedJson');
  @override
  late final GeneratedColumn<String> commandsExecutedJson =
      GeneratedColumn<String>('commands_executed_json', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _outputArtifactPathMeta =
      const VerificationMeta('outputArtifactPath');
  @override
  late final GeneratedColumn<String> outputArtifactPath =
      GeneratedColumn<String>('output_artifact_path', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isPassedMeta =
      const VerificationMeta('isPassed');
  @override
  late final GeneratedColumn<bool> isPassed = GeneratedColumn<bool>(
      'is_passed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_passed" IN (0, 1))'));
  static const VerificationMeta _metricsJsonMeta =
      const VerificationMeta('metricsJson');
  @override
  late final GeneratedColumn<String> metricsJson = GeneratedColumn<String>(
      'metrics_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        laboratoryId,
        executedAt,
        commandsExecutedJson,
        outputArtifactPath,
        isPassed,
        metricsJson
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'laboratory_runs';
  @override
  VerificationContext validateIntegrity(Insertable<LaboratoryRun> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('laboratory_id')) {
      context.handle(
          _laboratoryIdMeta,
          laboratoryId.isAcceptableOrUnknown(
              data['laboratory_id']!, _laboratoryIdMeta));
    } else if (isInserting) {
      context.missing(_laboratoryIdMeta);
    }
    if (data.containsKey('executed_at')) {
      context.handle(
          _executedAtMeta,
          executedAt.isAcceptableOrUnknown(
              data['executed_at']!, _executedAtMeta));
    }
    if (data.containsKey('commands_executed_json')) {
      context.handle(
          _commandsExecutedJsonMeta,
          commandsExecutedJson.isAcceptableOrUnknown(
              data['commands_executed_json']!, _commandsExecutedJsonMeta));
    } else if (isInserting) {
      context.missing(_commandsExecutedJsonMeta);
    }
    if (data.containsKey('output_artifact_path')) {
      context.handle(
          _outputArtifactPathMeta,
          outputArtifactPath.isAcceptableOrUnknown(
              data['output_artifact_path']!, _outputArtifactPathMeta));
    }
    if (data.containsKey('is_passed')) {
      context.handle(_isPassedMeta,
          isPassed.isAcceptableOrUnknown(data['is_passed']!, _isPassedMeta));
    } else if (isInserting) {
      context.missing(_isPassedMeta);
    }
    if (data.containsKey('metrics_json')) {
      context.handle(
          _metricsJsonMeta,
          metricsJson.isAcceptableOrUnknown(
              data['metrics_json']!, _metricsJsonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LaboratoryRun map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LaboratoryRun(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      laboratoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}laboratory_id'])!,
      executedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}executed_at'])!,
      commandsExecutedJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}commands_executed_json'])!,
      outputArtifactPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}output_artifact_path']),
      isPassed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_passed'])!,
      metricsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metrics_json']),
    );
  }

  @override
  $LaboratoryRunsTable createAlias(String alias) {
    return $LaboratoryRunsTable(attachedDatabase, alias);
  }
}

class LaboratoryRun extends DataClass implements Insertable<LaboratoryRun> {
  final String id;
  final String laboratoryId;
  final DateTime executedAt;
  final String commandsExecutedJson;
  final String? outputArtifactPath;
  final bool isPassed;
  final String? metricsJson;
  const LaboratoryRun(
      {required this.id,
      required this.laboratoryId,
      required this.executedAt,
      required this.commandsExecutedJson,
      this.outputArtifactPath,
      required this.isPassed,
      this.metricsJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['laboratory_id'] = Variable<String>(laboratoryId);
    map['executed_at'] = Variable<DateTime>(executedAt);
    map['commands_executed_json'] = Variable<String>(commandsExecutedJson);
    if (!nullToAbsent || outputArtifactPath != null) {
      map['output_artifact_path'] = Variable<String>(outputArtifactPath);
    }
    map['is_passed'] = Variable<bool>(isPassed);
    if (!nullToAbsent || metricsJson != null) {
      map['metrics_json'] = Variable<String>(metricsJson);
    }
    return map;
  }

  LaboratoryRunsCompanion toCompanion(bool nullToAbsent) {
    return LaboratoryRunsCompanion(
      id: Value(id),
      laboratoryId: Value(laboratoryId),
      executedAt: Value(executedAt),
      commandsExecutedJson: Value(commandsExecutedJson),
      outputArtifactPath: outputArtifactPath == null && nullToAbsent
          ? const Value.absent()
          : Value(outputArtifactPath),
      isPassed: Value(isPassed),
      metricsJson: metricsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(metricsJson),
    );
  }

  factory LaboratoryRun.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LaboratoryRun(
      id: serializer.fromJson<String>(json['id']),
      laboratoryId: serializer.fromJson<String>(json['laboratoryId']),
      executedAt: serializer.fromJson<DateTime>(json['executedAt']),
      commandsExecutedJson:
          serializer.fromJson<String>(json['commandsExecutedJson']),
      outputArtifactPath:
          serializer.fromJson<String?>(json['outputArtifactPath']),
      isPassed: serializer.fromJson<bool>(json['isPassed']),
      metricsJson: serializer.fromJson<String?>(json['metricsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'laboratoryId': serializer.toJson<String>(laboratoryId),
      'executedAt': serializer.toJson<DateTime>(executedAt),
      'commandsExecutedJson': serializer.toJson<String>(commandsExecutedJson),
      'outputArtifactPath': serializer.toJson<String?>(outputArtifactPath),
      'isPassed': serializer.toJson<bool>(isPassed),
      'metricsJson': serializer.toJson<String?>(metricsJson),
    };
  }

  LaboratoryRun copyWith(
          {String? id,
          String? laboratoryId,
          DateTime? executedAt,
          String? commandsExecutedJson,
          Value<String?> outputArtifactPath = const Value.absent(),
          bool? isPassed,
          Value<String?> metricsJson = const Value.absent()}) =>
      LaboratoryRun(
        id: id ?? this.id,
        laboratoryId: laboratoryId ?? this.laboratoryId,
        executedAt: executedAt ?? this.executedAt,
        commandsExecutedJson: commandsExecutedJson ?? this.commandsExecutedJson,
        outputArtifactPath: outputArtifactPath.present
            ? outputArtifactPath.value
            : this.outputArtifactPath,
        isPassed: isPassed ?? this.isPassed,
        metricsJson: metricsJson.present ? metricsJson.value : this.metricsJson,
      );
  LaboratoryRun copyWithCompanion(LaboratoryRunsCompanion data) {
    return LaboratoryRun(
      id: data.id.present ? data.id.value : this.id,
      laboratoryId: data.laboratoryId.present
          ? data.laboratoryId.value
          : this.laboratoryId,
      executedAt:
          data.executedAt.present ? data.executedAt.value : this.executedAt,
      commandsExecutedJson: data.commandsExecutedJson.present
          ? data.commandsExecutedJson.value
          : this.commandsExecutedJson,
      outputArtifactPath: data.outputArtifactPath.present
          ? data.outputArtifactPath.value
          : this.outputArtifactPath,
      isPassed: data.isPassed.present ? data.isPassed.value : this.isPassed,
      metricsJson:
          data.metricsJson.present ? data.metricsJson.value : this.metricsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LaboratoryRun(')
          ..write('id: $id, ')
          ..write('laboratoryId: $laboratoryId, ')
          ..write('executedAt: $executedAt, ')
          ..write('commandsExecutedJson: $commandsExecutedJson, ')
          ..write('outputArtifactPath: $outputArtifactPath, ')
          ..write('isPassed: $isPassed, ')
          ..write('metricsJson: $metricsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, laboratoryId, executedAt,
      commandsExecutedJson, outputArtifactPath, isPassed, metricsJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LaboratoryRun &&
          other.id == this.id &&
          other.laboratoryId == this.laboratoryId &&
          other.executedAt == this.executedAt &&
          other.commandsExecutedJson == this.commandsExecutedJson &&
          other.outputArtifactPath == this.outputArtifactPath &&
          other.isPassed == this.isPassed &&
          other.metricsJson == this.metricsJson);
}

class LaboratoryRunsCompanion extends UpdateCompanion<LaboratoryRun> {
  final Value<String> id;
  final Value<String> laboratoryId;
  final Value<DateTime> executedAt;
  final Value<String> commandsExecutedJson;
  final Value<String?> outputArtifactPath;
  final Value<bool> isPassed;
  final Value<String?> metricsJson;
  final Value<int> rowid;
  const LaboratoryRunsCompanion({
    this.id = const Value.absent(),
    this.laboratoryId = const Value.absent(),
    this.executedAt = const Value.absent(),
    this.commandsExecutedJson = const Value.absent(),
    this.outputArtifactPath = const Value.absent(),
    this.isPassed = const Value.absent(),
    this.metricsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LaboratoryRunsCompanion.insert({
    required String id,
    required String laboratoryId,
    this.executedAt = const Value.absent(),
    required String commandsExecutedJson,
    this.outputArtifactPath = const Value.absent(),
    required bool isPassed,
    this.metricsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        laboratoryId = Value(laboratoryId),
        commandsExecutedJson = Value(commandsExecutedJson),
        isPassed = Value(isPassed);
  static Insertable<LaboratoryRun> custom({
    Expression<String>? id,
    Expression<String>? laboratoryId,
    Expression<DateTime>? executedAt,
    Expression<String>? commandsExecutedJson,
    Expression<String>? outputArtifactPath,
    Expression<bool>? isPassed,
    Expression<String>? metricsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (laboratoryId != null) 'laboratory_id': laboratoryId,
      if (executedAt != null) 'executed_at': executedAt,
      if (commandsExecutedJson != null)
        'commands_executed_json': commandsExecutedJson,
      if (outputArtifactPath != null)
        'output_artifact_path': outputArtifactPath,
      if (isPassed != null) 'is_passed': isPassed,
      if (metricsJson != null) 'metrics_json': metricsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LaboratoryRunsCompanion copyWith(
      {Value<String>? id,
      Value<String>? laboratoryId,
      Value<DateTime>? executedAt,
      Value<String>? commandsExecutedJson,
      Value<String?>? outputArtifactPath,
      Value<bool>? isPassed,
      Value<String?>? metricsJson,
      Value<int>? rowid}) {
    return LaboratoryRunsCompanion(
      id: id ?? this.id,
      laboratoryId: laboratoryId ?? this.laboratoryId,
      executedAt: executedAt ?? this.executedAt,
      commandsExecutedJson: commandsExecutedJson ?? this.commandsExecutedJson,
      outputArtifactPath: outputArtifactPath ?? this.outputArtifactPath,
      isPassed: isPassed ?? this.isPassed,
      metricsJson: metricsJson ?? this.metricsJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (laboratoryId.present) {
      map['laboratory_id'] = Variable<String>(laboratoryId.value);
    }
    if (executedAt.present) {
      map['executed_at'] = Variable<DateTime>(executedAt.value);
    }
    if (commandsExecutedJson.present) {
      map['commands_executed_json'] =
          Variable<String>(commandsExecutedJson.value);
    }
    if (outputArtifactPath.present) {
      map['output_artifact_path'] = Variable<String>(outputArtifactPath.value);
    }
    if (isPassed.present) {
      map['is_passed'] = Variable<bool>(isPassed.value);
    }
    if (metricsJson.present) {
      map['metrics_json'] = Variable<String>(metricsJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LaboratoryRunsCompanion(')
          ..write('id: $id, ')
          ..write('laboratoryId: $laboratoryId, ')
          ..write('executedAt: $executedAt, ')
          ..write('commandsExecutedJson: $commandsExecutedJson, ')
          ..write('outputArtifactPath: $outputArtifactPath, ')
          ..write('isPassed: $isPassed, ')
          ..write('metricsJson: $metricsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CaseStudiesTable extends CaseStudies
    with TableInfo<$CaseStudiesTable, CaseStudy> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CaseStudiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chapterIdMeta =
      const VerificationMeta('chapterId');
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
      'chapter_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES chapters (id)'));
  static const VerificationMeta _caseTitleMeta =
      const VerificationMeta('caseTitle');
  @override
  late final GeneratedColumn<String> caseTitle = GeneratedColumn<String>(
      'case_title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _incidentSummaryMeta =
      const VerificationMeta('incidentSummary');
  @override
  late final GeneratedColumn<String> incidentSummary = GeneratedColumn<String>(
      'incident_summary', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _documentedFactsJsonMeta =
      const VerificationMeta('documentedFactsJson');
  @override
  late final GeneratedColumn<String> documentedFactsJson =
      GeneratedColumn<String>('documented_facts_json', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _investigativeInferencesJsonMeta =
      const VerificationMeta('investigativeInferencesJson');
  @override
  late final GeneratedColumn<String> investigativeInferencesJson =
      GeneratedColumn<String>(
          'investigative_inferences_json', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _alternativeHypothesesJsonMeta =
      const VerificationMeta('alternativeHypothesesJson');
  @override
  late final GeneratedColumn<String> alternativeHypothesesJson =
      GeneratedColumn<String>('alternative_hypotheses_json', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _evidentialMatrixJsonMeta =
      const VerificationMeta('evidentialMatrixJson');
  @override
  late final GeneratedColumn<String> evidentialMatrixJson =
      GeneratedColumn<String>('evidential_matrix_json', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        chapterId,
        caseTitle,
        incidentSummary,
        documentedFactsJson,
        investigativeInferencesJson,
        alternativeHypothesesJson,
        evidentialMatrixJson
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'case_studies';
  @override
  VerificationContext validateIntegrity(Insertable<CaseStudy> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(_chapterIdMeta,
          chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta));
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('case_title')) {
      context.handle(_caseTitleMeta,
          caseTitle.isAcceptableOrUnknown(data['case_title']!, _caseTitleMeta));
    } else if (isInserting) {
      context.missing(_caseTitleMeta);
    }
    if (data.containsKey('incident_summary')) {
      context.handle(
          _incidentSummaryMeta,
          incidentSummary.isAcceptableOrUnknown(
              data['incident_summary']!, _incidentSummaryMeta));
    } else if (isInserting) {
      context.missing(_incidentSummaryMeta);
    }
    if (data.containsKey('documented_facts_json')) {
      context.handle(
          _documentedFactsJsonMeta,
          documentedFactsJson.isAcceptableOrUnknown(
              data['documented_facts_json']!, _documentedFactsJsonMeta));
    } else if (isInserting) {
      context.missing(_documentedFactsJsonMeta);
    }
    if (data.containsKey('investigative_inferences_json')) {
      context.handle(
          _investigativeInferencesJsonMeta,
          investigativeInferencesJson.isAcceptableOrUnknown(
              data['investigative_inferences_json']!,
              _investigativeInferencesJsonMeta));
    } else if (isInserting) {
      context.missing(_investigativeInferencesJsonMeta);
    }
    if (data.containsKey('alternative_hypotheses_json')) {
      context.handle(
          _alternativeHypothesesJsonMeta,
          alternativeHypothesesJson.isAcceptableOrUnknown(
              data['alternative_hypotheses_json']!,
              _alternativeHypothesesJsonMeta));
    } else if (isInserting) {
      context.missing(_alternativeHypothesesJsonMeta);
    }
    if (data.containsKey('evidential_matrix_json')) {
      context.handle(
          _evidentialMatrixJsonMeta,
          evidentialMatrixJson.isAcceptableOrUnknown(
              data['evidential_matrix_json']!, _evidentialMatrixJsonMeta));
    } else if (isInserting) {
      context.missing(_evidentialMatrixJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CaseStudy map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CaseStudy(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      chapterId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chapter_id'])!,
      caseTitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}case_title'])!,
      incidentSummary: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}incident_summary'])!,
      documentedFactsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}documented_facts_json'])!,
      investigativeInferencesJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}investigative_inferences_json'])!,
      alternativeHypothesesJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}alternative_hypotheses_json'])!,
      evidentialMatrixJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}evidential_matrix_json'])!,
    );
  }

  @override
  $CaseStudiesTable createAlias(String alias) {
    return $CaseStudiesTable(attachedDatabase, alias);
  }
}

class CaseStudy extends DataClass implements Insertable<CaseStudy> {
  final String id;
  final String chapterId;
  final String caseTitle;
  final String incidentSummary;
  final String documentedFactsJson;
  final String investigativeInferencesJson;
  final String alternativeHypothesesJson;
  final String evidentialMatrixJson;
  const CaseStudy(
      {required this.id,
      required this.chapterId,
      required this.caseTitle,
      required this.incidentSummary,
      required this.documentedFactsJson,
      required this.investigativeInferencesJson,
      required this.alternativeHypothesesJson,
      required this.evidentialMatrixJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['chapter_id'] = Variable<String>(chapterId);
    map['case_title'] = Variable<String>(caseTitle);
    map['incident_summary'] = Variable<String>(incidentSummary);
    map['documented_facts_json'] = Variable<String>(documentedFactsJson);
    map['investigative_inferences_json'] =
        Variable<String>(investigativeInferencesJson);
    map['alternative_hypotheses_json'] =
        Variable<String>(alternativeHypothesesJson);
    map['evidential_matrix_json'] = Variable<String>(evidentialMatrixJson);
    return map;
  }

  CaseStudiesCompanion toCompanion(bool nullToAbsent) {
    return CaseStudiesCompanion(
      id: Value(id),
      chapterId: Value(chapterId),
      caseTitle: Value(caseTitle),
      incidentSummary: Value(incidentSummary),
      documentedFactsJson: Value(documentedFactsJson),
      investigativeInferencesJson: Value(investigativeInferencesJson),
      alternativeHypothesesJson: Value(alternativeHypothesesJson),
      evidentialMatrixJson: Value(evidentialMatrixJson),
    );
  }

  factory CaseStudy.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CaseStudy(
      id: serializer.fromJson<String>(json['id']),
      chapterId: serializer.fromJson<String>(json['chapterId']),
      caseTitle: serializer.fromJson<String>(json['caseTitle']),
      incidentSummary: serializer.fromJson<String>(json['incidentSummary']),
      documentedFactsJson:
          serializer.fromJson<String>(json['documentedFactsJson']),
      investigativeInferencesJson:
          serializer.fromJson<String>(json['investigativeInferencesJson']),
      alternativeHypothesesJson:
          serializer.fromJson<String>(json['alternativeHypothesesJson']),
      evidentialMatrixJson:
          serializer.fromJson<String>(json['evidentialMatrixJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'chapterId': serializer.toJson<String>(chapterId),
      'caseTitle': serializer.toJson<String>(caseTitle),
      'incidentSummary': serializer.toJson<String>(incidentSummary),
      'documentedFactsJson': serializer.toJson<String>(documentedFactsJson),
      'investigativeInferencesJson':
          serializer.toJson<String>(investigativeInferencesJson),
      'alternativeHypothesesJson':
          serializer.toJson<String>(alternativeHypothesesJson),
      'evidentialMatrixJson': serializer.toJson<String>(evidentialMatrixJson),
    };
  }

  CaseStudy copyWith(
          {String? id,
          String? chapterId,
          String? caseTitle,
          String? incidentSummary,
          String? documentedFactsJson,
          String? investigativeInferencesJson,
          String? alternativeHypothesesJson,
          String? evidentialMatrixJson}) =>
      CaseStudy(
        id: id ?? this.id,
        chapterId: chapterId ?? this.chapterId,
        caseTitle: caseTitle ?? this.caseTitle,
        incidentSummary: incidentSummary ?? this.incidentSummary,
        documentedFactsJson: documentedFactsJson ?? this.documentedFactsJson,
        investigativeInferencesJson:
            investigativeInferencesJson ?? this.investigativeInferencesJson,
        alternativeHypothesesJson:
            alternativeHypothesesJson ?? this.alternativeHypothesesJson,
        evidentialMatrixJson: evidentialMatrixJson ?? this.evidentialMatrixJson,
      );
  CaseStudy copyWithCompanion(CaseStudiesCompanion data) {
    return CaseStudy(
      id: data.id.present ? data.id.value : this.id,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      caseTitle: data.caseTitle.present ? data.caseTitle.value : this.caseTitle,
      incidentSummary: data.incidentSummary.present
          ? data.incidentSummary.value
          : this.incidentSummary,
      documentedFactsJson: data.documentedFactsJson.present
          ? data.documentedFactsJson.value
          : this.documentedFactsJson,
      investigativeInferencesJson: data.investigativeInferencesJson.present
          ? data.investigativeInferencesJson.value
          : this.investigativeInferencesJson,
      alternativeHypothesesJson: data.alternativeHypothesesJson.present
          ? data.alternativeHypothesesJson.value
          : this.alternativeHypothesesJson,
      evidentialMatrixJson: data.evidentialMatrixJson.present
          ? data.evidentialMatrixJson.value
          : this.evidentialMatrixJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CaseStudy(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('caseTitle: $caseTitle, ')
          ..write('incidentSummary: $incidentSummary, ')
          ..write('documentedFactsJson: $documentedFactsJson, ')
          ..write('investigativeInferencesJson: $investigativeInferencesJson, ')
          ..write('alternativeHypothesesJson: $alternativeHypothesesJson, ')
          ..write('evidentialMatrixJson: $evidentialMatrixJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      chapterId,
      caseTitle,
      incidentSummary,
      documentedFactsJson,
      investigativeInferencesJson,
      alternativeHypothesesJson,
      evidentialMatrixJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CaseStudy &&
          other.id == this.id &&
          other.chapterId == this.chapterId &&
          other.caseTitle == this.caseTitle &&
          other.incidentSummary == this.incidentSummary &&
          other.documentedFactsJson == this.documentedFactsJson &&
          other.investigativeInferencesJson ==
              this.investigativeInferencesJson &&
          other.alternativeHypothesesJson == this.alternativeHypothesesJson &&
          other.evidentialMatrixJson == this.evidentialMatrixJson);
}

class CaseStudiesCompanion extends UpdateCompanion<CaseStudy> {
  final Value<String> id;
  final Value<String> chapterId;
  final Value<String> caseTitle;
  final Value<String> incidentSummary;
  final Value<String> documentedFactsJson;
  final Value<String> investigativeInferencesJson;
  final Value<String> alternativeHypothesesJson;
  final Value<String> evidentialMatrixJson;
  final Value<int> rowid;
  const CaseStudiesCompanion({
    this.id = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.caseTitle = const Value.absent(),
    this.incidentSummary = const Value.absent(),
    this.documentedFactsJson = const Value.absent(),
    this.investigativeInferencesJson = const Value.absent(),
    this.alternativeHypothesesJson = const Value.absent(),
    this.evidentialMatrixJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CaseStudiesCompanion.insert({
    required String id,
    required String chapterId,
    required String caseTitle,
    required String incidentSummary,
    required String documentedFactsJson,
    required String investigativeInferencesJson,
    required String alternativeHypothesesJson,
    required String evidentialMatrixJson,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        chapterId = Value(chapterId),
        caseTitle = Value(caseTitle),
        incidentSummary = Value(incidentSummary),
        documentedFactsJson = Value(documentedFactsJson),
        investigativeInferencesJson = Value(investigativeInferencesJson),
        alternativeHypothesesJson = Value(alternativeHypothesesJson),
        evidentialMatrixJson = Value(evidentialMatrixJson);
  static Insertable<CaseStudy> custom({
    Expression<String>? id,
    Expression<String>? chapterId,
    Expression<String>? caseTitle,
    Expression<String>? incidentSummary,
    Expression<String>? documentedFactsJson,
    Expression<String>? investigativeInferencesJson,
    Expression<String>? alternativeHypothesesJson,
    Expression<String>? evidentialMatrixJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chapterId != null) 'chapter_id': chapterId,
      if (caseTitle != null) 'case_title': caseTitle,
      if (incidentSummary != null) 'incident_summary': incidentSummary,
      if (documentedFactsJson != null)
        'documented_facts_json': documentedFactsJson,
      if (investigativeInferencesJson != null)
        'investigative_inferences_json': investigativeInferencesJson,
      if (alternativeHypothesesJson != null)
        'alternative_hypotheses_json': alternativeHypothesesJson,
      if (evidentialMatrixJson != null)
        'evidential_matrix_json': evidentialMatrixJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CaseStudiesCompanion copyWith(
      {Value<String>? id,
      Value<String>? chapterId,
      Value<String>? caseTitle,
      Value<String>? incidentSummary,
      Value<String>? documentedFactsJson,
      Value<String>? investigativeInferencesJson,
      Value<String>? alternativeHypothesesJson,
      Value<String>? evidentialMatrixJson,
      Value<int>? rowid}) {
    return CaseStudiesCompanion(
      id: id ?? this.id,
      chapterId: chapterId ?? this.chapterId,
      caseTitle: caseTitle ?? this.caseTitle,
      incidentSummary: incidentSummary ?? this.incidentSummary,
      documentedFactsJson: documentedFactsJson ?? this.documentedFactsJson,
      investigativeInferencesJson:
          investigativeInferencesJson ?? this.investigativeInferencesJson,
      alternativeHypothesesJson:
          alternativeHypothesesJson ?? this.alternativeHypothesesJson,
      evidentialMatrixJson: evidentialMatrixJson ?? this.evidentialMatrixJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (caseTitle.present) {
      map['case_title'] = Variable<String>(caseTitle.value);
    }
    if (incidentSummary.present) {
      map['incident_summary'] = Variable<String>(incidentSummary.value);
    }
    if (documentedFactsJson.present) {
      map['documented_facts_json'] =
          Variable<String>(documentedFactsJson.value);
    }
    if (investigativeInferencesJson.present) {
      map['investigative_inferences_json'] =
          Variable<String>(investigativeInferencesJson.value);
    }
    if (alternativeHypothesesJson.present) {
      map['alternative_hypotheses_json'] =
          Variable<String>(alternativeHypothesesJson.value);
    }
    if (evidentialMatrixJson.present) {
      map['evidential_matrix_json'] =
          Variable<String>(evidentialMatrixJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CaseStudiesCompanion(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('caseTitle: $caseTitle, ')
          ..write('incidentSummary: $incidentSummary, ')
          ..write('documentedFactsJson: $documentedFactsJson, ')
          ..write('investigativeInferencesJson: $investigativeInferencesJson, ')
          ..write('alternativeHypothesesJson: $alternativeHypothesesJson, ')
          ..write('evidentialMatrixJson: $evidentialMatrixJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CaseSubmissionsTable extends CaseSubmissions
    with TableInfo<$CaseSubmissionsTable, CaseSubmission> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CaseSubmissionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _caseStudyIdMeta =
      const VerificationMeta('caseStudyId');
  @override
  late final GeneratedColumn<String> caseStudyId = GeneratedColumn<String>(
      'case_study_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES case_studies (id)'));
  static const VerificationMeta _submittedAtMeta =
      const VerificationMeta('submittedAt');
  @override
  late final GeneratedColumn<DateTime> submittedAt = GeneratedColumn<DateTime>(
      'submitted_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _reportPdfPathMeta =
      const VerificationMeta('reportPdfPath');
  @override
  late final GeneratedColumn<String> reportPdfPath = GeneratedColumn<String>(
      'report_pdf_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _conclusionTextMeta =
      const VerificationMeta('conclusionText');
  @override
  late final GeneratedColumn<String> conclusionText = GeneratedColumn<String>(
      'conclusion_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _hypothesisEvaluationJsonMeta =
      const VerificationMeta('hypothesisEvaluationJson');
  @override
  late final GeneratedColumn<String> hypothesisEvaluationJson =
      GeneratedColumn<String>('hypothesis_evaluation_json', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tutorEvaluationJsonMeta =
      const VerificationMeta('tutorEvaluationJson');
  @override
  late final GeneratedColumn<String> tutorEvaluationJson =
      GeneratedColumn<String>('tutor_evaluation_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        caseStudyId,
        submittedAt,
        reportPdfPath,
        conclusionText,
        hypothesisEvaluationJson,
        tutorEvaluationJson
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'case_submissions';
  @override
  VerificationContext validateIntegrity(Insertable<CaseSubmission> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('case_study_id')) {
      context.handle(
          _caseStudyIdMeta,
          caseStudyId.isAcceptableOrUnknown(
              data['case_study_id']!, _caseStudyIdMeta));
    } else if (isInserting) {
      context.missing(_caseStudyIdMeta);
    }
    if (data.containsKey('submitted_at')) {
      context.handle(
          _submittedAtMeta,
          submittedAt.isAcceptableOrUnknown(
              data['submitted_at']!, _submittedAtMeta));
    }
    if (data.containsKey('report_pdf_path')) {
      context.handle(
          _reportPdfPathMeta,
          reportPdfPath.isAcceptableOrUnknown(
              data['report_pdf_path']!, _reportPdfPathMeta));
    }
    if (data.containsKey('conclusion_text')) {
      context.handle(
          _conclusionTextMeta,
          conclusionText.isAcceptableOrUnknown(
              data['conclusion_text']!, _conclusionTextMeta));
    } else if (isInserting) {
      context.missing(_conclusionTextMeta);
    }
    if (data.containsKey('hypothesis_evaluation_json')) {
      context.handle(
          _hypothesisEvaluationJsonMeta,
          hypothesisEvaluationJson.isAcceptableOrUnknown(
              data['hypothesis_evaluation_json']!,
              _hypothesisEvaluationJsonMeta));
    } else if (isInserting) {
      context.missing(_hypothesisEvaluationJsonMeta);
    }
    if (data.containsKey('tutor_evaluation_json')) {
      context.handle(
          _tutorEvaluationJsonMeta,
          tutorEvaluationJson.isAcceptableOrUnknown(
              data['tutor_evaluation_json']!, _tutorEvaluationJsonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CaseSubmission map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CaseSubmission(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      caseStudyId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}case_study_id'])!,
      submittedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}submitted_at'])!,
      reportPdfPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}report_pdf_path']),
      conclusionText: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}conclusion_text'])!,
      hypothesisEvaluationJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}hypothesis_evaluation_json'])!,
      tutorEvaluationJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}tutor_evaluation_json']),
    );
  }

  @override
  $CaseSubmissionsTable createAlias(String alias) {
    return $CaseSubmissionsTable(attachedDatabase, alias);
  }
}

class CaseSubmission extends DataClass implements Insertable<CaseSubmission> {
  final String id;
  final String caseStudyId;
  final DateTime submittedAt;
  final String? reportPdfPath;
  final String conclusionText;
  final String hypothesisEvaluationJson;
  final String? tutorEvaluationJson;
  const CaseSubmission(
      {required this.id,
      required this.caseStudyId,
      required this.submittedAt,
      this.reportPdfPath,
      required this.conclusionText,
      required this.hypothesisEvaluationJson,
      this.tutorEvaluationJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['case_study_id'] = Variable<String>(caseStudyId);
    map['submitted_at'] = Variable<DateTime>(submittedAt);
    if (!nullToAbsent || reportPdfPath != null) {
      map['report_pdf_path'] = Variable<String>(reportPdfPath);
    }
    map['conclusion_text'] = Variable<String>(conclusionText);
    map['hypothesis_evaluation_json'] =
        Variable<String>(hypothesisEvaluationJson);
    if (!nullToAbsent || tutorEvaluationJson != null) {
      map['tutor_evaluation_json'] = Variable<String>(tutorEvaluationJson);
    }
    return map;
  }

  CaseSubmissionsCompanion toCompanion(bool nullToAbsent) {
    return CaseSubmissionsCompanion(
      id: Value(id),
      caseStudyId: Value(caseStudyId),
      submittedAt: Value(submittedAt),
      reportPdfPath: reportPdfPath == null && nullToAbsent
          ? const Value.absent()
          : Value(reportPdfPath),
      conclusionText: Value(conclusionText),
      hypothesisEvaluationJson: Value(hypothesisEvaluationJson),
      tutorEvaluationJson: tutorEvaluationJson == null && nullToAbsent
          ? const Value.absent()
          : Value(tutorEvaluationJson),
    );
  }

  factory CaseSubmission.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CaseSubmission(
      id: serializer.fromJson<String>(json['id']),
      caseStudyId: serializer.fromJson<String>(json['caseStudyId']),
      submittedAt: serializer.fromJson<DateTime>(json['submittedAt']),
      reportPdfPath: serializer.fromJson<String?>(json['reportPdfPath']),
      conclusionText: serializer.fromJson<String>(json['conclusionText']),
      hypothesisEvaluationJson:
          serializer.fromJson<String>(json['hypothesisEvaluationJson']),
      tutorEvaluationJson:
          serializer.fromJson<String?>(json['tutorEvaluationJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'caseStudyId': serializer.toJson<String>(caseStudyId),
      'submittedAt': serializer.toJson<DateTime>(submittedAt),
      'reportPdfPath': serializer.toJson<String?>(reportPdfPath),
      'conclusionText': serializer.toJson<String>(conclusionText),
      'hypothesisEvaluationJson':
          serializer.toJson<String>(hypothesisEvaluationJson),
      'tutorEvaluationJson': serializer.toJson<String?>(tutorEvaluationJson),
    };
  }

  CaseSubmission copyWith(
          {String? id,
          String? caseStudyId,
          DateTime? submittedAt,
          Value<String?> reportPdfPath = const Value.absent(),
          String? conclusionText,
          String? hypothesisEvaluationJson,
          Value<String?> tutorEvaluationJson = const Value.absent()}) =>
      CaseSubmission(
        id: id ?? this.id,
        caseStudyId: caseStudyId ?? this.caseStudyId,
        submittedAt: submittedAt ?? this.submittedAt,
        reportPdfPath:
            reportPdfPath.present ? reportPdfPath.value : this.reportPdfPath,
        conclusionText: conclusionText ?? this.conclusionText,
        hypothesisEvaluationJson:
            hypothesisEvaluationJson ?? this.hypothesisEvaluationJson,
        tutorEvaluationJson: tutorEvaluationJson.present
            ? tutorEvaluationJson.value
            : this.tutorEvaluationJson,
      );
  CaseSubmission copyWithCompanion(CaseSubmissionsCompanion data) {
    return CaseSubmission(
      id: data.id.present ? data.id.value : this.id,
      caseStudyId:
          data.caseStudyId.present ? data.caseStudyId.value : this.caseStudyId,
      submittedAt:
          data.submittedAt.present ? data.submittedAt.value : this.submittedAt,
      reportPdfPath: data.reportPdfPath.present
          ? data.reportPdfPath.value
          : this.reportPdfPath,
      conclusionText: data.conclusionText.present
          ? data.conclusionText.value
          : this.conclusionText,
      hypothesisEvaluationJson: data.hypothesisEvaluationJson.present
          ? data.hypothesisEvaluationJson.value
          : this.hypothesisEvaluationJson,
      tutorEvaluationJson: data.tutorEvaluationJson.present
          ? data.tutorEvaluationJson.value
          : this.tutorEvaluationJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CaseSubmission(')
          ..write('id: $id, ')
          ..write('caseStudyId: $caseStudyId, ')
          ..write('submittedAt: $submittedAt, ')
          ..write('reportPdfPath: $reportPdfPath, ')
          ..write('conclusionText: $conclusionText, ')
          ..write('hypothesisEvaluationJson: $hypothesisEvaluationJson, ')
          ..write('tutorEvaluationJson: $tutorEvaluationJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, caseStudyId, submittedAt, reportPdfPath,
      conclusionText, hypothesisEvaluationJson, tutorEvaluationJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CaseSubmission &&
          other.id == this.id &&
          other.caseStudyId == this.caseStudyId &&
          other.submittedAt == this.submittedAt &&
          other.reportPdfPath == this.reportPdfPath &&
          other.conclusionText == this.conclusionText &&
          other.hypothesisEvaluationJson == this.hypothesisEvaluationJson &&
          other.tutorEvaluationJson == this.tutorEvaluationJson);
}

class CaseSubmissionsCompanion extends UpdateCompanion<CaseSubmission> {
  final Value<String> id;
  final Value<String> caseStudyId;
  final Value<DateTime> submittedAt;
  final Value<String?> reportPdfPath;
  final Value<String> conclusionText;
  final Value<String> hypothesisEvaluationJson;
  final Value<String?> tutorEvaluationJson;
  final Value<int> rowid;
  const CaseSubmissionsCompanion({
    this.id = const Value.absent(),
    this.caseStudyId = const Value.absent(),
    this.submittedAt = const Value.absent(),
    this.reportPdfPath = const Value.absent(),
    this.conclusionText = const Value.absent(),
    this.hypothesisEvaluationJson = const Value.absent(),
    this.tutorEvaluationJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CaseSubmissionsCompanion.insert({
    required String id,
    required String caseStudyId,
    this.submittedAt = const Value.absent(),
    this.reportPdfPath = const Value.absent(),
    required String conclusionText,
    required String hypothesisEvaluationJson,
    this.tutorEvaluationJson = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        caseStudyId = Value(caseStudyId),
        conclusionText = Value(conclusionText),
        hypothesisEvaluationJson = Value(hypothesisEvaluationJson);
  static Insertable<CaseSubmission> custom({
    Expression<String>? id,
    Expression<String>? caseStudyId,
    Expression<DateTime>? submittedAt,
    Expression<String>? reportPdfPath,
    Expression<String>? conclusionText,
    Expression<String>? hypothesisEvaluationJson,
    Expression<String>? tutorEvaluationJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (caseStudyId != null) 'case_study_id': caseStudyId,
      if (submittedAt != null) 'submitted_at': submittedAt,
      if (reportPdfPath != null) 'report_pdf_path': reportPdfPath,
      if (conclusionText != null) 'conclusion_text': conclusionText,
      if (hypothesisEvaluationJson != null)
        'hypothesis_evaluation_json': hypothesisEvaluationJson,
      if (tutorEvaluationJson != null)
        'tutor_evaluation_json': tutorEvaluationJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CaseSubmissionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? caseStudyId,
      Value<DateTime>? submittedAt,
      Value<String?>? reportPdfPath,
      Value<String>? conclusionText,
      Value<String>? hypothesisEvaluationJson,
      Value<String?>? tutorEvaluationJson,
      Value<int>? rowid}) {
    return CaseSubmissionsCompanion(
      id: id ?? this.id,
      caseStudyId: caseStudyId ?? this.caseStudyId,
      submittedAt: submittedAt ?? this.submittedAt,
      reportPdfPath: reportPdfPath ?? this.reportPdfPath,
      conclusionText: conclusionText ?? this.conclusionText,
      hypothesisEvaluationJson:
          hypothesisEvaluationJson ?? this.hypothesisEvaluationJson,
      tutorEvaluationJson: tutorEvaluationJson ?? this.tutorEvaluationJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (caseStudyId.present) {
      map['case_study_id'] = Variable<String>(caseStudyId.value);
    }
    if (submittedAt.present) {
      map['submitted_at'] = Variable<DateTime>(submittedAt.value);
    }
    if (reportPdfPath.present) {
      map['report_pdf_path'] = Variable<String>(reportPdfPath.value);
    }
    if (conclusionText.present) {
      map['conclusion_text'] = Variable<String>(conclusionText.value);
    }
    if (hypothesisEvaluationJson.present) {
      map['hypothesis_evaluation_json'] =
          Variable<String>(hypothesisEvaluationJson.value);
    }
    if (tutorEvaluationJson.present) {
      map['tutor_evaluation_json'] =
          Variable<String>(tutorEvaluationJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CaseSubmissionsCompanion(')
          ..write('id: $id, ')
          ..write('caseStudyId: $caseStudyId, ')
          ..write('submittedAt: $submittedAt, ')
          ..write('reportPdfPath: $reportPdfPath, ')
          ..write('conclusionText: $conclusionText, ')
          ..write('hypothesisEvaluationJson: $hypothesisEvaluationJson, ')
          ..write('tutorEvaluationJson: $tutorEvaluationJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StudySessionsTable extends StudySessions
    with TableInfo<$StudySessionsTable, StudySession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudySessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chapterIdMeta =
      const VerificationMeta('chapterId');
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
      'chapter_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES chapters (id)'));
  static const VerificationMeta _startTimeMeta =
      const VerificationMeta('startTime');
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
      'start_time', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _endTimeMeta =
      const VerificationMeta('endTime');
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
      'end_time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _durationSecondsMeta =
      const VerificationMeta('durationSeconds');
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
      'duration_seconds', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _pagesReadMeta =
      const VerificationMeta('pagesRead');
  @override
  late final GeneratedColumn<int> pagesRead = GeneratedColumn<int>(
      'pages_read', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _notesCountMeta =
      const VerificationMeta('notesCount');
  @override
  late final GeneratedColumn<int> notesCount = GeneratedColumn<int>(
      'notes_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        chapterId,
        startTime,
        endTime,
        durationSeconds,
        pagesRead,
        notesCount
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'study_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<StudySession> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(_chapterIdMeta,
          chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta));
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(_startTimeMeta,
          startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));
    }
    if (data.containsKey('end_time')) {
      context.handle(_endTimeMeta,
          endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta));
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
          _durationSecondsMeta,
          durationSeconds.isAcceptableOrUnknown(
              data['duration_seconds']!, _durationSecondsMeta));
    }
    if (data.containsKey('pages_read')) {
      context.handle(_pagesReadMeta,
          pagesRead.isAcceptableOrUnknown(data['pages_read']!, _pagesReadMeta));
    }
    if (data.containsKey('notes_count')) {
      context.handle(
          _notesCountMeta,
          notesCount.isAcceptableOrUnknown(
              data['notes_count']!, _notesCountMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StudySession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudySession(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      chapterId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chapter_id'])!,
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_time'])!,
      endTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_time']),
      durationSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_seconds'])!,
      pagesRead: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}pages_read'])!,
      notesCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}notes_count'])!,
    );
  }

  @override
  $StudySessionsTable createAlias(String alias) {
    return $StudySessionsTable(attachedDatabase, alias);
  }
}

class StudySession extends DataClass implements Insertable<StudySession> {
  final String id;
  final String chapterId;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationSeconds;
  final int pagesRead;
  final int notesCount;
  const StudySession(
      {required this.id,
      required this.chapterId,
      required this.startTime,
      this.endTime,
      required this.durationSeconds,
      required this.pagesRead,
      required this.notesCount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['chapter_id'] = Variable<String>(chapterId);
    map['start_time'] = Variable<DateTime>(startTime);
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<DateTime>(endTime);
    }
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['pages_read'] = Variable<int>(pagesRead);
    map['notes_count'] = Variable<int>(notesCount);
    return map;
  }

  StudySessionsCompanion toCompanion(bool nullToAbsent) {
    return StudySessionsCompanion(
      id: Value(id),
      chapterId: Value(chapterId),
      startTime: Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      durationSeconds: Value(durationSeconds),
      pagesRead: Value(pagesRead),
      notesCount: Value(notesCount),
    );
  }

  factory StudySession.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudySession(
      id: serializer.fromJson<String>(json['id']),
      chapterId: serializer.fromJson<String>(json['chapterId']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime?>(json['endTime']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      pagesRead: serializer.fromJson<int>(json['pagesRead']),
      notesCount: serializer.fromJson<int>(json['notesCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'chapterId': serializer.toJson<String>(chapterId),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime?>(endTime),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'pagesRead': serializer.toJson<int>(pagesRead),
      'notesCount': serializer.toJson<int>(notesCount),
    };
  }

  StudySession copyWith(
          {String? id,
          String? chapterId,
          DateTime? startTime,
          Value<DateTime?> endTime = const Value.absent(),
          int? durationSeconds,
          int? pagesRead,
          int? notesCount}) =>
      StudySession(
        id: id ?? this.id,
        chapterId: chapterId ?? this.chapterId,
        startTime: startTime ?? this.startTime,
        endTime: endTime.present ? endTime.value : this.endTime,
        durationSeconds: durationSeconds ?? this.durationSeconds,
        pagesRead: pagesRead ?? this.pagesRead,
        notesCount: notesCount ?? this.notesCount,
      );
  StudySession copyWithCompanion(StudySessionsCompanion data) {
    return StudySession(
      id: data.id.present ? data.id.value : this.id,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      pagesRead: data.pagesRead.present ? data.pagesRead.value : this.pagesRead,
      notesCount:
          data.notesCount.present ? data.notesCount.value : this.notesCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudySession(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('pagesRead: $pagesRead, ')
          ..write('notesCount: $notesCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, chapterId, startTime, endTime,
      durationSeconds, pagesRead, notesCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudySession &&
          other.id == this.id &&
          other.chapterId == this.chapterId &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.durationSeconds == this.durationSeconds &&
          other.pagesRead == this.pagesRead &&
          other.notesCount == this.notesCount);
}

class StudySessionsCompanion extends UpdateCompanion<StudySession> {
  final Value<String> id;
  final Value<String> chapterId;
  final Value<DateTime> startTime;
  final Value<DateTime?> endTime;
  final Value<int> durationSeconds;
  final Value<int> pagesRead;
  final Value<int> notesCount;
  final Value<int> rowid;
  const StudySessionsCompanion({
    this.id = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.pagesRead = const Value.absent(),
    this.notesCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudySessionsCompanion.insert({
    required String id,
    required String chapterId,
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.pagesRead = const Value.absent(),
    this.notesCount = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        chapterId = Value(chapterId);
  static Insertable<StudySession> custom({
    Expression<String>? id,
    Expression<String>? chapterId,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<int>? durationSeconds,
    Expression<int>? pagesRead,
    Expression<int>? notesCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chapterId != null) 'chapter_id': chapterId,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (pagesRead != null) 'pages_read': pagesRead,
      if (notesCount != null) 'notes_count': notesCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudySessionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? chapterId,
      Value<DateTime>? startTime,
      Value<DateTime?>? endTime,
      Value<int>? durationSeconds,
      Value<int>? pagesRead,
      Value<int>? notesCount,
      Value<int>? rowid}) {
    return StudySessionsCompanion(
      id: id ?? this.id,
      chapterId: chapterId ?? this.chapterId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      pagesRead: pagesRead ?? this.pagesRead,
      notesCount: notesCount ?? this.notesCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (pagesRead.present) {
      map['pages_read'] = Variable<int>(pagesRead.value);
    }
    if (notesCount.present) {
      map['notes_count'] = Variable<int>(notesCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudySessionsCompanion(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('pagesRead: $pagesRead, ')
          ..write('notesCount: $notesCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingPositionsTable extends ReadingPositions
    with TableInfo<$ReadingPositionsTable, ReadingPosition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingPositionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _chapterIdMeta =
      const VerificationMeta('chapterId');
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
      'chapter_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES chapters (id)'));
  static const VerificationMeta _pageNumberMeta =
      const VerificationMeta('pageNumber');
  @override
  late final GeneratedColumn<int> pageNumber = GeneratedColumn<int>(
      'page_number', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _scrollRatioMeta =
      const VerificationMeta('scrollRatio');
  @override
  late final GeneratedColumn<double> scrollRatio = GeneratedColumn<double>(
      'scroll_ratio', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _lastParagraphIndexMeta =
      const VerificationMeta('lastParagraphIndex');
  @override
  late final GeneratedColumn<int> lastParagraphIndex = GeneratedColumn<int>(
      'last_paragraph_index', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [chapterId, pageNumber, scrollRatio, lastParagraphIndex, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_positions';
  @override
  VerificationContext validateIntegrity(Insertable<ReadingPosition> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('chapter_id')) {
      context.handle(_chapterIdMeta,
          chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta));
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('page_number')) {
      context.handle(
          _pageNumberMeta,
          pageNumber.isAcceptableOrUnknown(
              data['page_number']!, _pageNumberMeta));
    }
    if (data.containsKey('scroll_ratio')) {
      context.handle(
          _scrollRatioMeta,
          scrollRatio.isAcceptableOrUnknown(
              data['scroll_ratio']!, _scrollRatioMeta));
    }
    if (data.containsKey('last_paragraph_index')) {
      context.handle(
          _lastParagraphIndexMeta,
          lastParagraphIndex.isAcceptableOrUnknown(
              data['last_paragraph_index']!, _lastParagraphIndexMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chapterId};
  @override
  ReadingPosition map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingPosition(
      chapterId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chapter_id'])!,
      pageNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}page_number'])!,
      scrollRatio: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}scroll_ratio'])!,
      lastParagraphIndex: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}last_paragraph_index'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ReadingPositionsTable createAlias(String alias) {
    return $ReadingPositionsTable(attachedDatabase, alias);
  }
}

class ReadingPosition extends DataClass implements Insertable<ReadingPosition> {
  final String chapterId;
  final int pageNumber;
  final double scrollRatio;
  final int lastParagraphIndex;
  final DateTime updatedAt;
  const ReadingPosition(
      {required this.chapterId,
      required this.pageNumber,
      required this.scrollRatio,
      required this.lastParagraphIndex,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chapter_id'] = Variable<String>(chapterId);
    map['page_number'] = Variable<int>(pageNumber);
    map['scroll_ratio'] = Variable<double>(scrollRatio);
    map['last_paragraph_index'] = Variable<int>(lastParagraphIndex);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ReadingPositionsCompanion toCompanion(bool nullToAbsent) {
    return ReadingPositionsCompanion(
      chapterId: Value(chapterId),
      pageNumber: Value(pageNumber),
      scrollRatio: Value(scrollRatio),
      lastParagraphIndex: Value(lastParagraphIndex),
      updatedAt: Value(updatedAt),
    );
  }

  factory ReadingPosition.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingPosition(
      chapterId: serializer.fromJson<String>(json['chapterId']),
      pageNumber: serializer.fromJson<int>(json['pageNumber']),
      scrollRatio: serializer.fromJson<double>(json['scrollRatio']),
      lastParagraphIndex: serializer.fromJson<int>(json['lastParagraphIndex']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chapterId': serializer.toJson<String>(chapterId),
      'pageNumber': serializer.toJson<int>(pageNumber),
      'scrollRatio': serializer.toJson<double>(scrollRatio),
      'lastParagraphIndex': serializer.toJson<int>(lastParagraphIndex),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ReadingPosition copyWith(
          {String? chapterId,
          int? pageNumber,
          double? scrollRatio,
          int? lastParagraphIndex,
          DateTime? updatedAt}) =>
      ReadingPosition(
        chapterId: chapterId ?? this.chapterId,
        pageNumber: pageNumber ?? this.pageNumber,
        scrollRatio: scrollRatio ?? this.scrollRatio,
        lastParagraphIndex: lastParagraphIndex ?? this.lastParagraphIndex,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ReadingPosition copyWithCompanion(ReadingPositionsCompanion data) {
    return ReadingPosition(
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      pageNumber:
          data.pageNumber.present ? data.pageNumber.value : this.pageNumber,
      scrollRatio:
          data.scrollRatio.present ? data.scrollRatio.value : this.scrollRatio,
      lastParagraphIndex: data.lastParagraphIndex.present
          ? data.lastParagraphIndex.value
          : this.lastParagraphIndex,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingPosition(')
          ..write('chapterId: $chapterId, ')
          ..write('pageNumber: $pageNumber, ')
          ..write('scrollRatio: $scrollRatio, ')
          ..write('lastParagraphIndex: $lastParagraphIndex, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      chapterId, pageNumber, scrollRatio, lastParagraphIndex, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingPosition &&
          other.chapterId == this.chapterId &&
          other.pageNumber == this.pageNumber &&
          other.scrollRatio == this.scrollRatio &&
          other.lastParagraphIndex == this.lastParagraphIndex &&
          other.updatedAt == this.updatedAt);
}

class ReadingPositionsCompanion extends UpdateCompanion<ReadingPosition> {
  final Value<String> chapterId;
  final Value<int> pageNumber;
  final Value<double> scrollRatio;
  final Value<int> lastParagraphIndex;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ReadingPositionsCompanion({
    this.chapterId = const Value.absent(),
    this.pageNumber = const Value.absent(),
    this.scrollRatio = const Value.absent(),
    this.lastParagraphIndex = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadingPositionsCompanion.insert({
    required String chapterId,
    this.pageNumber = const Value.absent(),
    this.scrollRatio = const Value.absent(),
    this.lastParagraphIndex = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : chapterId = Value(chapterId);
  static Insertable<ReadingPosition> custom({
    Expression<String>? chapterId,
    Expression<int>? pageNumber,
    Expression<double>? scrollRatio,
    Expression<int>? lastParagraphIndex,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (chapterId != null) 'chapter_id': chapterId,
      if (pageNumber != null) 'page_number': pageNumber,
      if (scrollRatio != null) 'scroll_ratio': scrollRatio,
      if (lastParagraphIndex != null)
        'last_paragraph_index': lastParagraphIndex,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadingPositionsCompanion copyWith(
      {Value<String>? chapterId,
      Value<int>? pageNumber,
      Value<double>? scrollRatio,
      Value<int>? lastParagraphIndex,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ReadingPositionsCompanion(
      chapterId: chapterId ?? this.chapterId,
      pageNumber: pageNumber ?? this.pageNumber,
      scrollRatio: scrollRatio ?? this.scrollRatio,
      lastParagraphIndex: lastParagraphIndex ?? this.lastParagraphIndex,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (pageNumber.present) {
      map['page_number'] = Variable<int>(pageNumber.value);
    }
    if (scrollRatio.present) {
      map['scroll_ratio'] = Variable<double>(scrollRatio.value);
    }
    if (lastParagraphIndex.present) {
      map['last_paragraph_index'] = Variable<int>(lastParagraphIndex.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingPositionsCompanion(')
          ..write('chapterId: $chapterId, ')
          ..write('pageNumber: $pageNumber, ')
          ..write('scrollRatio: $scrollRatio, ')
          ..write('lastParagraphIndex: $lastParagraphIndex, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookmarksTable extends Bookmarks
    with TableInfo<$BookmarksTable, Bookmark> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chapterIdMeta =
      const VerificationMeta('chapterId');
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
      'chapter_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES chapters (id)'));
  static const VerificationMeta _pageNumberMeta =
      const VerificationMeta('pageNumber');
  @override
  late final GeneratedColumn<int> pageNumber = GeneratedColumn<int>(
      'page_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _sectionTitleMeta =
      const VerificationMeta('sectionTitle');
  @override
  late final GeneratedColumn<String> sectionTitle = GeneratedColumn<String>(
      'section_title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, chapterId, pageNumber, sectionTitle, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmarks';
  @override
  VerificationContext validateIntegrity(Insertable<Bookmark> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(_chapterIdMeta,
          chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta));
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('page_number')) {
      context.handle(
          _pageNumberMeta,
          pageNumber.isAcceptableOrUnknown(
              data['page_number']!, _pageNumberMeta));
    } else if (isInserting) {
      context.missing(_pageNumberMeta);
    }
    if (data.containsKey('section_title')) {
      context.handle(
          _sectionTitleMeta,
          sectionTitle.isAcceptableOrUnknown(
              data['section_title']!, _sectionTitleMeta));
    } else if (isInserting) {
      context.missing(_sectionTitleMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Bookmark map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Bookmark(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      chapterId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chapter_id'])!,
      pageNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}page_number'])!,
      sectionTitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}section_title'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $BookmarksTable createAlias(String alias) {
    return $BookmarksTable(attachedDatabase, alias);
  }
}

class Bookmark extends DataClass implements Insertable<Bookmark> {
  final String id;
  final String chapterId;
  final int pageNumber;
  final String sectionTitle;
  final DateTime createdAt;
  const Bookmark(
      {required this.id,
      required this.chapterId,
      required this.pageNumber,
      required this.sectionTitle,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['chapter_id'] = Variable<String>(chapterId);
    map['page_number'] = Variable<int>(pageNumber);
    map['section_title'] = Variable<String>(sectionTitle);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BookmarksCompanion toCompanion(bool nullToAbsent) {
    return BookmarksCompanion(
      id: Value(id),
      chapterId: Value(chapterId),
      pageNumber: Value(pageNumber),
      sectionTitle: Value(sectionTitle),
      createdAt: Value(createdAt),
    );
  }

  factory Bookmark.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Bookmark(
      id: serializer.fromJson<String>(json['id']),
      chapterId: serializer.fromJson<String>(json['chapterId']),
      pageNumber: serializer.fromJson<int>(json['pageNumber']),
      sectionTitle: serializer.fromJson<String>(json['sectionTitle']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'chapterId': serializer.toJson<String>(chapterId),
      'pageNumber': serializer.toJson<int>(pageNumber),
      'sectionTitle': serializer.toJson<String>(sectionTitle),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Bookmark copyWith(
          {String? id,
          String? chapterId,
          int? pageNumber,
          String? sectionTitle,
          DateTime? createdAt}) =>
      Bookmark(
        id: id ?? this.id,
        chapterId: chapterId ?? this.chapterId,
        pageNumber: pageNumber ?? this.pageNumber,
        sectionTitle: sectionTitle ?? this.sectionTitle,
        createdAt: createdAt ?? this.createdAt,
      );
  Bookmark copyWithCompanion(BookmarksCompanion data) {
    return Bookmark(
      id: data.id.present ? data.id.value : this.id,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      pageNumber:
          data.pageNumber.present ? data.pageNumber.value : this.pageNumber,
      sectionTitle: data.sectionTitle.present
          ? data.sectionTitle.value
          : this.sectionTitle,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Bookmark(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('pageNumber: $pageNumber, ')
          ..write('sectionTitle: $sectionTitle, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, chapterId, pageNumber, sectionTitle, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Bookmark &&
          other.id == this.id &&
          other.chapterId == this.chapterId &&
          other.pageNumber == this.pageNumber &&
          other.sectionTitle == this.sectionTitle &&
          other.createdAt == this.createdAt);
}

class BookmarksCompanion extends UpdateCompanion<Bookmark> {
  final Value<String> id;
  final Value<String> chapterId;
  final Value<int> pageNumber;
  final Value<String> sectionTitle;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BookmarksCompanion({
    this.id = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.pageNumber = const Value.absent(),
    this.sectionTitle = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookmarksCompanion.insert({
    required String id,
    required String chapterId,
    required int pageNumber,
    required String sectionTitle,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        chapterId = Value(chapterId),
        pageNumber = Value(pageNumber),
        sectionTitle = Value(sectionTitle);
  static Insertable<Bookmark> custom({
    Expression<String>? id,
    Expression<String>? chapterId,
    Expression<int>? pageNumber,
    Expression<String>? sectionTitle,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chapterId != null) 'chapter_id': chapterId,
      if (pageNumber != null) 'page_number': pageNumber,
      if (sectionTitle != null) 'section_title': sectionTitle,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookmarksCompanion copyWith(
      {Value<String>? id,
      Value<String>? chapterId,
      Value<int>? pageNumber,
      Value<String>? sectionTitle,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return BookmarksCompanion(
      id: id ?? this.id,
      chapterId: chapterId ?? this.chapterId,
      pageNumber: pageNumber ?? this.pageNumber,
      sectionTitle: sectionTitle ?? this.sectionTitle,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (pageNumber.present) {
      map['page_number'] = Variable<int>(pageNumber.value);
    }
    if (sectionTitle.present) {
      map['section_title'] = Variable<String>(sectionTitle.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarksCompanion(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('pageNumber: $pageNumber, ')
          ..write('sectionTitle: $sectionTitle, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AnnotationsTable extends Annotations
    with TableInfo<$AnnotationsTable, Annotation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnnotationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chapterIdMeta =
      const VerificationMeta('chapterId');
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
      'chapter_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES chapters (id)'));
  static const VerificationMeta _pageNumberMeta =
      const VerificationMeta('pageNumber');
  @override
  late final GeneratedColumn<int> pageNumber = GeneratedColumn<int>(
      'page_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _selectedTextMeta =
      const VerificationMeta('selectedText');
  @override
  late final GeneratedColumn<String> selectedText = GeneratedColumn<String>(
      'selected_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _highlightColorMeta =
      const VerificationMeta('highlightColor');
  @override
  late final GeneratedColumn<String> highlightColor = GeneratedColumn<String>(
      'highlight_color', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('#347259'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        chapterId,
        pageNumber,
        selectedText,
        note,
        highlightColor,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'annotations';
  @override
  VerificationContext validateIntegrity(Insertable<Annotation> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(_chapterIdMeta,
          chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta));
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('page_number')) {
      context.handle(
          _pageNumberMeta,
          pageNumber.isAcceptableOrUnknown(
              data['page_number']!, _pageNumberMeta));
    } else if (isInserting) {
      context.missing(_pageNumberMeta);
    }
    if (data.containsKey('selected_text')) {
      context.handle(
          _selectedTextMeta,
          selectedText.isAcceptableOrUnknown(
              data['selected_text']!, _selectedTextMeta));
    } else if (isInserting) {
      context.missing(_selectedTextMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    if (data.containsKey('highlight_color')) {
      context.handle(
          _highlightColorMeta,
          highlightColor.isAcceptableOrUnknown(
              data['highlight_color']!, _highlightColorMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Annotation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Annotation(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      chapterId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chapter_id'])!,
      pageNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}page_number'])!,
      selectedText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}selected_text'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note'])!,
      highlightColor: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}highlight_color'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $AnnotationsTable createAlias(String alias) {
    return $AnnotationsTable(attachedDatabase, alias);
  }
}

class Annotation extends DataClass implements Insertable<Annotation> {
  final String id;
  final String chapterId;
  final int pageNumber;
  final String selectedText;
  final String note;
  final String highlightColor;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Annotation(
      {required this.id,
      required this.chapterId,
      required this.pageNumber,
      required this.selectedText,
      required this.note,
      required this.highlightColor,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['chapter_id'] = Variable<String>(chapterId);
    map['page_number'] = Variable<int>(pageNumber);
    map['selected_text'] = Variable<String>(selectedText);
    map['note'] = Variable<String>(note);
    map['highlight_color'] = Variable<String>(highlightColor);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AnnotationsCompanion toCompanion(bool nullToAbsent) {
    return AnnotationsCompanion(
      id: Value(id),
      chapterId: Value(chapterId),
      pageNumber: Value(pageNumber),
      selectedText: Value(selectedText),
      note: Value(note),
      highlightColor: Value(highlightColor),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Annotation.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Annotation(
      id: serializer.fromJson<String>(json['id']),
      chapterId: serializer.fromJson<String>(json['chapterId']),
      pageNumber: serializer.fromJson<int>(json['pageNumber']),
      selectedText: serializer.fromJson<String>(json['selectedText']),
      note: serializer.fromJson<String>(json['note']),
      highlightColor: serializer.fromJson<String>(json['highlightColor']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'chapterId': serializer.toJson<String>(chapterId),
      'pageNumber': serializer.toJson<int>(pageNumber),
      'selectedText': serializer.toJson<String>(selectedText),
      'note': serializer.toJson<String>(note),
      'highlightColor': serializer.toJson<String>(highlightColor),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Annotation copyWith(
          {String? id,
          String? chapterId,
          int? pageNumber,
          String? selectedText,
          String? note,
          String? highlightColor,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Annotation(
        id: id ?? this.id,
        chapterId: chapterId ?? this.chapterId,
        pageNumber: pageNumber ?? this.pageNumber,
        selectedText: selectedText ?? this.selectedText,
        note: note ?? this.note,
        highlightColor: highlightColor ?? this.highlightColor,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Annotation copyWithCompanion(AnnotationsCompanion data) {
    return Annotation(
      id: data.id.present ? data.id.value : this.id,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      pageNumber:
          data.pageNumber.present ? data.pageNumber.value : this.pageNumber,
      selectedText: data.selectedText.present
          ? data.selectedText.value
          : this.selectedText,
      note: data.note.present ? data.note.value : this.note,
      highlightColor: data.highlightColor.present
          ? data.highlightColor.value
          : this.highlightColor,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Annotation(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('pageNumber: $pageNumber, ')
          ..write('selectedText: $selectedText, ')
          ..write('note: $note, ')
          ..write('highlightColor: $highlightColor, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, chapterId, pageNumber, selectedText, note,
      highlightColor, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Annotation &&
          other.id == this.id &&
          other.chapterId == this.chapterId &&
          other.pageNumber == this.pageNumber &&
          other.selectedText == this.selectedText &&
          other.note == this.note &&
          other.highlightColor == this.highlightColor &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AnnotationsCompanion extends UpdateCompanion<Annotation> {
  final Value<String> id;
  final Value<String> chapterId;
  final Value<int> pageNumber;
  final Value<String> selectedText;
  final Value<String> note;
  final Value<String> highlightColor;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AnnotationsCompanion({
    this.id = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.pageNumber = const Value.absent(),
    this.selectedText = const Value.absent(),
    this.note = const Value.absent(),
    this.highlightColor = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnnotationsCompanion.insert({
    required String id,
    required String chapterId,
    required int pageNumber,
    required String selectedText,
    required String note,
    this.highlightColor = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        chapterId = Value(chapterId),
        pageNumber = Value(pageNumber),
        selectedText = Value(selectedText),
        note = Value(note);
  static Insertable<Annotation> custom({
    Expression<String>? id,
    Expression<String>? chapterId,
    Expression<int>? pageNumber,
    Expression<String>? selectedText,
    Expression<String>? note,
    Expression<String>? highlightColor,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chapterId != null) 'chapter_id': chapterId,
      if (pageNumber != null) 'page_number': pageNumber,
      if (selectedText != null) 'selected_text': selectedText,
      if (note != null) 'note': note,
      if (highlightColor != null) 'highlight_color': highlightColor,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnnotationsCompanion copyWith(
      {Value<String>? id,
      Value<String>? chapterId,
      Value<int>? pageNumber,
      Value<String>? selectedText,
      Value<String>? note,
      Value<String>? highlightColor,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return AnnotationsCompanion(
      id: id ?? this.id,
      chapterId: chapterId ?? this.chapterId,
      pageNumber: pageNumber ?? this.pageNumber,
      selectedText: selectedText ?? this.selectedText,
      note: note ?? this.note,
      highlightColor: highlightColor ?? this.highlightColor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (pageNumber.present) {
      map['page_number'] = Variable<int>(pageNumber.value);
    }
    if (selectedText.present) {
      map['selected_text'] = Variable<String>(selectedText.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (highlightColor.present) {
      map['highlight_color'] = Variable<String>(highlightColor.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnnotationsCompanion(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('pageNumber: $pageNumber, ')
          ..write('selectedText: $selectedText, ')
          ..write('note: $note, ')
          ..write('highlightColor: $highlightColor, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReviewSchedulesTable extends ReviewSchedules
    with TableInfo<$ReviewSchedulesTable, ReviewSchedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewSchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chapterIdMeta =
      const VerificationMeta('chapterId');
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
      'chapter_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES chapters (id)'));
  static const VerificationMeta _competencyIdMeta =
      const VerificationMeta('competencyId');
  @override
  late final GeneratedColumn<String> competencyId = GeneratedColumn<String>(
      'competency_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES competencies (id)'));
  static const VerificationMeta _scheduledDateMeta =
      const VerificationMeta('scheduledDate');
  @override
  late final GeneratedColumn<DateTime> scheduledDate =
      GeneratedColumn<DateTime>('scheduled_date', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _repetitionIntervalDaysMeta =
      const VerificationMeta('repetitionIntervalDays');
  @override
  late final GeneratedColumn<int> repetitionIntervalDays = GeneratedColumn<int>(
      'repetition_interval_days', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _easinessFactorMeta =
      const VerificationMeta('easinessFactor');
  @override
  late final GeneratedColumn<double> easinessFactor = GeneratedColumn<double>(
      'easiness_factor', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(2.5));
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _lastReviewedAtMeta =
      const VerificationMeta('lastReviewedAt');
  @override
  late final GeneratedColumn<DateTime> lastReviewedAt =
      GeneratedColumn<DateTime>('last_reviewed_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        chapterId,
        competencyId,
        scheduledDate,
        repetitionIntervalDays,
        easinessFactor,
        isCompleted,
        lastReviewedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'review_schedules';
  @override
  VerificationContext validateIntegrity(Insertable<ReviewSchedule> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(_chapterIdMeta,
          chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta));
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('competency_id')) {
      context.handle(
          _competencyIdMeta,
          competencyId.isAcceptableOrUnknown(
              data['competency_id']!, _competencyIdMeta));
    }
    if (data.containsKey('scheduled_date')) {
      context.handle(
          _scheduledDateMeta,
          scheduledDate.isAcceptableOrUnknown(
              data['scheduled_date']!, _scheduledDateMeta));
    } else if (isInserting) {
      context.missing(_scheduledDateMeta);
    }
    if (data.containsKey('repetition_interval_days')) {
      context.handle(
          _repetitionIntervalDaysMeta,
          repetitionIntervalDays.isAcceptableOrUnknown(
              data['repetition_interval_days']!, _repetitionIntervalDaysMeta));
    }
    if (data.containsKey('easiness_factor')) {
      context.handle(
          _easinessFactorMeta,
          easinessFactor.isAcceptableOrUnknown(
              data['easiness_factor']!, _easinessFactorMeta));
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('last_reviewed_at')) {
      context.handle(
          _lastReviewedAtMeta,
          lastReviewedAt.isAcceptableOrUnknown(
              data['last_reviewed_at']!, _lastReviewedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReviewSchedule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewSchedule(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      chapterId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chapter_id'])!,
      competencyId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}competency_id']),
      scheduledDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}scheduled_date'])!,
      repetitionIntervalDays: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}repetition_interval_days'])!,
      easinessFactor: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}easiness_factor'])!,
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      lastReviewedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_reviewed_at']),
    );
  }

  @override
  $ReviewSchedulesTable createAlias(String alias) {
    return $ReviewSchedulesTable(attachedDatabase, alias);
  }
}

class ReviewSchedule extends DataClass implements Insertable<ReviewSchedule> {
  final String id;
  final String chapterId;
  final String? competencyId;
  final DateTime scheduledDate;
  final int repetitionIntervalDays;
  final double easinessFactor;
  final bool isCompleted;
  final DateTime? lastReviewedAt;
  const ReviewSchedule(
      {required this.id,
      required this.chapterId,
      this.competencyId,
      required this.scheduledDate,
      required this.repetitionIntervalDays,
      required this.easinessFactor,
      required this.isCompleted,
      this.lastReviewedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['chapter_id'] = Variable<String>(chapterId);
    if (!nullToAbsent || competencyId != null) {
      map['competency_id'] = Variable<String>(competencyId);
    }
    map['scheduled_date'] = Variable<DateTime>(scheduledDate);
    map['repetition_interval_days'] = Variable<int>(repetitionIntervalDays);
    map['easiness_factor'] = Variable<double>(easinessFactor);
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || lastReviewedAt != null) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt);
    }
    return map;
  }

  ReviewSchedulesCompanion toCompanion(bool nullToAbsent) {
    return ReviewSchedulesCompanion(
      id: Value(id),
      chapterId: Value(chapterId),
      competencyId: competencyId == null && nullToAbsent
          ? const Value.absent()
          : Value(competencyId),
      scheduledDate: Value(scheduledDate),
      repetitionIntervalDays: Value(repetitionIntervalDays),
      easinessFactor: Value(easinessFactor),
      isCompleted: Value(isCompleted),
      lastReviewedAt: lastReviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReviewedAt),
    );
  }

  factory ReviewSchedule.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewSchedule(
      id: serializer.fromJson<String>(json['id']),
      chapterId: serializer.fromJson<String>(json['chapterId']),
      competencyId: serializer.fromJson<String?>(json['competencyId']),
      scheduledDate: serializer.fromJson<DateTime>(json['scheduledDate']),
      repetitionIntervalDays:
          serializer.fromJson<int>(json['repetitionIntervalDays']),
      easinessFactor: serializer.fromJson<double>(json['easinessFactor']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      lastReviewedAt: serializer.fromJson<DateTime?>(json['lastReviewedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'chapterId': serializer.toJson<String>(chapterId),
      'competencyId': serializer.toJson<String?>(competencyId),
      'scheduledDate': serializer.toJson<DateTime>(scheduledDate),
      'repetitionIntervalDays': serializer.toJson<int>(repetitionIntervalDays),
      'easinessFactor': serializer.toJson<double>(easinessFactor),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'lastReviewedAt': serializer.toJson<DateTime?>(lastReviewedAt),
    };
  }

  ReviewSchedule copyWith(
          {String? id,
          String? chapterId,
          Value<String?> competencyId = const Value.absent(),
          DateTime? scheduledDate,
          int? repetitionIntervalDays,
          double? easinessFactor,
          bool? isCompleted,
          Value<DateTime?> lastReviewedAt = const Value.absent()}) =>
      ReviewSchedule(
        id: id ?? this.id,
        chapterId: chapterId ?? this.chapterId,
        competencyId:
            competencyId.present ? competencyId.value : this.competencyId,
        scheduledDate: scheduledDate ?? this.scheduledDate,
        repetitionIntervalDays:
            repetitionIntervalDays ?? this.repetitionIntervalDays,
        easinessFactor: easinessFactor ?? this.easinessFactor,
        isCompleted: isCompleted ?? this.isCompleted,
        lastReviewedAt:
            lastReviewedAt.present ? lastReviewedAt.value : this.lastReviewedAt,
      );
  ReviewSchedule copyWithCompanion(ReviewSchedulesCompanion data) {
    return ReviewSchedule(
      id: data.id.present ? data.id.value : this.id,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      competencyId: data.competencyId.present
          ? data.competencyId.value
          : this.competencyId,
      scheduledDate: data.scheduledDate.present
          ? data.scheduledDate.value
          : this.scheduledDate,
      repetitionIntervalDays: data.repetitionIntervalDays.present
          ? data.repetitionIntervalDays.value
          : this.repetitionIntervalDays,
      easinessFactor: data.easinessFactor.present
          ? data.easinessFactor.value
          : this.easinessFactor,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      lastReviewedAt: data.lastReviewedAt.present
          ? data.lastReviewedAt.value
          : this.lastReviewedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewSchedule(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('competencyId: $competencyId, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('repetitionIntervalDays: $repetitionIntervalDays, ')
          ..write('easinessFactor: $easinessFactor, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('lastReviewedAt: $lastReviewedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, chapterId, competencyId, scheduledDate,
      repetitionIntervalDays, easinessFactor, isCompleted, lastReviewedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewSchedule &&
          other.id == this.id &&
          other.chapterId == this.chapterId &&
          other.competencyId == this.competencyId &&
          other.scheduledDate == this.scheduledDate &&
          other.repetitionIntervalDays == this.repetitionIntervalDays &&
          other.easinessFactor == this.easinessFactor &&
          other.isCompleted == this.isCompleted &&
          other.lastReviewedAt == this.lastReviewedAt);
}

class ReviewSchedulesCompanion extends UpdateCompanion<ReviewSchedule> {
  final Value<String> id;
  final Value<String> chapterId;
  final Value<String?> competencyId;
  final Value<DateTime> scheduledDate;
  final Value<int> repetitionIntervalDays;
  final Value<double> easinessFactor;
  final Value<bool> isCompleted;
  final Value<DateTime?> lastReviewedAt;
  final Value<int> rowid;
  const ReviewSchedulesCompanion({
    this.id = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.competencyId = const Value.absent(),
    this.scheduledDate = const Value.absent(),
    this.repetitionIntervalDays = const Value.absent(),
    this.easinessFactor = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReviewSchedulesCompanion.insert({
    required String id,
    required String chapterId,
    this.competencyId = const Value.absent(),
    required DateTime scheduledDate,
    this.repetitionIntervalDays = const Value.absent(),
    this.easinessFactor = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        chapterId = Value(chapterId),
        scheduledDate = Value(scheduledDate);
  static Insertable<ReviewSchedule> custom({
    Expression<String>? id,
    Expression<String>? chapterId,
    Expression<String>? competencyId,
    Expression<DateTime>? scheduledDate,
    Expression<int>? repetitionIntervalDays,
    Expression<double>? easinessFactor,
    Expression<bool>? isCompleted,
    Expression<DateTime>? lastReviewedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chapterId != null) 'chapter_id': chapterId,
      if (competencyId != null) 'competency_id': competencyId,
      if (scheduledDate != null) 'scheduled_date': scheduledDate,
      if (repetitionIntervalDays != null)
        'repetition_interval_days': repetitionIntervalDays,
      if (easinessFactor != null) 'easiness_factor': easinessFactor,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (lastReviewedAt != null) 'last_reviewed_at': lastReviewedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReviewSchedulesCompanion copyWith(
      {Value<String>? id,
      Value<String>? chapterId,
      Value<String?>? competencyId,
      Value<DateTime>? scheduledDate,
      Value<int>? repetitionIntervalDays,
      Value<double>? easinessFactor,
      Value<bool>? isCompleted,
      Value<DateTime?>? lastReviewedAt,
      Value<int>? rowid}) {
    return ReviewSchedulesCompanion(
      id: id ?? this.id,
      chapterId: chapterId ?? this.chapterId,
      competencyId: competencyId ?? this.competencyId,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      repetitionIntervalDays:
          repetitionIntervalDays ?? this.repetitionIntervalDays,
      easinessFactor: easinessFactor ?? this.easinessFactor,
      isCompleted: isCompleted ?? this.isCompleted,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (competencyId.present) {
      map['competency_id'] = Variable<String>(competencyId.value);
    }
    if (scheduledDate.present) {
      map['scheduled_date'] = Variable<DateTime>(scheduledDate.value);
    }
    if (repetitionIntervalDays.present) {
      map['repetition_interval_days'] =
          Variable<int>(repetitionIntervalDays.value);
    }
    if (easinessFactor.present) {
      map['easiness_factor'] = Variable<double>(easinessFactor.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (lastReviewedAt.present) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewSchedulesCompanion(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('competencyId: $competencyId, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('repetitionIntervalDays: $repetitionIntervalDays, ')
          ..write('easinessFactor: $easinessFactor, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContentRevisionsTable extends ContentRevisions
    with TableInfo<$ContentRevisionsTable, ContentRevision> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContentRevisionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chapterIdMeta =
      const VerificationMeta('chapterId');
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
      'chapter_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES chapters (id)'));
  static const VerificationMeta _revisionCodeMeta =
      const VerificationMeta('revisionCode');
  @override
  late final GeneratedColumn<String> revisionCode = GeneratedColumn<String>(
      'revision_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
      'author', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _checksumSha256Meta =
      const VerificationMeta('checksumSha256');
  @override
  late final GeneratedColumn<String> checksumSha256 = GeneratedColumn<String>(
      'checksum_sha256', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _manifestJsonMeta =
      const VerificationMeta('manifestJson');
  @override
  late final GeneratedColumn<String> manifestJson = GeneratedColumn<String>(
      'manifest_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isApprovedMeta =
      const VerificationMeta('isApproved');
  @override
  late final GeneratedColumn<bool> isApproved = GeneratedColumn<bool>(
      'is_approved', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_approved" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _approvedAtMeta =
      const VerificationMeta('approvedAt');
  @override
  late final GeneratedColumn<DateTime> approvedAt = GeneratedColumn<DateTime>(
      'approved_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        chapterId,
        revisionCode,
        author,
        checksumSha256,
        manifestJson,
        isApproved,
        approvedAt,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'content_revisions';
  @override
  VerificationContext validateIntegrity(Insertable<ContentRevision> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(_chapterIdMeta,
          chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta));
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('revision_code')) {
      context.handle(
          _revisionCodeMeta,
          revisionCode.isAcceptableOrUnknown(
              data['revision_code']!, _revisionCodeMeta));
    } else if (isInserting) {
      context.missing(_revisionCodeMeta);
    }
    if (data.containsKey('author')) {
      context.handle(_authorMeta,
          author.isAcceptableOrUnknown(data['author']!, _authorMeta));
    } else if (isInserting) {
      context.missing(_authorMeta);
    }
    if (data.containsKey('checksum_sha256')) {
      context.handle(
          _checksumSha256Meta,
          checksumSha256.isAcceptableOrUnknown(
              data['checksum_sha256']!, _checksumSha256Meta));
    } else if (isInserting) {
      context.missing(_checksumSha256Meta);
    }
    if (data.containsKey('manifest_json')) {
      context.handle(
          _manifestJsonMeta,
          manifestJson.isAcceptableOrUnknown(
              data['manifest_json']!, _manifestJsonMeta));
    } else if (isInserting) {
      context.missing(_manifestJsonMeta);
    }
    if (data.containsKey('is_approved')) {
      context.handle(
          _isApprovedMeta,
          isApproved.isAcceptableOrUnknown(
              data['is_approved']!, _isApprovedMeta));
    }
    if (data.containsKey('approved_at')) {
      context.handle(
          _approvedAtMeta,
          approvedAt.isAcceptableOrUnknown(
              data['approved_at']!, _approvedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContentRevision map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContentRevision(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      chapterId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chapter_id'])!,
      revisionCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}revision_code'])!,
      author: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}author'])!,
      checksumSha256: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}checksum_sha256'])!,
      manifestJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}manifest_json'])!,
      isApproved: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_approved'])!,
      approvedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}approved_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ContentRevisionsTable createAlias(String alias) {
    return $ContentRevisionsTable(attachedDatabase, alias);
  }
}

class ContentRevision extends DataClass implements Insertable<ContentRevision> {
  final String id;
  final String chapterId;
  final String revisionCode;
  final String author;
  final String checksumSha256;
  final String manifestJson;
  final bool isApproved;
  final DateTime? approvedAt;
  final DateTime createdAt;
  const ContentRevision(
      {required this.id,
      required this.chapterId,
      required this.revisionCode,
      required this.author,
      required this.checksumSha256,
      required this.manifestJson,
      required this.isApproved,
      this.approvedAt,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['chapter_id'] = Variable<String>(chapterId);
    map['revision_code'] = Variable<String>(revisionCode);
    map['author'] = Variable<String>(author);
    map['checksum_sha256'] = Variable<String>(checksumSha256);
    map['manifest_json'] = Variable<String>(manifestJson);
    map['is_approved'] = Variable<bool>(isApproved);
    if (!nullToAbsent || approvedAt != null) {
      map['approved_at'] = Variable<DateTime>(approvedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ContentRevisionsCompanion toCompanion(bool nullToAbsent) {
    return ContentRevisionsCompanion(
      id: Value(id),
      chapterId: Value(chapterId),
      revisionCode: Value(revisionCode),
      author: Value(author),
      checksumSha256: Value(checksumSha256),
      manifestJson: Value(manifestJson),
      isApproved: Value(isApproved),
      approvedAt: approvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(approvedAt),
      createdAt: Value(createdAt),
    );
  }

  factory ContentRevision.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContentRevision(
      id: serializer.fromJson<String>(json['id']),
      chapterId: serializer.fromJson<String>(json['chapterId']),
      revisionCode: serializer.fromJson<String>(json['revisionCode']),
      author: serializer.fromJson<String>(json['author']),
      checksumSha256: serializer.fromJson<String>(json['checksumSha256']),
      manifestJson: serializer.fromJson<String>(json['manifestJson']),
      isApproved: serializer.fromJson<bool>(json['isApproved']),
      approvedAt: serializer.fromJson<DateTime?>(json['approvedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'chapterId': serializer.toJson<String>(chapterId),
      'revisionCode': serializer.toJson<String>(revisionCode),
      'author': serializer.toJson<String>(author),
      'checksumSha256': serializer.toJson<String>(checksumSha256),
      'manifestJson': serializer.toJson<String>(manifestJson),
      'isApproved': serializer.toJson<bool>(isApproved),
      'approvedAt': serializer.toJson<DateTime?>(approvedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ContentRevision copyWith(
          {String? id,
          String? chapterId,
          String? revisionCode,
          String? author,
          String? checksumSha256,
          String? manifestJson,
          bool? isApproved,
          Value<DateTime?> approvedAt = const Value.absent(),
          DateTime? createdAt}) =>
      ContentRevision(
        id: id ?? this.id,
        chapterId: chapterId ?? this.chapterId,
        revisionCode: revisionCode ?? this.revisionCode,
        author: author ?? this.author,
        checksumSha256: checksumSha256 ?? this.checksumSha256,
        manifestJson: manifestJson ?? this.manifestJson,
        isApproved: isApproved ?? this.isApproved,
        approvedAt: approvedAt.present ? approvedAt.value : this.approvedAt,
        createdAt: createdAt ?? this.createdAt,
      );
  ContentRevision copyWithCompanion(ContentRevisionsCompanion data) {
    return ContentRevision(
      id: data.id.present ? data.id.value : this.id,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      revisionCode: data.revisionCode.present
          ? data.revisionCode.value
          : this.revisionCode,
      author: data.author.present ? data.author.value : this.author,
      checksumSha256: data.checksumSha256.present
          ? data.checksumSha256.value
          : this.checksumSha256,
      manifestJson: data.manifestJson.present
          ? data.manifestJson.value
          : this.manifestJson,
      isApproved:
          data.isApproved.present ? data.isApproved.value : this.isApproved,
      approvedAt:
          data.approvedAt.present ? data.approvedAt.value : this.approvedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContentRevision(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('revisionCode: $revisionCode, ')
          ..write('author: $author, ')
          ..write('checksumSha256: $checksumSha256, ')
          ..write('manifestJson: $manifestJson, ')
          ..write('isApproved: $isApproved, ')
          ..write('approvedAt: $approvedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, chapterId, revisionCode, author,
      checksumSha256, manifestJson, isApproved, approvedAt, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContentRevision &&
          other.id == this.id &&
          other.chapterId == this.chapterId &&
          other.revisionCode == this.revisionCode &&
          other.author == this.author &&
          other.checksumSha256 == this.checksumSha256 &&
          other.manifestJson == this.manifestJson &&
          other.isApproved == this.isApproved &&
          other.approvedAt == this.approvedAt &&
          other.createdAt == this.createdAt);
}

class ContentRevisionsCompanion extends UpdateCompanion<ContentRevision> {
  final Value<String> id;
  final Value<String> chapterId;
  final Value<String> revisionCode;
  final Value<String> author;
  final Value<String> checksumSha256;
  final Value<String> manifestJson;
  final Value<bool> isApproved;
  final Value<DateTime?> approvedAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ContentRevisionsCompanion({
    this.id = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.revisionCode = const Value.absent(),
    this.author = const Value.absent(),
    this.checksumSha256 = const Value.absent(),
    this.manifestJson = const Value.absent(),
    this.isApproved = const Value.absent(),
    this.approvedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContentRevisionsCompanion.insert({
    required String id,
    required String chapterId,
    required String revisionCode,
    required String author,
    required String checksumSha256,
    required String manifestJson,
    this.isApproved = const Value.absent(),
    this.approvedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        chapterId = Value(chapterId),
        revisionCode = Value(revisionCode),
        author = Value(author),
        checksumSha256 = Value(checksumSha256),
        manifestJson = Value(manifestJson);
  static Insertable<ContentRevision> custom({
    Expression<String>? id,
    Expression<String>? chapterId,
    Expression<String>? revisionCode,
    Expression<String>? author,
    Expression<String>? checksumSha256,
    Expression<String>? manifestJson,
    Expression<bool>? isApproved,
    Expression<DateTime>? approvedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chapterId != null) 'chapter_id': chapterId,
      if (revisionCode != null) 'revision_code': revisionCode,
      if (author != null) 'author': author,
      if (checksumSha256 != null) 'checksum_sha256': checksumSha256,
      if (manifestJson != null) 'manifest_json': manifestJson,
      if (isApproved != null) 'is_approved': isApproved,
      if (approvedAt != null) 'approved_at': approvedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContentRevisionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? chapterId,
      Value<String>? revisionCode,
      Value<String>? author,
      Value<String>? checksumSha256,
      Value<String>? manifestJson,
      Value<bool>? isApproved,
      Value<DateTime?>? approvedAt,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return ContentRevisionsCompanion(
      id: id ?? this.id,
      chapterId: chapterId ?? this.chapterId,
      revisionCode: revisionCode ?? this.revisionCode,
      author: author ?? this.author,
      checksumSha256: checksumSha256 ?? this.checksumSha256,
      manifestJson: manifestJson ?? this.manifestJson,
      isApproved: isApproved ?? this.isApproved,
      approvedAt: approvedAt ?? this.approvedAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (revisionCode.present) {
      map['revision_code'] = Variable<String>(revisionCode.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (checksumSha256.present) {
      map['checksum_sha256'] = Variable<String>(checksumSha256.value);
    }
    if (manifestJson.present) {
      map['manifest_json'] = Variable<String>(manifestJson.value);
    }
    if (isApproved.present) {
      map['is_approved'] = Variable<bool>(isApproved.value);
    }
    if (approvedAt.present) {
      map['approved_at'] = Variable<DateTime>(approvedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContentRevisionsCompanion(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('revisionCode: $revisionCode, ')
          ..write('author: $author, ')
          ..write('checksumSha256: $checksumSha256, ')
          ..write('manifestJson: $manifestJson, ')
          ..write('isApproved: $isApproved, ')
          ..write('approvedAt: $approvedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SourceDocumentsTable extends SourceDocuments
    with TableInfo<$SourceDocumentsTable, SourceDocument> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SourceDocumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chapterIdMeta =
      const VerificationMeta('chapterId');
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
      'chapter_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES chapters (id)'));
  static const VerificationMeta _fileNameMeta =
      const VerificationMeta('fileName');
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
      'file_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fileTypeMeta =
      const VerificationMeta('fileType');
  @override
  late final GeneratedColumn<String> fileType = GeneratedColumn<String>(
      'file_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
      'sha256', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fileSizeBytesMeta =
      const VerificationMeta('fileSizeBytes');
  @override
  late final GeneratedColumn<int> fileSizeBytes = GeneratedColumn<int>(
      'file_size_bytes', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _localPathMeta =
      const VerificationMeta('localPath');
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
      'local_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _importedAtMeta =
      const VerificationMeta('importedAt');
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
      'imported_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        chapterId,
        fileName,
        fileType,
        sha256,
        fileSizeBytes,
        localPath,
        importedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'source_documents';
  @override
  VerificationContext validateIntegrity(Insertable<SourceDocument> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(_chapterIdMeta,
          chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta));
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(_fileNameMeta,
          fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta));
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('file_type')) {
      context.handle(_fileTypeMeta,
          fileType.isAcceptableOrUnknown(data['file_type']!, _fileTypeMeta));
    } else if (isInserting) {
      context.missing(_fileTypeMeta);
    }
    if (data.containsKey('sha256')) {
      context.handle(_sha256Meta,
          sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta));
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    if (data.containsKey('file_size_bytes')) {
      context.handle(
          _fileSizeBytesMeta,
          fileSizeBytes.isAcceptableOrUnknown(
              data['file_size_bytes']!, _fileSizeBytesMeta));
    } else if (isInserting) {
      context.missing(_fileSizeBytesMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(_localPathMeta,
          localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta));
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('imported_at')) {
      context.handle(
          _importedAtMeta,
          importedAt.isAcceptableOrUnknown(
              data['imported_at']!, _importedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SourceDocument map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SourceDocument(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      chapterId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chapter_id'])!,
      fileName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_name'])!,
      fileType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_type'])!,
      sha256: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sha256'])!,
      fileSizeBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}file_size_bytes'])!,
      localPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_path'])!,
      importedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}imported_at'])!,
    );
  }

  @override
  $SourceDocumentsTable createAlias(String alias) {
    return $SourceDocumentsTable(attachedDatabase, alias);
  }
}

class SourceDocument extends DataClass implements Insertable<SourceDocument> {
  final String id;
  final String chapterId;
  final String fileName;
  final String fileType;
  final String sha256;
  final int fileSizeBytes;
  final String localPath;
  final DateTime importedAt;
  const SourceDocument(
      {required this.id,
      required this.chapterId,
      required this.fileName,
      required this.fileType,
      required this.sha256,
      required this.fileSizeBytes,
      required this.localPath,
      required this.importedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['chapter_id'] = Variable<String>(chapterId);
    map['file_name'] = Variable<String>(fileName);
    map['file_type'] = Variable<String>(fileType);
    map['sha256'] = Variable<String>(sha256);
    map['file_size_bytes'] = Variable<int>(fileSizeBytes);
    map['local_path'] = Variable<String>(localPath);
    map['imported_at'] = Variable<DateTime>(importedAt);
    return map;
  }

  SourceDocumentsCompanion toCompanion(bool nullToAbsent) {
    return SourceDocumentsCompanion(
      id: Value(id),
      chapterId: Value(chapterId),
      fileName: Value(fileName),
      fileType: Value(fileType),
      sha256: Value(sha256),
      fileSizeBytes: Value(fileSizeBytes),
      localPath: Value(localPath),
      importedAt: Value(importedAt),
    );
  }

  factory SourceDocument.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SourceDocument(
      id: serializer.fromJson<String>(json['id']),
      chapterId: serializer.fromJson<String>(json['chapterId']),
      fileName: serializer.fromJson<String>(json['fileName']),
      fileType: serializer.fromJson<String>(json['fileType']),
      sha256: serializer.fromJson<String>(json['sha256']),
      fileSizeBytes: serializer.fromJson<int>(json['fileSizeBytes']),
      localPath: serializer.fromJson<String>(json['localPath']),
      importedAt: serializer.fromJson<DateTime>(json['importedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'chapterId': serializer.toJson<String>(chapterId),
      'fileName': serializer.toJson<String>(fileName),
      'fileType': serializer.toJson<String>(fileType),
      'sha256': serializer.toJson<String>(sha256),
      'fileSizeBytes': serializer.toJson<int>(fileSizeBytes),
      'localPath': serializer.toJson<String>(localPath),
      'importedAt': serializer.toJson<DateTime>(importedAt),
    };
  }

  SourceDocument copyWith(
          {String? id,
          String? chapterId,
          String? fileName,
          String? fileType,
          String? sha256,
          int? fileSizeBytes,
          String? localPath,
          DateTime? importedAt}) =>
      SourceDocument(
        id: id ?? this.id,
        chapterId: chapterId ?? this.chapterId,
        fileName: fileName ?? this.fileName,
        fileType: fileType ?? this.fileType,
        sha256: sha256 ?? this.sha256,
        fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
        localPath: localPath ?? this.localPath,
        importedAt: importedAt ?? this.importedAt,
      );
  SourceDocument copyWithCompanion(SourceDocumentsCompanion data) {
    return SourceDocument(
      id: data.id.present ? data.id.value : this.id,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      fileType: data.fileType.present ? data.fileType.value : this.fileType,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      fileSizeBytes: data.fileSizeBytes.present
          ? data.fileSizeBytes.value
          : this.fileSizeBytes,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      importedAt:
          data.importedAt.present ? data.importedAt.value : this.importedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SourceDocument(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('fileName: $fileName, ')
          ..write('fileType: $fileType, ')
          ..write('sha256: $sha256, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('localPath: $localPath, ')
          ..write('importedAt: $importedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, chapterId, fileName, fileType, sha256,
      fileSizeBytes, localPath, importedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SourceDocument &&
          other.id == this.id &&
          other.chapterId == this.chapterId &&
          other.fileName == this.fileName &&
          other.fileType == this.fileType &&
          other.sha256 == this.sha256 &&
          other.fileSizeBytes == this.fileSizeBytes &&
          other.localPath == this.localPath &&
          other.importedAt == this.importedAt);
}

class SourceDocumentsCompanion extends UpdateCompanion<SourceDocument> {
  final Value<String> id;
  final Value<String> chapterId;
  final Value<String> fileName;
  final Value<String> fileType;
  final Value<String> sha256;
  final Value<int> fileSizeBytes;
  final Value<String> localPath;
  final Value<DateTime> importedAt;
  final Value<int> rowid;
  const SourceDocumentsCompanion({
    this.id = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.fileName = const Value.absent(),
    this.fileType = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.fileSizeBytes = const Value.absent(),
    this.localPath = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SourceDocumentsCompanion.insert({
    required String id,
    required String chapterId,
    required String fileName,
    required String fileType,
    required String sha256,
    required int fileSizeBytes,
    required String localPath,
    this.importedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        chapterId = Value(chapterId),
        fileName = Value(fileName),
        fileType = Value(fileType),
        sha256 = Value(sha256),
        fileSizeBytes = Value(fileSizeBytes),
        localPath = Value(localPath);
  static Insertable<SourceDocument> custom({
    Expression<String>? id,
    Expression<String>? chapterId,
    Expression<String>? fileName,
    Expression<String>? fileType,
    Expression<String>? sha256,
    Expression<int>? fileSizeBytes,
    Expression<String>? localPath,
    Expression<DateTime>? importedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chapterId != null) 'chapter_id': chapterId,
      if (fileName != null) 'file_name': fileName,
      if (fileType != null) 'file_type': fileType,
      if (sha256 != null) 'sha256': sha256,
      if (fileSizeBytes != null) 'file_size_bytes': fileSizeBytes,
      if (localPath != null) 'local_path': localPath,
      if (importedAt != null) 'imported_at': importedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SourceDocumentsCompanion copyWith(
      {Value<String>? id,
      Value<String>? chapterId,
      Value<String>? fileName,
      Value<String>? fileType,
      Value<String>? sha256,
      Value<int>? fileSizeBytes,
      Value<String>? localPath,
      Value<DateTime>? importedAt,
      Value<int>? rowid}) {
    return SourceDocumentsCompanion(
      id: id ?? this.id,
      chapterId: chapterId ?? this.chapterId,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      sha256: sha256 ?? this.sha256,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      localPath: localPath ?? this.localPath,
      importedAt: importedAt ?? this.importedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (fileType.present) {
      map['file_type'] = Variable<String>(fileType.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (fileSizeBytes.present) {
      map['file_size_bytes'] = Variable<int>(fileSizeBytes.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SourceDocumentsCompanion(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('fileName: $fileName, ')
          ..write('fileType: $fileType, ')
          ..write('sha256: $sha256, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('localPath: $localPath, ')
          ..write('importedAt: $importedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncJournalsTable extends SyncJournals
    with TableInfo<$SyncJournalsTable, SyncJournal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncJournalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceProviderMeta =
      const VerificationMeta('sourceProvider');
  @override
  late final GeneratedColumn<String> sourceProvider = GeneratedColumn<String>(
      'source_provider', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _operationMeta =
      const VerificationMeta('operation');
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
      'operation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sha256BeforeMeta =
      const VerificationMeta('sha256Before');
  @override
  late final GeneratedColumn<String> sha256Before = GeneratedColumn<String>(
      'sha256_before', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sha256AfterMeta =
      const VerificationMeta('sha256After');
  @override
  late final GeneratedColumn<String> sha256After = GeneratedColumn<String>(
      'sha256_after', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
      'synced_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('SUCCESS'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sourceProvider,
        entityType,
        entityId,
        operation,
        sha256Before,
        sha256After,
        syncedAt,
        status
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_journals';
  @override
  VerificationContext validateIntegrity(Insertable<SyncJournal> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source_provider')) {
      context.handle(
          _sourceProviderMeta,
          sourceProvider.isAcceptableOrUnknown(
              data['source_provider']!, _sourceProviderMeta));
    } else if (isInserting) {
      context.missing(_sourceProviderMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(_operationMeta,
          operation.isAcceptableOrUnknown(data['operation']!, _operationMeta));
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('sha256_before')) {
      context.handle(
          _sha256BeforeMeta,
          sha256Before.isAcceptableOrUnknown(
              data['sha256_before']!, _sha256BeforeMeta));
    }
    if (data.containsKey('sha256_after')) {
      context.handle(
          _sha256AfterMeta,
          sha256After.isAcceptableOrUnknown(
              data['sha256_after']!, _sha256AfterMeta));
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncJournal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncJournal(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sourceProvider: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}source_provider'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      operation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation'])!,
      sha256Before: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sha256_before']),
      sha256After: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sha256_after']),
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}synced_at'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
    );
  }

  @override
  $SyncJournalsTable createAlias(String alias) {
    return $SyncJournalsTable(attachedDatabase, alias);
  }
}

class SyncJournal extends DataClass implements Insertable<SyncJournal> {
  final String id;
  final String sourceProvider;
  final String entityType;
  final String entityId;
  final String operation;
  final String? sha256Before;
  final String? sha256After;
  final DateTime syncedAt;
  final String status;
  const SyncJournal(
      {required this.id,
      required this.sourceProvider,
      required this.entityType,
      required this.entityId,
      required this.operation,
      this.sha256Before,
      this.sha256After,
      required this.syncedAt,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source_provider'] = Variable<String>(sourceProvider);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['operation'] = Variable<String>(operation);
    if (!nullToAbsent || sha256Before != null) {
      map['sha256_before'] = Variable<String>(sha256Before);
    }
    if (!nullToAbsent || sha256After != null) {
      map['sha256_after'] = Variable<String>(sha256After);
    }
    map['synced_at'] = Variable<DateTime>(syncedAt);
    map['status'] = Variable<String>(status);
    return map;
  }

  SyncJournalsCompanion toCompanion(bool nullToAbsent) {
    return SyncJournalsCompanion(
      id: Value(id),
      sourceProvider: Value(sourceProvider),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operation: Value(operation),
      sha256Before: sha256Before == null && nullToAbsent
          ? const Value.absent()
          : Value(sha256Before),
      sha256After: sha256After == null && nullToAbsent
          ? const Value.absent()
          : Value(sha256After),
      syncedAt: Value(syncedAt),
      status: Value(status),
    );
  }

  factory SyncJournal.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncJournal(
      id: serializer.fromJson<String>(json['id']),
      sourceProvider: serializer.fromJson<String>(json['sourceProvider']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<String>(json['operation']),
      sha256Before: serializer.fromJson<String?>(json['sha256Before']),
      sha256After: serializer.fromJson<String?>(json['sha256After']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sourceProvider': serializer.toJson<String>(sourceProvider),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<String>(operation),
      'sha256Before': serializer.toJson<String?>(sha256Before),
      'sha256After': serializer.toJson<String?>(sha256After),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
      'status': serializer.toJson<String>(status),
    };
  }

  SyncJournal copyWith(
          {String? id,
          String? sourceProvider,
          String? entityType,
          String? entityId,
          String? operation,
          Value<String?> sha256Before = const Value.absent(),
          Value<String?> sha256After = const Value.absent(),
          DateTime? syncedAt,
          String? status}) =>
      SyncJournal(
        id: id ?? this.id,
        sourceProvider: sourceProvider ?? this.sourceProvider,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        operation: operation ?? this.operation,
        sha256Before:
            sha256Before.present ? sha256Before.value : this.sha256Before,
        sha256After: sha256After.present ? sha256After.value : this.sha256After,
        syncedAt: syncedAt ?? this.syncedAt,
        status: status ?? this.status,
      );
  SyncJournal copyWithCompanion(SyncJournalsCompanion data) {
    return SyncJournal(
      id: data.id.present ? data.id.value : this.id,
      sourceProvider: data.sourceProvider.present
          ? data.sourceProvider.value
          : this.sourceProvider,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      sha256Before: data.sha256Before.present
          ? data.sha256Before.value
          : this.sha256Before,
      sha256After:
          data.sha256After.present ? data.sha256After.value : this.sha256After,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncJournal(')
          ..write('id: $id, ')
          ..write('sourceProvider: $sourceProvider, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('sha256Before: $sha256Before, ')
          ..write('sha256After: $sha256After, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sourceProvider, entityType, entityId,
      operation, sha256Before, sha256After, syncedAt, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncJournal &&
          other.id == this.id &&
          other.sourceProvider == this.sourceProvider &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.sha256Before == this.sha256Before &&
          other.sha256After == this.sha256After &&
          other.syncedAt == this.syncedAt &&
          other.status == this.status);
}

class SyncJournalsCompanion extends UpdateCompanion<SyncJournal> {
  final Value<String> id;
  final Value<String> sourceProvider;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> operation;
  final Value<String?> sha256Before;
  final Value<String?> sha256After;
  final Value<DateTime> syncedAt;
  final Value<String> status;
  final Value<int> rowid;
  const SyncJournalsCompanion({
    this.id = const Value.absent(),
    this.sourceProvider = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.sha256Before = const Value.absent(),
    this.sha256After = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncJournalsCompanion.insert({
    required String id,
    required String sourceProvider,
    required String entityType,
    required String entityId,
    required String operation,
    this.sha256Before = const Value.absent(),
    this.sha256After = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        sourceProvider = Value(sourceProvider),
        entityType = Value(entityType),
        entityId = Value(entityId),
        operation = Value(operation);
  static Insertable<SyncJournal> custom({
    Expression<String>? id,
    Expression<String>? sourceProvider,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<String>? sha256Before,
    Expression<String>? sha256After,
    Expression<DateTime>? syncedAt,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceProvider != null) 'source_provider': sourceProvider,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (sha256Before != null) 'sha256_before': sha256Before,
      if (sha256After != null) 'sha256_after': sha256After,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncJournalsCompanion copyWith(
      {Value<String>? id,
      Value<String>? sourceProvider,
      Value<String>? entityType,
      Value<String>? entityId,
      Value<String>? operation,
      Value<String?>? sha256Before,
      Value<String?>? sha256After,
      Value<DateTime>? syncedAt,
      Value<String>? status,
      Value<int>? rowid}) {
    return SyncJournalsCompanion(
      id: id ?? this.id,
      sourceProvider: sourceProvider ?? this.sourceProvider,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      sha256Before: sha256Before ?? this.sha256Before,
      sha256After: sha256After ?? this.sha256After,
      syncedAt: syncedAt ?? this.syncedAt,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sourceProvider.present) {
      map['source_provider'] = Variable<String>(sourceProvider.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (sha256Before.present) {
      map['sha256_before'] = Variable<String>(sha256Before.value);
    }
    if (sha256After.present) {
      map['sha256_after'] = Variable<String>(sha256After.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncJournalsCompanion(')
          ..write('id: $id, ')
          ..write('sourceProvider: $sourceProvider, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('sha256Before: $sha256Before, ')
          ..write('sha256After: $sha256After, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserSettingsEntriesTable extends UserSettingsEntries
    with TableInfo<$UserSettingsEntriesTable, UserSettingsEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSettingsEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_settings_entries';
  @override
  VerificationContext validateIntegrity(Insertable<UserSettingsEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  UserSettingsEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSettingsEntry(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $UserSettingsEntriesTable createAlias(String alias) {
    return $UserSettingsEntriesTable(attachedDatabase, alias);
  }
}

class UserSettingsEntry extends DataClass
    implements Insertable<UserSettingsEntry> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const UserSettingsEntry(
      {required this.key, required this.value, required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserSettingsEntriesCompanion toCompanion(bool nullToAbsent) {
    return UserSettingsEntriesCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserSettingsEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSettingsEntry(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserSettingsEntry copyWith(
          {String? key, String? value, DateTime? updatedAt}) =>
      UserSettingsEntry(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  UserSettingsEntry copyWithCompanion(UserSettingsEntriesCompanion data) {
    return UserSettingsEntry(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsEntry(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSettingsEntry &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class UserSettingsEntriesCompanion extends UpdateCompanion<UserSettingsEntry> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UserSettingsEntriesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserSettingsEntriesCompanion.insert({
    required String key,
    required String value,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<UserSettingsEntry> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserSettingsEntriesCompanion copyWith(
      {Value<String>? key,
      Value<String>? value,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return UserSettingsEntriesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsEntriesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AIInteractionsTable extends AIInteractions
    with TableInfo<$AIInteractionsTable, AIInteraction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AIInteractionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chapterIdMeta =
      const VerificationMeta('chapterId');
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
      'chapter_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES chapters (id)'));
  static const VerificationMeta _modelIdMeta =
      const VerificationMeta('modelId');
  @override
  late final GeneratedColumn<String> modelId = GeneratedColumn<String>(
      'model_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pedagogicalModeMeta =
      const VerificationMeta('pedagogicalMode');
  @override
  late final GeneratedColumn<String> pedagogicalMode = GeneratedColumn<String>(
      'pedagogical_mode', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userPromptMeta =
      const VerificationMeta('userPrompt');
  @override
  late final GeneratedColumn<String> userPrompt = GeneratedColumn<String>(
      'user_prompt', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contextChunksJsonMeta =
      const VerificationMeta('contextChunksJson');
  @override
  late final GeneratedColumn<String> contextChunksJson =
      GeneratedColumn<String>('context_chunks_json', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _aiResponseMeta =
      const VerificationMeta('aiResponse');
  @override
  late final GeneratedColumn<String> aiResponse = GeneratedColumn<String>(
      'ai_response', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _citationTagsMeta =
      const VerificationMeta('citationTags');
  @override
  late final GeneratedColumn<String> citationTags = GeneratedColumn<String>(
      'citation_tags', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        chapterId,
        modelId,
        pedagogicalMode,
        userPrompt,
        contextChunksJson,
        aiResponse,
        citationTags,
        timestamp
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'a_i_interactions';
  @override
  VerificationContext validateIntegrity(Insertable<AIInteraction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(_chapterIdMeta,
          chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta));
    }
    if (data.containsKey('model_id')) {
      context.handle(_modelIdMeta,
          modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta));
    } else if (isInserting) {
      context.missing(_modelIdMeta);
    }
    if (data.containsKey('pedagogical_mode')) {
      context.handle(
          _pedagogicalModeMeta,
          pedagogicalMode.isAcceptableOrUnknown(
              data['pedagogical_mode']!, _pedagogicalModeMeta));
    } else if (isInserting) {
      context.missing(_pedagogicalModeMeta);
    }
    if (data.containsKey('user_prompt')) {
      context.handle(
          _userPromptMeta,
          userPrompt.isAcceptableOrUnknown(
              data['user_prompt']!, _userPromptMeta));
    } else if (isInserting) {
      context.missing(_userPromptMeta);
    }
    if (data.containsKey('context_chunks_json')) {
      context.handle(
          _contextChunksJsonMeta,
          contextChunksJson.isAcceptableOrUnknown(
              data['context_chunks_json']!, _contextChunksJsonMeta));
    } else if (isInserting) {
      context.missing(_contextChunksJsonMeta);
    }
    if (data.containsKey('ai_response')) {
      context.handle(
          _aiResponseMeta,
          aiResponse.isAcceptableOrUnknown(
              data['ai_response']!, _aiResponseMeta));
    } else if (isInserting) {
      context.missing(_aiResponseMeta);
    }
    if (data.containsKey('citation_tags')) {
      context.handle(
          _citationTagsMeta,
          citationTags.isAcceptableOrUnknown(
              data['citation_tags']!, _citationTagsMeta));
    } else if (isInserting) {
      context.missing(_citationTagsMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AIInteraction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AIInteraction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      chapterId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chapter_id']),
      modelId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}model_id'])!,
      pedagogicalMode: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}pedagogical_mode'])!,
      userPrompt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_prompt'])!,
      contextChunksJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}context_chunks_json'])!,
      aiResponse: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ai_response'])!,
      citationTags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}citation_tags'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
    );
  }

  @override
  $AIInteractionsTable createAlias(String alias) {
    return $AIInteractionsTable(attachedDatabase, alias);
  }
}

class AIInteraction extends DataClass implements Insertable<AIInteraction> {
  final String id;
  final String? chapterId;
  final String modelId;
  final String pedagogicalMode;
  final String userPrompt;
  final String contextChunksJson;
  final String aiResponse;
  final String citationTags;
  final DateTime timestamp;
  const AIInteraction(
      {required this.id,
      this.chapterId,
      required this.modelId,
      required this.pedagogicalMode,
      required this.userPrompt,
      required this.contextChunksJson,
      required this.aiResponse,
      required this.citationTags,
      required this.timestamp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || chapterId != null) {
      map['chapter_id'] = Variable<String>(chapterId);
    }
    map['model_id'] = Variable<String>(modelId);
    map['pedagogical_mode'] = Variable<String>(pedagogicalMode);
    map['user_prompt'] = Variable<String>(userPrompt);
    map['context_chunks_json'] = Variable<String>(contextChunksJson);
    map['ai_response'] = Variable<String>(aiResponse);
    map['citation_tags'] = Variable<String>(citationTags);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  AIInteractionsCompanion toCompanion(bool nullToAbsent) {
    return AIInteractionsCompanion(
      id: Value(id),
      chapterId: chapterId == null && nullToAbsent
          ? const Value.absent()
          : Value(chapterId),
      modelId: Value(modelId),
      pedagogicalMode: Value(pedagogicalMode),
      userPrompt: Value(userPrompt),
      contextChunksJson: Value(contextChunksJson),
      aiResponse: Value(aiResponse),
      citationTags: Value(citationTags),
      timestamp: Value(timestamp),
    );
  }

  factory AIInteraction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AIInteraction(
      id: serializer.fromJson<String>(json['id']),
      chapterId: serializer.fromJson<String?>(json['chapterId']),
      modelId: serializer.fromJson<String>(json['modelId']),
      pedagogicalMode: serializer.fromJson<String>(json['pedagogicalMode']),
      userPrompt: serializer.fromJson<String>(json['userPrompt']),
      contextChunksJson: serializer.fromJson<String>(json['contextChunksJson']),
      aiResponse: serializer.fromJson<String>(json['aiResponse']),
      citationTags: serializer.fromJson<String>(json['citationTags']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'chapterId': serializer.toJson<String?>(chapterId),
      'modelId': serializer.toJson<String>(modelId),
      'pedagogicalMode': serializer.toJson<String>(pedagogicalMode),
      'userPrompt': serializer.toJson<String>(userPrompt),
      'contextChunksJson': serializer.toJson<String>(contextChunksJson),
      'aiResponse': serializer.toJson<String>(aiResponse),
      'citationTags': serializer.toJson<String>(citationTags),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  AIInteraction copyWith(
          {String? id,
          Value<String?> chapterId = const Value.absent(),
          String? modelId,
          String? pedagogicalMode,
          String? userPrompt,
          String? contextChunksJson,
          String? aiResponse,
          String? citationTags,
          DateTime? timestamp}) =>
      AIInteraction(
        id: id ?? this.id,
        chapterId: chapterId.present ? chapterId.value : this.chapterId,
        modelId: modelId ?? this.modelId,
        pedagogicalMode: pedagogicalMode ?? this.pedagogicalMode,
        userPrompt: userPrompt ?? this.userPrompt,
        contextChunksJson: contextChunksJson ?? this.contextChunksJson,
        aiResponse: aiResponse ?? this.aiResponse,
        citationTags: citationTags ?? this.citationTags,
        timestamp: timestamp ?? this.timestamp,
      );
  AIInteraction copyWithCompanion(AIInteractionsCompanion data) {
    return AIInteraction(
      id: data.id.present ? data.id.value : this.id,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      pedagogicalMode: data.pedagogicalMode.present
          ? data.pedagogicalMode.value
          : this.pedagogicalMode,
      userPrompt:
          data.userPrompt.present ? data.userPrompt.value : this.userPrompt,
      contextChunksJson: data.contextChunksJson.present
          ? data.contextChunksJson.value
          : this.contextChunksJson,
      aiResponse:
          data.aiResponse.present ? data.aiResponse.value : this.aiResponse,
      citationTags: data.citationTags.present
          ? data.citationTags.value
          : this.citationTags,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AIInteraction(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('modelId: $modelId, ')
          ..write('pedagogicalMode: $pedagogicalMode, ')
          ..write('userPrompt: $userPrompt, ')
          ..write('contextChunksJson: $contextChunksJson, ')
          ..write('aiResponse: $aiResponse, ')
          ..write('citationTags: $citationTags, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, chapterId, modelId, pedagogicalMode,
      userPrompt, contextChunksJson, aiResponse, citationTags, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AIInteraction &&
          other.id == this.id &&
          other.chapterId == this.chapterId &&
          other.modelId == this.modelId &&
          other.pedagogicalMode == this.pedagogicalMode &&
          other.userPrompt == this.userPrompt &&
          other.contextChunksJson == this.contextChunksJson &&
          other.aiResponse == this.aiResponse &&
          other.citationTags == this.citationTags &&
          other.timestamp == this.timestamp);
}

class AIInteractionsCompanion extends UpdateCompanion<AIInteraction> {
  final Value<String> id;
  final Value<String?> chapterId;
  final Value<String> modelId;
  final Value<String> pedagogicalMode;
  final Value<String> userPrompt;
  final Value<String> contextChunksJson;
  final Value<String> aiResponse;
  final Value<String> citationTags;
  final Value<DateTime> timestamp;
  final Value<int> rowid;
  const AIInteractionsCompanion({
    this.id = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.modelId = const Value.absent(),
    this.pedagogicalMode = const Value.absent(),
    this.userPrompt = const Value.absent(),
    this.contextChunksJson = const Value.absent(),
    this.aiResponse = const Value.absent(),
    this.citationTags = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AIInteractionsCompanion.insert({
    required String id,
    this.chapterId = const Value.absent(),
    required String modelId,
    required String pedagogicalMode,
    required String userPrompt,
    required String contextChunksJson,
    required String aiResponse,
    required String citationTags,
    this.timestamp = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        modelId = Value(modelId),
        pedagogicalMode = Value(pedagogicalMode),
        userPrompt = Value(userPrompt),
        contextChunksJson = Value(contextChunksJson),
        aiResponse = Value(aiResponse),
        citationTags = Value(citationTags);
  static Insertable<AIInteraction> custom({
    Expression<String>? id,
    Expression<String>? chapterId,
    Expression<String>? modelId,
    Expression<String>? pedagogicalMode,
    Expression<String>? userPrompt,
    Expression<String>? contextChunksJson,
    Expression<String>? aiResponse,
    Expression<String>? citationTags,
    Expression<DateTime>? timestamp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chapterId != null) 'chapter_id': chapterId,
      if (modelId != null) 'model_id': modelId,
      if (pedagogicalMode != null) 'pedagogical_mode': pedagogicalMode,
      if (userPrompt != null) 'user_prompt': userPrompt,
      if (contextChunksJson != null) 'context_chunks_json': contextChunksJson,
      if (aiResponse != null) 'ai_response': aiResponse,
      if (citationTags != null) 'citation_tags': citationTags,
      if (timestamp != null) 'timestamp': timestamp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AIInteractionsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? chapterId,
      Value<String>? modelId,
      Value<String>? pedagogicalMode,
      Value<String>? userPrompt,
      Value<String>? contextChunksJson,
      Value<String>? aiResponse,
      Value<String>? citationTags,
      Value<DateTime>? timestamp,
      Value<int>? rowid}) {
    return AIInteractionsCompanion(
      id: id ?? this.id,
      chapterId: chapterId ?? this.chapterId,
      modelId: modelId ?? this.modelId,
      pedagogicalMode: pedagogicalMode ?? this.pedagogicalMode,
      userPrompt: userPrompt ?? this.userPrompt,
      contextChunksJson: contextChunksJson ?? this.contextChunksJson,
      aiResponse: aiResponse ?? this.aiResponse,
      citationTags: citationTags ?? this.citationTags,
      timestamp: timestamp ?? this.timestamp,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<String>(modelId.value);
    }
    if (pedagogicalMode.present) {
      map['pedagogical_mode'] = Variable<String>(pedagogicalMode.value);
    }
    if (userPrompt.present) {
      map['user_prompt'] = Variable<String>(userPrompt.value);
    }
    if (contextChunksJson.present) {
      map['context_chunks_json'] = Variable<String>(contextChunksJson.value);
    }
    if (aiResponse.present) {
      map['ai_response'] = Variable<String>(aiResponse.value);
    }
    if (citationTags.present) {
      map['citation_tags'] = Variable<String>(citationTags.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AIInteractionsCompanion(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('modelId: $modelId, ')
          ..write('pedagogicalMode: $pedagogicalMode, ')
          ..write('userPrompt: $userPrompt, ')
          ..write('contextChunksJson: $contextChunksJson, ')
          ..write('aiResponse: $aiResponse, ')
          ..write('citationTags: $citationTags, ')
          ..write('timestamp: $timestamp, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AudioSettingsEntriesTable extends AudioSettingsEntries
    with TableInfo<$AudioSettingsEntriesTable, AudioSettingsEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AudioSettingsEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('default'));
  static const VerificationMeta _preferredEngineMeta =
      const VerificationMeta('preferredEngine');
  @override
  late final GeneratedColumn<String> preferredEngine = GeneratedColumn<String>(
      'preferred_engine', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('kokoro'));
  static const VerificationMeta _voiceNameMeta =
      const VerificationMeta('voiceName');
  @override
  late final GeneratedColumn<String> voiceName = GeneratedColumn<String>(
      'voice_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Charon'));
  static const VerificationMeta _playbackSpeedMeta =
      const VerificationMeta('playbackSpeed');
  @override
  late final GeneratedColumn<double> playbackSpeed = GeneratedColumn<double>(
      'playback_speed', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.0));
  static const VerificationMeta _chunkCharTargetMeta =
      const VerificationMeta('chunkCharTarget');
  @override
  late final GeneratedColumn<int> chunkCharTarget = GeneratedColumn<int>(
      'chunk_char_target', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(450));
  static const VerificationMeta _autoScrollFollowAlongMeta =
      const VerificationMeta('autoScrollFollowAlong');
  @override
  late final GeneratedColumn<bool> autoScrollFollowAlong =
      GeneratedColumn<bool>('auto_scroll_follow_along', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("auto_scroll_follow_along" IN (0, 1))'),
          defaultValue: const Constant(true));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        preferredEngine,
        voiceName,
        playbackSpeed,
        chunkCharTarget,
        autoScrollFollowAlong,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audio_settings_entries';
  @override
  VerificationContext validateIntegrity(Insertable<AudioSettingsEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('preferred_engine')) {
      context.handle(
          _preferredEngineMeta,
          preferredEngine.isAcceptableOrUnknown(
              data['preferred_engine']!, _preferredEngineMeta));
    }
    if (data.containsKey('voice_name')) {
      context.handle(_voiceNameMeta,
          voiceName.isAcceptableOrUnknown(data['voice_name']!, _voiceNameMeta));
    }
    if (data.containsKey('playback_speed')) {
      context.handle(
          _playbackSpeedMeta,
          playbackSpeed.isAcceptableOrUnknown(
              data['playback_speed']!, _playbackSpeedMeta));
    }
    if (data.containsKey('chunk_char_target')) {
      context.handle(
          _chunkCharTargetMeta,
          chunkCharTarget.isAcceptableOrUnknown(
              data['chunk_char_target']!, _chunkCharTargetMeta));
    }
    if (data.containsKey('auto_scroll_follow_along')) {
      context.handle(
          _autoScrollFollowAlongMeta,
          autoScrollFollowAlong.isAcceptableOrUnknown(
              data['auto_scroll_follow_along']!, _autoScrollFollowAlongMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AudioSettingsEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AudioSettingsEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      preferredEngine: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}preferred_engine'])!,
      voiceName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}voice_name'])!,
      playbackSpeed: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}playback_speed'])!,
      chunkCharTarget: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chunk_char_target'])!,
      autoScrollFollowAlong: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}auto_scroll_follow_along'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $AudioSettingsEntriesTable createAlias(String alias) {
    return $AudioSettingsEntriesTable(attachedDatabase, alias);
  }
}

class AudioSettingsEntry extends DataClass
    implements Insertable<AudioSettingsEntry> {
  final String id;
  final String preferredEngine;
  final String voiceName;
  final double playbackSpeed;
  final int chunkCharTarget;
  final bool autoScrollFollowAlong;
  final DateTime updatedAt;
  const AudioSettingsEntry(
      {required this.id,
      required this.preferredEngine,
      required this.voiceName,
      required this.playbackSpeed,
      required this.chunkCharTarget,
      required this.autoScrollFollowAlong,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['preferred_engine'] = Variable<String>(preferredEngine);
    map['voice_name'] = Variable<String>(voiceName);
    map['playback_speed'] = Variable<double>(playbackSpeed);
    map['chunk_char_target'] = Variable<int>(chunkCharTarget);
    map['auto_scroll_follow_along'] = Variable<bool>(autoScrollFollowAlong);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AudioSettingsEntriesCompanion toCompanion(bool nullToAbsent) {
    return AudioSettingsEntriesCompanion(
      id: Value(id),
      preferredEngine: Value(preferredEngine),
      voiceName: Value(voiceName),
      playbackSpeed: Value(playbackSpeed),
      chunkCharTarget: Value(chunkCharTarget),
      autoScrollFollowAlong: Value(autoScrollFollowAlong),
      updatedAt: Value(updatedAt),
    );
  }

  factory AudioSettingsEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AudioSettingsEntry(
      id: serializer.fromJson<String>(json['id']),
      preferredEngine: serializer.fromJson<String>(json['preferredEngine']),
      voiceName: serializer.fromJson<String>(json['voiceName']),
      playbackSpeed: serializer.fromJson<double>(json['playbackSpeed']),
      chunkCharTarget: serializer.fromJson<int>(json['chunkCharTarget']),
      autoScrollFollowAlong:
          serializer.fromJson<bool>(json['autoScrollFollowAlong']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'preferredEngine': serializer.toJson<String>(preferredEngine),
      'voiceName': serializer.toJson<String>(voiceName),
      'playbackSpeed': serializer.toJson<double>(playbackSpeed),
      'chunkCharTarget': serializer.toJson<int>(chunkCharTarget),
      'autoScrollFollowAlong': serializer.toJson<bool>(autoScrollFollowAlong),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AudioSettingsEntry copyWith(
          {String? id,
          String? preferredEngine,
          String? voiceName,
          double? playbackSpeed,
          int? chunkCharTarget,
          bool? autoScrollFollowAlong,
          DateTime? updatedAt}) =>
      AudioSettingsEntry(
        id: id ?? this.id,
        preferredEngine: preferredEngine ?? this.preferredEngine,
        voiceName: voiceName ?? this.voiceName,
        playbackSpeed: playbackSpeed ?? this.playbackSpeed,
        chunkCharTarget: chunkCharTarget ?? this.chunkCharTarget,
        autoScrollFollowAlong:
            autoScrollFollowAlong ?? this.autoScrollFollowAlong,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AudioSettingsEntry copyWithCompanion(AudioSettingsEntriesCompanion data) {
    return AudioSettingsEntry(
      id: data.id.present ? data.id.value : this.id,
      preferredEngine: data.preferredEngine.present
          ? data.preferredEngine.value
          : this.preferredEngine,
      voiceName: data.voiceName.present ? data.voiceName.value : this.voiceName,
      playbackSpeed: data.playbackSpeed.present
          ? data.playbackSpeed.value
          : this.playbackSpeed,
      chunkCharTarget: data.chunkCharTarget.present
          ? data.chunkCharTarget.value
          : this.chunkCharTarget,
      autoScrollFollowAlong: data.autoScrollFollowAlong.present
          ? data.autoScrollFollowAlong.value
          : this.autoScrollFollowAlong,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AudioSettingsEntry(')
          ..write('id: $id, ')
          ..write('preferredEngine: $preferredEngine, ')
          ..write('voiceName: $voiceName, ')
          ..write('playbackSpeed: $playbackSpeed, ')
          ..write('chunkCharTarget: $chunkCharTarget, ')
          ..write('autoScrollFollowAlong: $autoScrollFollowAlong, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, preferredEngine, voiceName, playbackSpeed,
      chunkCharTarget, autoScrollFollowAlong, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AudioSettingsEntry &&
          other.id == this.id &&
          other.preferredEngine == this.preferredEngine &&
          other.voiceName == this.voiceName &&
          other.playbackSpeed == this.playbackSpeed &&
          other.chunkCharTarget == this.chunkCharTarget &&
          other.autoScrollFollowAlong == this.autoScrollFollowAlong &&
          other.updatedAt == this.updatedAt);
}

class AudioSettingsEntriesCompanion
    extends UpdateCompanion<AudioSettingsEntry> {
  final Value<String> id;
  final Value<String> preferredEngine;
  final Value<String> voiceName;
  final Value<double> playbackSpeed;
  final Value<int> chunkCharTarget;
  final Value<bool> autoScrollFollowAlong;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AudioSettingsEntriesCompanion({
    this.id = const Value.absent(),
    this.preferredEngine = const Value.absent(),
    this.voiceName = const Value.absent(),
    this.playbackSpeed = const Value.absent(),
    this.chunkCharTarget = const Value.absent(),
    this.autoScrollFollowAlong = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AudioSettingsEntriesCompanion.insert({
    this.id = const Value.absent(),
    this.preferredEngine = const Value.absent(),
    this.voiceName = const Value.absent(),
    this.playbackSpeed = const Value.absent(),
    this.chunkCharTarget = const Value.absent(),
    this.autoScrollFollowAlong = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  static Insertable<AudioSettingsEntry> custom({
    Expression<String>? id,
    Expression<String>? preferredEngine,
    Expression<String>? voiceName,
    Expression<double>? playbackSpeed,
    Expression<int>? chunkCharTarget,
    Expression<bool>? autoScrollFollowAlong,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (preferredEngine != null) 'preferred_engine': preferredEngine,
      if (voiceName != null) 'voice_name': voiceName,
      if (playbackSpeed != null) 'playback_speed': playbackSpeed,
      if (chunkCharTarget != null) 'chunk_char_target': chunkCharTarget,
      if (autoScrollFollowAlong != null)
        'auto_scroll_follow_along': autoScrollFollowAlong,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AudioSettingsEntriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? preferredEngine,
      Value<String>? voiceName,
      Value<double>? playbackSpeed,
      Value<int>? chunkCharTarget,
      Value<bool>? autoScrollFollowAlong,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return AudioSettingsEntriesCompanion(
      id: id ?? this.id,
      preferredEngine: preferredEngine ?? this.preferredEngine,
      voiceName: voiceName ?? this.voiceName,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      chunkCharTarget: chunkCharTarget ?? this.chunkCharTarget,
      autoScrollFollowAlong:
          autoScrollFollowAlong ?? this.autoScrollFollowAlong,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (preferredEngine.present) {
      map['preferred_engine'] = Variable<String>(preferredEngine.value);
    }
    if (voiceName.present) {
      map['voice_name'] = Variable<String>(voiceName.value);
    }
    if (playbackSpeed.present) {
      map['playback_speed'] = Variable<double>(playbackSpeed.value);
    }
    if (chunkCharTarget.present) {
      map['chunk_char_target'] = Variable<int>(chunkCharTarget.value);
    }
    if (autoScrollFollowAlong.present) {
      map['auto_scroll_follow_along'] =
          Variable<bool>(autoScrollFollowAlong.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AudioSettingsEntriesCompanion(')
          ..write('id: $id, ')
          ..write('preferredEngine: $preferredEngine, ')
          ..write('voiceName: $voiceName, ')
          ..write('playbackSpeed: $playbackSpeed, ')
          ..write('chunkCharTarget: $chunkCharTarget, ')
          ..write('autoScrollFollowAlong: $autoScrollFollowAlong, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CurriculumsTable curriculums = $CurriculumsTable(this);
  late final $VolumesTable volumes = $VolumesTable(this);
  late final $ChaptersTable chapters = $ChaptersTable(this);
  late final $LessonsTable lessons = $LessonsTable(this);
  late final $LearningObjectivesTable learningObjectives =
      $LearningObjectivesTable(this);
  late final $CompetenciesTable competencies = $CompetenciesTable(this);
  late final $ExercisesTable exercises = $ExercisesTable(this);
  late final $AssessmentsTable assessments = $AssessmentsTable(this);
  late final $AssessmentAttemptsTable assessmentAttempts =
      $AssessmentAttemptsTable(this);
  late final $LaboratoriesTable laboratories = $LaboratoriesTable(this);
  late final $LaboratoryRunsTable laboratoryRuns = $LaboratoryRunsTable(this);
  late final $CaseStudiesTable caseStudies = $CaseStudiesTable(this);
  late final $CaseSubmissionsTable caseSubmissions =
      $CaseSubmissionsTable(this);
  late final $StudySessionsTable studySessions = $StudySessionsTable(this);
  late final $ReadingPositionsTable readingPositions =
      $ReadingPositionsTable(this);
  late final $BookmarksTable bookmarks = $BookmarksTable(this);
  late final $AnnotationsTable annotations = $AnnotationsTable(this);
  late final $ReviewSchedulesTable reviewSchedules =
      $ReviewSchedulesTable(this);
  late final $ContentRevisionsTable contentRevisions =
      $ContentRevisionsTable(this);
  late final $SourceDocumentsTable sourceDocuments =
      $SourceDocumentsTable(this);
  late final $SyncJournalsTable syncJournals = $SyncJournalsTable(this);
  late final $UserSettingsEntriesTable userSettingsEntries =
      $UserSettingsEntriesTable(this);
  late final $AIInteractionsTable aIInteractions = $AIInteractionsTable(this);
  late final $AudioSettingsEntriesTable audioSettingsEntries =
      $AudioSettingsEntriesTable(this);
  late final CurriculumDao curriculumDao = CurriculumDao(this as AppDatabase);
  late final UserProgressDao userProgressDao =
      UserProgressDao(this as AppDatabase);
  late final AssessmentDao assessmentDao = AssessmentDao(this as AppDatabase);
  late final LaboratoryDao laboratoryDao = LaboratoryDao(this as AppDatabase);
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  late final AudioDao audioDao = AudioDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        curriculums,
        volumes,
        chapters,
        lessons,
        learningObjectives,
        competencies,
        exercises,
        assessments,
        assessmentAttempts,
        laboratories,
        laboratoryRuns,
        caseStudies,
        caseSubmissions,
        studySessions,
        readingPositions,
        bookmarks,
        annotations,
        reviewSchedules,
        contentRevisions,
        sourceDocuments,
        syncJournals,
        userSettingsEntries,
        aIInteractions,
        audioSettingsEntries
      ];
}

typedef $$CurriculumsTableCreateCompanionBuilder = CurriculumsCompanion
    Function({
  required String id,
  required String name,
  required String version,
  required String description,
  Value<int> totalVolumes,
  Value<double> weeklyTargetHours,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$CurriculumsTableUpdateCompanionBuilder = CurriculumsCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String> version,
  Value<String> description,
  Value<int> totalVolumes,
  Value<double> weeklyTargetHours,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$CurriculumsTableReferences
    extends BaseReferences<_$AppDatabase, $CurriculumsTable, Curriculum> {
  $$CurriculumsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$VolumesTable, List<Volume>> _volumesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.volumes,
          aliasName:
              $_aliasNameGenerator(db.curriculums.id, db.volumes.curriculumId));

  $$VolumesTableProcessedTableManager get volumesRefs {
    final manager = $$VolumesTableTableManager($_db, $_db.volumes)
        .filter((f) => f.curriculumId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_volumesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CurriculumsTableFilterComposer
    extends Composer<_$AppDatabase, $CurriculumsTable> {
  $$CurriculumsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalVolumes => $composableBuilder(
      column: $table.totalVolumes, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weeklyTargetHours => $composableBuilder(
      column: $table.weeklyTargetHours,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> volumesRefs(
      Expression<bool> Function($$VolumesTableFilterComposer f) f) {
    final $$VolumesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.volumes,
        getReferencedColumn: (t) => t.curriculumId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VolumesTableFilterComposer(
              $db: $db,
              $table: $db.volumes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CurriculumsTableOrderingComposer
    extends Composer<_$AppDatabase, $CurriculumsTable> {
  $$CurriculumsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalVolumes => $composableBuilder(
      column: $table.totalVolumes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weeklyTargetHours => $composableBuilder(
      column: $table.weeklyTargetHours,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CurriculumsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CurriculumsTable> {
  $$CurriculumsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get totalVolumes => $composableBuilder(
      column: $table.totalVolumes, builder: (column) => column);

  GeneratedColumn<double> get weeklyTargetHours => $composableBuilder(
      column: $table.weeklyTargetHours, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> volumesRefs<T extends Object>(
      Expression<T> Function($$VolumesTableAnnotationComposer a) f) {
    final $$VolumesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.volumes,
        getReferencedColumn: (t) => t.curriculumId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VolumesTableAnnotationComposer(
              $db: $db,
              $table: $db.volumes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CurriculumsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CurriculumsTable,
    Curriculum,
    $$CurriculumsTableFilterComposer,
    $$CurriculumsTableOrderingComposer,
    $$CurriculumsTableAnnotationComposer,
    $$CurriculumsTableCreateCompanionBuilder,
    $$CurriculumsTableUpdateCompanionBuilder,
    (Curriculum, $$CurriculumsTableReferences),
    Curriculum,
    PrefetchHooks Function({bool volumesRefs})> {
  $$CurriculumsTableTableManager(_$AppDatabase db, $CurriculumsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CurriculumsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CurriculumsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CurriculumsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> version = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<int> totalVolumes = const Value.absent(),
            Value<double> weeklyTargetHours = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CurriculumsCompanion(
            id: id,
            name: name,
            version: version,
            description: description,
            totalVolumes: totalVolumes,
            weeklyTargetHours: weeklyTargetHours,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String version,
            required String description,
            Value<int> totalVolumes = const Value.absent(),
            Value<double> weeklyTargetHours = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CurriculumsCompanion.insert(
            id: id,
            name: name,
            version: version,
            description: description,
            totalVolumes: totalVolumes,
            weeklyTargetHours: weeklyTargetHours,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CurriculumsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({volumesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (volumesRefs) db.volumes],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (volumesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$CurriculumsTableReferences._volumesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CurriculumsTableReferences(db, table, p0)
                                .volumesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.curriculumId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CurriculumsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CurriculumsTable,
    Curriculum,
    $$CurriculumsTableFilterComposer,
    $$CurriculumsTableOrderingComposer,
    $$CurriculumsTableAnnotationComposer,
    $$CurriculumsTableCreateCompanionBuilder,
    $$CurriculumsTableUpdateCompanionBuilder,
    (Curriculum, $$CurriculumsTableReferences),
    Curriculum,
    PrefetchHooks Function({bool volumesRefs})>;
typedef $$VolumesTableCreateCompanionBuilder = VolumesCompanion Function({
  required String id,
  required String curriculumId,
  required int volumeNumber,
  required String title,
  required String discipline,
  required String description,
  required int totalChapters,
  Value<bool> isPrintPreserved,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$VolumesTableUpdateCompanionBuilder = VolumesCompanion Function({
  Value<String> id,
  Value<String> curriculumId,
  Value<int> volumeNumber,
  Value<String> title,
  Value<String> discipline,
  Value<String> description,
  Value<int> totalChapters,
  Value<bool> isPrintPreserved,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$VolumesTableReferences
    extends BaseReferences<_$AppDatabase, $VolumesTable, Volume> {
  $$VolumesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CurriculumsTable _curriculumIdTable(_$AppDatabase db) =>
      db.curriculums.createAlias(
          $_aliasNameGenerator(db.volumes.curriculumId, db.curriculums.id));

  $$CurriculumsTableProcessedTableManager get curriculumId {
    final manager = $$CurriculumsTableTableManager($_db, $_db.curriculums)
        .filter((f) => f.id($_item.curriculumId));
    final item = $_typedResult.readTableOrNull(_curriculumIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$ChaptersTable, List<Chapter>> _chaptersRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.chapters,
          aliasName: $_aliasNameGenerator(db.volumes.id, db.chapters.volumeId));

  $$ChaptersTableProcessedTableManager get chaptersRefs {
    final manager = $$ChaptersTableTableManager($_db, $_db.chapters)
        .filter((f) => f.volumeId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_chaptersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$VolumesTableFilterComposer
    extends Composer<_$AppDatabase, $VolumesTable> {
  $$VolumesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get volumeNumber => $composableBuilder(
      column: $table.volumeNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get discipline => $composableBuilder(
      column: $table.discipline, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalChapters => $composableBuilder(
      column: $table.totalChapters, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPrintPreserved => $composableBuilder(
      column: $table.isPrintPreserved,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$CurriculumsTableFilterComposer get curriculumId {
    final $$CurriculumsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.curriculumId,
        referencedTable: $db.curriculums,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CurriculumsTableFilterComposer(
              $db: $db,
              $table: $db.curriculums,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> chaptersRefs(
      Expression<bool> Function($$ChaptersTableFilterComposer f) f) {
    final $$ChaptersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.volumeId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableFilterComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$VolumesTableOrderingComposer
    extends Composer<_$AppDatabase, $VolumesTable> {
  $$VolumesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get volumeNumber => $composableBuilder(
      column: $table.volumeNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get discipline => $composableBuilder(
      column: $table.discipline, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalChapters => $composableBuilder(
      column: $table.totalChapters,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPrintPreserved => $composableBuilder(
      column: $table.isPrintPreserved,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$CurriculumsTableOrderingComposer get curriculumId {
    final $$CurriculumsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.curriculumId,
        referencedTable: $db.curriculums,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CurriculumsTableOrderingComposer(
              $db: $db,
              $table: $db.curriculums,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$VolumesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VolumesTable> {
  $$VolumesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get volumeNumber => $composableBuilder(
      column: $table.volumeNumber, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get discipline => $composableBuilder(
      column: $table.discipline, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get totalChapters => $composableBuilder(
      column: $table.totalChapters, builder: (column) => column);

  GeneratedColumn<bool> get isPrintPreserved => $composableBuilder(
      column: $table.isPrintPreserved, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CurriculumsTableAnnotationComposer get curriculumId {
    final $$CurriculumsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.curriculumId,
        referencedTable: $db.curriculums,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CurriculumsTableAnnotationComposer(
              $db: $db,
              $table: $db.curriculums,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> chaptersRefs<T extends Object>(
      Expression<T> Function($$ChaptersTableAnnotationComposer a) f) {
    final $$ChaptersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.volumeId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableAnnotationComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$VolumesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VolumesTable,
    Volume,
    $$VolumesTableFilterComposer,
    $$VolumesTableOrderingComposer,
    $$VolumesTableAnnotationComposer,
    $$VolumesTableCreateCompanionBuilder,
    $$VolumesTableUpdateCompanionBuilder,
    (Volume, $$VolumesTableReferences),
    Volume,
    PrefetchHooks Function({bool curriculumId, bool chaptersRefs})> {
  $$VolumesTableTableManager(_$AppDatabase db, $VolumesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VolumesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VolumesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VolumesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> curriculumId = const Value.absent(),
            Value<int> volumeNumber = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> discipline = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<int> totalChapters = const Value.absent(),
            Value<bool> isPrintPreserved = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VolumesCompanion(
            id: id,
            curriculumId: curriculumId,
            volumeNumber: volumeNumber,
            title: title,
            discipline: discipline,
            description: description,
            totalChapters: totalChapters,
            isPrintPreserved: isPrintPreserved,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String curriculumId,
            required int volumeNumber,
            required String title,
            required String discipline,
            required String description,
            required int totalChapters,
            Value<bool> isPrintPreserved = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VolumesCompanion.insert(
            id: id,
            curriculumId: curriculumId,
            volumeNumber: volumeNumber,
            title: title,
            discipline: discipline,
            description: description,
            totalChapters: totalChapters,
            isPrintPreserved: isPrintPreserved,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$VolumesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {curriculumId = false, chaptersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (chaptersRefs) db.chapters],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (curriculumId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.curriculumId,
                    referencedTable:
                        $$VolumesTableReferences._curriculumIdTable(db),
                    referencedColumn:
                        $$VolumesTableReferences._curriculumIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (chaptersRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$VolumesTableReferences._chaptersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$VolumesTableReferences(db, table, p0)
                                .chaptersRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.volumeId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$VolumesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VolumesTable,
    Volume,
    $$VolumesTableFilterComposer,
    $$VolumesTableOrderingComposer,
    $$VolumesTableAnnotationComposer,
    $$VolumesTableCreateCompanionBuilder,
    $$VolumesTableUpdateCompanionBuilder,
    (Volume, $$VolumesTableReferences),
    Volume,
    PrefetchHooks Function({bool curriculumId, bool chaptersRefs})>;
typedef $$ChaptersTableCreateCompanionBuilder = ChaptersCompanion Function({
  required String id,
  required String volumeId,
  required int chapterNumber,
  required String title,
  Value<String> editorialStatus,
  Value<String?> activeRevisionId,
  required int orderIndex,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$ChaptersTableUpdateCompanionBuilder = ChaptersCompanion Function({
  Value<String> id,
  Value<String> volumeId,
  Value<int> chapterNumber,
  Value<String> title,
  Value<String> editorialStatus,
  Value<String?> activeRevisionId,
  Value<int> orderIndex,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$ChaptersTableReferences
    extends BaseReferences<_$AppDatabase, $ChaptersTable, Chapter> {
  $$ChaptersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VolumesTable _volumeIdTable(_$AppDatabase db) => db.volumes
      .createAlias($_aliasNameGenerator(db.chapters.volumeId, db.volumes.id));

  $$VolumesTableProcessedTableManager get volumeId {
    final manager = $$VolumesTableTableManager($_db, $_db.volumes)
        .filter((f) => f.id($_item.volumeId));
    final item = $_typedResult.readTableOrNull(_volumeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$LessonsTable, List<Lesson>> _lessonsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.lessons,
          aliasName:
              $_aliasNameGenerator(db.chapters.id, db.lessons.chapterId));

  $$LessonsTableProcessedTableManager get lessonsRefs {
    final manager = $$LessonsTableTableManager($_db, $_db.lessons)
        .filter((f) => f.chapterId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_lessonsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$LearningObjectivesTable, List<LearningObjective>>
      _learningObjectivesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.learningObjectives,
              aliasName: $_aliasNameGenerator(
                  db.chapters.id, db.learningObjectives.chapterId));

  $$LearningObjectivesTableProcessedTableManager get learningObjectivesRefs {
    final manager =
        $$LearningObjectivesTableTableManager($_db, $_db.learningObjectives)
            .filter((f) => f.chapterId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_learningObjectivesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ExercisesTable, List<Exercise>>
      _exercisesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.exercises,
              aliasName:
                  $_aliasNameGenerator(db.chapters.id, db.exercises.chapterId));

  $$ExercisesTableProcessedTableManager get exercisesRefs {
    final manager = $$ExercisesTableTableManager($_db, $_db.exercises)
        .filter((f) => f.chapterId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_exercisesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$AssessmentsTable, List<Assessment>>
      _assessmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.assessments,
          aliasName:
              $_aliasNameGenerator(db.chapters.id, db.assessments.chapterId));

  $$AssessmentsTableProcessedTableManager get assessmentsRefs {
    final manager = $$AssessmentsTableTableManager($_db, $_db.assessments)
        .filter((f) => f.chapterId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_assessmentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$LaboratoriesTable, List<Laboratory>>
      _laboratoriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.laboratories,
          aliasName:
              $_aliasNameGenerator(db.chapters.id, db.laboratories.chapterId));

  $$LaboratoriesTableProcessedTableManager get laboratoriesRefs {
    final manager = $$LaboratoriesTableTableManager($_db, $_db.laboratories)
        .filter((f) => f.chapterId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_laboratoriesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$CaseStudiesTable, List<CaseStudy>>
      _caseStudiesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.caseStudies,
          aliasName:
              $_aliasNameGenerator(db.chapters.id, db.caseStudies.chapterId));

  $$CaseStudiesTableProcessedTableManager get caseStudiesRefs {
    final manager = $$CaseStudiesTableTableManager($_db, $_db.caseStudies)
        .filter((f) => f.chapterId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_caseStudiesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$StudySessionsTable, List<StudySession>>
      _studySessionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.studySessions,
              aliasName: $_aliasNameGenerator(
                  db.chapters.id, db.studySessions.chapterId));

  $$StudySessionsTableProcessedTableManager get studySessionsRefs {
    final manager = $$StudySessionsTableTableManager($_db, $_db.studySessions)
        .filter((f) => f.chapterId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_studySessionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ReadingPositionsTable, List<ReadingPosition>>
      _readingPositionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.readingPositions,
              aliasName: $_aliasNameGenerator(
                  db.chapters.id, db.readingPositions.chapterId));

  $$ReadingPositionsTableProcessedTableManager get readingPositionsRefs {
    final manager =
        $$ReadingPositionsTableTableManager($_db, $_db.readingPositions)
            .filter((f) => f.chapterId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_readingPositionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$BookmarksTable, List<Bookmark>>
      _bookmarksRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.bookmarks,
              aliasName:
                  $_aliasNameGenerator(db.chapters.id, db.bookmarks.chapterId));

  $$BookmarksTableProcessedTableManager get bookmarksRefs {
    final manager = $$BookmarksTableTableManager($_db, $_db.bookmarks)
        .filter((f) => f.chapterId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_bookmarksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$AnnotationsTable, List<Annotation>>
      _annotationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.annotations,
          aliasName:
              $_aliasNameGenerator(db.chapters.id, db.annotations.chapterId));

  $$AnnotationsTableProcessedTableManager get annotationsRefs {
    final manager = $$AnnotationsTableTableManager($_db, $_db.annotations)
        .filter((f) => f.chapterId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_annotationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ReviewSchedulesTable, List<ReviewSchedule>>
      _reviewSchedulesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.reviewSchedules,
              aliasName: $_aliasNameGenerator(
                  db.chapters.id, db.reviewSchedules.chapterId));

  $$ReviewSchedulesTableProcessedTableManager get reviewSchedulesRefs {
    final manager =
        $$ReviewSchedulesTableTableManager($_db, $_db.reviewSchedules)
            .filter((f) => f.chapterId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_reviewSchedulesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ContentRevisionsTable, List<ContentRevision>>
      _contentRevisionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.contentRevisions,
              aliasName: $_aliasNameGenerator(
                  db.chapters.id, db.contentRevisions.chapterId));

  $$ContentRevisionsTableProcessedTableManager get contentRevisionsRefs {
    final manager =
        $$ContentRevisionsTableTableManager($_db, $_db.contentRevisions)
            .filter((f) => f.chapterId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_contentRevisionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SourceDocumentsTable, List<SourceDocument>>
      _sourceDocumentsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.sourceDocuments,
              aliasName: $_aliasNameGenerator(
                  db.chapters.id, db.sourceDocuments.chapterId));

  $$SourceDocumentsTableProcessedTableManager get sourceDocumentsRefs {
    final manager =
        $$SourceDocumentsTableTableManager($_db, $_db.sourceDocuments)
            .filter((f) => f.chapterId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_sourceDocumentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$AIInteractionsTable, List<AIInteraction>>
      _aIInteractionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.aIInteractions,
              aliasName: $_aliasNameGenerator(
                  db.chapters.id, db.aIInteractions.chapterId));

  $$AIInteractionsTableProcessedTableManager get aIInteractionsRefs {
    final manager = $$AIInteractionsTableTableManager($_db, $_db.aIInteractions)
        .filter((f) => f.chapterId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_aIInteractionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ChaptersTableFilterComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get chapterNumber => $composableBuilder(
      column: $table.chapterNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get editorialStatus => $composableBuilder(
      column: $table.editorialStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get activeRevisionId => $composableBuilder(
      column: $table.activeRevisionId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$VolumesTableFilterComposer get volumeId {
    final $$VolumesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.volumeId,
        referencedTable: $db.volumes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VolumesTableFilterComposer(
              $db: $db,
              $table: $db.volumes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> lessonsRefs(
      Expression<bool> Function($$LessonsTableFilterComposer f) f) {
    final $$LessonsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.lessons,
        getReferencedColumn: (t) => t.chapterId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LessonsTableFilterComposer(
              $db: $db,
              $table: $db.lessons,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> learningObjectivesRefs(
      Expression<bool> Function($$LearningObjectivesTableFilterComposer f) f) {
    final $$LearningObjectivesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.learningObjectives,
        getReferencedColumn: (t) => t.chapterId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LearningObjectivesTableFilterComposer(
              $db: $db,
              $table: $db.learningObjectives,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> exercisesRefs(
      Expression<bool> Function($$ExercisesTableFilterComposer f) f) {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.exercises,
        getReferencedColumn: (t) => t.chapterId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExercisesTableFilterComposer(
              $db: $db,
              $table: $db.exercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> assessmentsRefs(
      Expression<bool> Function($$AssessmentsTableFilterComposer f) f) {
    final $$AssessmentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.assessments,
        getReferencedColumn: (t) => t.chapterId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AssessmentsTableFilterComposer(
              $db: $db,
              $table: $db.assessments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> laboratoriesRefs(
      Expression<bool> Function($$LaboratoriesTableFilterComposer f) f) {
    final $$LaboratoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.laboratories,
        getReferencedColumn: (t) => t.chapterId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LaboratoriesTableFilterComposer(
              $db: $db,
              $table: $db.laboratories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> caseStudiesRefs(
      Expression<bool> Function($$CaseStudiesTableFilterComposer f) f) {
    final $$CaseStudiesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.caseStudies,
        getReferencedColumn: (t) => t.chapterId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CaseStudiesTableFilterComposer(
              $db: $db,
              $table: $db.caseStudies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> studySessionsRefs(
      Expression<bool> Function($$StudySessionsTableFilterComposer f) f) {
    final $$StudySessionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.studySessions,
        getReferencedColumn: (t) => t.chapterId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StudySessionsTableFilterComposer(
              $db: $db,
              $table: $db.studySessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> readingPositionsRefs(
      Expression<bool> Function($$ReadingPositionsTableFilterComposer f) f) {
    final $$ReadingPositionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.readingPositions,
        getReferencedColumn: (t) => t.chapterId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReadingPositionsTableFilterComposer(
              $db: $db,
              $table: $db.readingPositions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> bookmarksRefs(
      Expression<bool> Function($$BookmarksTableFilterComposer f) f) {
    final $$BookmarksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.bookmarks,
        getReferencedColumn: (t) => t.chapterId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BookmarksTableFilterComposer(
              $db: $db,
              $table: $db.bookmarks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> annotationsRefs(
      Expression<bool> Function($$AnnotationsTableFilterComposer f) f) {
    final $$AnnotationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.annotations,
        getReferencedColumn: (t) => t.chapterId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AnnotationsTableFilterComposer(
              $db: $db,
              $table: $db.annotations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> reviewSchedulesRefs(
      Expression<bool> Function($$ReviewSchedulesTableFilterComposer f) f) {
    final $$ReviewSchedulesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.reviewSchedules,
        getReferencedColumn: (t) => t.chapterId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReviewSchedulesTableFilterComposer(
              $db: $db,
              $table: $db.reviewSchedules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> contentRevisionsRefs(
      Expression<bool> Function($$ContentRevisionsTableFilterComposer f) f) {
    final $$ContentRevisionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.contentRevisions,
        getReferencedColumn: (t) => t.chapterId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ContentRevisionsTableFilterComposer(
              $db: $db,
              $table: $db.contentRevisions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> sourceDocumentsRefs(
      Expression<bool> Function($$SourceDocumentsTableFilterComposer f) f) {
    final $$SourceDocumentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sourceDocuments,
        getReferencedColumn: (t) => t.chapterId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SourceDocumentsTableFilterComposer(
              $db: $db,
              $table: $db.sourceDocuments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> aIInteractionsRefs(
      Expression<bool> Function($$AIInteractionsTableFilterComposer f) f) {
    final $$AIInteractionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.aIInteractions,
        getReferencedColumn: (t) => t.chapterId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AIInteractionsTableFilterComposer(
              $db: $db,
              $table: $db.aIInteractions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ChaptersTableOrderingComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get chapterNumber => $composableBuilder(
      column: $table.chapterNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get editorialStatus => $composableBuilder(
      column: $table.editorialStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get activeRevisionId => $composableBuilder(
      column: $table.activeRevisionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$VolumesTableOrderingComposer get volumeId {
    final $$VolumesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.volumeId,
        referencedTable: $db.volumes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VolumesTableOrderingComposer(
              $db: $db,
              $table: $db.volumes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ChaptersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get chapterNumber => $composableBuilder(
      column: $table.chapterNumber, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get editorialStatus => $composableBuilder(
      column: $table.editorialStatus, builder: (column) => column);

  GeneratedColumn<String> get activeRevisionId => $composableBuilder(
      column: $table.activeRevisionId, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$VolumesTableAnnotationComposer get volumeId {
    final $$VolumesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.volumeId,
        referencedTable: $db.volumes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VolumesTableAnnotationComposer(
              $db: $db,
              $table: $db.volumes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> lessonsRefs<T extends Object>(
      Expression<T> Function($$LessonsTableAnnotationComposer a) f) {
    final $$LessonsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.lessons,
        getReferencedColumn: (t) => t.chapterId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LessonsTableAnnotationComposer(
              $db: $db,
              $table: $db.lessons,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> learningObjectivesRefs<T extends Object>(
      Expression<T> Function($$LearningObjectivesTableAnnotationComposer a) f) {
    final $$LearningObjectivesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.learningObjectives,
            getReferencedColumn: (t) => t.chapterId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$LearningObjectivesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.learningObjectives,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> exercisesRefs<T extends Object>(
      Expression<T> Function($$ExercisesTableAnnotationComposer a) f) {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.exercises,
        getReferencedColumn: (t) => t.chapterId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExercisesTableAnnotationComposer(
              $db: $db,
              $table: $db.exercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> assessmentsRefs<T extends Object>(
      Expression<T> Function($$AssessmentsTableAnnotationComposer a) f) {
    final $$AssessmentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.assessments,
        getReferencedColumn: (t) => t.chapterId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AssessmentsTableAnnotationComposer(
              $db: $db,
              $table: $db.assessments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> laboratoriesRefs<T extends Object>(
      Expression<T> Function($$LaboratoriesTableAnnotationComposer a) f) {
    final $$LaboratoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.laboratories,
        getReferencedColumn: (t) => t.chapterId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LaboratoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.laboratories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> caseStudiesRefs<T extends Object>(
      Expression<T> Function($$CaseStudiesTableAnnotationComposer a) f) {
    final $$CaseStudiesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.caseStudies,
        getReferencedColumn: (t) => t.chapterId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CaseStudiesTableAnnotationComposer(
              $db: $db,
              $table: $db.caseStudies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> studySessionsRefs<T extends Object>(
      Expression<T> Function($$StudySessionsTableAnnotationComposer a) f) {
    final $$StudySessionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.studySessions,
        getReferencedColumn: (t) => t.chapterId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StudySessionsTableAnnotationComposer(
              $db: $db,
              $table: $db.studySessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> readingPositionsRefs<T extends Object>(
      Expression<T> Function($$ReadingPositionsTableAnnotationComposer a) f) {
    final $$ReadingPositionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.readingPositions,
        getReferencedColumn: (t) => t.chapterId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReadingPositionsTableAnnotationComposer(
              $db: $db,
              $table: $db.readingPositions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> bookmarksRefs<T extends Object>(
      Expression<T> Function($$BookmarksTableAnnotationComposer a) f) {
    final $$BookmarksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.bookmarks,
        getReferencedColumn: (t) => t.chapterId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BookmarksTableAnnotationComposer(
              $db: $db,
              $table: $db.bookmarks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> annotationsRefs<T extends Object>(
      Expression<T> Function($$AnnotationsTableAnnotationComposer a) f) {
    final $$AnnotationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.annotations,
        getReferencedColumn: (t) => t.chapterId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AnnotationsTableAnnotationComposer(
              $db: $db,
              $table: $db.annotations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> reviewSchedulesRefs<T extends Object>(
      Expression<T> Function($$ReviewSchedulesTableAnnotationComposer a) f) {
    final $$ReviewSchedulesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.reviewSchedules,
        getReferencedColumn: (t) => t.chapterId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReviewSchedulesTableAnnotationComposer(
              $db: $db,
              $table: $db.reviewSchedules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> contentRevisionsRefs<T extends Object>(
      Expression<T> Function($$ContentRevisionsTableAnnotationComposer a) f) {
    final $$ContentRevisionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.contentRevisions,
        getReferencedColumn: (t) => t.chapterId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ContentRevisionsTableAnnotationComposer(
              $db: $db,
              $table: $db.contentRevisions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> sourceDocumentsRefs<T extends Object>(
      Expression<T> Function($$SourceDocumentsTableAnnotationComposer a) f) {
    final $$SourceDocumentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sourceDocuments,
        getReferencedColumn: (t) => t.chapterId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SourceDocumentsTableAnnotationComposer(
              $db: $db,
              $table: $db.sourceDocuments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> aIInteractionsRefs<T extends Object>(
      Expression<T> Function($$AIInteractionsTableAnnotationComposer a) f) {
    final $$AIInteractionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.aIInteractions,
        getReferencedColumn: (t) => t.chapterId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AIInteractionsTableAnnotationComposer(
              $db: $db,
              $table: $db.aIInteractions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ChaptersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChaptersTable,
    Chapter,
    $$ChaptersTableFilterComposer,
    $$ChaptersTableOrderingComposer,
    $$ChaptersTableAnnotationComposer,
    $$ChaptersTableCreateCompanionBuilder,
    $$ChaptersTableUpdateCompanionBuilder,
    (Chapter, $$ChaptersTableReferences),
    Chapter,
    PrefetchHooks Function(
        {bool volumeId,
        bool lessonsRefs,
        bool learningObjectivesRefs,
        bool exercisesRefs,
        bool assessmentsRefs,
        bool laboratoriesRefs,
        bool caseStudiesRefs,
        bool studySessionsRefs,
        bool readingPositionsRefs,
        bool bookmarksRefs,
        bool annotationsRefs,
        bool reviewSchedulesRefs,
        bool contentRevisionsRefs,
        bool sourceDocumentsRefs,
        bool aIInteractionsRefs})> {
  $$ChaptersTableTableManager(_$AppDatabase db, $ChaptersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChaptersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChaptersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChaptersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> volumeId = const Value.absent(),
            Value<int> chapterNumber = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> editorialStatus = const Value.absent(),
            Value<String?> activeRevisionId = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChaptersCompanion(
            id: id,
            volumeId: volumeId,
            chapterNumber: chapterNumber,
            title: title,
            editorialStatus: editorialStatus,
            activeRevisionId: activeRevisionId,
            orderIndex: orderIndex,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String volumeId,
            required int chapterNumber,
            required String title,
            Value<String> editorialStatus = const Value.absent(),
            Value<String?> activeRevisionId = const Value.absent(),
            required int orderIndex,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChaptersCompanion.insert(
            id: id,
            volumeId: volumeId,
            chapterNumber: chapterNumber,
            title: title,
            editorialStatus: editorialStatus,
            activeRevisionId: activeRevisionId,
            orderIndex: orderIndex,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ChaptersTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {volumeId = false,
              lessonsRefs = false,
              learningObjectivesRefs = false,
              exercisesRefs = false,
              assessmentsRefs = false,
              laboratoriesRefs = false,
              caseStudiesRefs = false,
              studySessionsRefs = false,
              readingPositionsRefs = false,
              bookmarksRefs = false,
              annotationsRefs = false,
              reviewSchedulesRefs = false,
              contentRevisionsRefs = false,
              sourceDocumentsRefs = false,
              aIInteractionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (lessonsRefs) db.lessons,
                if (learningObjectivesRefs) db.learningObjectives,
                if (exercisesRefs) db.exercises,
                if (assessmentsRefs) db.assessments,
                if (laboratoriesRefs) db.laboratories,
                if (caseStudiesRefs) db.caseStudies,
                if (studySessionsRefs) db.studySessions,
                if (readingPositionsRefs) db.readingPositions,
                if (bookmarksRefs) db.bookmarks,
                if (annotationsRefs) db.annotations,
                if (reviewSchedulesRefs) db.reviewSchedules,
                if (contentRevisionsRefs) db.contentRevisions,
                if (sourceDocumentsRefs) db.sourceDocuments,
                if (aIInteractionsRefs) db.aIInteractions
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (volumeId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.volumeId,
                    referencedTable:
                        $$ChaptersTableReferences._volumeIdTable(db),
                    referencedColumn:
                        $$ChaptersTableReferences._volumeIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (lessonsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$ChaptersTableReferences._lessonsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ChaptersTableReferences(db, table, p0)
                                .lessonsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.chapterId == item.id),
                        typedResults: items),
                  if (learningObjectivesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$ChaptersTableReferences
                            ._learningObjectivesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ChaptersTableReferences(db, table, p0)
                                .learningObjectivesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.chapterId == item.id),
                        typedResults: items),
                  if (exercisesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$ChaptersTableReferences._exercisesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ChaptersTableReferences(db, table, p0)
                                .exercisesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.chapterId == item.id),
                        typedResults: items),
                  if (assessmentsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$ChaptersTableReferences._assessmentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ChaptersTableReferences(db, table, p0)
                                .assessmentsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.chapterId == item.id),
                        typedResults: items),
                  if (laboratoriesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$ChaptersTableReferences
                            ._laboratoriesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ChaptersTableReferences(db, table, p0)
                                .laboratoriesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.chapterId == item.id),
                        typedResults: items),
                  if (caseStudiesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$ChaptersTableReferences._caseStudiesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ChaptersTableReferences(db, table, p0)
                                .caseStudiesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.chapterId == item.id),
                        typedResults: items),
                  if (studySessionsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$ChaptersTableReferences
                            ._studySessionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ChaptersTableReferences(db, table, p0)
                                .studySessionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.chapterId == item.id),
                        typedResults: items),
                  if (readingPositionsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$ChaptersTableReferences
                            ._readingPositionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ChaptersTableReferences(db, table, p0)
                                .readingPositionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.chapterId == item.id),
                        typedResults: items),
                  if (bookmarksRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$ChaptersTableReferences._bookmarksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ChaptersTableReferences(db, table, p0)
                                .bookmarksRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.chapterId == item.id),
                        typedResults: items),
                  if (annotationsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$ChaptersTableReferences._annotationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ChaptersTableReferences(db, table, p0)
                                .annotationsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.chapterId == item.id),
                        typedResults: items),
                  if (reviewSchedulesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$ChaptersTableReferences
                            ._reviewSchedulesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ChaptersTableReferences(db, table, p0)
                                .reviewSchedulesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.chapterId == item.id),
                        typedResults: items),
                  if (contentRevisionsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$ChaptersTableReferences
                            ._contentRevisionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ChaptersTableReferences(db, table, p0)
                                .contentRevisionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.chapterId == item.id),
                        typedResults: items),
                  if (sourceDocumentsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$ChaptersTableReferences
                            ._sourceDocumentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ChaptersTableReferences(db, table, p0)
                                .sourceDocumentsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.chapterId == item.id),
                        typedResults: items),
                  if (aIInteractionsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$ChaptersTableReferences
                            ._aIInteractionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ChaptersTableReferences(db, table, p0)
                                .aIInteractionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.chapterId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ChaptersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ChaptersTable,
    Chapter,
    $$ChaptersTableFilterComposer,
    $$ChaptersTableOrderingComposer,
    $$ChaptersTableAnnotationComposer,
    $$ChaptersTableCreateCompanionBuilder,
    $$ChaptersTableUpdateCompanionBuilder,
    (Chapter, $$ChaptersTableReferences),
    Chapter,
    PrefetchHooks Function(
        {bool volumeId,
        bool lessonsRefs,
        bool learningObjectivesRefs,
        bool exercisesRefs,
        bool assessmentsRefs,
        bool laboratoriesRefs,
        bool caseStudiesRefs,
        bool studySessionsRefs,
        bool readingPositionsRefs,
        bool bookmarksRefs,
        bool annotationsRefs,
        bool reviewSchedulesRefs,
        bool contentRevisionsRefs,
        bool sourceDocumentsRefs,
        bool aIInteractionsRefs})>;
typedef $$LessonsTableCreateCompanionBuilder = LessonsCompanion Function({
  required String id,
  required String chapterId,
  required int lessonNumber,
  required String title,
  Value<int> stepCount,
  Value<int> estimatedMinutes,
  required int orderIndex,
  Value<int> rowid,
});
typedef $$LessonsTableUpdateCompanionBuilder = LessonsCompanion Function({
  Value<String> id,
  Value<String> chapterId,
  Value<int> lessonNumber,
  Value<String> title,
  Value<int> stepCount,
  Value<int> estimatedMinutes,
  Value<int> orderIndex,
  Value<int> rowid,
});

final class $$LessonsTableReferences
    extends BaseReferences<_$AppDatabase, $LessonsTable, Lesson> {
  $$LessonsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ChaptersTable _chapterIdTable(_$AppDatabase db) => db.chapters
      .createAlias($_aliasNameGenerator(db.lessons.chapterId, db.chapters.id));

  $$ChaptersTableProcessedTableManager get chapterId {
    final manager = $$ChaptersTableTableManager($_db, $_db.chapters)
        .filter((f) => f.id($_item.chapterId));
    final item = $_typedResult.readTableOrNull(_chapterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$LearningObjectivesTable, List<LearningObjective>>
      _learningObjectivesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.learningObjectives,
              aliasName: $_aliasNameGenerator(
                  db.lessons.id, db.learningObjectives.lessonId));

  $$LearningObjectivesTableProcessedTableManager get learningObjectivesRefs {
    final manager =
        $$LearningObjectivesTableTableManager($_db, $_db.learningObjectives)
            .filter((f) => f.lessonId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_learningObjectivesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ExercisesTable, List<Exercise>>
      _exercisesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.exercises,
              aliasName:
                  $_aliasNameGenerator(db.lessons.id, db.exercises.lessonId));

  $$ExercisesTableProcessedTableManager get exercisesRefs {
    final manager = $$ExercisesTableTableManager($_db, $_db.exercises)
        .filter((f) => f.lessonId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_exercisesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$LessonsTableFilterComposer
    extends Composer<_$AppDatabase, $LessonsTable> {
  $$LessonsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lessonNumber => $composableBuilder(
      column: $table.lessonNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get stepCount => $composableBuilder(
      column: $table.stepCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get estimatedMinutes => $composableBuilder(
      column: $table.estimatedMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnFilters(column));

  $$ChaptersTableFilterComposer get chapterId {
    final $$ChaptersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableFilterComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> learningObjectivesRefs(
      Expression<bool> Function($$LearningObjectivesTableFilterComposer f) f) {
    final $$LearningObjectivesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.learningObjectives,
        getReferencedColumn: (t) => t.lessonId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LearningObjectivesTableFilterComposer(
              $db: $db,
              $table: $db.learningObjectives,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> exercisesRefs(
      Expression<bool> Function($$ExercisesTableFilterComposer f) f) {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.exercises,
        getReferencedColumn: (t) => t.lessonId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExercisesTableFilterComposer(
              $db: $db,
              $table: $db.exercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$LessonsTableOrderingComposer
    extends Composer<_$AppDatabase, $LessonsTable> {
  $$LessonsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lessonNumber => $composableBuilder(
      column: $table.lessonNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get stepCount => $composableBuilder(
      column: $table.stepCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get estimatedMinutes => $composableBuilder(
      column: $table.estimatedMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnOrderings(column));

  $$ChaptersTableOrderingComposer get chapterId {
    final $$ChaptersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableOrderingComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LessonsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LessonsTable> {
  $$LessonsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get lessonNumber => $composableBuilder(
      column: $table.lessonNumber, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get stepCount =>
      $composableBuilder(column: $table.stepCount, builder: (column) => column);

  GeneratedColumn<int> get estimatedMinutes => $composableBuilder(
      column: $table.estimatedMinutes, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => column);

  $$ChaptersTableAnnotationComposer get chapterId {
    final $$ChaptersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableAnnotationComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> learningObjectivesRefs<T extends Object>(
      Expression<T> Function($$LearningObjectivesTableAnnotationComposer a) f) {
    final $$LearningObjectivesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.learningObjectives,
            getReferencedColumn: (t) => t.lessonId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$LearningObjectivesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.learningObjectives,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> exercisesRefs<T extends Object>(
      Expression<T> Function($$ExercisesTableAnnotationComposer a) f) {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.exercises,
        getReferencedColumn: (t) => t.lessonId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExercisesTableAnnotationComposer(
              $db: $db,
              $table: $db.exercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$LessonsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LessonsTable,
    Lesson,
    $$LessonsTableFilterComposer,
    $$LessonsTableOrderingComposer,
    $$LessonsTableAnnotationComposer,
    $$LessonsTableCreateCompanionBuilder,
    $$LessonsTableUpdateCompanionBuilder,
    (Lesson, $$LessonsTableReferences),
    Lesson,
    PrefetchHooks Function(
        {bool chapterId, bool learningObjectivesRefs, bool exercisesRefs})> {
  $$LessonsTableTableManager(_$AppDatabase db, $LessonsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LessonsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LessonsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LessonsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> chapterId = const Value.absent(),
            Value<int> lessonNumber = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<int> stepCount = const Value.absent(),
            Value<int> estimatedMinutes = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LessonsCompanion(
            id: id,
            chapterId: chapterId,
            lessonNumber: lessonNumber,
            title: title,
            stepCount: stepCount,
            estimatedMinutes: estimatedMinutes,
            orderIndex: orderIndex,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String chapterId,
            required int lessonNumber,
            required String title,
            Value<int> stepCount = const Value.absent(),
            Value<int> estimatedMinutes = const Value.absent(),
            required int orderIndex,
            Value<int> rowid = const Value.absent(),
          }) =>
              LessonsCompanion.insert(
            id: id,
            chapterId: chapterId,
            lessonNumber: lessonNumber,
            title: title,
            stepCount: stepCount,
            estimatedMinutes: estimatedMinutes,
            orderIndex: orderIndex,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$LessonsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {chapterId = false,
              learningObjectivesRefs = false,
              exercisesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (learningObjectivesRefs) db.learningObjectives,
                if (exercisesRefs) db.exercises
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (chapterId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.chapterId,
                    referencedTable:
                        $$LessonsTableReferences._chapterIdTable(db),
                    referencedColumn:
                        $$LessonsTableReferences._chapterIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (learningObjectivesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$LessonsTableReferences
                            ._learningObjectivesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$LessonsTableReferences(db, table, p0)
                                .learningObjectivesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.lessonId == item.id),
                        typedResults: items),
                  if (exercisesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$LessonsTableReferences._exercisesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$LessonsTableReferences(db, table, p0)
                                .exercisesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.lessonId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$LessonsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LessonsTable,
    Lesson,
    $$LessonsTableFilterComposer,
    $$LessonsTableOrderingComposer,
    $$LessonsTableAnnotationComposer,
    $$LessonsTableCreateCompanionBuilder,
    $$LessonsTableUpdateCompanionBuilder,
    (Lesson, $$LessonsTableReferences),
    Lesson,
    PrefetchHooks Function(
        {bool chapterId, bool learningObjectivesRefs, bool exercisesRefs})>;
typedef $$LearningObjectivesTableCreateCompanionBuilder
    = LearningObjectivesCompanion Function({
  required String id,
  required String chapterId,
  Value<String?> lessonId,
  required String description,
  required String bloomTaxonomyLevel,
  required int orderIndex,
  Value<int> rowid,
});
typedef $$LearningObjectivesTableUpdateCompanionBuilder
    = LearningObjectivesCompanion Function({
  Value<String> id,
  Value<String> chapterId,
  Value<String?> lessonId,
  Value<String> description,
  Value<String> bloomTaxonomyLevel,
  Value<int> orderIndex,
  Value<int> rowid,
});

final class $$LearningObjectivesTableReferences extends BaseReferences<
    _$AppDatabase, $LearningObjectivesTable, LearningObjective> {
  $$LearningObjectivesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ChaptersTable _chapterIdTable(_$AppDatabase db) =>
      db.chapters.createAlias($_aliasNameGenerator(
          db.learningObjectives.chapterId, db.chapters.id));

  $$ChaptersTableProcessedTableManager get chapterId {
    final manager = $$ChaptersTableTableManager($_db, $_db.chapters)
        .filter((f) => f.id($_item.chapterId));
    final item = $_typedResult.readTableOrNull(_chapterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $LessonsTable _lessonIdTable(_$AppDatabase db) =>
      db.lessons.createAlias(
          $_aliasNameGenerator(db.learningObjectives.lessonId, db.lessons.id));

  $$LessonsTableProcessedTableManager? get lessonId {
    if ($_item.lessonId == null) return null;
    final manager = $$LessonsTableTableManager($_db, $_db.lessons)
        .filter((f) => f.id($_item.lessonId!));
    final item = $_typedResult.readTableOrNull(_lessonIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$LearningObjectivesTableFilterComposer
    extends Composer<_$AppDatabase, $LearningObjectivesTable> {
  $$LearningObjectivesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bloomTaxonomyLevel => $composableBuilder(
      column: $table.bloomTaxonomyLevel,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnFilters(column));

  $$ChaptersTableFilterComposer get chapterId {
    final $$ChaptersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableFilterComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LessonsTableFilterComposer get lessonId {
    final $$LessonsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.lessonId,
        referencedTable: $db.lessons,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LessonsTableFilterComposer(
              $db: $db,
              $table: $db.lessons,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LearningObjectivesTableOrderingComposer
    extends Composer<_$AppDatabase, $LearningObjectivesTable> {
  $$LearningObjectivesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bloomTaxonomyLevel => $composableBuilder(
      column: $table.bloomTaxonomyLevel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnOrderings(column));

  $$ChaptersTableOrderingComposer get chapterId {
    final $$ChaptersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableOrderingComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LessonsTableOrderingComposer get lessonId {
    final $$LessonsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.lessonId,
        referencedTable: $db.lessons,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LessonsTableOrderingComposer(
              $db: $db,
              $table: $db.lessons,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LearningObjectivesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LearningObjectivesTable> {
  $$LearningObjectivesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get bloomTaxonomyLevel => $composableBuilder(
      column: $table.bloomTaxonomyLevel, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => column);

  $$ChaptersTableAnnotationComposer get chapterId {
    final $$ChaptersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableAnnotationComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LessonsTableAnnotationComposer get lessonId {
    final $$LessonsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.lessonId,
        referencedTable: $db.lessons,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LessonsTableAnnotationComposer(
              $db: $db,
              $table: $db.lessons,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LearningObjectivesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LearningObjectivesTable,
    LearningObjective,
    $$LearningObjectivesTableFilterComposer,
    $$LearningObjectivesTableOrderingComposer,
    $$LearningObjectivesTableAnnotationComposer,
    $$LearningObjectivesTableCreateCompanionBuilder,
    $$LearningObjectivesTableUpdateCompanionBuilder,
    (LearningObjective, $$LearningObjectivesTableReferences),
    LearningObjective,
    PrefetchHooks Function({bool chapterId, bool lessonId})> {
  $$LearningObjectivesTableTableManager(
      _$AppDatabase db, $LearningObjectivesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LearningObjectivesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LearningObjectivesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LearningObjectivesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> chapterId = const Value.absent(),
            Value<String?> lessonId = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> bloomTaxonomyLevel = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LearningObjectivesCompanion(
            id: id,
            chapterId: chapterId,
            lessonId: lessonId,
            description: description,
            bloomTaxonomyLevel: bloomTaxonomyLevel,
            orderIndex: orderIndex,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String chapterId,
            Value<String?> lessonId = const Value.absent(),
            required String description,
            required String bloomTaxonomyLevel,
            required int orderIndex,
            Value<int> rowid = const Value.absent(),
          }) =>
              LearningObjectivesCompanion.insert(
            id: id,
            chapterId: chapterId,
            lessonId: lessonId,
            description: description,
            bloomTaxonomyLevel: bloomTaxonomyLevel,
            orderIndex: orderIndex,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$LearningObjectivesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({chapterId = false, lessonId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (chapterId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.chapterId,
                    referencedTable:
                        $$LearningObjectivesTableReferences._chapterIdTable(db),
                    referencedColumn: $$LearningObjectivesTableReferences
                        ._chapterIdTable(db)
                        .id,
                  ) as T;
                }
                if (lessonId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.lessonId,
                    referencedTable:
                        $$LearningObjectivesTableReferences._lessonIdTable(db),
                    referencedColumn: $$LearningObjectivesTableReferences
                        ._lessonIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$LearningObjectivesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LearningObjectivesTable,
    LearningObjective,
    $$LearningObjectivesTableFilterComposer,
    $$LearningObjectivesTableOrderingComposer,
    $$LearningObjectivesTableAnnotationComposer,
    $$LearningObjectivesTableCreateCompanionBuilder,
    $$LearningObjectivesTableUpdateCompanionBuilder,
    (LearningObjective, $$LearningObjectivesTableReferences),
    LearningObjective,
    PrefetchHooks Function({bool chapterId, bool lessonId})>;
typedef $$CompetenciesTableCreateCompanionBuilder = CompetenciesCompanion
    Function({
  required String id,
  required String code,
  required String name,
  required String domain,
  Value<double> targetScore,
  required String description,
  Value<int> rowid,
});
typedef $$CompetenciesTableUpdateCompanionBuilder = CompetenciesCompanion
    Function({
  Value<String> id,
  Value<String> code,
  Value<String> name,
  Value<String> domain,
  Value<double> targetScore,
  Value<String> description,
  Value<int> rowid,
});

final class $$CompetenciesTableReferences
    extends BaseReferences<_$AppDatabase, $CompetenciesTable, Competency> {
  $$CompetenciesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ReviewSchedulesTable, List<ReviewSchedule>>
      _reviewSchedulesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.reviewSchedules,
              aliasName: $_aliasNameGenerator(
                  db.competencies.id, db.reviewSchedules.competencyId));

  $$ReviewSchedulesTableProcessedTableManager get reviewSchedulesRefs {
    final manager =
        $$ReviewSchedulesTableTableManager($_db, $_db.reviewSchedules)
            .filter((f) => f.competencyId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_reviewSchedulesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CompetenciesTableFilterComposer
    extends Composer<_$AppDatabase, $CompetenciesTable> {
  $$CompetenciesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get domain => $composableBuilder(
      column: $table.domain, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get targetScore => $composableBuilder(
      column: $table.targetScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  Expression<bool> reviewSchedulesRefs(
      Expression<bool> Function($$ReviewSchedulesTableFilterComposer f) f) {
    final $$ReviewSchedulesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.reviewSchedules,
        getReferencedColumn: (t) => t.competencyId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReviewSchedulesTableFilterComposer(
              $db: $db,
              $table: $db.reviewSchedules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CompetenciesTableOrderingComposer
    extends Composer<_$AppDatabase, $CompetenciesTable> {
  $$CompetenciesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get domain => $composableBuilder(
      column: $table.domain, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get targetScore => $composableBuilder(
      column: $table.targetScore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));
}

class $$CompetenciesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompetenciesTable> {
  $$CompetenciesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get domain =>
      $composableBuilder(column: $table.domain, builder: (column) => column);

  GeneratedColumn<double> get targetScore => $composableBuilder(
      column: $table.targetScore, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  Expression<T> reviewSchedulesRefs<T extends Object>(
      Expression<T> Function($$ReviewSchedulesTableAnnotationComposer a) f) {
    final $$ReviewSchedulesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.reviewSchedules,
        getReferencedColumn: (t) => t.competencyId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReviewSchedulesTableAnnotationComposer(
              $db: $db,
              $table: $db.reviewSchedules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CompetenciesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CompetenciesTable,
    Competency,
    $$CompetenciesTableFilterComposer,
    $$CompetenciesTableOrderingComposer,
    $$CompetenciesTableAnnotationComposer,
    $$CompetenciesTableCreateCompanionBuilder,
    $$CompetenciesTableUpdateCompanionBuilder,
    (Competency, $$CompetenciesTableReferences),
    Competency,
    PrefetchHooks Function({bool reviewSchedulesRefs})> {
  $$CompetenciesTableTableManager(_$AppDatabase db, $CompetenciesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompetenciesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompetenciesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompetenciesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> domain = const Value.absent(),
            Value<double> targetScore = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CompetenciesCompanion(
            id: id,
            code: code,
            name: name,
            domain: domain,
            targetScore: targetScore,
            description: description,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String code,
            required String name,
            required String domain,
            Value<double> targetScore = const Value.absent(),
            required String description,
            Value<int> rowid = const Value.absent(),
          }) =>
              CompetenciesCompanion.insert(
            id: id,
            code: code,
            name: name,
            domain: domain,
            targetScore: targetScore,
            description: description,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CompetenciesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({reviewSchedulesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (reviewSchedulesRefs) db.reviewSchedules
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (reviewSchedulesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$CompetenciesTableReferences
                            ._reviewSchedulesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CompetenciesTableReferences(db, table, p0)
                                .reviewSchedulesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.competencyId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CompetenciesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CompetenciesTable,
    Competency,
    $$CompetenciesTableFilterComposer,
    $$CompetenciesTableOrderingComposer,
    $$CompetenciesTableAnnotationComposer,
    $$CompetenciesTableCreateCompanionBuilder,
    $$CompetenciesTableUpdateCompanionBuilder,
    (Competency, $$CompetenciesTableReferences),
    Competency,
    PrefetchHooks Function({bool reviewSchedulesRefs})>;
typedef $$ExercisesTableCreateCompanionBuilder = ExercisesCompanion Function({
  required String id,
  required String chapterId,
  Value<String?> lessonId,
  required String exerciseType,
  required String problemPrompt,
  required String solvedSolution,
  required int orderIndex,
  Value<int> rowid,
});
typedef $$ExercisesTableUpdateCompanionBuilder = ExercisesCompanion Function({
  Value<String> id,
  Value<String> chapterId,
  Value<String?> lessonId,
  Value<String> exerciseType,
  Value<String> problemPrompt,
  Value<String> solvedSolution,
  Value<int> orderIndex,
  Value<int> rowid,
});

final class $$ExercisesTableReferences
    extends BaseReferences<_$AppDatabase, $ExercisesTable, Exercise> {
  $$ExercisesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ChaptersTable _chapterIdTable(_$AppDatabase db) =>
      db.chapters.createAlias(
          $_aliasNameGenerator(db.exercises.chapterId, db.chapters.id));

  $$ChaptersTableProcessedTableManager get chapterId {
    final manager = $$ChaptersTableTableManager($_db, $_db.chapters)
        .filter((f) => f.id($_item.chapterId));
    final item = $_typedResult.readTableOrNull(_chapterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $LessonsTable _lessonIdTable(_$AppDatabase db) => db.lessons
      .createAlias($_aliasNameGenerator(db.exercises.lessonId, db.lessons.id));

  $$LessonsTableProcessedTableManager? get lessonId {
    if ($_item.lessonId == null) return null;
    final manager = $$LessonsTableTableManager($_db, $_db.lessons)
        .filter((f) => f.id($_item.lessonId!));
    final item = $_typedResult.readTableOrNull(_lessonIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get exerciseType => $composableBuilder(
      column: $table.exerciseType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get problemPrompt => $composableBuilder(
      column: $table.problemPrompt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get solvedSolution => $composableBuilder(
      column: $table.solvedSolution,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnFilters(column));

  $$ChaptersTableFilterComposer get chapterId {
    final $$ChaptersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableFilterComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LessonsTableFilterComposer get lessonId {
    final $$LessonsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.lessonId,
        referencedTable: $db.lessons,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LessonsTableFilterComposer(
              $db: $db,
              $table: $db.lessons,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get exerciseType => $composableBuilder(
      column: $table.exerciseType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get problemPrompt => $composableBuilder(
      column: $table.problemPrompt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get solvedSolution => $composableBuilder(
      column: $table.solvedSolution,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnOrderings(column));

  $$ChaptersTableOrderingComposer get chapterId {
    final $$ChaptersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableOrderingComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LessonsTableOrderingComposer get lessonId {
    final $$LessonsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.lessonId,
        referencedTable: $db.lessons,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LessonsTableOrderingComposer(
              $db: $db,
              $table: $db.lessons,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get exerciseType => $composableBuilder(
      column: $table.exerciseType, builder: (column) => column);

  GeneratedColumn<String> get problemPrompt => $composableBuilder(
      column: $table.problemPrompt, builder: (column) => column);

  GeneratedColumn<String> get solvedSolution => $composableBuilder(
      column: $table.solvedSolution, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => column);

  $$ChaptersTableAnnotationComposer get chapterId {
    final $$ChaptersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableAnnotationComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$LessonsTableAnnotationComposer get lessonId {
    final $$LessonsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.lessonId,
        referencedTable: $db.lessons,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LessonsTableAnnotationComposer(
              $db: $db,
              $table: $db.lessons,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ExercisesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExercisesTable,
    Exercise,
    $$ExercisesTableFilterComposer,
    $$ExercisesTableOrderingComposer,
    $$ExercisesTableAnnotationComposer,
    $$ExercisesTableCreateCompanionBuilder,
    $$ExercisesTableUpdateCompanionBuilder,
    (Exercise, $$ExercisesTableReferences),
    Exercise,
    PrefetchHooks Function({bool chapterId, bool lessonId})> {
  $$ExercisesTableTableManager(_$AppDatabase db, $ExercisesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> chapterId = const Value.absent(),
            Value<String?> lessonId = const Value.absent(),
            Value<String> exerciseType = const Value.absent(),
            Value<String> problemPrompt = const Value.absent(),
            Value<String> solvedSolution = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExercisesCompanion(
            id: id,
            chapterId: chapterId,
            lessonId: lessonId,
            exerciseType: exerciseType,
            problemPrompt: problemPrompt,
            solvedSolution: solvedSolution,
            orderIndex: orderIndex,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String chapterId,
            Value<String?> lessonId = const Value.absent(),
            required String exerciseType,
            required String problemPrompt,
            required String solvedSolution,
            required int orderIndex,
            Value<int> rowid = const Value.absent(),
          }) =>
              ExercisesCompanion.insert(
            id: id,
            chapterId: chapterId,
            lessonId: lessonId,
            exerciseType: exerciseType,
            problemPrompt: problemPrompt,
            solvedSolution: solvedSolution,
            orderIndex: orderIndex,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ExercisesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({chapterId = false, lessonId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (chapterId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.chapterId,
                    referencedTable:
                        $$ExercisesTableReferences._chapterIdTable(db),
                    referencedColumn:
                        $$ExercisesTableReferences._chapterIdTable(db).id,
                  ) as T;
                }
                if (lessonId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.lessonId,
                    referencedTable:
                        $$ExercisesTableReferences._lessonIdTable(db),
                    referencedColumn:
                        $$ExercisesTableReferences._lessonIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ExercisesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ExercisesTable,
    Exercise,
    $$ExercisesTableFilterComposer,
    $$ExercisesTableOrderingComposer,
    $$ExercisesTableAnnotationComposer,
    $$ExercisesTableCreateCompanionBuilder,
    $$ExercisesTableUpdateCompanionBuilder,
    (Exercise, $$ExercisesTableReferences),
    Exercise,
    PrefetchHooks Function({bool chapterId, bool lessonId})>;
typedef $$AssessmentsTableCreateCompanionBuilder = AssessmentsCompanion
    Function({
  required String id,
  required String chapterId,
  required String title,
  Value<double> passingBenchmark,
  required String questionDataJson,
  required int totalQuestions,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$AssessmentsTableUpdateCompanionBuilder = AssessmentsCompanion
    Function({
  Value<String> id,
  Value<String> chapterId,
  Value<String> title,
  Value<double> passingBenchmark,
  Value<String> questionDataJson,
  Value<int> totalQuestions,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$AssessmentsTableReferences
    extends BaseReferences<_$AppDatabase, $AssessmentsTable, Assessment> {
  $$AssessmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ChaptersTable _chapterIdTable(_$AppDatabase db) =>
      db.chapters.createAlias(
          $_aliasNameGenerator(db.assessments.chapterId, db.chapters.id));

  $$ChaptersTableProcessedTableManager get chapterId {
    final manager = $$ChaptersTableTableManager($_db, $_db.chapters)
        .filter((f) => f.id($_item.chapterId));
    final item = $_typedResult.readTableOrNull(_chapterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$AssessmentAttemptsTable, List<AssessmentAttempt>>
      _assessmentAttemptsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.assessmentAttempts,
              aliasName: $_aliasNameGenerator(
                  db.assessments.id, db.assessmentAttempts.assessmentId));

  $$AssessmentAttemptsTableProcessedTableManager get assessmentAttemptsRefs {
    final manager =
        $$AssessmentAttemptsTableTableManager($_db, $_db.assessmentAttempts)
            .filter((f) => f.assessmentId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_assessmentAttemptsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$AssessmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AssessmentsTable> {
  $$AssessmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get passingBenchmark => $composableBuilder(
      column: $table.passingBenchmark,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get questionDataJson => $composableBuilder(
      column: $table.questionDataJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalQuestions => $composableBuilder(
      column: $table.totalQuestions,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$ChaptersTableFilterComposer get chapterId {
    final $$ChaptersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableFilterComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> assessmentAttemptsRefs(
      Expression<bool> Function($$AssessmentAttemptsTableFilterComposer f) f) {
    final $$AssessmentAttemptsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.assessmentAttempts,
        getReferencedColumn: (t) => t.assessmentId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AssessmentAttemptsTableFilterComposer(
              $db: $db,
              $table: $db.assessmentAttempts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AssessmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssessmentsTable> {
  $$AssessmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get passingBenchmark => $composableBuilder(
      column: $table.passingBenchmark,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get questionDataJson => $composableBuilder(
      column: $table.questionDataJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalQuestions => $composableBuilder(
      column: $table.totalQuestions,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$ChaptersTableOrderingComposer get chapterId {
    final $$ChaptersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableOrderingComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AssessmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssessmentsTable> {
  $$AssessmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<double> get passingBenchmark => $composableBuilder(
      column: $table.passingBenchmark, builder: (column) => column);

  GeneratedColumn<String> get questionDataJson => $composableBuilder(
      column: $table.questionDataJson, builder: (column) => column);

  GeneratedColumn<int> get totalQuestions => $composableBuilder(
      column: $table.totalQuestions, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ChaptersTableAnnotationComposer get chapterId {
    final $$ChaptersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableAnnotationComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> assessmentAttemptsRefs<T extends Object>(
      Expression<T> Function($$AssessmentAttemptsTableAnnotationComposer a) f) {
    final $$AssessmentAttemptsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.assessmentAttempts,
            getReferencedColumn: (t) => t.assessmentId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$AssessmentAttemptsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.assessmentAttempts,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$AssessmentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AssessmentsTable,
    Assessment,
    $$AssessmentsTableFilterComposer,
    $$AssessmentsTableOrderingComposer,
    $$AssessmentsTableAnnotationComposer,
    $$AssessmentsTableCreateCompanionBuilder,
    $$AssessmentsTableUpdateCompanionBuilder,
    (Assessment, $$AssessmentsTableReferences),
    Assessment,
    PrefetchHooks Function({bool chapterId, bool assessmentAttemptsRefs})> {
  $$AssessmentsTableTableManager(_$AppDatabase db, $AssessmentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssessmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssessmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssessmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> chapterId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<double> passingBenchmark = const Value.absent(),
            Value<String> questionDataJson = const Value.absent(),
            Value<int> totalQuestions = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AssessmentsCompanion(
            id: id,
            chapterId: chapterId,
            title: title,
            passingBenchmark: passingBenchmark,
            questionDataJson: questionDataJson,
            totalQuestions: totalQuestions,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String chapterId,
            required String title,
            Value<double> passingBenchmark = const Value.absent(),
            required String questionDataJson,
            required int totalQuestions,
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AssessmentsCompanion.insert(
            id: id,
            chapterId: chapterId,
            title: title,
            passingBenchmark: passingBenchmark,
            questionDataJson: questionDataJson,
            totalQuestions: totalQuestions,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$AssessmentsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {chapterId = false, assessmentAttemptsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (assessmentAttemptsRefs) db.assessmentAttempts
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (chapterId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.chapterId,
                    referencedTable:
                        $$AssessmentsTableReferences._chapterIdTable(db),
                    referencedColumn:
                        $$AssessmentsTableReferences._chapterIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (assessmentAttemptsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$AssessmentsTableReferences
                            ._assessmentAttemptsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AssessmentsTableReferences(db, table, p0)
                                .assessmentAttemptsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.assessmentId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$AssessmentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AssessmentsTable,
    Assessment,
    $$AssessmentsTableFilterComposer,
    $$AssessmentsTableOrderingComposer,
    $$AssessmentsTableAnnotationComposer,
    $$AssessmentsTableCreateCompanionBuilder,
    $$AssessmentsTableUpdateCompanionBuilder,
    (Assessment, $$AssessmentsTableReferences),
    Assessment,
    PrefetchHooks Function({bool chapterId, bool assessmentAttemptsRefs})>;
typedef $$AssessmentAttemptsTableCreateCompanionBuilder
    = AssessmentAttemptsCompanion Function({
  required String id,
  required String assessmentId,
  Value<DateTime> timestamp,
  required double score,
  required bool passed,
  required String responsesJson,
  Value<String?> discursiveFeedback,
  Value<int> durationSeconds,
  Value<int> rowid,
});
typedef $$AssessmentAttemptsTableUpdateCompanionBuilder
    = AssessmentAttemptsCompanion Function({
  Value<String> id,
  Value<String> assessmentId,
  Value<DateTime> timestamp,
  Value<double> score,
  Value<bool> passed,
  Value<String> responsesJson,
  Value<String?> discursiveFeedback,
  Value<int> durationSeconds,
  Value<int> rowid,
});

final class $$AssessmentAttemptsTableReferences extends BaseReferences<
    _$AppDatabase, $AssessmentAttemptsTable, AssessmentAttempt> {
  $$AssessmentAttemptsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $AssessmentsTable _assessmentIdTable(_$AppDatabase db) =>
      db.assessments.createAlias($_aliasNameGenerator(
          db.assessmentAttempts.assessmentId, db.assessments.id));

  $$AssessmentsTableProcessedTableManager get assessmentId {
    final manager = $$AssessmentsTableTableManager($_db, $_db.assessments)
        .filter((f) => f.id($_item.assessmentId));
    final item = $_typedResult.readTableOrNull(_assessmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$AssessmentAttemptsTableFilterComposer
    extends Composer<_$AppDatabase, $AssessmentAttemptsTable> {
  $$AssessmentAttemptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get score => $composableBuilder(
      column: $table.score, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get passed => $composableBuilder(
      column: $table.passed, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get responsesJson => $composableBuilder(
      column: $table.responsesJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get discursiveFeedback => $composableBuilder(
      column: $table.discursiveFeedback,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnFilters(column));

  $$AssessmentsTableFilterComposer get assessmentId {
    final $$AssessmentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.assessmentId,
        referencedTable: $db.assessments,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AssessmentsTableFilterComposer(
              $db: $db,
              $table: $db.assessments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AssessmentAttemptsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssessmentAttemptsTable> {
  $$AssessmentAttemptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get score => $composableBuilder(
      column: $table.score, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get passed => $composableBuilder(
      column: $table.passed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get responsesJson => $composableBuilder(
      column: $table.responsesJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get discursiveFeedback => $composableBuilder(
      column: $table.discursiveFeedback,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnOrderings(column));

  $$AssessmentsTableOrderingComposer get assessmentId {
    final $$AssessmentsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.assessmentId,
        referencedTable: $db.assessments,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AssessmentsTableOrderingComposer(
              $db: $db,
              $table: $db.assessments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AssessmentAttemptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssessmentAttemptsTable> {
  $$AssessmentAttemptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<double> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<bool> get passed =>
      $composableBuilder(column: $table.passed, builder: (column) => column);

  GeneratedColumn<String> get responsesJson => $composableBuilder(
      column: $table.responsesJson, builder: (column) => column);

  GeneratedColumn<String> get discursiveFeedback => $composableBuilder(
      column: $table.discursiveFeedback, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds, builder: (column) => column);

  $$AssessmentsTableAnnotationComposer get assessmentId {
    final $$AssessmentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.assessmentId,
        referencedTable: $db.assessments,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AssessmentsTableAnnotationComposer(
              $db: $db,
              $table: $db.assessments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AssessmentAttemptsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AssessmentAttemptsTable,
    AssessmentAttempt,
    $$AssessmentAttemptsTableFilterComposer,
    $$AssessmentAttemptsTableOrderingComposer,
    $$AssessmentAttemptsTableAnnotationComposer,
    $$AssessmentAttemptsTableCreateCompanionBuilder,
    $$AssessmentAttemptsTableUpdateCompanionBuilder,
    (AssessmentAttempt, $$AssessmentAttemptsTableReferences),
    AssessmentAttempt,
    PrefetchHooks Function({bool assessmentId})> {
  $$AssessmentAttemptsTableTableManager(
      _$AppDatabase db, $AssessmentAttemptsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssessmentAttemptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssessmentAttemptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssessmentAttemptsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> assessmentId = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<double> score = const Value.absent(),
            Value<bool> passed = const Value.absent(),
            Value<String> responsesJson = const Value.absent(),
            Value<String?> discursiveFeedback = const Value.absent(),
            Value<int> durationSeconds = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AssessmentAttemptsCompanion(
            id: id,
            assessmentId: assessmentId,
            timestamp: timestamp,
            score: score,
            passed: passed,
            responsesJson: responsesJson,
            discursiveFeedback: discursiveFeedback,
            durationSeconds: durationSeconds,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String assessmentId,
            Value<DateTime> timestamp = const Value.absent(),
            required double score,
            required bool passed,
            required String responsesJson,
            Value<String?> discursiveFeedback = const Value.absent(),
            Value<int> durationSeconds = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AssessmentAttemptsCompanion.insert(
            id: id,
            assessmentId: assessmentId,
            timestamp: timestamp,
            score: score,
            passed: passed,
            responsesJson: responsesJson,
            discursiveFeedback: discursiveFeedback,
            durationSeconds: durationSeconds,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$AssessmentAttemptsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({assessmentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (assessmentId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.assessmentId,
                    referencedTable: $$AssessmentAttemptsTableReferences
                        ._assessmentIdTable(db),
                    referencedColumn: $$AssessmentAttemptsTableReferences
                        ._assessmentIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$AssessmentAttemptsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AssessmentAttemptsTable,
    AssessmentAttempt,
    $$AssessmentAttemptsTableFilterComposer,
    $$AssessmentAttemptsTableOrderingComposer,
    $$AssessmentAttemptsTableAnnotationComposer,
    $$AssessmentAttemptsTableCreateCompanionBuilder,
    $$AssessmentAttemptsTableUpdateCompanionBuilder,
    (AssessmentAttempt, $$AssessmentAttemptsTableReferences),
    AssessmentAttempt,
    PrefetchHooks Function({bool assessmentId})>;
typedef $$LaboratoriesTableCreateCompanionBuilder = LaboratoriesCompanion
    Function({
  required String id,
  required String chapterId,
  required String domain,
  required String title,
  required String environmentType,
  Value<String?> initialDatasetPath,
  required String instructionsMarkdown,
  required String verificationRubricJson,
  Value<int> rowid,
});
typedef $$LaboratoriesTableUpdateCompanionBuilder = LaboratoriesCompanion
    Function({
  Value<String> id,
  Value<String> chapterId,
  Value<String> domain,
  Value<String> title,
  Value<String> environmentType,
  Value<String?> initialDatasetPath,
  Value<String> instructionsMarkdown,
  Value<String> verificationRubricJson,
  Value<int> rowid,
});

final class $$LaboratoriesTableReferences
    extends BaseReferences<_$AppDatabase, $LaboratoriesTable, Laboratory> {
  $$LaboratoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ChaptersTable _chapterIdTable(_$AppDatabase db) =>
      db.chapters.createAlias(
          $_aliasNameGenerator(db.laboratories.chapterId, db.chapters.id));

  $$ChaptersTableProcessedTableManager get chapterId {
    final manager = $$ChaptersTableTableManager($_db, $_db.chapters)
        .filter((f) => f.id($_item.chapterId));
    final item = $_typedResult.readTableOrNull(_chapterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$LaboratoryRunsTable, List<LaboratoryRun>>
      _laboratoryRunsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.laboratoryRuns,
              aliasName: $_aliasNameGenerator(
                  db.laboratories.id, db.laboratoryRuns.laboratoryId));

  $$LaboratoryRunsTableProcessedTableManager get laboratoryRunsRefs {
    final manager = $$LaboratoryRunsTableTableManager($_db, $_db.laboratoryRuns)
        .filter((f) => f.laboratoryId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_laboratoryRunsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$LaboratoriesTableFilterComposer
    extends Composer<_$AppDatabase, $LaboratoriesTable> {
  $$LaboratoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get domain => $composableBuilder(
      column: $table.domain, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get environmentType => $composableBuilder(
      column: $table.environmentType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get initialDatasetPath => $composableBuilder(
      column: $table.initialDatasetPath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get instructionsMarkdown => $composableBuilder(
      column: $table.instructionsMarkdown,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get verificationRubricJson => $composableBuilder(
      column: $table.verificationRubricJson,
      builder: (column) => ColumnFilters(column));

  $$ChaptersTableFilterComposer get chapterId {
    final $$ChaptersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableFilterComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> laboratoryRunsRefs(
      Expression<bool> Function($$LaboratoryRunsTableFilterComposer f) f) {
    final $$LaboratoryRunsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.laboratoryRuns,
        getReferencedColumn: (t) => t.laboratoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LaboratoryRunsTableFilterComposer(
              $db: $db,
              $table: $db.laboratoryRuns,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$LaboratoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LaboratoriesTable> {
  $$LaboratoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get domain => $composableBuilder(
      column: $table.domain, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get environmentType => $composableBuilder(
      column: $table.environmentType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get initialDatasetPath => $composableBuilder(
      column: $table.initialDatasetPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get instructionsMarkdown => $composableBuilder(
      column: $table.instructionsMarkdown,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get verificationRubricJson => $composableBuilder(
      column: $table.verificationRubricJson,
      builder: (column) => ColumnOrderings(column));

  $$ChaptersTableOrderingComposer get chapterId {
    final $$ChaptersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableOrderingComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LaboratoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LaboratoriesTable> {
  $$LaboratoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get domain =>
      $composableBuilder(column: $table.domain, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get environmentType => $composableBuilder(
      column: $table.environmentType, builder: (column) => column);

  GeneratedColumn<String> get initialDatasetPath => $composableBuilder(
      column: $table.initialDatasetPath, builder: (column) => column);

  GeneratedColumn<String> get instructionsMarkdown => $composableBuilder(
      column: $table.instructionsMarkdown, builder: (column) => column);

  GeneratedColumn<String> get verificationRubricJson => $composableBuilder(
      column: $table.verificationRubricJson, builder: (column) => column);

  $$ChaptersTableAnnotationComposer get chapterId {
    final $$ChaptersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableAnnotationComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> laboratoryRunsRefs<T extends Object>(
      Expression<T> Function($$LaboratoryRunsTableAnnotationComposer a) f) {
    final $$LaboratoryRunsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.laboratoryRuns,
        getReferencedColumn: (t) => t.laboratoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LaboratoryRunsTableAnnotationComposer(
              $db: $db,
              $table: $db.laboratoryRuns,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$LaboratoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LaboratoriesTable,
    Laboratory,
    $$LaboratoriesTableFilterComposer,
    $$LaboratoriesTableOrderingComposer,
    $$LaboratoriesTableAnnotationComposer,
    $$LaboratoriesTableCreateCompanionBuilder,
    $$LaboratoriesTableUpdateCompanionBuilder,
    (Laboratory, $$LaboratoriesTableReferences),
    Laboratory,
    PrefetchHooks Function({bool chapterId, bool laboratoryRunsRefs})> {
  $$LaboratoriesTableTableManager(_$AppDatabase db, $LaboratoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LaboratoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LaboratoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LaboratoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> chapterId = const Value.absent(),
            Value<String> domain = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> environmentType = const Value.absent(),
            Value<String?> initialDatasetPath = const Value.absent(),
            Value<String> instructionsMarkdown = const Value.absent(),
            Value<String> verificationRubricJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LaboratoriesCompanion(
            id: id,
            chapterId: chapterId,
            domain: domain,
            title: title,
            environmentType: environmentType,
            initialDatasetPath: initialDatasetPath,
            instructionsMarkdown: instructionsMarkdown,
            verificationRubricJson: verificationRubricJson,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String chapterId,
            required String domain,
            required String title,
            required String environmentType,
            Value<String?> initialDatasetPath = const Value.absent(),
            required String instructionsMarkdown,
            required String verificationRubricJson,
            Value<int> rowid = const Value.absent(),
          }) =>
              LaboratoriesCompanion.insert(
            id: id,
            chapterId: chapterId,
            domain: domain,
            title: title,
            environmentType: environmentType,
            initialDatasetPath: initialDatasetPath,
            instructionsMarkdown: instructionsMarkdown,
            verificationRubricJson: verificationRubricJson,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$LaboratoriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {chapterId = false, laboratoryRunsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (laboratoryRunsRefs) db.laboratoryRuns
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (chapterId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.chapterId,
                    referencedTable:
                        $$LaboratoriesTableReferences._chapterIdTable(db),
                    referencedColumn:
                        $$LaboratoriesTableReferences._chapterIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (laboratoryRunsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$LaboratoriesTableReferences
                            ._laboratoryRunsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$LaboratoriesTableReferences(db, table, p0)
                                .laboratoryRunsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.laboratoryId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$LaboratoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LaboratoriesTable,
    Laboratory,
    $$LaboratoriesTableFilterComposer,
    $$LaboratoriesTableOrderingComposer,
    $$LaboratoriesTableAnnotationComposer,
    $$LaboratoriesTableCreateCompanionBuilder,
    $$LaboratoriesTableUpdateCompanionBuilder,
    (Laboratory, $$LaboratoriesTableReferences),
    Laboratory,
    PrefetchHooks Function({bool chapterId, bool laboratoryRunsRefs})>;
typedef $$LaboratoryRunsTableCreateCompanionBuilder = LaboratoryRunsCompanion
    Function({
  required String id,
  required String laboratoryId,
  Value<DateTime> executedAt,
  required String commandsExecutedJson,
  Value<String?> outputArtifactPath,
  required bool isPassed,
  Value<String?> metricsJson,
  Value<int> rowid,
});
typedef $$LaboratoryRunsTableUpdateCompanionBuilder = LaboratoryRunsCompanion
    Function({
  Value<String> id,
  Value<String> laboratoryId,
  Value<DateTime> executedAt,
  Value<String> commandsExecutedJson,
  Value<String?> outputArtifactPath,
  Value<bool> isPassed,
  Value<String?> metricsJson,
  Value<int> rowid,
});

final class $$LaboratoryRunsTableReferences
    extends BaseReferences<_$AppDatabase, $LaboratoryRunsTable, LaboratoryRun> {
  $$LaboratoryRunsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $LaboratoriesTable _laboratoryIdTable(_$AppDatabase db) =>
      db.laboratories.createAlias($_aliasNameGenerator(
          db.laboratoryRuns.laboratoryId, db.laboratories.id));

  $$LaboratoriesTableProcessedTableManager get laboratoryId {
    final manager = $$LaboratoriesTableTableManager($_db, $_db.laboratories)
        .filter((f) => f.id($_item.laboratoryId));
    final item = $_typedResult.readTableOrNull(_laboratoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$LaboratoryRunsTableFilterComposer
    extends Composer<_$AppDatabase, $LaboratoryRunsTable> {
  $$LaboratoryRunsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get executedAt => $composableBuilder(
      column: $table.executedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get commandsExecutedJson => $composableBuilder(
      column: $table.commandsExecutedJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get outputArtifactPath => $composableBuilder(
      column: $table.outputArtifactPath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPassed => $composableBuilder(
      column: $table.isPassed, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metricsJson => $composableBuilder(
      column: $table.metricsJson, builder: (column) => ColumnFilters(column));

  $$LaboratoriesTableFilterComposer get laboratoryId {
    final $$LaboratoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.laboratoryId,
        referencedTable: $db.laboratories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LaboratoriesTableFilterComposer(
              $db: $db,
              $table: $db.laboratories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LaboratoryRunsTableOrderingComposer
    extends Composer<_$AppDatabase, $LaboratoryRunsTable> {
  $$LaboratoryRunsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get executedAt => $composableBuilder(
      column: $table.executedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get commandsExecutedJson => $composableBuilder(
      column: $table.commandsExecutedJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get outputArtifactPath => $composableBuilder(
      column: $table.outputArtifactPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPassed => $composableBuilder(
      column: $table.isPassed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metricsJson => $composableBuilder(
      column: $table.metricsJson, builder: (column) => ColumnOrderings(column));

  $$LaboratoriesTableOrderingComposer get laboratoryId {
    final $$LaboratoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.laboratoryId,
        referencedTable: $db.laboratories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LaboratoriesTableOrderingComposer(
              $db: $db,
              $table: $db.laboratories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LaboratoryRunsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LaboratoryRunsTable> {
  $$LaboratoryRunsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get executedAt => $composableBuilder(
      column: $table.executedAt, builder: (column) => column);

  GeneratedColumn<String> get commandsExecutedJson => $composableBuilder(
      column: $table.commandsExecutedJson, builder: (column) => column);

  GeneratedColumn<String> get outputArtifactPath => $composableBuilder(
      column: $table.outputArtifactPath, builder: (column) => column);

  GeneratedColumn<bool> get isPassed =>
      $composableBuilder(column: $table.isPassed, builder: (column) => column);

  GeneratedColumn<String> get metricsJson => $composableBuilder(
      column: $table.metricsJson, builder: (column) => column);

  $$LaboratoriesTableAnnotationComposer get laboratoryId {
    final $$LaboratoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.laboratoryId,
        referencedTable: $db.laboratories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LaboratoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.laboratories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LaboratoryRunsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LaboratoryRunsTable,
    LaboratoryRun,
    $$LaboratoryRunsTableFilterComposer,
    $$LaboratoryRunsTableOrderingComposer,
    $$LaboratoryRunsTableAnnotationComposer,
    $$LaboratoryRunsTableCreateCompanionBuilder,
    $$LaboratoryRunsTableUpdateCompanionBuilder,
    (LaboratoryRun, $$LaboratoryRunsTableReferences),
    LaboratoryRun,
    PrefetchHooks Function({bool laboratoryId})> {
  $$LaboratoryRunsTableTableManager(
      _$AppDatabase db, $LaboratoryRunsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LaboratoryRunsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LaboratoryRunsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LaboratoryRunsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> laboratoryId = const Value.absent(),
            Value<DateTime> executedAt = const Value.absent(),
            Value<String> commandsExecutedJson = const Value.absent(),
            Value<String?> outputArtifactPath = const Value.absent(),
            Value<bool> isPassed = const Value.absent(),
            Value<String?> metricsJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LaboratoryRunsCompanion(
            id: id,
            laboratoryId: laboratoryId,
            executedAt: executedAt,
            commandsExecutedJson: commandsExecutedJson,
            outputArtifactPath: outputArtifactPath,
            isPassed: isPassed,
            metricsJson: metricsJson,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String laboratoryId,
            Value<DateTime> executedAt = const Value.absent(),
            required String commandsExecutedJson,
            Value<String?> outputArtifactPath = const Value.absent(),
            required bool isPassed,
            Value<String?> metricsJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LaboratoryRunsCompanion.insert(
            id: id,
            laboratoryId: laboratoryId,
            executedAt: executedAt,
            commandsExecutedJson: commandsExecutedJson,
            outputArtifactPath: outputArtifactPath,
            isPassed: isPassed,
            metricsJson: metricsJson,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$LaboratoryRunsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({laboratoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (laboratoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.laboratoryId,
                    referencedTable:
                        $$LaboratoryRunsTableReferences._laboratoryIdTable(db),
                    referencedColumn: $$LaboratoryRunsTableReferences
                        ._laboratoryIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$LaboratoryRunsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LaboratoryRunsTable,
    LaboratoryRun,
    $$LaboratoryRunsTableFilterComposer,
    $$LaboratoryRunsTableOrderingComposer,
    $$LaboratoryRunsTableAnnotationComposer,
    $$LaboratoryRunsTableCreateCompanionBuilder,
    $$LaboratoryRunsTableUpdateCompanionBuilder,
    (LaboratoryRun, $$LaboratoryRunsTableReferences),
    LaboratoryRun,
    PrefetchHooks Function({bool laboratoryId})>;
typedef $$CaseStudiesTableCreateCompanionBuilder = CaseStudiesCompanion
    Function({
  required String id,
  required String chapterId,
  required String caseTitle,
  required String incidentSummary,
  required String documentedFactsJson,
  required String investigativeInferencesJson,
  required String alternativeHypothesesJson,
  required String evidentialMatrixJson,
  Value<int> rowid,
});
typedef $$CaseStudiesTableUpdateCompanionBuilder = CaseStudiesCompanion
    Function({
  Value<String> id,
  Value<String> chapterId,
  Value<String> caseTitle,
  Value<String> incidentSummary,
  Value<String> documentedFactsJson,
  Value<String> investigativeInferencesJson,
  Value<String> alternativeHypothesesJson,
  Value<String> evidentialMatrixJson,
  Value<int> rowid,
});

final class $$CaseStudiesTableReferences
    extends BaseReferences<_$AppDatabase, $CaseStudiesTable, CaseStudy> {
  $$CaseStudiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ChaptersTable _chapterIdTable(_$AppDatabase db) =>
      db.chapters.createAlias(
          $_aliasNameGenerator(db.caseStudies.chapterId, db.chapters.id));

  $$ChaptersTableProcessedTableManager get chapterId {
    final manager = $$ChaptersTableTableManager($_db, $_db.chapters)
        .filter((f) => f.id($_item.chapterId));
    final item = $_typedResult.readTableOrNull(_chapterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$CaseSubmissionsTable, List<CaseSubmission>>
      _caseSubmissionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.caseSubmissions,
              aliasName: $_aliasNameGenerator(
                  db.caseStudies.id, db.caseSubmissions.caseStudyId));

  $$CaseSubmissionsTableProcessedTableManager get caseSubmissionsRefs {
    final manager =
        $$CaseSubmissionsTableTableManager($_db, $_db.caseSubmissions)
            .filter((f) => f.caseStudyId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_caseSubmissionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CaseStudiesTableFilterComposer
    extends Composer<_$AppDatabase, $CaseStudiesTable> {
  $$CaseStudiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get caseTitle => $composableBuilder(
      column: $table.caseTitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get incidentSummary => $composableBuilder(
      column: $table.incidentSummary,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get documentedFactsJson => $composableBuilder(
      column: $table.documentedFactsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get investigativeInferencesJson => $composableBuilder(
      column: $table.investigativeInferencesJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get alternativeHypothesesJson => $composableBuilder(
      column: $table.alternativeHypothesesJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get evidentialMatrixJson => $composableBuilder(
      column: $table.evidentialMatrixJson,
      builder: (column) => ColumnFilters(column));

  $$ChaptersTableFilterComposer get chapterId {
    final $$ChaptersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableFilterComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> caseSubmissionsRefs(
      Expression<bool> Function($$CaseSubmissionsTableFilterComposer f) f) {
    final $$CaseSubmissionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.caseSubmissions,
        getReferencedColumn: (t) => t.caseStudyId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CaseSubmissionsTableFilterComposer(
              $db: $db,
              $table: $db.caseSubmissions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CaseStudiesTableOrderingComposer
    extends Composer<_$AppDatabase, $CaseStudiesTable> {
  $$CaseStudiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get caseTitle => $composableBuilder(
      column: $table.caseTitle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get incidentSummary => $composableBuilder(
      column: $table.incidentSummary,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get documentedFactsJson => $composableBuilder(
      column: $table.documentedFactsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get investigativeInferencesJson => $composableBuilder(
      column: $table.investigativeInferencesJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get alternativeHypothesesJson => $composableBuilder(
      column: $table.alternativeHypothesesJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get evidentialMatrixJson => $composableBuilder(
      column: $table.evidentialMatrixJson,
      builder: (column) => ColumnOrderings(column));

  $$ChaptersTableOrderingComposer get chapterId {
    final $$ChaptersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableOrderingComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CaseStudiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CaseStudiesTable> {
  $$CaseStudiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get caseTitle =>
      $composableBuilder(column: $table.caseTitle, builder: (column) => column);

  GeneratedColumn<String> get incidentSummary => $composableBuilder(
      column: $table.incidentSummary, builder: (column) => column);

  GeneratedColumn<String> get documentedFactsJson => $composableBuilder(
      column: $table.documentedFactsJson, builder: (column) => column);

  GeneratedColumn<String> get investigativeInferencesJson => $composableBuilder(
      column: $table.investigativeInferencesJson, builder: (column) => column);

  GeneratedColumn<String> get alternativeHypothesesJson => $composableBuilder(
      column: $table.alternativeHypothesesJson, builder: (column) => column);

  GeneratedColumn<String> get evidentialMatrixJson => $composableBuilder(
      column: $table.evidentialMatrixJson, builder: (column) => column);

  $$ChaptersTableAnnotationComposer get chapterId {
    final $$ChaptersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableAnnotationComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> caseSubmissionsRefs<T extends Object>(
      Expression<T> Function($$CaseSubmissionsTableAnnotationComposer a) f) {
    final $$CaseSubmissionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.caseSubmissions,
        getReferencedColumn: (t) => t.caseStudyId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CaseSubmissionsTableAnnotationComposer(
              $db: $db,
              $table: $db.caseSubmissions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CaseStudiesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CaseStudiesTable,
    CaseStudy,
    $$CaseStudiesTableFilterComposer,
    $$CaseStudiesTableOrderingComposer,
    $$CaseStudiesTableAnnotationComposer,
    $$CaseStudiesTableCreateCompanionBuilder,
    $$CaseStudiesTableUpdateCompanionBuilder,
    (CaseStudy, $$CaseStudiesTableReferences),
    CaseStudy,
    PrefetchHooks Function({bool chapterId, bool caseSubmissionsRefs})> {
  $$CaseStudiesTableTableManager(_$AppDatabase db, $CaseStudiesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CaseStudiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CaseStudiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CaseStudiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> chapterId = const Value.absent(),
            Value<String> caseTitle = const Value.absent(),
            Value<String> incidentSummary = const Value.absent(),
            Value<String> documentedFactsJson = const Value.absent(),
            Value<String> investigativeInferencesJson = const Value.absent(),
            Value<String> alternativeHypothesesJson = const Value.absent(),
            Value<String> evidentialMatrixJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CaseStudiesCompanion(
            id: id,
            chapterId: chapterId,
            caseTitle: caseTitle,
            incidentSummary: incidentSummary,
            documentedFactsJson: documentedFactsJson,
            investigativeInferencesJson: investigativeInferencesJson,
            alternativeHypothesesJson: alternativeHypothesesJson,
            evidentialMatrixJson: evidentialMatrixJson,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String chapterId,
            required String caseTitle,
            required String incidentSummary,
            required String documentedFactsJson,
            required String investigativeInferencesJson,
            required String alternativeHypothesesJson,
            required String evidentialMatrixJson,
            Value<int> rowid = const Value.absent(),
          }) =>
              CaseStudiesCompanion.insert(
            id: id,
            chapterId: chapterId,
            caseTitle: caseTitle,
            incidentSummary: incidentSummary,
            documentedFactsJson: documentedFactsJson,
            investigativeInferencesJson: investigativeInferencesJson,
            alternativeHypothesesJson: alternativeHypothesesJson,
            evidentialMatrixJson: evidentialMatrixJson,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CaseStudiesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {chapterId = false, caseSubmissionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (caseSubmissionsRefs) db.caseSubmissions
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (chapterId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.chapterId,
                    referencedTable:
                        $$CaseStudiesTableReferences._chapterIdTable(db),
                    referencedColumn:
                        $$CaseStudiesTableReferences._chapterIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (caseSubmissionsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$CaseStudiesTableReferences
                            ._caseSubmissionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CaseStudiesTableReferences(db, table, p0)
                                .caseSubmissionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.caseStudyId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CaseStudiesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CaseStudiesTable,
    CaseStudy,
    $$CaseStudiesTableFilterComposer,
    $$CaseStudiesTableOrderingComposer,
    $$CaseStudiesTableAnnotationComposer,
    $$CaseStudiesTableCreateCompanionBuilder,
    $$CaseStudiesTableUpdateCompanionBuilder,
    (CaseStudy, $$CaseStudiesTableReferences),
    CaseStudy,
    PrefetchHooks Function({bool chapterId, bool caseSubmissionsRefs})>;
typedef $$CaseSubmissionsTableCreateCompanionBuilder = CaseSubmissionsCompanion
    Function({
  required String id,
  required String caseStudyId,
  Value<DateTime> submittedAt,
  Value<String?> reportPdfPath,
  required String conclusionText,
  required String hypothesisEvaluationJson,
  Value<String?> tutorEvaluationJson,
  Value<int> rowid,
});
typedef $$CaseSubmissionsTableUpdateCompanionBuilder = CaseSubmissionsCompanion
    Function({
  Value<String> id,
  Value<String> caseStudyId,
  Value<DateTime> submittedAt,
  Value<String?> reportPdfPath,
  Value<String> conclusionText,
  Value<String> hypothesisEvaluationJson,
  Value<String?> tutorEvaluationJson,
  Value<int> rowid,
});

final class $$CaseSubmissionsTableReferences extends BaseReferences<
    _$AppDatabase, $CaseSubmissionsTable, CaseSubmission> {
  $$CaseSubmissionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $CaseStudiesTable _caseStudyIdTable(_$AppDatabase db) =>
      db.caseStudies.createAlias($_aliasNameGenerator(
          db.caseSubmissions.caseStudyId, db.caseStudies.id));

  $$CaseStudiesTableProcessedTableManager get caseStudyId {
    final manager = $$CaseStudiesTableTableManager($_db, $_db.caseStudies)
        .filter((f) => f.id($_item.caseStudyId));
    final item = $_typedResult.readTableOrNull(_caseStudyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$CaseSubmissionsTableFilterComposer
    extends Composer<_$AppDatabase, $CaseSubmissionsTable> {
  $$CaseSubmissionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get submittedAt => $composableBuilder(
      column: $table.submittedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reportPdfPath => $composableBuilder(
      column: $table.reportPdfPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get conclusionText => $composableBuilder(
      column: $table.conclusionText,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hypothesisEvaluationJson => $composableBuilder(
      column: $table.hypothesisEvaluationJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tutorEvaluationJson => $composableBuilder(
      column: $table.tutorEvaluationJson,
      builder: (column) => ColumnFilters(column));

  $$CaseStudiesTableFilterComposer get caseStudyId {
    final $$CaseStudiesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.caseStudyId,
        referencedTable: $db.caseStudies,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CaseStudiesTableFilterComposer(
              $db: $db,
              $table: $db.caseStudies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CaseSubmissionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CaseSubmissionsTable> {
  $$CaseSubmissionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get submittedAt => $composableBuilder(
      column: $table.submittedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reportPdfPath => $composableBuilder(
      column: $table.reportPdfPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get conclusionText => $composableBuilder(
      column: $table.conclusionText,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hypothesisEvaluationJson => $composableBuilder(
      column: $table.hypothesisEvaluationJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tutorEvaluationJson => $composableBuilder(
      column: $table.tutorEvaluationJson,
      builder: (column) => ColumnOrderings(column));

  $$CaseStudiesTableOrderingComposer get caseStudyId {
    final $$CaseStudiesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.caseStudyId,
        referencedTable: $db.caseStudies,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CaseStudiesTableOrderingComposer(
              $db: $db,
              $table: $db.caseStudies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CaseSubmissionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CaseSubmissionsTable> {
  $$CaseSubmissionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get submittedAt => $composableBuilder(
      column: $table.submittedAt, builder: (column) => column);

  GeneratedColumn<String> get reportPdfPath => $composableBuilder(
      column: $table.reportPdfPath, builder: (column) => column);

  GeneratedColumn<String> get conclusionText => $composableBuilder(
      column: $table.conclusionText, builder: (column) => column);

  GeneratedColumn<String> get hypothesisEvaluationJson => $composableBuilder(
      column: $table.hypothesisEvaluationJson, builder: (column) => column);

  GeneratedColumn<String> get tutorEvaluationJson => $composableBuilder(
      column: $table.tutorEvaluationJson, builder: (column) => column);

  $$CaseStudiesTableAnnotationComposer get caseStudyId {
    final $$CaseStudiesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.caseStudyId,
        referencedTable: $db.caseStudies,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CaseStudiesTableAnnotationComposer(
              $db: $db,
              $table: $db.caseStudies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CaseSubmissionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CaseSubmissionsTable,
    CaseSubmission,
    $$CaseSubmissionsTableFilterComposer,
    $$CaseSubmissionsTableOrderingComposer,
    $$CaseSubmissionsTableAnnotationComposer,
    $$CaseSubmissionsTableCreateCompanionBuilder,
    $$CaseSubmissionsTableUpdateCompanionBuilder,
    (CaseSubmission, $$CaseSubmissionsTableReferences),
    CaseSubmission,
    PrefetchHooks Function({bool caseStudyId})> {
  $$CaseSubmissionsTableTableManager(
      _$AppDatabase db, $CaseSubmissionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CaseSubmissionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CaseSubmissionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CaseSubmissionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> caseStudyId = const Value.absent(),
            Value<DateTime> submittedAt = const Value.absent(),
            Value<String?> reportPdfPath = const Value.absent(),
            Value<String> conclusionText = const Value.absent(),
            Value<String> hypothesisEvaluationJson = const Value.absent(),
            Value<String?> tutorEvaluationJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CaseSubmissionsCompanion(
            id: id,
            caseStudyId: caseStudyId,
            submittedAt: submittedAt,
            reportPdfPath: reportPdfPath,
            conclusionText: conclusionText,
            hypothesisEvaluationJson: hypothesisEvaluationJson,
            tutorEvaluationJson: tutorEvaluationJson,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String caseStudyId,
            Value<DateTime> submittedAt = const Value.absent(),
            Value<String?> reportPdfPath = const Value.absent(),
            required String conclusionText,
            required String hypothesisEvaluationJson,
            Value<String?> tutorEvaluationJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CaseSubmissionsCompanion.insert(
            id: id,
            caseStudyId: caseStudyId,
            submittedAt: submittedAt,
            reportPdfPath: reportPdfPath,
            conclusionText: conclusionText,
            hypothesisEvaluationJson: hypothesisEvaluationJson,
            tutorEvaluationJson: tutorEvaluationJson,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CaseSubmissionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({caseStudyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (caseStudyId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.caseStudyId,
                    referencedTable:
                        $$CaseSubmissionsTableReferences._caseStudyIdTable(db),
                    referencedColumn: $$CaseSubmissionsTableReferences
                        ._caseStudyIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$CaseSubmissionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CaseSubmissionsTable,
    CaseSubmission,
    $$CaseSubmissionsTableFilterComposer,
    $$CaseSubmissionsTableOrderingComposer,
    $$CaseSubmissionsTableAnnotationComposer,
    $$CaseSubmissionsTableCreateCompanionBuilder,
    $$CaseSubmissionsTableUpdateCompanionBuilder,
    (CaseSubmission, $$CaseSubmissionsTableReferences),
    CaseSubmission,
    PrefetchHooks Function({bool caseStudyId})>;
typedef $$StudySessionsTableCreateCompanionBuilder = StudySessionsCompanion
    Function({
  required String id,
  required String chapterId,
  Value<DateTime> startTime,
  Value<DateTime?> endTime,
  Value<int> durationSeconds,
  Value<int> pagesRead,
  Value<int> notesCount,
  Value<int> rowid,
});
typedef $$StudySessionsTableUpdateCompanionBuilder = StudySessionsCompanion
    Function({
  Value<String> id,
  Value<String> chapterId,
  Value<DateTime> startTime,
  Value<DateTime?> endTime,
  Value<int> durationSeconds,
  Value<int> pagesRead,
  Value<int> notesCount,
  Value<int> rowid,
});

final class $$StudySessionsTableReferences
    extends BaseReferences<_$AppDatabase, $StudySessionsTable, StudySession> {
  $$StudySessionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ChaptersTable _chapterIdTable(_$AppDatabase db) =>
      db.chapters.createAlias(
          $_aliasNameGenerator(db.studySessions.chapterId, db.chapters.id));

  $$ChaptersTableProcessedTableManager get chapterId {
    final manager = $$ChaptersTableTableManager($_db, $_db.chapters)
        .filter((f) => f.id($_item.chapterId));
    final item = $_typedResult.readTableOrNull(_chapterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$StudySessionsTableFilterComposer
    extends Composer<_$AppDatabase, $StudySessionsTable> {
  $$StudySessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pagesRead => $composableBuilder(
      column: $table.pagesRead, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get notesCount => $composableBuilder(
      column: $table.notesCount, builder: (column) => ColumnFilters(column));

  $$ChaptersTableFilterComposer get chapterId {
    final $$ChaptersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableFilterComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StudySessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $StudySessionsTable> {
  $$StudySessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pagesRead => $composableBuilder(
      column: $table.pagesRead, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get notesCount => $composableBuilder(
      column: $table.notesCount, builder: (column) => ColumnOrderings(column));

  $$ChaptersTableOrderingComposer get chapterId {
    final $$ChaptersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableOrderingComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StudySessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudySessionsTable> {
  $$StudySessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds, builder: (column) => column);

  GeneratedColumn<int> get pagesRead =>
      $composableBuilder(column: $table.pagesRead, builder: (column) => column);

  GeneratedColumn<int> get notesCount => $composableBuilder(
      column: $table.notesCount, builder: (column) => column);

  $$ChaptersTableAnnotationComposer get chapterId {
    final $$ChaptersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableAnnotationComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StudySessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StudySessionsTable,
    StudySession,
    $$StudySessionsTableFilterComposer,
    $$StudySessionsTableOrderingComposer,
    $$StudySessionsTableAnnotationComposer,
    $$StudySessionsTableCreateCompanionBuilder,
    $$StudySessionsTableUpdateCompanionBuilder,
    (StudySession, $$StudySessionsTableReferences),
    StudySession,
    PrefetchHooks Function({bool chapterId})> {
  $$StudySessionsTableTableManager(_$AppDatabase db, $StudySessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudySessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudySessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudySessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> chapterId = const Value.absent(),
            Value<DateTime> startTime = const Value.absent(),
            Value<DateTime?> endTime = const Value.absent(),
            Value<int> durationSeconds = const Value.absent(),
            Value<int> pagesRead = const Value.absent(),
            Value<int> notesCount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StudySessionsCompanion(
            id: id,
            chapterId: chapterId,
            startTime: startTime,
            endTime: endTime,
            durationSeconds: durationSeconds,
            pagesRead: pagesRead,
            notesCount: notesCount,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String chapterId,
            Value<DateTime> startTime = const Value.absent(),
            Value<DateTime?> endTime = const Value.absent(),
            Value<int> durationSeconds = const Value.absent(),
            Value<int> pagesRead = const Value.absent(),
            Value<int> notesCount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StudySessionsCompanion.insert(
            id: id,
            chapterId: chapterId,
            startTime: startTime,
            endTime: endTime,
            durationSeconds: durationSeconds,
            pagesRead: pagesRead,
            notesCount: notesCount,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$StudySessionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({chapterId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (chapterId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.chapterId,
                    referencedTable:
                        $$StudySessionsTableReferences._chapterIdTable(db),
                    referencedColumn:
                        $$StudySessionsTableReferences._chapterIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$StudySessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StudySessionsTable,
    StudySession,
    $$StudySessionsTableFilterComposer,
    $$StudySessionsTableOrderingComposer,
    $$StudySessionsTableAnnotationComposer,
    $$StudySessionsTableCreateCompanionBuilder,
    $$StudySessionsTableUpdateCompanionBuilder,
    (StudySession, $$StudySessionsTableReferences),
    StudySession,
    PrefetchHooks Function({bool chapterId})>;
typedef $$ReadingPositionsTableCreateCompanionBuilder
    = ReadingPositionsCompanion Function({
  required String chapterId,
  Value<int> pageNumber,
  Value<double> scrollRatio,
  Value<int> lastParagraphIndex,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$ReadingPositionsTableUpdateCompanionBuilder
    = ReadingPositionsCompanion Function({
  Value<String> chapterId,
  Value<int> pageNumber,
  Value<double> scrollRatio,
  Value<int> lastParagraphIndex,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$ReadingPositionsTableReferences extends BaseReferences<
    _$AppDatabase, $ReadingPositionsTable, ReadingPosition> {
  $$ReadingPositionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ChaptersTable _chapterIdTable(_$AppDatabase db) =>
      db.chapters.createAlias(
          $_aliasNameGenerator(db.readingPositions.chapterId, db.chapters.id));

  $$ChaptersTableProcessedTableManager get chapterId {
    final manager = $$ChaptersTableTableManager($_db, $_db.chapters)
        .filter((f) => f.id($_item.chapterId));
    final item = $_typedResult.readTableOrNull(_chapterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ReadingPositionsTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingPositionsTable> {
  $$ReadingPositionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get pageNumber => $composableBuilder(
      column: $table.pageNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get scrollRatio => $composableBuilder(
      column: $table.scrollRatio, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastParagraphIndex => $composableBuilder(
      column: $table.lastParagraphIndex,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$ChaptersTableFilterComposer get chapterId {
    final $$ChaptersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableFilterComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReadingPositionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingPositionsTable> {
  $$ReadingPositionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get pageNumber => $composableBuilder(
      column: $table.pageNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get scrollRatio => $composableBuilder(
      column: $table.scrollRatio, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastParagraphIndex => $composableBuilder(
      column: $table.lastParagraphIndex,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$ChaptersTableOrderingComposer get chapterId {
    final $$ChaptersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableOrderingComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReadingPositionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingPositionsTable> {
  $$ReadingPositionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get pageNumber => $composableBuilder(
      column: $table.pageNumber, builder: (column) => column);

  GeneratedColumn<double> get scrollRatio => $composableBuilder(
      column: $table.scrollRatio, builder: (column) => column);

  GeneratedColumn<int> get lastParagraphIndex => $composableBuilder(
      column: $table.lastParagraphIndex, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ChaptersTableAnnotationComposer get chapterId {
    final $$ChaptersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableAnnotationComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReadingPositionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReadingPositionsTable,
    ReadingPosition,
    $$ReadingPositionsTableFilterComposer,
    $$ReadingPositionsTableOrderingComposer,
    $$ReadingPositionsTableAnnotationComposer,
    $$ReadingPositionsTableCreateCompanionBuilder,
    $$ReadingPositionsTableUpdateCompanionBuilder,
    (ReadingPosition, $$ReadingPositionsTableReferences),
    ReadingPosition,
    PrefetchHooks Function({bool chapterId})> {
  $$ReadingPositionsTableTableManager(
      _$AppDatabase db, $ReadingPositionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingPositionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingPositionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingPositionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> chapterId = const Value.absent(),
            Value<int> pageNumber = const Value.absent(),
            Value<double> scrollRatio = const Value.absent(),
            Value<int> lastParagraphIndex = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReadingPositionsCompanion(
            chapterId: chapterId,
            pageNumber: pageNumber,
            scrollRatio: scrollRatio,
            lastParagraphIndex: lastParagraphIndex,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String chapterId,
            Value<int> pageNumber = const Value.absent(),
            Value<double> scrollRatio = const Value.absent(),
            Value<int> lastParagraphIndex = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReadingPositionsCompanion.insert(
            chapterId: chapterId,
            pageNumber: pageNumber,
            scrollRatio: scrollRatio,
            lastParagraphIndex: lastParagraphIndex,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ReadingPositionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({chapterId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (chapterId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.chapterId,
                    referencedTable:
                        $$ReadingPositionsTableReferences._chapterIdTable(db),
                    referencedColumn: $$ReadingPositionsTableReferences
                        ._chapterIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ReadingPositionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReadingPositionsTable,
    ReadingPosition,
    $$ReadingPositionsTableFilterComposer,
    $$ReadingPositionsTableOrderingComposer,
    $$ReadingPositionsTableAnnotationComposer,
    $$ReadingPositionsTableCreateCompanionBuilder,
    $$ReadingPositionsTableUpdateCompanionBuilder,
    (ReadingPosition, $$ReadingPositionsTableReferences),
    ReadingPosition,
    PrefetchHooks Function({bool chapterId})>;
typedef $$BookmarksTableCreateCompanionBuilder = BookmarksCompanion Function({
  required String id,
  required String chapterId,
  required int pageNumber,
  required String sectionTitle,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$BookmarksTableUpdateCompanionBuilder = BookmarksCompanion Function({
  Value<String> id,
  Value<String> chapterId,
  Value<int> pageNumber,
  Value<String> sectionTitle,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$BookmarksTableReferences
    extends BaseReferences<_$AppDatabase, $BookmarksTable, Bookmark> {
  $$BookmarksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ChaptersTable _chapterIdTable(_$AppDatabase db) =>
      db.chapters.createAlias(
          $_aliasNameGenerator(db.bookmarks.chapterId, db.chapters.id));

  $$ChaptersTableProcessedTableManager get chapterId {
    final manager = $$ChaptersTableTableManager($_db, $_db.chapters)
        .filter((f) => f.id($_item.chapterId));
    final item = $_typedResult.readTableOrNull(_chapterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$BookmarksTableFilterComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pageNumber => $composableBuilder(
      column: $table.pageNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sectionTitle => $composableBuilder(
      column: $table.sectionTitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$ChaptersTableFilterComposer get chapterId {
    final $$ChaptersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableFilterComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BookmarksTableOrderingComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pageNumber => $composableBuilder(
      column: $table.pageNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sectionTitle => $composableBuilder(
      column: $table.sectionTitle,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$ChaptersTableOrderingComposer get chapterId {
    final $$ChaptersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableOrderingComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BookmarksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get pageNumber => $composableBuilder(
      column: $table.pageNumber, builder: (column) => column);

  GeneratedColumn<String> get sectionTitle => $composableBuilder(
      column: $table.sectionTitle, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ChaptersTableAnnotationComposer get chapterId {
    final $$ChaptersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableAnnotationComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BookmarksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BookmarksTable,
    Bookmark,
    $$BookmarksTableFilterComposer,
    $$BookmarksTableOrderingComposer,
    $$BookmarksTableAnnotationComposer,
    $$BookmarksTableCreateCompanionBuilder,
    $$BookmarksTableUpdateCompanionBuilder,
    (Bookmark, $$BookmarksTableReferences),
    Bookmark,
    PrefetchHooks Function({bool chapterId})> {
  $$BookmarksTableTableManager(_$AppDatabase db, $BookmarksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> chapterId = const Value.absent(),
            Value<int> pageNumber = const Value.absent(),
            Value<String> sectionTitle = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BookmarksCompanion(
            id: id,
            chapterId: chapterId,
            pageNumber: pageNumber,
            sectionTitle: sectionTitle,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String chapterId,
            required int pageNumber,
            required String sectionTitle,
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BookmarksCompanion.insert(
            id: id,
            chapterId: chapterId,
            pageNumber: pageNumber,
            sectionTitle: sectionTitle,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$BookmarksTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({chapterId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (chapterId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.chapterId,
                    referencedTable:
                        $$BookmarksTableReferences._chapterIdTable(db),
                    referencedColumn:
                        $$BookmarksTableReferences._chapterIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$BookmarksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BookmarksTable,
    Bookmark,
    $$BookmarksTableFilterComposer,
    $$BookmarksTableOrderingComposer,
    $$BookmarksTableAnnotationComposer,
    $$BookmarksTableCreateCompanionBuilder,
    $$BookmarksTableUpdateCompanionBuilder,
    (Bookmark, $$BookmarksTableReferences),
    Bookmark,
    PrefetchHooks Function({bool chapterId})>;
typedef $$AnnotationsTableCreateCompanionBuilder = AnnotationsCompanion
    Function({
  required String id,
  required String chapterId,
  required int pageNumber,
  required String selectedText,
  required String note,
  Value<String> highlightColor,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$AnnotationsTableUpdateCompanionBuilder = AnnotationsCompanion
    Function({
  Value<String> id,
  Value<String> chapterId,
  Value<int> pageNumber,
  Value<String> selectedText,
  Value<String> note,
  Value<String> highlightColor,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$AnnotationsTableReferences
    extends BaseReferences<_$AppDatabase, $AnnotationsTable, Annotation> {
  $$AnnotationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ChaptersTable _chapterIdTable(_$AppDatabase db) =>
      db.chapters.createAlias(
          $_aliasNameGenerator(db.annotations.chapterId, db.chapters.id));

  $$ChaptersTableProcessedTableManager get chapterId {
    final manager = $$ChaptersTableTableManager($_db, $_db.chapters)
        .filter((f) => f.id($_item.chapterId));
    final item = $_typedResult.readTableOrNull(_chapterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$AnnotationsTableFilterComposer
    extends Composer<_$AppDatabase, $AnnotationsTable> {
  $$AnnotationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pageNumber => $composableBuilder(
      column: $table.pageNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get selectedText => $composableBuilder(
      column: $table.selectedText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get highlightColor => $composableBuilder(
      column: $table.highlightColor,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$ChaptersTableFilterComposer get chapterId {
    final $$ChaptersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableFilterComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AnnotationsTableOrderingComposer
    extends Composer<_$AppDatabase, $AnnotationsTable> {
  $$AnnotationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pageNumber => $composableBuilder(
      column: $table.pageNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get selectedText => $composableBuilder(
      column: $table.selectedText,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get highlightColor => $composableBuilder(
      column: $table.highlightColor,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$ChaptersTableOrderingComposer get chapterId {
    final $$ChaptersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableOrderingComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AnnotationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnnotationsTable> {
  $$AnnotationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get pageNumber => $composableBuilder(
      column: $table.pageNumber, builder: (column) => column);

  GeneratedColumn<String> get selectedText => $composableBuilder(
      column: $table.selectedText, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get highlightColor => $composableBuilder(
      column: $table.highlightColor, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ChaptersTableAnnotationComposer get chapterId {
    final $$ChaptersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableAnnotationComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AnnotationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AnnotationsTable,
    Annotation,
    $$AnnotationsTableFilterComposer,
    $$AnnotationsTableOrderingComposer,
    $$AnnotationsTableAnnotationComposer,
    $$AnnotationsTableCreateCompanionBuilder,
    $$AnnotationsTableUpdateCompanionBuilder,
    (Annotation, $$AnnotationsTableReferences),
    Annotation,
    PrefetchHooks Function({bool chapterId})> {
  $$AnnotationsTableTableManager(_$AppDatabase db, $AnnotationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnnotationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnnotationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnnotationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> chapterId = const Value.absent(),
            Value<int> pageNumber = const Value.absent(),
            Value<String> selectedText = const Value.absent(),
            Value<String> note = const Value.absent(),
            Value<String> highlightColor = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AnnotationsCompanion(
            id: id,
            chapterId: chapterId,
            pageNumber: pageNumber,
            selectedText: selectedText,
            note: note,
            highlightColor: highlightColor,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String chapterId,
            required int pageNumber,
            required String selectedText,
            required String note,
            Value<String> highlightColor = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AnnotationsCompanion.insert(
            id: id,
            chapterId: chapterId,
            pageNumber: pageNumber,
            selectedText: selectedText,
            note: note,
            highlightColor: highlightColor,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$AnnotationsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({chapterId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (chapterId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.chapterId,
                    referencedTable:
                        $$AnnotationsTableReferences._chapterIdTable(db),
                    referencedColumn:
                        $$AnnotationsTableReferences._chapterIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$AnnotationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AnnotationsTable,
    Annotation,
    $$AnnotationsTableFilterComposer,
    $$AnnotationsTableOrderingComposer,
    $$AnnotationsTableAnnotationComposer,
    $$AnnotationsTableCreateCompanionBuilder,
    $$AnnotationsTableUpdateCompanionBuilder,
    (Annotation, $$AnnotationsTableReferences),
    Annotation,
    PrefetchHooks Function({bool chapterId})>;
typedef $$ReviewSchedulesTableCreateCompanionBuilder = ReviewSchedulesCompanion
    Function({
  required String id,
  required String chapterId,
  Value<String?> competencyId,
  required DateTime scheduledDate,
  Value<int> repetitionIntervalDays,
  Value<double> easinessFactor,
  Value<bool> isCompleted,
  Value<DateTime?> lastReviewedAt,
  Value<int> rowid,
});
typedef $$ReviewSchedulesTableUpdateCompanionBuilder = ReviewSchedulesCompanion
    Function({
  Value<String> id,
  Value<String> chapterId,
  Value<String?> competencyId,
  Value<DateTime> scheduledDate,
  Value<int> repetitionIntervalDays,
  Value<double> easinessFactor,
  Value<bool> isCompleted,
  Value<DateTime?> lastReviewedAt,
  Value<int> rowid,
});

final class $$ReviewSchedulesTableReferences extends BaseReferences<
    _$AppDatabase, $ReviewSchedulesTable, ReviewSchedule> {
  $$ReviewSchedulesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ChaptersTable _chapterIdTable(_$AppDatabase db) =>
      db.chapters.createAlias(
          $_aliasNameGenerator(db.reviewSchedules.chapterId, db.chapters.id));

  $$ChaptersTableProcessedTableManager get chapterId {
    final manager = $$ChaptersTableTableManager($_db, $_db.chapters)
        .filter((f) => f.id($_item.chapterId));
    final item = $_typedResult.readTableOrNull(_chapterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $CompetenciesTable _competencyIdTable(_$AppDatabase db) =>
      db.competencies.createAlias($_aliasNameGenerator(
          db.reviewSchedules.competencyId, db.competencies.id));

  $$CompetenciesTableProcessedTableManager? get competencyId {
    if ($_item.competencyId == null) return null;
    final manager = $$CompetenciesTableTableManager($_db, $_db.competencies)
        .filter((f) => f.id($_item.competencyId!));
    final item = $_typedResult.readTableOrNull(_competencyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ReviewSchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $ReviewSchedulesTable> {
  $$ReviewSchedulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get scheduledDate => $composableBuilder(
      column: $table.scheduledDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get repetitionIntervalDays => $composableBuilder(
      column: $table.repetitionIntervalDays,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get easinessFactor => $composableBuilder(
      column: $table.easinessFactor,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastReviewedAt => $composableBuilder(
      column: $table.lastReviewedAt,
      builder: (column) => ColumnFilters(column));

  $$ChaptersTableFilterComposer get chapterId {
    final $$ChaptersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableFilterComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CompetenciesTableFilterComposer get competencyId {
    final $$CompetenciesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.competencyId,
        referencedTable: $db.competencies,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CompetenciesTableFilterComposer(
              $db: $db,
              $table: $db.competencies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReviewSchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReviewSchedulesTable> {
  $$ReviewSchedulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get scheduledDate => $composableBuilder(
      column: $table.scheduledDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get repetitionIntervalDays => $composableBuilder(
      column: $table.repetitionIntervalDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get easinessFactor => $composableBuilder(
      column: $table.easinessFactor,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastReviewedAt => $composableBuilder(
      column: $table.lastReviewedAt,
      builder: (column) => ColumnOrderings(column));

  $$ChaptersTableOrderingComposer get chapterId {
    final $$ChaptersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableOrderingComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CompetenciesTableOrderingComposer get competencyId {
    final $$CompetenciesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.competencyId,
        referencedTable: $db.competencies,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CompetenciesTableOrderingComposer(
              $db: $db,
              $table: $db.competencies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReviewSchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReviewSchedulesTable> {
  $$ReviewSchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledDate => $composableBuilder(
      column: $table.scheduledDate, builder: (column) => column);

  GeneratedColumn<int> get repetitionIntervalDays => $composableBuilder(
      column: $table.repetitionIntervalDays, builder: (column) => column);

  GeneratedColumn<double> get easinessFactor => $composableBuilder(
      column: $table.easinessFactor, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<DateTime> get lastReviewedAt => $composableBuilder(
      column: $table.lastReviewedAt, builder: (column) => column);

  $$ChaptersTableAnnotationComposer get chapterId {
    final $$ChaptersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableAnnotationComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CompetenciesTableAnnotationComposer get competencyId {
    final $$CompetenciesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.competencyId,
        referencedTable: $db.competencies,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CompetenciesTableAnnotationComposer(
              $db: $db,
              $table: $db.competencies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReviewSchedulesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReviewSchedulesTable,
    ReviewSchedule,
    $$ReviewSchedulesTableFilterComposer,
    $$ReviewSchedulesTableOrderingComposer,
    $$ReviewSchedulesTableAnnotationComposer,
    $$ReviewSchedulesTableCreateCompanionBuilder,
    $$ReviewSchedulesTableUpdateCompanionBuilder,
    (ReviewSchedule, $$ReviewSchedulesTableReferences),
    ReviewSchedule,
    PrefetchHooks Function({bool chapterId, bool competencyId})> {
  $$ReviewSchedulesTableTableManager(
      _$AppDatabase db, $ReviewSchedulesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReviewSchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReviewSchedulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReviewSchedulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> chapterId = const Value.absent(),
            Value<String?> competencyId = const Value.absent(),
            Value<DateTime> scheduledDate = const Value.absent(),
            Value<int> repetitionIntervalDays = const Value.absent(),
            Value<double> easinessFactor = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime?> lastReviewedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReviewSchedulesCompanion(
            id: id,
            chapterId: chapterId,
            competencyId: competencyId,
            scheduledDate: scheduledDate,
            repetitionIntervalDays: repetitionIntervalDays,
            easinessFactor: easinessFactor,
            isCompleted: isCompleted,
            lastReviewedAt: lastReviewedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String chapterId,
            Value<String?> competencyId = const Value.absent(),
            required DateTime scheduledDate,
            Value<int> repetitionIntervalDays = const Value.absent(),
            Value<double> easinessFactor = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime?> lastReviewedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReviewSchedulesCompanion.insert(
            id: id,
            chapterId: chapterId,
            competencyId: competencyId,
            scheduledDate: scheduledDate,
            repetitionIntervalDays: repetitionIntervalDays,
            easinessFactor: easinessFactor,
            isCompleted: isCompleted,
            lastReviewedAt: lastReviewedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ReviewSchedulesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({chapterId = false, competencyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (chapterId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.chapterId,
                    referencedTable:
                        $$ReviewSchedulesTableReferences._chapterIdTable(db),
                    referencedColumn:
                        $$ReviewSchedulesTableReferences._chapterIdTable(db).id,
                  ) as T;
                }
                if (competencyId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.competencyId,
                    referencedTable:
                        $$ReviewSchedulesTableReferences._competencyIdTable(db),
                    referencedColumn: $$ReviewSchedulesTableReferences
                        ._competencyIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ReviewSchedulesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReviewSchedulesTable,
    ReviewSchedule,
    $$ReviewSchedulesTableFilterComposer,
    $$ReviewSchedulesTableOrderingComposer,
    $$ReviewSchedulesTableAnnotationComposer,
    $$ReviewSchedulesTableCreateCompanionBuilder,
    $$ReviewSchedulesTableUpdateCompanionBuilder,
    (ReviewSchedule, $$ReviewSchedulesTableReferences),
    ReviewSchedule,
    PrefetchHooks Function({bool chapterId, bool competencyId})>;
typedef $$ContentRevisionsTableCreateCompanionBuilder
    = ContentRevisionsCompanion Function({
  required String id,
  required String chapterId,
  required String revisionCode,
  required String author,
  required String checksumSha256,
  required String manifestJson,
  Value<bool> isApproved,
  Value<DateTime?> approvedAt,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$ContentRevisionsTableUpdateCompanionBuilder
    = ContentRevisionsCompanion Function({
  Value<String> id,
  Value<String> chapterId,
  Value<String> revisionCode,
  Value<String> author,
  Value<String> checksumSha256,
  Value<String> manifestJson,
  Value<bool> isApproved,
  Value<DateTime?> approvedAt,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$ContentRevisionsTableReferences extends BaseReferences<
    _$AppDatabase, $ContentRevisionsTable, ContentRevision> {
  $$ContentRevisionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ChaptersTable _chapterIdTable(_$AppDatabase db) =>
      db.chapters.createAlias(
          $_aliasNameGenerator(db.contentRevisions.chapterId, db.chapters.id));

  $$ChaptersTableProcessedTableManager get chapterId {
    final manager = $$ChaptersTableTableManager($_db, $_db.chapters)
        .filter((f) => f.id($_item.chapterId));
    final item = $_typedResult.readTableOrNull(_chapterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ContentRevisionsTableFilterComposer
    extends Composer<_$AppDatabase, $ContentRevisionsTable> {
  $$ContentRevisionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get revisionCode => $composableBuilder(
      column: $table.revisionCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get checksumSha256 => $composableBuilder(
      column: $table.checksumSha256,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get manifestJson => $composableBuilder(
      column: $table.manifestJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isApproved => $composableBuilder(
      column: $table.isApproved, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get approvedAt => $composableBuilder(
      column: $table.approvedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$ChaptersTableFilterComposer get chapterId {
    final $$ChaptersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableFilterComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ContentRevisionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContentRevisionsTable> {
  $$ContentRevisionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get revisionCode => $composableBuilder(
      column: $table.revisionCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get checksumSha256 => $composableBuilder(
      column: $table.checksumSha256,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get manifestJson => $composableBuilder(
      column: $table.manifestJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isApproved => $composableBuilder(
      column: $table.isApproved, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get approvedAt => $composableBuilder(
      column: $table.approvedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$ChaptersTableOrderingComposer get chapterId {
    final $$ChaptersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableOrderingComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ContentRevisionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContentRevisionsTable> {
  $$ContentRevisionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get revisionCode => $composableBuilder(
      column: $table.revisionCode, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get checksumSha256 => $composableBuilder(
      column: $table.checksumSha256, builder: (column) => column);

  GeneratedColumn<String> get manifestJson => $composableBuilder(
      column: $table.manifestJson, builder: (column) => column);

  GeneratedColumn<bool> get isApproved => $composableBuilder(
      column: $table.isApproved, builder: (column) => column);

  GeneratedColumn<DateTime> get approvedAt => $composableBuilder(
      column: $table.approvedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ChaptersTableAnnotationComposer get chapterId {
    final $$ChaptersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableAnnotationComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ContentRevisionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ContentRevisionsTable,
    ContentRevision,
    $$ContentRevisionsTableFilterComposer,
    $$ContentRevisionsTableOrderingComposer,
    $$ContentRevisionsTableAnnotationComposer,
    $$ContentRevisionsTableCreateCompanionBuilder,
    $$ContentRevisionsTableUpdateCompanionBuilder,
    (ContentRevision, $$ContentRevisionsTableReferences),
    ContentRevision,
    PrefetchHooks Function({bool chapterId})> {
  $$ContentRevisionsTableTableManager(
      _$AppDatabase db, $ContentRevisionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContentRevisionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContentRevisionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContentRevisionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> chapterId = const Value.absent(),
            Value<String> revisionCode = const Value.absent(),
            Value<String> author = const Value.absent(),
            Value<String> checksumSha256 = const Value.absent(),
            Value<String> manifestJson = const Value.absent(),
            Value<bool> isApproved = const Value.absent(),
            Value<DateTime?> approvedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ContentRevisionsCompanion(
            id: id,
            chapterId: chapterId,
            revisionCode: revisionCode,
            author: author,
            checksumSha256: checksumSha256,
            manifestJson: manifestJson,
            isApproved: isApproved,
            approvedAt: approvedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String chapterId,
            required String revisionCode,
            required String author,
            required String checksumSha256,
            required String manifestJson,
            Value<bool> isApproved = const Value.absent(),
            Value<DateTime?> approvedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ContentRevisionsCompanion.insert(
            id: id,
            chapterId: chapterId,
            revisionCode: revisionCode,
            author: author,
            checksumSha256: checksumSha256,
            manifestJson: manifestJson,
            isApproved: isApproved,
            approvedAt: approvedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ContentRevisionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({chapterId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (chapterId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.chapterId,
                    referencedTable:
                        $$ContentRevisionsTableReferences._chapterIdTable(db),
                    referencedColumn: $$ContentRevisionsTableReferences
                        ._chapterIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ContentRevisionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ContentRevisionsTable,
    ContentRevision,
    $$ContentRevisionsTableFilterComposer,
    $$ContentRevisionsTableOrderingComposer,
    $$ContentRevisionsTableAnnotationComposer,
    $$ContentRevisionsTableCreateCompanionBuilder,
    $$ContentRevisionsTableUpdateCompanionBuilder,
    (ContentRevision, $$ContentRevisionsTableReferences),
    ContentRevision,
    PrefetchHooks Function({bool chapterId})>;
typedef $$SourceDocumentsTableCreateCompanionBuilder = SourceDocumentsCompanion
    Function({
  required String id,
  required String chapterId,
  required String fileName,
  required String fileType,
  required String sha256,
  required int fileSizeBytes,
  required String localPath,
  Value<DateTime> importedAt,
  Value<int> rowid,
});
typedef $$SourceDocumentsTableUpdateCompanionBuilder = SourceDocumentsCompanion
    Function({
  Value<String> id,
  Value<String> chapterId,
  Value<String> fileName,
  Value<String> fileType,
  Value<String> sha256,
  Value<int> fileSizeBytes,
  Value<String> localPath,
  Value<DateTime> importedAt,
  Value<int> rowid,
});

final class $$SourceDocumentsTableReferences extends BaseReferences<
    _$AppDatabase, $SourceDocumentsTable, SourceDocument> {
  $$SourceDocumentsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ChaptersTable _chapterIdTable(_$AppDatabase db) =>
      db.chapters.createAlias(
          $_aliasNameGenerator(db.sourceDocuments.chapterId, db.chapters.id));

  $$ChaptersTableProcessedTableManager get chapterId {
    final manager = $$ChaptersTableTableManager($_db, $_db.chapters)
        .filter((f) => f.id($_item.chapterId));
    final item = $_typedResult.readTableOrNull(_chapterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SourceDocumentsTableFilterComposer
    extends Composer<_$AppDatabase, $SourceDocumentsTable> {
  $$SourceDocumentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fileName => $composableBuilder(
      column: $table.fileName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fileType => $composableBuilder(
      column: $table.fileType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sha256 => $composableBuilder(
      column: $table.sha256, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fileSizeBytes => $composableBuilder(
      column: $table.fileSizeBytes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
      column: $table.importedAt, builder: (column) => ColumnFilters(column));

  $$ChaptersTableFilterComposer get chapterId {
    final $$ChaptersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableFilterComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SourceDocumentsTableOrderingComposer
    extends Composer<_$AppDatabase, $SourceDocumentsTable> {
  $$SourceDocumentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fileName => $composableBuilder(
      column: $table.fileName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fileType => $composableBuilder(
      column: $table.fileType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sha256 => $composableBuilder(
      column: $table.sha256, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fileSizeBytes => $composableBuilder(
      column: $table.fileSizeBytes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
      column: $table.importedAt, builder: (column) => ColumnOrderings(column));

  $$ChaptersTableOrderingComposer get chapterId {
    final $$ChaptersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableOrderingComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SourceDocumentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SourceDocumentsTable> {
  $$SourceDocumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get fileType =>
      $composableBuilder(column: $table.fileType, builder: (column) => column);

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<int> get fileSizeBytes => $composableBuilder(
      column: $table.fileSizeBytes, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
      column: $table.importedAt, builder: (column) => column);

  $$ChaptersTableAnnotationComposer get chapterId {
    final $$ChaptersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableAnnotationComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SourceDocumentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SourceDocumentsTable,
    SourceDocument,
    $$SourceDocumentsTableFilterComposer,
    $$SourceDocumentsTableOrderingComposer,
    $$SourceDocumentsTableAnnotationComposer,
    $$SourceDocumentsTableCreateCompanionBuilder,
    $$SourceDocumentsTableUpdateCompanionBuilder,
    (SourceDocument, $$SourceDocumentsTableReferences),
    SourceDocument,
    PrefetchHooks Function({bool chapterId})> {
  $$SourceDocumentsTableTableManager(
      _$AppDatabase db, $SourceDocumentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SourceDocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SourceDocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SourceDocumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> chapterId = const Value.absent(),
            Value<String> fileName = const Value.absent(),
            Value<String> fileType = const Value.absent(),
            Value<String> sha256 = const Value.absent(),
            Value<int> fileSizeBytes = const Value.absent(),
            Value<String> localPath = const Value.absent(),
            Value<DateTime> importedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SourceDocumentsCompanion(
            id: id,
            chapterId: chapterId,
            fileName: fileName,
            fileType: fileType,
            sha256: sha256,
            fileSizeBytes: fileSizeBytes,
            localPath: localPath,
            importedAt: importedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String chapterId,
            required String fileName,
            required String fileType,
            required String sha256,
            required int fileSizeBytes,
            required String localPath,
            Value<DateTime> importedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SourceDocumentsCompanion.insert(
            id: id,
            chapterId: chapterId,
            fileName: fileName,
            fileType: fileType,
            sha256: sha256,
            fileSizeBytes: fileSizeBytes,
            localPath: localPath,
            importedAt: importedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SourceDocumentsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({chapterId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (chapterId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.chapterId,
                    referencedTable:
                        $$SourceDocumentsTableReferences._chapterIdTable(db),
                    referencedColumn:
                        $$SourceDocumentsTableReferences._chapterIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$SourceDocumentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SourceDocumentsTable,
    SourceDocument,
    $$SourceDocumentsTableFilterComposer,
    $$SourceDocumentsTableOrderingComposer,
    $$SourceDocumentsTableAnnotationComposer,
    $$SourceDocumentsTableCreateCompanionBuilder,
    $$SourceDocumentsTableUpdateCompanionBuilder,
    (SourceDocument, $$SourceDocumentsTableReferences),
    SourceDocument,
    PrefetchHooks Function({bool chapterId})>;
typedef $$SyncJournalsTableCreateCompanionBuilder = SyncJournalsCompanion
    Function({
  required String id,
  required String sourceProvider,
  required String entityType,
  required String entityId,
  required String operation,
  Value<String?> sha256Before,
  Value<String?> sha256After,
  Value<DateTime> syncedAt,
  Value<String> status,
  Value<int> rowid,
});
typedef $$SyncJournalsTableUpdateCompanionBuilder = SyncJournalsCompanion
    Function({
  Value<String> id,
  Value<String> sourceProvider,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> operation,
  Value<String?> sha256Before,
  Value<String?> sha256After,
  Value<DateTime> syncedAt,
  Value<String> status,
  Value<int> rowid,
});

class $$SyncJournalsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncJournalsTable> {
  $$SyncJournalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceProvider => $composableBuilder(
      column: $table.sourceProvider,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sha256Before => $composableBuilder(
      column: $table.sha256Before, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sha256After => $composableBuilder(
      column: $table.sha256After, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));
}

class $$SyncJournalsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncJournalsTable> {
  $$SyncJournalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceProvider => $composableBuilder(
      column: $table.sourceProvider,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sha256Before => $composableBuilder(
      column: $table.sha256Before,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sha256After => $composableBuilder(
      column: $table.sha256After, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));
}

class $$SyncJournalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncJournalsTable> {
  $$SyncJournalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceProvider => $composableBuilder(
      column: $table.sourceProvider, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get sha256Before => $composableBuilder(
      column: $table.sha256Before, builder: (column) => column);

  GeneratedColumn<String> get sha256After => $composableBuilder(
      column: $table.sha256After, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$SyncJournalsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncJournalsTable,
    SyncJournal,
    $$SyncJournalsTableFilterComposer,
    $$SyncJournalsTableOrderingComposer,
    $$SyncJournalsTableAnnotationComposer,
    $$SyncJournalsTableCreateCompanionBuilder,
    $$SyncJournalsTableUpdateCompanionBuilder,
    (
      SyncJournal,
      BaseReferences<_$AppDatabase, $SyncJournalsTable, SyncJournal>
    ),
    SyncJournal,
    PrefetchHooks Function()> {
  $$SyncJournalsTableTableManager(_$AppDatabase db, $SyncJournalsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncJournalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncJournalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncJournalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> sourceProvider = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String> operation = const Value.absent(),
            Value<String?> sha256Before = const Value.absent(),
            Value<String?> sha256After = const Value.absent(),
            Value<DateTime> syncedAt = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncJournalsCompanion(
            id: id,
            sourceProvider: sourceProvider,
            entityType: entityType,
            entityId: entityId,
            operation: operation,
            sha256Before: sha256Before,
            sha256After: sha256After,
            syncedAt: syncedAt,
            status: status,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String sourceProvider,
            required String entityType,
            required String entityId,
            required String operation,
            Value<String?> sha256Before = const Value.absent(),
            Value<String?> sha256After = const Value.absent(),
            Value<DateTime> syncedAt = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncJournalsCompanion.insert(
            id: id,
            sourceProvider: sourceProvider,
            entityType: entityType,
            entityId: entityId,
            operation: operation,
            sha256Before: sha256Before,
            sha256After: sha256After,
            syncedAt: syncedAt,
            status: status,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncJournalsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncJournalsTable,
    SyncJournal,
    $$SyncJournalsTableFilterComposer,
    $$SyncJournalsTableOrderingComposer,
    $$SyncJournalsTableAnnotationComposer,
    $$SyncJournalsTableCreateCompanionBuilder,
    $$SyncJournalsTableUpdateCompanionBuilder,
    (
      SyncJournal,
      BaseReferences<_$AppDatabase, $SyncJournalsTable, SyncJournal>
    ),
    SyncJournal,
    PrefetchHooks Function()>;
typedef $$UserSettingsEntriesTableCreateCompanionBuilder
    = UserSettingsEntriesCompanion Function({
  required String key,
  required String value,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$UserSettingsEntriesTableUpdateCompanionBuilder
    = UserSettingsEntriesCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$UserSettingsEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $UserSettingsEntriesTable> {
  $$UserSettingsEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$UserSettingsEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserSettingsEntriesTable> {
  $$UserSettingsEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$UserSettingsEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserSettingsEntriesTable> {
  $$UserSettingsEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserSettingsEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserSettingsEntriesTable,
    UserSettingsEntry,
    $$UserSettingsEntriesTableFilterComposer,
    $$UserSettingsEntriesTableOrderingComposer,
    $$UserSettingsEntriesTableAnnotationComposer,
    $$UserSettingsEntriesTableCreateCompanionBuilder,
    $$UserSettingsEntriesTableUpdateCompanionBuilder,
    (
      UserSettingsEntry,
      BaseReferences<_$AppDatabase, $UserSettingsEntriesTable,
          UserSettingsEntry>
    ),
    UserSettingsEntry,
    PrefetchHooks Function()> {
  $$UserSettingsEntriesTableTableManager(
      _$AppDatabase db, $UserSettingsEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSettingsEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserSettingsEntriesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserSettingsEntriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserSettingsEntriesCompanion(
            key: key,
            value: value,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserSettingsEntriesCompanion.insert(
            key: key,
            value: value,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserSettingsEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserSettingsEntriesTable,
    UserSettingsEntry,
    $$UserSettingsEntriesTableFilterComposer,
    $$UserSettingsEntriesTableOrderingComposer,
    $$UserSettingsEntriesTableAnnotationComposer,
    $$UserSettingsEntriesTableCreateCompanionBuilder,
    $$UserSettingsEntriesTableUpdateCompanionBuilder,
    (
      UserSettingsEntry,
      BaseReferences<_$AppDatabase, $UserSettingsEntriesTable,
          UserSettingsEntry>
    ),
    UserSettingsEntry,
    PrefetchHooks Function()>;
typedef $$AIInteractionsTableCreateCompanionBuilder = AIInteractionsCompanion
    Function({
  required String id,
  Value<String?> chapterId,
  required String modelId,
  required String pedagogicalMode,
  required String userPrompt,
  required String contextChunksJson,
  required String aiResponse,
  required String citationTags,
  Value<DateTime> timestamp,
  Value<int> rowid,
});
typedef $$AIInteractionsTableUpdateCompanionBuilder = AIInteractionsCompanion
    Function({
  Value<String> id,
  Value<String?> chapterId,
  Value<String> modelId,
  Value<String> pedagogicalMode,
  Value<String> userPrompt,
  Value<String> contextChunksJson,
  Value<String> aiResponse,
  Value<String> citationTags,
  Value<DateTime> timestamp,
  Value<int> rowid,
});

final class $$AIInteractionsTableReferences
    extends BaseReferences<_$AppDatabase, $AIInteractionsTable, AIInteraction> {
  $$AIInteractionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ChaptersTable _chapterIdTable(_$AppDatabase db) =>
      db.chapters.createAlias(
          $_aliasNameGenerator(db.aIInteractions.chapterId, db.chapters.id));

  $$ChaptersTableProcessedTableManager? get chapterId {
    if ($_item.chapterId == null) return null;
    final manager = $$ChaptersTableTableManager($_db, $_db.chapters)
        .filter((f) => f.id($_item.chapterId!));
    final item = $_typedResult.readTableOrNull(_chapterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$AIInteractionsTableFilterComposer
    extends Composer<_$AppDatabase, $AIInteractionsTable> {
  $$AIInteractionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get modelId => $composableBuilder(
      column: $table.modelId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pedagogicalMode => $composableBuilder(
      column: $table.pedagogicalMode,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userPrompt => $composableBuilder(
      column: $table.userPrompt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contextChunksJson => $composableBuilder(
      column: $table.contextChunksJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get aiResponse => $composableBuilder(
      column: $table.aiResponse, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get citationTags => $composableBuilder(
      column: $table.citationTags, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  $$ChaptersTableFilterComposer get chapterId {
    final $$ChaptersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableFilterComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AIInteractionsTableOrderingComposer
    extends Composer<_$AppDatabase, $AIInteractionsTable> {
  $$AIInteractionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modelId => $composableBuilder(
      column: $table.modelId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pedagogicalMode => $composableBuilder(
      column: $table.pedagogicalMode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userPrompt => $composableBuilder(
      column: $table.userPrompt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contextChunksJson => $composableBuilder(
      column: $table.contextChunksJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get aiResponse => $composableBuilder(
      column: $table.aiResponse, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get citationTags => $composableBuilder(
      column: $table.citationTags,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  $$ChaptersTableOrderingComposer get chapterId {
    final $$ChaptersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableOrderingComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AIInteractionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AIInteractionsTable> {
  $$AIInteractionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get modelId =>
      $composableBuilder(column: $table.modelId, builder: (column) => column);

  GeneratedColumn<String> get pedagogicalMode => $composableBuilder(
      column: $table.pedagogicalMode, builder: (column) => column);

  GeneratedColumn<String> get userPrompt => $composableBuilder(
      column: $table.userPrompt, builder: (column) => column);

  GeneratedColumn<String> get contextChunksJson => $composableBuilder(
      column: $table.contextChunksJson, builder: (column) => column);

  GeneratedColumn<String> get aiResponse => $composableBuilder(
      column: $table.aiResponse, builder: (column) => column);

  GeneratedColumn<String> get citationTags => $composableBuilder(
      column: $table.citationTags, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  $$ChaptersTableAnnotationComposer get chapterId {
    final $$ChaptersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableAnnotationComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AIInteractionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AIInteractionsTable,
    AIInteraction,
    $$AIInteractionsTableFilterComposer,
    $$AIInteractionsTableOrderingComposer,
    $$AIInteractionsTableAnnotationComposer,
    $$AIInteractionsTableCreateCompanionBuilder,
    $$AIInteractionsTableUpdateCompanionBuilder,
    (AIInteraction, $$AIInteractionsTableReferences),
    AIInteraction,
    PrefetchHooks Function({bool chapterId})> {
  $$AIInteractionsTableTableManager(
      _$AppDatabase db, $AIInteractionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AIInteractionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AIInteractionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AIInteractionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> chapterId = const Value.absent(),
            Value<String> modelId = const Value.absent(),
            Value<String> pedagogicalMode = const Value.absent(),
            Value<String> userPrompt = const Value.absent(),
            Value<String> contextChunksJson = const Value.absent(),
            Value<String> aiResponse = const Value.absent(),
            Value<String> citationTags = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AIInteractionsCompanion(
            id: id,
            chapterId: chapterId,
            modelId: modelId,
            pedagogicalMode: pedagogicalMode,
            userPrompt: userPrompt,
            contextChunksJson: contextChunksJson,
            aiResponse: aiResponse,
            citationTags: citationTags,
            timestamp: timestamp,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> chapterId = const Value.absent(),
            required String modelId,
            required String pedagogicalMode,
            required String userPrompt,
            required String contextChunksJson,
            required String aiResponse,
            required String citationTags,
            Value<DateTime> timestamp = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AIInteractionsCompanion.insert(
            id: id,
            chapterId: chapterId,
            modelId: modelId,
            pedagogicalMode: pedagogicalMode,
            userPrompt: userPrompt,
            contextChunksJson: contextChunksJson,
            aiResponse: aiResponse,
            citationTags: citationTags,
            timestamp: timestamp,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$AIInteractionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({chapterId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (chapterId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.chapterId,
                    referencedTable:
                        $$AIInteractionsTableReferences._chapterIdTable(db),
                    referencedColumn:
                        $$AIInteractionsTableReferences._chapterIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$AIInteractionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AIInteractionsTable,
    AIInteraction,
    $$AIInteractionsTableFilterComposer,
    $$AIInteractionsTableOrderingComposer,
    $$AIInteractionsTableAnnotationComposer,
    $$AIInteractionsTableCreateCompanionBuilder,
    $$AIInteractionsTableUpdateCompanionBuilder,
    (AIInteraction, $$AIInteractionsTableReferences),
    AIInteraction,
    PrefetchHooks Function({bool chapterId})>;
typedef $$AudioSettingsEntriesTableCreateCompanionBuilder
    = AudioSettingsEntriesCompanion Function({
  Value<String> id,
  Value<String> preferredEngine,
  Value<String> voiceName,
  Value<double> playbackSpeed,
  Value<int> chunkCharTarget,
  Value<bool> autoScrollFollowAlong,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$AudioSettingsEntriesTableUpdateCompanionBuilder
    = AudioSettingsEntriesCompanion Function({
  Value<String> id,
  Value<String> preferredEngine,
  Value<String> voiceName,
  Value<double> playbackSpeed,
  Value<int> chunkCharTarget,
  Value<bool> autoScrollFollowAlong,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$AudioSettingsEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $AudioSettingsEntriesTable> {
  $$AudioSettingsEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get preferredEngine => $composableBuilder(
      column: $table.preferredEngine,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get voiceName => $composableBuilder(
      column: $table.voiceName, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get playbackSpeed => $composableBuilder(
      column: $table.playbackSpeed, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get chunkCharTarget => $composableBuilder(
      column: $table.chunkCharTarget,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get autoScrollFollowAlong => $composableBuilder(
      column: $table.autoScrollFollowAlong,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$AudioSettingsEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $AudioSettingsEntriesTable> {
  $$AudioSettingsEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get preferredEngine => $composableBuilder(
      column: $table.preferredEngine,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get voiceName => $composableBuilder(
      column: $table.voiceName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get playbackSpeed => $composableBuilder(
      column: $table.playbackSpeed,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get chunkCharTarget => $composableBuilder(
      column: $table.chunkCharTarget,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get autoScrollFollowAlong => $composableBuilder(
      column: $table.autoScrollFollowAlong,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$AudioSettingsEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AudioSettingsEntriesTable> {
  $$AudioSettingsEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get preferredEngine => $composableBuilder(
      column: $table.preferredEngine, builder: (column) => column);

  GeneratedColumn<String> get voiceName =>
      $composableBuilder(column: $table.voiceName, builder: (column) => column);

  GeneratedColumn<double> get playbackSpeed => $composableBuilder(
      column: $table.playbackSpeed, builder: (column) => column);

  GeneratedColumn<int> get chunkCharTarget => $composableBuilder(
      column: $table.chunkCharTarget, builder: (column) => column);

  GeneratedColumn<bool> get autoScrollFollowAlong => $composableBuilder(
      column: $table.autoScrollFollowAlong, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AudioSettingsEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AudioSettingsEntriesTable,
    AudioSettingsEntry,
    $$AudioSettingsEntriesTableFilterComposer,
    $$AudioSettingsEntriesTableOrderingComposer,
    $$AudioSettingsEntriesTableAnnotationComposer,
    $$AudioSettingsEntriesTableCreateCompanionBuilder,
    $$AudioSettingsEntriesTableUpdateCompanionBuilder,
    (
      AudioSettingsEntry,
      BaseReferences<_$AppDatabase, $AudioSettingsEntriesTable,
          AudioSettingsEntry>
    ),
    AudioSettingsEntry,
    PrefetchHooks Function()> {
  $$AudioSettingsEntriesTableTableManager(
      _$AppDatabase db, $AudioSettingsEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AudioSettingsEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AudioSettingsEntriesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AudioSettingsEntriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> preferredEngine = const Value.absent(),
            Value<String> voiceName = const Value.absent(),
            Value<double> playbackSpeed = const Value.absent(),
            Value<int> chunkCharTarget = const Value.absent(),
            Value<bool> autoScrollFollowAlong = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AudioSettingsEntriesCompanion(
            id: id,
            preferredEngine: preferredEngine,
            voiceName: voiceName,
            playbackSpeed: playbackSpeed,
            chunkCharTarget: chunkCharTarget,
            autoScrollFollowAlong: autoScrollFollowAlong,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> preferredEngine = const Value.absent(),
            Value<String> voiceName = const Value.absent(),
            Value<double> playbackSpeed = const Value.absent(),
            Value<int> chunkCharTarget = const Value.absent(),
            Value<bool> autoScrollFollowAlong = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AudioSettingsEntriesCompanion.insert(
            id: id,
            preferredEngine: preferredEngine,
            voiceName: voiceName,
            playbackSpeed: playbackSpeed,
            chunkCharTarget: chunkCharTarget,
            autoScrollFollowAlong: autoScrollFollowAlong,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AudioSettingsEntriesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $AudioSettingsEntriesTable,
        AudioSettingsEntry,
        $$AudioSettingsEntriesTableFilterComposer,
        $$AudioSettingsEntriesTableOrderingComposer,
        $$AudioSettingsEntriesTableAnnotationComposer,
        $$AudioSettingsEntriesTableCreateCompanionBuilder,
        $$AudioSettingsEntriesTableUpdateCompanionBuilder,
        (
          AudioSettingsEntry,
          BaseReferences<_$AppDatabase, $AudioSettingsEntriesTable,
              AudioSettingsEntry>
        ),
        AudioSettingsEntry,
        PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CurriculumsTableTableManager get curriculums =>
      $$CurriculumsTableTableManager(_db, _db.curriculums);
  $$VolumesTableTableManager get volumes =>
      $$VolumesTableTableManager(_db, _db.volumes);
  $$ChaptersTableTableManager get chapters =>
      $$ChaptersTableTableManager(_db, _db.chapters);
  $$LessonsTableTableManager get lessons =>
      $$LessonsTableTableManager(_db, _db.lessons);
  $$LearningObjectivesTableTableManager get learningObjectives =>
      $$LearningObjectivesTableTableManager(_db, _db.learningObjectives);
  $$CompetenciesTableTableManager get competencies =>
      $$CompetenciesTableTableManager(_db, _db.competencies);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db, _db.exercises);
  $$AssessmentsTableTableManager get assessments =>
      $$AssessmentsTableTableManager(_db, _db.assessments);
  $$AssessmentAttemptsTableTableManager get assessmentAttempts =>
      $$AssessmentAttemptsTableTableManager(_db, _db.assessmentAttempts);
  $$LaboratoriesTableTableManager get laboratories =>
      $$LaboratoriesTableTableManager(_db, _db.laboratories);
  $$LaboratoryRunsTableTableManager get laboratoryRuns =>
      $$LaboratoryRunsTableTableManager(_db, _db.laboratoryRuns);
  $$CaseStudiesTableTableManager get caseStudies =>
      $$CaseStudiesTableTableManager(_db, _db.caseStudies);
  $$CaseSubmissionsTableTableManager get caseSubmissions =>
      $$CaseSubmissionsTableTableManager(_db, _db.caseSubmissions);
  $$StudySessionsTableTableManager get studySessions =>
      $$StudySessionsTableTableManager(_db, _db.studySessions);
  $$ReadingPositionsTableTableManager get readingPositions =>
      $$ReadingPositionsTableTableManager(_db, _db.readingPositions);
  $$BookmarksTableTableManager get bookmarks =>
      $$BookmarksTableTableManager(_db, _db.bookmarks);
  $$AnnotationsTableTableManager get annotations =>
      $$AnnotationsTableTableManager(_db, _db.annotations);
  $$ReviewSchedulesTableTableManager get reviewSchedules =>
      $$ReviewSchedulesTableTableManager(_db, _db.reviewSchedules);
  $$ContentRevisionsTableTableManager get contentRevisions =>
      $$ContentRevisionsTableTableManager(_db, _db.contentRevisions);
  $$SourceDocumentsTableTableManager get sourceDocuments =>
      $$SourceDocumentsTableTableManager(_db, _db.sourceDocuments);
  $$SyncJournalsTableTableManager get syncJournals =>
      $$SyncJournalsTableTableManager(_db, _db.syncJournals);
  $$UserSettingsEntriesTableTableManager get userSettingsEntries =>
      $$UserSettingsEntriesTableTableManager(_db, _db.userSettingsEntries);
  $$AIInteractionsTableTableManager get aIInteractions =>
      $$AIInteractionsTableTableManager(_db, _db.aIInteractions);
  $$AudioSettingsEntriesTableTableManager get audioSettingsEntries =>
      $$AudioSettingsEntriesTableTableManager(_db, _db.audioSettingsEntries);
}
