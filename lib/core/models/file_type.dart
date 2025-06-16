enum FileType {
  SHOPPING_LIST,
  EXTRA_INFORMATION,
  MEAL_PLAN,
  RECOMMENDATIONS,
  MEASUREMENTS
}

extension FileTypeExtension on FileType {
  String get description {
    switch (this) {
      case FileType.SHOPPING_LIST:
        return "Lista de Compras";
      case FileType.EXTRA_INFORMATION:
        return "Información Extra";
      case FileType.MEAL_PLAN:
        return "Plan de Alimentación";
      case FileType.RECOMMENDATIONS:
        return "Recomendaciones";
      case FileType.MEASUREMENTS:
        return "Mediciones";
    }
  }
}