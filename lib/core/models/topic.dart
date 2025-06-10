enum Topic {
  ALL,
  PERDER_GRASA,
  MANTENER_PESO,
  AUMENTAR_PESO,
  GANAR_MUSCULO,
  HABITO_SALUDABLE
}

extension TopicExtension on Topic {
  String get description {
    switch (this) {
      case Topic.ALL:
        return "General";
      case Topic.PERDER_GRASA:
        return "Perder grasa";
      case Topic.MANTENER_PESO:
        return "Mantener peso";
      case Topic.AUMENTAR_PESO:
        return "Aumentar peso";
      case Topic.GANAR_MUSCULO:
        return "Ganar músculo";
      case Topic.HABITO_SALUDABLE:
        return "Crear hábitos saludables";
    }
  }
}