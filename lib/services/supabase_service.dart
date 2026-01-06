import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  static const String supabaseUrl = 'https://qnljbtpffljaemgrrnkh.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_iSx4h5Vl08WHnxj_c7TmLA_bIhYiM-C';

  SupabaseClient get client => Supabase.instance.client;

  GoTrueClient get auth => client.auth;

  SupabaseQueryBuilder get notes => client.from('notes');

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
}
