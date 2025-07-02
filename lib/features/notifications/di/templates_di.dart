import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/datasources/templates_remote_datasource.dart';
import '../data/repositories/templates_repository_impl.dart';
import '../domain/repositories/templates_repository.dart';
import '../domain/usecases/manage_templates.dart';

// Data Sources
final templatesRemoteDataSourceProvider = Provider<TemplatesRemoteDataSource>((
  ref,
) {
  final firestore = FirebaseFirestore.instance;
  return TemplatesRemoteDataSourceImpl(firestore);
});

// Repository
final templatesRepositoryProvider = Provider<TemplatesRepository>((ref) {
  final remoteDataSource = ref.watch(templatesRemoteDataSourceProvider);
  return TemplatesRepositoryImpl(remoteDataSource: remoteDataSource);
});

// Use Cases
final getTemplatesProvider = Provider<GetTemplates>((ref) {
  final repository = ref.watch(templatesRepositoryProvider);
  return GetTemplates(repository);
});

final createTemplateProvider = Provider<CreateTemplate>((ref) {
  final repository = ref.watch(templatesRepositoryProvider);
  return CreateTemplate(repository);
});

final updateTemplateProvider = Provider<UpdateTemplate>((ref) {
  final repository = ref.watch(templatesRepositoryProvider);
  return UpdateTemplate(repository);
});

final deleteTemplateProvider = Provider<DeleteTemplate>((ref) {
  final repository = ref.watch(templatesRepositoryProvider);
  return DeleteTemplate(repository);
});

final validateTemplateProvider = Provider<ValidateTemplate>((ref) {
  final repository = ref.watch(templatesRepositoryProvider);
  return ValidateTemplate(repository);
});

final previewTemplateProvider = Provider<PreviewTemplate>((ref) {
  final repository = ref.watch(templatesRepositoryProvider);
  return PreviewTemplate(repository);
});

final duplicateTemplateProvider = Provider<DuplicateTemplate>((ref) {
  final repository = ref.watch(templatesRepositoryProvider);
  return DuplicateTemplate(repository);
});

final getTemplatesByTypeProvider = Provider<GetTemplatesByType>((ref) {
  final repository = ref.watch(templatesRepositoryProvider);
  return GetTemplatesByType(repository);
});

final watchTemplatesProvider = Provider<WatchTemplates>((ref) {
  final repository = ref.watch(templatesRepositoryProvider);
  return WatchTemplates(repository);
});

final importTemplateProvider = Provider<ImportTemplate>((ref) {
  final repository = ref.watch(templatesRepositoryProvider);
  return ImportTemplate(repository);
});

final exportTemplateProvider = Provider<ExportTemplate>((ref) {
  final repository = ref.watch(templatesRepositoryProvider);
  return ExportTemplate(repository);
});
