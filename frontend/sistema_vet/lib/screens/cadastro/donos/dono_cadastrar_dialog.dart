/* Dialog de cadastro de novo dono — usado no painel admin.
 * Coleta os dados do tutor (nome, CPF, e-mail, telefone, endereço e senha)
 * e chama DonoService.criar() para registrar no backend. */
import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../models/dono_model.dart';
import '../../../services/dono_service.dart';

/// Abre o diálogo de cadastro de um novo Dono/Tutor (uso administrativo).
/// Retorna [true] se o dono foi cadastrado com sucesso.
Future<bool> mostrarCadastrarDonoDialog(BuildContext context) async {
  final nomeCtrl  = TextEditingController();
  final cpfCtrl   = TextEditingController();
  final emailCtrl = TextEditingController();
  final telCtrl   = TextEditingController();
  final endCtrl   = TextEditingController();
  final senhaCtrl = TextEditingController();

  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Novo Dono/Tutor',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
      ),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _f('Nome *', nomeCtrl),
          _f('CPF *', cpfCtrl, hint: '000.000.000-00'),
          _f('E-mail *', emailCtrl),
          _f('Telefone *', telCtrl),
          _f('Endereço *', endCtrl),
          _f('Senha * (mín. 6 caracteres)', senhaCtrl, obscure: true),
        ]),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: () async {
            if (nomeCtrl.text.trim().isEmpty ||
                cpfCtrl.text.trim().isEmpty ||
                senhaCtrl.text.length < 6) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(
                    content: Text('Preencha todos os campos obrigatórios.'),
                    backgroundColor: AppColors.error),
              );
              return;
            }
            try {
              await DonoService.criar(CreateDonoRequest(
                nome:      nomeCtrl.text.trim(),
                cpf:       cpfCtrl.text.trim(),
                email:     emailCtrl.text.trim(),
                telefone:  telCtrl.text.trim(),
                endereco:  endCtrl.text.trim(),
                senha:     senhaCtrl.text,
              ));
              if (ctx.mounted) Navigator.pop(ctx, true);
            } catch (e) {
              if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                      content: Text('Erro: $e'),
                      backgroundColor: AppColors.error),
                );
              }
            }
          },
          child:
              const Text('Salvar', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );

  return result == true;
}

Widget _f(String label, TextEditingController ctrl,
    {String? hint, bool obscure = false}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(
      controller: ctrl,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    ),
  );
}
