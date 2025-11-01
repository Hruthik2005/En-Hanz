class Profile {
  String name;
  int age;
  String schoolClass;
  String gender;
  List<String> disabilities;
  String handedness;

  Profile({
    required this.name,
    required this.age,
    required this.schoolClass,
    required this.gender,
    required this.disabilities,
    required this.handedness,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
        'schoolClass': schoolClass,
        'gender': gender,
        'disabilities': disabilities,
        'handedness': handedness,
      };

  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
        name: j['name'] ?? '',
        age: j['age'] ?? 0,
        schoolClass: j['schoolClass'] ?? '',
        gender: j['gender'] ?? '',
        disabilities: List<String>.from(j['disabilities'] ?? []),
        handedness: j['handedness'] ?? 'Right',
      );
}
