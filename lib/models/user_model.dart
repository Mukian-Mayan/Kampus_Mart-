class UserModel {
  final String? id;
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final String? address;
  final String? profileImageUrl;
  final String userType; // 'buyer', 'seller', 'admin'
  final bool isEmailVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    this.id,
    required this.email,
    this.displayName,
    this.phoneNumber,
    this.address,
    this.profileImageUrl,
    required this.userType,
    this.isEmailVerified = false,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor to create UserModel from Firestore document
  factory UserModel.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    // Handle both new format (displayName) and old format (firstName + lastName)
    String? displayName = data['displayName'];
    if (displayName == null || displayName.isEmpty) {
      final firstName = data['firstName'] ?? '';
      final lastName = data['lastName'] ?? '';
      if (firstName.isNotEmpty || lastName.isNotEmpty) {
        displayName = '$firstName $lastName'.trim();
      }
    }

    return UserModel(
      id: documentId,
      email: data['email'] ?? '',
      displayName: displayName,
      phoneNumber: data['phoneNumber'],
      address: data['address'],
      profileImageUrl: data['profileImageUrl'],
      userType: data['userType'] ?? data['role'] ?? 'buyer',
      isEmailVerified: data['isEmailVerified'] ?? false,
      createdAt: data['createdAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
    );
  }

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'address': address,
      'profileImageUrl': profileImageUrl,
      'userType': userType,
      'isEmailVerified': isEmailVerified,
    };
  }

  // Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? address,
    String? profileImageUrl,
    String? userType,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      userType: userType ?? this.userType,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
