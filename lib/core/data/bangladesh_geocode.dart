/// Bangladesh administrative divisions and districts data
/// Source: https://github.com/nuhil/bangladesh-geocode

class Division {
  final String id;
  final String name;
  final String bnName;

  const Division({
    required this.id,
    required this.name,
    required this.bnName,
  });
}

class District {
  final String id;
  final String divisionId;
  final String name;
  final String bnName;

  const District({
    required this.id,
    required this.divisionId,
    required this.name,
    required this.bnName,
  });
}

class BangladeshGeocode {
  static const List<Division> divisions = [
    Division(id: '1', name: 'Chattagram', bnName: 'চট্টগ্রাম'),
    Division(id: '2', name: 'Rajshahi', bnName: 'রাজশাহী'),
    Division(id: '3', name: 'Khulna', bnName: 'খুলনা'),
    Division(id: '4', name: 'Barisal', bnName: 'বরিশাল'),
    Division(id: '5', name: 'Sylhet', bnName: 'সিলেট'),
    Division(id: '6', name: 'Dhaka', bnName: 'ঢাকা'),
    Division(id: '7', name: 'Rangpur', bnName: 'রংপুর'),
    Division(id: '8', name: 'Mymensingh', bnName: 'ময়মনসিংহ'),
  ];

  static const List<District> districts = [
    // Chattagram Division (id: 1)
    District(id: '1', divisionId: '1', name: 'Comilla', bnName: 'কুমিল্লা'),
    District(id: '2', divisionId: '1', name: 'Feni', bnName: 'ফেনী'),
    District(id: '3', divisionId: '1', name: 'Brahmanbaria', bnName: 'ব্রাহ্মণবাড়িয়া'),
    District(id: '4', divisionId: '1', name: 'Rangamati', bnName: 'রাঙ্গামাটি'),
    District(id: '5', divisionId: '1', name: 'Noakhali', bnName: 'নোয়াখালী'),
    District(id: '6', divisionId: '1', name: 'Chandpur', bnName: 'চাঁদপুর'),
    District(id: '7', divisionId: '1', name: 'Lakshmipur', bnName: 'লক্ষ্মীপুর'),
    District(id: '8', divisionId: '1', name: 'Chattogram', bnName: 'চট্টগ্রাম'),
    District(id: '9', divisionId: '1', name: 'Coxsbazar', bnName: 'কক্সবাজার'),
    District(id: '10', divisionId: '1', name: 'Khagrachhari', bnName: 'খাগড়াছড়ি'),
    District(id: '11', divisionId: '1', name: 'Bandarban', bnName: 'বান্দরবান'),

    // Rajshahi Division (id: 2)
    District(id: '12', divisionId: '2', name: 'Sirajganj', bnName: 'সিরাজগঞ্জ'),
    District(id: '13', divisionId: '2', name: 'Pabna', bnName: 'পাবনা'),
    District(id: '14', divisionId: '2', name: 'Bogra', bnName: 'বগুড়া'),
    District(id: '15', divisionId: '2', name: 'Rajshahi', bnName: 'রাজশাহী'),
    District(id: '16', divisionId: '2', name: 'Natore', bnName: 'নাটোর'),
    District(id: '17', divisionId: '2', name: 'Joypurhat', bnName: 'জয়পুরহাট'),
    District(id: '18', divisionId: '2', name: 'Chapainawabganj', bnName: 'চাঁপাইনবাবগঞ্জ'),
    District(id: '19', divisionId: '2', name: 'Naogaon', bnName: 'নওগাঁ'),

    // Khulna Division (id: 3)
    District(id: '20', divisionId: '3', name: 'Jessore', bnName: 'যশোর'),
    District(id: '21', divisionId: '3', name: 'Satkhira', bnName: 'সাতক্ষীরা'),
    District(id: '22', divisionId: '3', name: 'Meherpur', bnName: 'মেহেরপুর'),
    District(id: '23', divisionId: '3', name: 'Narail', bnName: 'নড়াইল'),
    District(id: '24', divisionId: '3', name: 'Chuadanga', bnName: 'চুয়াডাঙ্গা'),
    District(id: '25', divisionId: '3', name: 'Kushtia', bnName: 'কুষ্টিয়া'),
    District(id: '26', divisionId: '3', name: 'Magura', bnName: 'মাগুরা'),
    District(id: '27', divisionId: '3', name: 'Khulna', bnName: 'খুলনা'),
    District(id: '28', divisionId: '3', name: 'Bagerhat', bnName: 'বাগেরহাট'),
    District(id: '29', divisionId: '3', name: 'Jhenaidah', bnName: 'ঝিনাইদহ'),

    // Barisal Division (id: 4)
    District(id: '30', divisionId: '4', name: 'Jhalakathi', bnName: 'ঝালকাঠি'),
    District(id: '31', divisionId: '4', name: 'Patuakhali', bnName: 'পটুয়াখালী'),
    District(id: '32', divisionId: '4', name: 'Pirojpur', bnName: 'পিরোজপুর'),
    District(id: '33', divisionId: '4', name: 'Barisal', bnName: 'বরিশাল'),
    District(id: '34', divisionId: '4', name: 'Bhola', bnName: 'ভোলা'),
    District(id: '35', divisionId: '4', name: 'Barguna', bnName: 'বরগুনা'),

    // Sylhet Division (id: 5)
    District(id: '36', divisionId: '5', name: 'Sylhet', bnName: 'সিলেট'),
    District(id: '37', divisionId: '5', name: 'Moulvibazar', bnName: 'মৌলভীবাজার'),
    District(id: '38', divisionId: '5', name: 'Habiganj', bnName: 'হবিগঞ্জ'),
    District(id: '39', divisionId: '5', name: 'Sunamganj', bnName: 'সুনামগঞ্জ'),

    // Dhaka Division (id: 6)
    District(id: '40', divisionId: '6', name: 'Narsingdi', bnName: 'নরসিংদী'),
    District(id: '41', divisionId: '6', name: 'Gazipur', bnName: 'গাজীপুর'),
    District(id: '42', divisionId: '6', name: 'Shariatpur', bnName: 'শরীয়তপুর'),
    District(id: '43', divisionId: '6', name: 'Narayanganj', bnName: 'নারায়ণগঞ্জ'),
    District(id: '44', divisionId: '6', name: 'Tangail', bnName: 'টাঙ্গাইল'),
    District(id: '45', divisionId: '6', name: 'Kishoreganj', bnName: 'কিশোরগঞ্জ'),
    District(id: '46', divisionId: '6', name: 'Manikganj', bnName: 'মানিকগঞ্জ'),
    District(id: '47', divisionId: '6', name: 'Dhaka', bnName: 'ঢাকা'),
    District(id: '48', divisionId: '6', name: 'Munshiganj', bnName: 'মুন্সিগঞ্জ'),
    District(id: '49', divisionId: '6', name: 'Rajbari', bnName: 'রাজবাড়ী'),
    District(id: '50', divisionId: '6', name: 'Madaripur', bnName: 'মাদারীপুর'),
    District(id: '51', divisionId: '6', name: 'Gopalganj', bnName: 'গোপালগঞ্জ'),
    District(id: '52', divisionId: '6', name: 'Faridpur', bnName: 'ফরিদপুর'),

    // Rangpur Division (id: 7)
    District(id: '53', divisionId: '7', name: 'Panchagarh', bnName: 'পঞ্চগড়'),
    District(id: '54', divisionId: '7', name: 'Dinajpur', bnName: 'দিনাজপুর'),
    District(id: '55', divisionId: '7', name: 'Lalmonirhat', bnName: 'লালমনিরহাট'),
    District(id: '56', divisionId: '7', name: 'Nilphamari', bnName: 'নীলফামারী'),
    District(id: '57', divisionId: '7', name: 'Gaibandha', bnName: 'গাইবান্ধা'),
    District(id: '58', divisionId: '7', name: 'Thakurgaon', bnName: 'ঠাকুরগাঁও'),
    District(id: '59', divisionId: '7', name: 'Rangpur', bnName: 'রংপুর'),
    District(id: '60', divisionId: '7', name: 'Kurigram', bnName: 'কুড়িগ্রাম'),

    // Mymensingh Division (id: 8)
    District(id: '61', divisionId: '8', name: 'Sherpur', bnName: 'শেরপুর'),
    District(id: '62', divisionId: '8', name: 'Mymensingh', bnName: 'ময়মনসিংহ'),
    District(id: '63', divisionId: '8', name: 'Jamalpur', bnName: 'জামালপুর'),
    District(id: '64', divisionId: '8', name: 'Netrokona', bnName: 'নেত্রকোণা'),
  ];

