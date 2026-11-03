// Yemen Real Estate Portal — بوابة اليمن العقارية
// Contract Service — إدارة نماذج وحفظ عقود الملاك

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/property.dart';
import '../models/property_contract.dart';

class ContractService {
  static const String _defaultTemplateKey =
      'yemen_real_estate_owner_default_contract';
  static const String _contractsPrefix = 'yemen_real_estate_contract_';

  /// In-memory cache for demo/fast access
  static final Map<String, PropertyContract> _memoryContracts = {};

  /// جلب النموذج الافتراضي المحفوظ لصاحب العقار
  static Future<PropertyContract> getOwnerDefaultTemplate({
    required Property property,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedJsonStr = prefs.getString(_defaultTemplateKey);
      if (savedJsonStr != null && savedJsonStr.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(savedJsonStr);
        final savedContract = PropertyContract.fromJson(data);
        // مهم: نُعيد استخدام بنود العقد فقط، وليس اسم المستأجر
        // اسم المستأجر يجب أن يكون فارغاً في كل عقد جديد
        return savedContract.copyWith(
          propertyId: property.id,
          propertyCity: property.city,
          propertyDistrict: property.district,
          propertyAddressDetails: property.addressDetails ?? '',
          amount: property.price,
          currency: property.currency,
          contractType: property.dealType,
          tenantName: '', // لا نُعيد استخدام اسم مستأجر من عقد سابق
          tenantPhone: '', // لا نُعيد استخدام هاتف مستأجر من عقد سابق
          tenantIdCard: '', // لا نُعيد استخدام هوية مستأجر من عقد سابق
          tenantAddress: '', // لا نُعيد استخدام عنوان مستأجر من عقد سابق
        );
      }
    } catch (_) {}

    return PropertyContract.defaultTemplate(
      propertyId: property.id,
      ownerName: property.owner?.fullName ?? '',
      ownerPhone: property.contactPhone,
      city: property.city,
      district: property.district,
      price: property.price,
      currency: property.currency,
      dealType: property.dealType,
    );
  }

  /// حفظ العقد الحالي كنموذج افتراضي للعقارات القادمة
  static Future<void> saveAsDefaultTemplate(PropertyContract contract) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_defaultTemplateKey, jsonEncode(contract.toJson()));
    } catch (_) {}
  }

  /// حفظ عقد خاص بعقار معين
  static Future<void> savePropertyContract(PropertyContract contract) async {
    _memoryContracts[contract.propertyId] = contract;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        '$_contractsPrefix${contract.propertyId}',
        jsonEncode(contract.toJson()),
      );
    } catch (_) {}
  }

  /// جلب عقد عقار معين
  static Future<PropertyContract> getPropertyContract(Property property) async {
    if (_memoryContracts.containsKey(property.id)) {
      return _memoryContracts[property.id]!;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedStr = prefs.getString('$_contractsPrefix${property.id}');
      if (savedStr != null) {
        final contract = PropertyContract.fromJson(jsonDecode(savedStr));
        _memoryContracts[property.id] = contract;
        return contract;
      }
    } catch (_) {}

    final defaultContract = await getOwnerDefaultTemplate(property: property);
    _memoryContracts[property.id] = defaultContract;
    return defaultContract;
  }
}
