class DigitalWillRequest {
  const DigitalWillRequest({
    required this.step1BasicInfo,
    required this.step2Assets,
    required this.step3Liabilities,
    required this.step4Wasiyyah,
    required this.step5Heirs,
  });

  final Step1BasicInfoRequest step1BasicInfo;
  final Step2AssetsRequest step2Assets;
  final Step3LiabilitiesRequest step3Liabilities;
  final Step4WasiyyahRequest step4Wasiyyah;
  final Step5HeirsRequest step5Heirs;

  Map<String, dynamic> toJson() {
    return {
      'step1_basic_info': step1BasicInfo.toJson(),
      'step2_assets': step2Assets.toJson(),
      'step3_liabilities': step3Liabilities.toJson(),
      'step4_wasiyyah': step4Wasiyyah.toJson(),
      'step5_heirs': step5Heirs.toJson(),
    };
  }
}

class Step1BasicInfoRequest {
  const Step1BasicInfoRequest({
    required this.firebaseUserId,
    required this.userName,
    required this.userEmail,
    required this.fullName,
    required this.gender,
    required this.dateOfBirth,
    required this.dateOfDeath,
    required this.countryJurisdiction,
    required this.executorName,
    required this.executorContact,
  });

  final String firebaseUserId;
  final String userName;
  final String userEmail;
  final String fullName;
  final String gender;
  final String dateOfBirth;
  final String dateOfDeath;
  final String countryJurisdiction;
  final String executorName;
  final String executorContact;

  Map<String, dynamic> toJson() {
    return {
      'firebase_user_id': firebaseUserId,
      'user_name': userName,
      'user_email': userEmail,
      'full_name': fullName,
      'gender': gender.toLowerCase(),
      'date_of_birth': dateOfBirth,
      'date_of_death': dateOfDeath,
      'country_jurisdiction': countryJurisdiction,
      'executor_name': executorName,
      'executor_contact': executorContact,
    };
  }
}

class DigitalWillAssetItemRequest {
  const DigitalWillAssetItemRequest({
    required this.name,
    required this.estimatedValue,
    required this.notes,
  });

  final String name;
  final double estimatedValue;
  final String notes;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'estimated_value': estimatedValue,
      'notes': notes,
    };
  }
}

class Step2AssetsRequest {
  const Step2AssetsRequest({
    required this.realEstate,
    required this.vehicles,
    required this.financialAssets,
    required this.businessAssets,
    required this.preciousMetals,
    required this.otherAssets,
  });

  final List<DigitalWillAssetItemRequest> realEstate;
  final List<DigitalWillAssetItemRequest> vehicles;
  final List<DigitalWillAssetItemRequest> financialAssets;
  final List<DigitalWillAssetItemRequest> businessAssets;
  final List<DigitalWillAssetItemRequest> preciousMetals;
  final List<DigitalWillAssetItemRequest> otherAssets;

  Map<String, dynamic> toJson() {
    return {
      'real_estate': realEstate.map((item) => item.toJson()).toList(),
      'vehicles': vehicles.map((item) => item.toJson()).toList(),
      'financial_assets': financialAssets.map((item) => item.toJson()).toList(),
      'business_assets': businessAssets.map((item) => item.toJson()).toList(),
      'precious_metals': preciousMetals.map((item) => item.toJson()).toList(),
      'other_assets': otherAssets.map((item) => item.toJson()).toList(),
    };
  }
}

class DigitalWillLiabilityItemRequest {
  const DigitalWillLiabilityItemRequest({
    required this.name,
    required this.estimatedValue,
    required this.notes,
  });

  final String name;
  final double estimatedValue;
  final String notes;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'estimated_value': estimatedValue,
      'notes': notes,
    };
  }
}

class Step3LiabilitiesRequest {
  const Step3LiabilitiesRequest({
    required this.debts,
    required this.mahrDue,
    required this.funeralExpenses,
  });

  final List<DigitalWillLiabilityItemRequest> debts;
  final List<DigitalWillLiabilityItemRequest> mahrDue;
  final List<DigitalWillLiabilityItemRequest> funeralExpenses;

