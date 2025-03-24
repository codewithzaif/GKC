import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/member.dart';
import '../models/fund.dart';

class DatabaseService {
  static const String _membersKey = 'members';
  static const String _fundsKey = 'funds';

  // Member methods
  Future<List<Member>> getMembers() async {
    final prefs = await SharedPreferences.getInstance();
    final membersJson = prefs.getStringList(_membersKey) ?? [];
    
    return membersJson
        .map((memberStr) => Member.fromJson(jsonDecode(memberStr)))
        .toList();
  }

  Future<void> saveMember(Member member) async {
    final prefs = await SharedPreferences.getInstance();
    final members = await getMembers();
    
    // Check if member exists and update, otherwise add
    final index = members.indexWhere((m) => m.id == member.id);
    if (index >= 0) {
      members[index] = member;
    } else {
      members.add(member);
    }
    
    await prefs.setStringList(
      _membersKey,
      members.map((member) => jsonEncode(member.toJson())).toList(),
    );
  }

  Future<void> deleteMember(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final members = await getMembers();
    
    members.removeWhere((member) => member.id == id);
    
    await prefs.setStringList(
      _membersKey,
      members.map((member) => jsonEncode(member.toJson())).toList(),
    );
  }

  Future<void> updateMemberPaymentStatus(String id, bool hasPaid) async {
    final members = await getMembers();
    final index = members.indexWhere((member) => member.id == id);
    
    if (index >= 0) {
      final member = members[index];
      final updatedMember = Member(
        id: member.id,
        name: member.name,
        contactNumber: member.contactNumber,
        email: member.email,
        houseNumber: member.houseNumber,
        isOwner: member.isOwner,
        hasPaid: hasPaid,
        latitude: member.latitude,
        longitude: member.longitude,
      );
      
      await saveMember(updatedMember);
    }
  }

  // Fund methods
  Future<List<Fund>> getFunds() async {
    final prefs = await SharedPreferences.getInstance();
    final fundsJson = prefs.getStringList(_fundsKey) ?? [];
    
    return fundsJson
        .map((fundStr) => Fund.fromJson(jsonDecode(fundStr)))
        .toList();
  }

  Future<void> saveFund(Fund fund) async {
    final prefs = await SharedPreferences.getInstance();
    final funds = await getFunds();
    
    // Check if fund exists and update, otherwise add
    final index = funds.indexWhere((f) => f.id == fund.id);
    if (index >= 0) {
      funds[index] = fund;
    } else {
      funds.add(fund);
    }
    
    await prefs.setStringList(
      _fundsKey,
      funds.map((fund) => jsonEncode(fund.toJson())).toList(),
    );
  }

  Future<void> deleteFund(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final funds = await getFunds();
    
    funds.removeWhere((fund) => fund.id == id);
    
    await prefs.setStringList(
      _fundsKey,
      funds.map((fund) => jsonEncode(fund.toJson())).toList(),
    );
  }

  // Get total fund balance
  Future<double> getTotalBalance() async {
    final funds = await getFunds();
    double total = 0;
    
    for (var fund in funds) {
      if (fund.isIncome) {
        total += fund.amount;
      } else {
        total -= fund.amount;
      }
    }
    
    return total;
  }
} 