  /// Get division by ID
  static Division? getDivisionById(String id) {
    try {
      return divisions.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get districts for a division
  static List<District> getDistrictsByDivision(String divisionId) {
    return districts.where((d) => d.divisionId == divisionId).toList();
  }

  /// Get district by ID
  static District? getDistrictById(String id) {
    try {
      return districts.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Common occupation list
  static const List<String> occupations = [
    'Student',
    'Software Engineer',
    'Doctor',
    'Teacher',
    'Business Owner',
    'Government Employee',
    'Private Employee',
    'Banker',
    'Lawyer',
    'Engineer',
    'Accountant',
    'Farmer',
    'Freelancer',
    'Homemaker',
    'Retired',
    'Other',
  ];

  /// Bengali occupation names
  static const Map<String, String> occupationsBn = {
    'Student': 'শিক্ষার্থী',
    'Software Engineer': 'সফটওয়্যার ইঞ্জিনিয়ার',
    'Doctor': 'ডাক্তার',
    'Teacher': 'শিক্ষক',
    'Business Owner': 'ব্যবসায়ী',
    'Government Employee': 'সরকারি চাকরিজীবী',
    'Private Employee': 'বেসরকারি চাকরিজীবী',
    'Banker': 'ব্যাংকার',
    'Lawyer': 'আইনজীবী',
    'Engineer': 'প্রকৌশলী',
    'Accountant': 'হিসাবরক্ষক',
    'Farmer': 'কৃষক',
    'Freelancer': 'ফ্রিল্যান্সার',
    'Homemaker': 'গৃহিণী',
    'Retired': 'অবসরপ্রাপ্ত',
    'Other': 'অন্যান্য',
  };
}
