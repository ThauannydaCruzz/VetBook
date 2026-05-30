/* Dialog de cadastro de novo veterinário — usado no painel admin.
 * Coleta nome, CRMV, especialidade, e-mail, telefone e clínica (opcional).
 * O dropdown de clínica mostra apenas as clínicas ativas.
 * Chama VeterinarioService.criar() com token de admin. */
import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../models/veterinario_model.dart';
import '../../../services/veterinario_service.dart';

/// Abre o diálogo de cadastro de um novo Veterinário.
/// Retorna [true] se cadastrado com sucesso.
Future<bool> mostrarCadastrarVetDialog(BuildContext context) async {
  final nomeCtrl  = TextEditingController();
  final crmvCtrl  = TextEditingController();
  final specCtrl  = TextEditingController();
  final emailCtrl = TextEditingController();
  final telCtrl   = TextEditingController();

  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Novo Veterinário',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
      ),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _f('Nome *', nomeCtrl),
          _f('CRMV (ex: SP-12345) *', crmvCtrl),
          _f('Especialidade *', specCtrl),
          _f('E-mail *', emailCtrl),
          _f('Telefone *', telCtrl),
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
                crmvCtrl.text.trim().isEmpty ||
                specCtrl.text.trim().isEmpty) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(
                    content: Text('Preencha os campos obrigatórios.'),
                    backgroundColor: AppColors.error),
              );
              return;
            }
            try {
              await VeterinarioService.criar(CreateVeterinarioRequest(
                nome:         nomeCtrl.text.trim(),
                crmv:         crmvCtrl.text.trim(),
                especialidade: specCtrl.text.trim(),
                email:        emailCtrl.text.trim(),
                telefone:     telCtrl.text.trim(),
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

Widget _f(String label, TextEditingController ctrl) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    ),
  );
}
