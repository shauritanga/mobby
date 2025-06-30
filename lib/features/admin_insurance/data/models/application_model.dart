import '../../domain/entities/application.dart';

/// Insurance application model for data layer
class InsuranceApplicationModel extends InsuranceApplication {
  const InsuranceApplicationModel({
    required super.id,
    required super.applicationNumber,
    required super.userId,
    required super.userName,
    required super.userEmail,
    required super.partnerId,
    required super.partnerName,
    required super.type,
    required super.status,
    required super.priority,
    required super.title,
    required super.description,
    required super.applicationData,
    super.documents,
    super.notes,
    required super.requestedCoverageAmount,
    required super.premiumAmount,
    required super.currency,
    required super.requestedStartDate,
    required super.requestedEndDate,
    super.assignedTo,
    super.assignedToName,
    super.assignedDate,
    super.rejectionReason,
    super.statusHistory,
    super.underwritingData,
    super.riskScore,
    super.riskCategory,
    required super.submittedDate,
    super.processedDate,
    super.approvedDate,
    super.rejectedDate,
    super.metadata,
    required super.createdAt,
    required super.updatedAt,
  });

  factory InsuranceApplicationModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return InsuranceApplicationModel(
      id: id,
      applicationNumber: data['applicationNumber'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userEmail: data['userEmail'] ?? '',
      partnerId: data['partnerId'] ?? '',
      partnerName: data['partnerName'] ?? '',
      type: ApplicationType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => ApplicationType.motor,
      ),
      status: ApplicationStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ApplicationStatus.pending,
      ),
      priority: ApplicationPriority.values.firstWhere(
        (e) => e.name == data['priority'],
        orElse: () => ApplicationPriority.normal,
      ),
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      applicationData: Map<String, dynamic>.from(data['applicationData'] ?? {}),
      documents: (data['documents'] as List<dynamic>?)
          ?.map((e) => ApplicationDocumentModel.fromMap(e))
          .toList() ?? [],
      notes: (data['notes'] as List<dynamic>?)
          ?.map((e) => ApplicationNoteModel.fromMap(e))
          .toList() ?? [],
      requestedCoverageAmount: (data['requestedCoverageAmount'] ?? 0).toDouble(),
      premiumAmount: (data['premiumAmount'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'TZS',
      requestedStartDate: DateTime.parse(data['requestedStartDate']),
      requestedEndDate: DateTime.parse(data['requestedEndDate']),
      assignedTo: data['assignedTo'],
      assignedToName: data['assignedToName'],
      assignedDate: data['assignedDate'] != null ? DateTime.parse(data['assignedDate']) : null,
      rejectionReason: data['rejectionReason'],
      statusHistory: (data['statusHistory'] as List<dynamic>?)
          ?.map((e) => ApplicationStatusHistoryModel.fromMap(e))
          .toList() ?? [],
      underwritingData: Map<String, dynamic>.from(data['underwritingData'] ?? {}),
      riskScore: data['riskScore']?.toDouble(),
      riskCategory: data['riskCategory'],
      submittedDate: DateTime.parse(data['submittedDate']),
      processedDate: data['processedDate'] != null ? DateTime.parse(data['processedDate']) : null,
      approvedDate: data['approvedDate'] != null ? DateTime.parse(data['approvedDate']) : null,
      rejectedDate: data['rejectedDate'] != null ? DateTime.parse(data['rejectedDate']) : null,
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'applicationNumber': applicationNumber,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'partnerId': partnerId,
      'partnerName': partnerName,
      'type': type.name,
      'status': status.name,
      'priority': priority.name,
      'title': title,
      'description': description,
      'applicationData': applicationData,
      'documents': documents.map((e) => ApplicationDocumentModel.fromEntity(e).toMap()).toList(),
      'notes': notes.map((e) => ApplicationNoteModel.fromEntity(e).toMap()).toList(),
      'requestedCoverageAmount': requestedCoverageAmount,
      'premiumAmount': premiumAmount,
      'currency': currency,
      'requestedStartDate': requestedStartDate.toIso8601String(),
      'requestedEndDate': requestedEndDate.toIso8601String(),
      'assignedTo': assignedTo,
      'assignedToName': assignedToName,
      'assignedDate': assignedDate?.toIso8601String(),
      'rejectionReason': rejectionReason,
      'statusHistory': statusHistory.map((e) => ApplicationStatusHistoryModel.fromEntity(e).toMap()).toList(),
      'underwritingData': underwritingData,
      'riskScore': riskScore,
      'riskCategory': riskCategory,
      'submittedDate': submittedDate.toIso8601String(),
      'processedDate': processedDate?.toIso8601String(),
      'approvedDate': approvedDate?.toIso8601String(),
      'rejectedDate': rejectedDate?.toIso8601String(),
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory InsuranceApplicationModel.fromEntity(InsuranceApplication entity) {
    return InsuranceApplicationModel(
      id: entity.id,
      applicationNumber: entity.applicationNumber,
      userId: entity.userId,
      userName: entity.userName,
      userEmail: entity.userEmail,
      partnerId: entity.partnerId,
      partnerName: entity.partnerName,
      type: entity.type,
      status: entity.status,
      priority: entity.priority,
      title: entity.title,
      description: entity.description,
      applicationData: entity.applicationData,
      documents: entity.documents,
      notes: entity.notes,
      requestedCoverageAmount: entity.requestedCoverageAmount,
      premiumAmount: entity.premiumAmount,
      currency: entity.currency,
      requestedStartDate: entity.requestedStartDate,
      requestedEndDate: entity.requestedEndDate,
      assignedTo: entity.assignedTo,
      assignedToName: entity.assignedToName,
      assignedDate: entity.assignedDate,
      rejectionReason: entity.rejectionReason,
      statusHistory: entity.statusHistory,
      underwritingData: entity.underwritingData,
      riskScore: entity.riskScore,
      riskCategory: entity.riskCategory,
      submittedDate: entity.submittedDate,
      processedDate: entity.processedDate,
      approvedDate: entity.approvedDate,
      rejectedDate: entity.rejectedDate,
      metadata: entity.metadata,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  InsuranceApplication toEntity() {
    return InsuranceApplication(
      id: id,
      applicationNumber: applicationNumber,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      partnerId: partnerId,
      partnerName: partnerName,
      type: type,
      status: status,
      priority: priority,
      title: title,
      description: description,
      applicationData: applicationData,
      documents: documents,
      notes: notes,
      requestedCoverageAmount: requestedCoverageAmount,
      premiumAmount: premiumAmount,
      currency: currency,
      requestedStartDate: requestedStartDate,
      requestedEndDate: requestedEndDate,
      assignedTo: assignedTo,
      assignedToName: assignedToName,
      assignedDate: assignedDate,
      rejectionReason: rejectionReason,
      statusHistory: statusHistory,
      underwritingData: underwritingData,
      riskScore: riskScore,
      riskCategory: riskCategory,
      submittedDate: submittedDate,
      processedDate: processedDate,
      approvedDate: approvedDate,
      rejectedDate: rejectedDate,
      metadata: metadata,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Application document model
class ApplicationDocumentModel extends ApplicationDocument {
  const ApplicationDocumentModel({
    required super.id,
    required super.fileName,
    required super.fileUrl,
    required super.documentType,
    required super.fileSize,
    required super.mimeType,
    required super.uploadedDate,
    required super.uploadedBy,
  });

  factory ApplicationDocumentModel.fromMap(Map<String, dynamic> data) {
    return ApplicationDocumentModel(
      id: data['id'] ?? '',
      fileName: data['fileName'] ?? '',
      fileUrl: data['fileUrl'] ?? '',
      documentType: data['documentType'] ?? '',
      fileSize: data['fileSize'] ?? 0,
      mimeType: data['mimeType'] ?? '',
      uploadedDate: DateTime.parse(data['uploadedDate']),
      uploadedBy: data['uploadedBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'documentType': documentType,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'uploadedDate': uploadedDate.toIso8601String(),
      'uploadedBy': uploadedBy,
    };
  }

  factory ApplicationDocumentModel.fromEntity(ApplicationDocument entity) {
    return ApplicationDocumentModel(
      id: entity.id,
      fileName: entity.fileName,
      fileUrl: entity.fileUrl,
      documentType: entity.documentType,
      fileSize: entity.fileSize,
      mimeType: entity.mimeType,
      uploadedDate: entity.uploadedDate,
      uploadedBy: entity.uploadedBy,
    );
  }
}

/// Application note model
class ApplicationNoteModel extends ApplicationNote {
  const ApplicationNoteModel({
    required super.id,
    required super.content,
    required super.addedBy,
    required super.addedByName,
    required super.isInternal,
    required super.addedDate,
  });

  factory ApplicationNoteModel.fromMap(Map<String, dynamic> data) {
    return ApplicationNoteModel(
      id: data['id'] ?? '',
      content: data['content'] ?? '',
      addedBy: data['addedBy'] ?? '',
      addedByName: data['addedByName'] ?? '',
      isInternal: data['isInternal'] ?? false,
      addedDate: DateTime.parse(data['addedDate']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'addedBy': addedBy,
      'addedByName': addedByName,
      'isInternal': isInternal,
      'addedDate': addedDate.toIso8601String(),
    };
  }

  factory ApplicationNoteModel.fromEntity(ApplicationNote entity) {
    return ApplicationNoteModel(
      id: entity.id,
      content: entity.content,
      addedBy: entity.addedBy,
      addedByName: entity.addedByName,
      isInternal: entity.isInternal,
      addedDate: entity.addedDate,
    );
  }
}

/// Application status history model
class ApplicationStatusHistoryModel extends ApplicationStatusHistory {
  const ApplicationStatusHistoryModel({
    required super.id,
    required super.fromStatus,
    required super.toStatus,
    required super.changedBy,
    required super.changedByName,
    super.reason,
    required super.changedDate,
  });

  factory ApplicationStatusHistoryModel.fromMap(Map<String, dynamic> data) {
    return ApplicationStatusHistoryModel(
      id: data['id'] ?? '',
      fromStatus: ApplicationStatus.values.firstWhere(
        (e) => e.name == data['fromStatus'],
        orElse: () => ApplicationStatus.pending,
      ),
      toStatus: ApplicationStatus.values.firstWhere(
        (e) => e.name == data['toStatus'],
        orElse: () => ApplicationStatus.pending,
      ),
      changedBy: data['changedBy'] ?? '',
      changedByName: data['changedByName'] ?? '',
      reason: data['reason'],
      changedDate: DateTime.parse(data['changedDate']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fromStatus': fromStatus.name,
      'toStatus': toStatus.name,
      'changedBy': changedBy,
      'changedByName': changedByName,
      'reason': reason,
      'changedDate': changedDate.toIso8601String(),
    };
  }

  factory ApplicationStatusHistoryModel.fromEntity(ApplicationStatusHistory entity) {
    return ApplicationStatusHistoryModel(
      id: entity.id,
      fromStatus: entity.fromStatus,
      toStatus: entity.toStatus,
      changedBy: entity.changedBy,
      changedByName: entity.changedByName,
      reason: entity.reason,
      changedDate: entity.changedDate,
    );
  }
}
