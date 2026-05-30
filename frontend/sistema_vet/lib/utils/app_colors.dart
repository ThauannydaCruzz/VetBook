import 'package:flutter/material.dart';

/* Paleta de cores centralizada do VetBook.
 * Centralizar as cores aqui facilita manter consistência visual em todo o app
 * e permite mudar o tema em um único lugar. */
class AppColors {
  // Cor principal do app — verde veterinário (#2D7D5A)
  static const Color primary      = Color(0xFF2D7D5A);
  // Versão clara do primary — usada em fundos de cards e chips
  static const Color primaryLight = Color(0xFFE8F5EF);
  // Versão escura do primary — usada em gradientes e overlays
  static const Color primaryMid   = Color(0xFF1A5C40);
  // Cor secundária — azul para elementos informativos
  static const Color secondary    = Color(0xFF4A90D9);
  // Cor de destaque — laranja para preços e avisos leves
  static const Color accent       = Color(0xFFF5A623);
  // Cor de fundo das telas
  static const Color surface      = Color(0xFFF7FAF9);
  // Cor de fundo de cards e containers
  static const Color card         = Color(0xFFFFFFFF);
  // Cor principal do texto — quase preto esverdeado
  static const Color textPrimary  = Color(0xFF1A2E26);
  // Cor de texto secundário — usado em labels, datas, informações menos importantes
  static const Color textMuted    = Color(0xFF6B8C7D);
  // Cor de erro — vermelho para mensagens de erro e ações destrutivas
  static const Color error        = Color(0xFFE24B4A);
  // Alias de error — mantido para compatibilidade com código legado
  static const Color danger       = Color(0xFFE24B4A);
  // Cor de sucesso — verde escuro para confirmações e status positivos
  static const Color success      = Color(0xFF3B8B2D);
  // Cor de aviso — laranja (mesmo que accent) para alertas
  static const Color warning      = Color(0xFFF5A623);
  // Cor de bordas e divisores — verde muito claro
  static const Color border       = Color(0xFFD6E8DE);

  // Cores de badge para status "Agendada" (amarelo âmbar)
  static const Color badgeAmber   = Color(0xFFFEF3E2); // Fundo do badge
  static const Color textAmber    = Color(0xFFB07000);  // Texto do badge
}
