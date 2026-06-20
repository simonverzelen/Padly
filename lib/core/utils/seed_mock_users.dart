import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedMockUsers() async {
  final firestore = FirebaseFirestore.instance;

  final users = [
    {
      'id': 'mock_jan_dewit',
      'firstName': 'Jan',
      'lastName': 'De Wit',
      'name': 'Jan De Wit',
      'rank': 'P400',
      'email': 'jan@padly.be',
      'imageUrl': 'https://i.pravatar.cc/300?img=11',
    },
    {
      'id': 'mock_emma_claes',
      'firstName': 'Emma',
      'lastName': 'Claes',
      'name': 'Emma Claes',
      'rank': 'P300',
      'email': 'emma@padly.be',
      'imageUrl': 'https://i.pravatar.cc/300?img=1',
    },
    {
      'id': 'mock_thomas_peeters',
      'firstName': 'Thomas',
      'lastName': 'Peeters',
      'name': 'Thomas Peeters',
      'rank': 'P200',
      'email': 'thomas@padly.be',
      'imageUrl': 'https://i.pravatar.cc/300?img=12',
    },
    {
      'id': 'mock_sarah_vermeersch',
      'firstName': 'Sarah',
      'lastName': 'Vermeersch',
      'name': 'Sarah Vermeersch',
      'rank': 'P500',
      'email': 'sarah@padly.be',
      'imageUrl': 'https://i.pravatar.cc/300?img=5',
    },
    {
      'id': 'mock_luca_martens',
      'firstName': 'Luca',
      'lastName': 'Martens',
      'name': 'Luca Martens',
      'rank': 'P100',
      'email': 'luca@padly.be',
      'imageUrl': 'https://i.pravatar.cc/300?img=13',
    },
    {
      'id': 'mock_charlotte_dupont',
      'firstName': 'Charlotte',
      'lastName': 'Dupont',
      'name': 'Charlotte Dupont',
      'rank': 'P300',
      'email': 'charlotte@padly.be',
      'imageUrl': 'https://i.pravatar.cc/300?img=3',
    },
    {
      'id': 'mock_daan_hendrickx',
      'firstName': 'Daan',
      'lastName': 'Hendrickx',
      'name': 'Daan Hendrickx',
      'rank': 'P400',
      'email': 'daan@padly.be',
      'imageUrl': 'https://i.pravatar.cc/300?img=15',
    },
    {
      'id': 'mock_julie_wouters',
      'firstName': 'Julie',
      'lastName': 'Wouters',
      'name': 'Julie Wouters',
      'rank': 'P200',
      'email': 'julie@padly.be',
      'imageUrl': 'https://i.pravatar.cc/300?img=2',
    },
  ];

  for (final user in users) {
    final id = user['id'] as String;
    final ref = firestore.collection('users').doc(id);
    final doc = await ref.get();
    if (!doc.exists) {
      final data = Map<String, dynamic>.from(user)
        ..remove('id')
        ..['searchKeywords'] = _generateKeywords(user['name'] as String);
      await ref.set(data, SetOptions(merge: true));
    }
  }
}

List<String> _generateKeywords(String fullName) {
  final keywords = <String>{};
  for (final word in fullName.trim().split(RegExp(r'\s+'))) {
    final lower = word.toLowerCase();
    for (int i = 1; i <= lower.length; i++) {
      keywords.add(lower.substring(0, i));
    }
  }
  return keywords.toList();
}
