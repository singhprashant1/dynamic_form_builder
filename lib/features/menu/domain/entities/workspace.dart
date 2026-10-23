import 'package:equatable/equatable.dart';

/// One selectable app config (Sales, HR, …).
class Workspace extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? icon;

  /// Theme seed colour as `#RRGGBB`.
  final String? color;

  const Workspace({
    required this.id,
    required this.title,
    this.description,
    this.icon,
    this.color,
  });

  @override
  List<Object?> get props => [id, title, description, icon, color];
}