  Map<String, dynamic> toJson() {
    return {
      'debts': debts.map((item) => item.toJson()).toList(),
      'mahr_due': mahrDue.map((item) => item.toJson()).toList(),
      'funeral_expenses': funeralExpenses.map((item) => item.toJson()).toList(),
    };
  }
}

class DigitalWillBeneficiaryRequest {
  const DigitalWillBeneficiaryRequest({
    required this.type,
    required this.name,
    required this.amount,
    required this.percentage,
    required this.isHeir,
    required this.description,
  });

  final String type;
  final String name;
  final double? amount;
  final double? percentage;
  final bool isHeir;
  final String description;

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'name': name,
      'amount': amount,
      'percentage': percentage,
      'is_heir': isHeir,
      'description': description,
    };
  }
}

class Step4WasiyyahRequest {
  const Step4WasiyyahRequest({
    required this.hasWasiyyah,
    required this.wasiyyahType,
    required this.beneficiaries,
    required this.totalWasiyyahAmount,
    required this.notes,
  });

  final bool hasWasiyyah;
  final String wasiyyahType;
  final List<DigitalWillBeneficiaryRequest> beneficiaries;
  final double totalWasiyyahAmount;
  final String notes;

  Map<String, dynamic> toJson() {
    return {
      'has_wasiyyah': hasWasiyyah,
      'wasiyyah_type': wasiyyahType,
      'beneficiaries': beneficiaries.map((item) => item.toJson()).toList(),
      'total_wasiyyah_amount': totalWasiyyahAmount,
      'notes': notes,
    };
  }
}

class Step5HeirsRequest {
  const Step5HeirsRequest({
    required this.maritalStatus,
    required this.wivesCount,
    required this.wifeStatuses,
    required this.wifeNames,
    required this.fatherAlive,
    required this.motherAlive,
    required this.sons,
    required this.daughters,
    required this.sonNames,
    required this.daughterNames,
    required this.grandfatherAlive,
    required this.grandmotherMaternalAlive,
    required this.grandmotherPaternalAlive,
    required this.brothersCount,
    required this.sistersCount,
    required this.brothersFull,
    required this.sistersFull,
    required this.brothersPaternal,
    required this.sistersPaternal,
    required this.brothersMaternal,
    required this.sistersMaternal,
    required this.nephews,
    required this.uncles,
    required this.cousins,
  });

  final String maritalStatus;
  final int wivesCount;
  final List<String> wifeStatuses;
  final List<String> wifeNames;
  final bool fatherAlive;
  final bool motherAlive;
  final int sons;
  final int daughters;
  final List<String> sonNames;
  final List<String> daughterNames;
  final bool grandfatherAlive;
  final bool grandmotherMaternalAlive;
  final bool grandmotherPaternalAlive;
  final int brothersCount;
  final int sistersCount;
  final int brothersFull;
  final int sistersFull;
  final int brothersPaternal;
  final int sistersPaternal;
  final int brothersMaternal;
  final int sistersMaternal;
  final int nephews;
  final int uncles;
  final int cousins;

  Map<String, dynamic> toJson() {
    return {
      'marital_status': maritalStatus.toLowerCase(),
      'wives_count': wivesCount,
      'wife_statuses':
          wifeStatuses.map((status) => status.toLowerCase()).toList(),
      'wife_names': wifeNames,
      'father_alive': fatherAlive,
      'mother_alive': motherAlive,
      'sons': sons,
      'daughters': daughters,
      'son_names': sonNames,
      'daughter_names': daughterNames,
      'grandfather_alive': grandfatherAlive,
      'grandmother_maternal_alive': grandmotherMaternalAlive,
      'grandmother_paternal_alive': grandmotherPaternalAlive,
      'brothers_count': brothersCount,
      'sisters_count': sistersCount,
      'brothers_full': brothersFull,
      'sisters_full': sistersFull,
      'brothers_paternal': brothersPaternal,
      'sisters_paternal': sistersPaternal,
      'brothers_maternal': brothersMaternal,
      'sisters_maternal': sistersMaternal,
      'nephews': nephews,
      'uncles': uncles,
      'cousins': cousins,
    };
  }
}
