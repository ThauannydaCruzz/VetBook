import 'package:flutter/material.dart';

/* Chave global do Navigator — permite navegar de qualquer lugar do app,
 * mesmo fora da árvore de widgets (ex: dentro do ApiService).
 *
 * Por que isso é necessário?
 * Quando o ApiService detecta um erro 401 (token expirado), ele precisa
 * redirecionar o usuário para a tela de login, mas não tem acesso ao BuildContext.
 * Usando appNavigatorKey.currentState?.pushReplacementNamed('/login'),
 * a navegação funciona de qualquer parte do código. */
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
