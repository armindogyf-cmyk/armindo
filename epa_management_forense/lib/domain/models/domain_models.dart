enum UserProfile {
  administrador,
  partner,
  advogado,
  analistaForense,
  gestorDocumental,
  auditorInterno,
  operadorDigitalizacao,
  consulta,
}

class User { const User({required this.id, required this.name, required this.roleId}); final String id; final String name; final String roleId; }
class Role { const Role({required this.id, required this.name, required this.permissions}); final String id; final String name; final List<String> permissions; }
class Source { const Source({required this.id, required this.type, required this.path, required this.ingestedAt}); final String id; final String type; final String path; final DateTime ingestedAt; }
class Document { const Document({required this.id, required this.sourceId, required this.hashSha256, required this.extractionStatus}); final String id; final String sourceId; final String hashSha256; final String extractionStatus; }
class DocumentVersion { const DocumentVersion({required this.id, required this.documentId, required this.version}); final String id; final String documentId; final int version; }
class DocumentSegment { const DocumentSegment({required this.id, required this.documentId, required this.label, required this.content}); final String id; final String documentId; final String label; final String content; }
class TxtArtifact { const TxtArtifact({required this.id, required this.documentId, required this.type, required this.content}); final String id; final String documentId; final String type; final String content; }
class Process { const Process({required this.id, required this.courtId, required this.phase, required this.state, required this.score}); final String id; final String courtId; final String phase; final String state; final double score; }
class Court { const Court({required this.id, required this.name, required this.judgeSeat}); final String id; final String name; final String judgeSeat; }
class Event { const Event({required this.id, required this.processId, required this.type, required this.impact}); final String id; final String processId; final String type; final String impact; }
class Entity { const Entity({required this.id, required this.name, required this.category, required this.role}); final String id; final String name; final String category; final String role; }
class EntityRelation { const EntityRelation({required this.id, required this.sourceEntityId, required this.targetEntityId, required this.kind}); final String id; final String sourceEntityId; final String targetEntityId; final String kind; }
class Fact { const Fact({required this.id, required this.documentId, required this.extractedFact, required this.inference, required this.legalConclusion}); final String id; final String documentId; final String extractedFact; final String inference; final String legalConclusion; }
class Vehicle { const Vehicle({required this.id, required this.plate, required this.ownerEntityId}); final String id; final String plate; final String ownerEntityId; }
class Transfer { const Transfer({required this.id, required this.vehicleId, required this.fromEntityId, required this.toEntityId}); final String id; final String vehicleId; final String fromEntityId; final String toEntityId; }
class RiskRecord { const RiskRecord({required this.id, required this.processId, required this.probability, required this.impact, required this.score}); final String id; final String processId; final double probability; final double impact; final double score; }
class KnowledgeItem { const KnowledgeItem({required this.id, required this.category, required this.title, required this.confidence}); final String id; final String category; final String title; final double confidence; }
class AuditLog { const AuditLog({required this.id, required this.userId, required this.action, required this.objectType, required this.createdAt}); final String id; final String userId; final String action; final String objectType; final DateTime createdAt; }
class ValidationRecord { const ValidationRecord({required this.id, required this.documentId, required this.status, required this.notes}); final String id; final String documentId; final String status; final String notes; }
class Tag { const Tag({required this.id, required this.label}); final String id; final String label; }
class Attachment { const Attachment({required this.id, required this.documentId, required this.filePath}); final String id; final String documentId; final String filePath; }
