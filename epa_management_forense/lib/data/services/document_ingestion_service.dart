import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

class DocumentIngestionService {
  static const supportedFormats = [
    'pdf',
    'docx',
    'xlsx',
    'xls',
    'txt',
    'rtf',
    'image_scan',
    'email_export',
  ];

  static const txtTypes = [
    'TRANSCRICAO',
    'ESTRUTURA',
    'ANALISE',
    'RISCO',
    'CONHECIMENTO',
  ];

  final _uuid = const Uuid();

  Map<String, dynamic> buildIngestionRecord({
    required String sourcePath,
    required String sourceType,
    String? processId,
  }) {
    final now = DateTime.now().toUtc().toIso8601String();
    final sourceId = _uuid.v4();
    final documentId = _uuid.v4();
    final hash = sha256.convert(utf8.encode('$sourcePath|$now')).toString();

    return {
      'source_id': sourceId,
      'documento_id': documentId,
      'hash_sha256': hash,
      'timestamp_ingestao': now,
      'tipo_fonte': sourceType,
      'caminho_origem': sourcePath,
      'processo_associado': processId,
      'estado_extracao': 'PENDENTE',
    };
  }

  List<Map<String, dynamic>> buildTxtArtifacts({
    required String documentId,
    required String sourceId,
    required String processId,
    required String hash,
  }) {
    final now = DateTime.now().toUtc().toIso8601String();
    return txtTypes
        .map(
          (type) => {
            'TXT_ID': _uuid.v4(),
            'TIPO_TXT': type,
            'DOCUMENTO_ID': documentId,
            'PROCESSO_ID': processId,
            'FONTE_ID': sourceId,
            'HASH_DOCUMENTAL': hash,
            'TIMESTAMP_GERACAO': now,
            'VERSAO': 1,
            'MOTOR_RESPONSAVEL': 'pipeline_base_v1',
            'ESTADO': 'GERADO',
            'CONTEUDO': '',
            'METADADOS': <String, dynamic>{'rastreavel': true},
            'LOG_TECNICO': 'Artefacto inicial criado.',
          },
        )
        .toList();
  }
}
