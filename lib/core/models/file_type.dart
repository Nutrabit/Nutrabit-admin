enum FileType {
  SHOPPING_LIST,
  EXERCISE_PLAN,
  MEAL_PLAN,
  RECOMMENDATIONS,
  IN_BODY
}

extension FileTypeExtension on FileType {
  String get description {
    switch (this) {
      case FileType.SHOPPING_LIST:
        return "Lista de Compras";
      case FileType.EXERCISE_PLAN:
        return "Plan de Ejercicio";
      case FileType.MEAL_PLAN:
        return "Plan de Alimentación";
      case FileType.RECOMMENDATIONS:
        return "Recomendaciones";
      case FileType.IN_BODY:
        return "InBody";
    }
  }
}