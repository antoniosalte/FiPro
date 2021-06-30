import 'package:flutter/material.dart';

import 'package:fipro/models.dart/settings.dart';

class SettingsService {
  static Future<Settings?> displayDialogOKCallBack(
      BuildContext context, Settings settings) async {
    return await showDialog<Settings?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Configuracion",
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tasa de Interes',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Efectiva"),
                  Radio<String>(
                    value: "Efectiva",
                    groupValue: settings.rateType,
                    onChanged: (String? value) {
                      settings.rateType = value!;
                      Navigator.of(context).pop(settings);
                    },
                  ),
                  SizedBox(width: 16.0),
                  Text("Nominal"),
                  Radio<String>(
                    value: "Nominal",
                    groupValue: settings.rateType,
                    onChanged: (String? value) {
                      settings.rateType = value!;
                      Navigator.of(context).pop(settings);
                    },
                  ),
                ],
              ),
              // SizedBox(height: 16.0),
              // Text(
              //   'Moneda',
              //   style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Text("Soles PEN"),
              //     Radio<String>(
              //       value: "Soles PEN",
              //       groupValue: settings.currency,
              //       onChanged: (String? value) {
              //         settings.currency = value!;
              //         Navigator.of(context).pop(settings);
              //       },
              //     ),
              //     SizedBox(width: 16.0),
              //     Text("Dolares USD"),
              //     Radio<String>(
              //       value: "Dolares USD",
              //       groupValue: settings.currency,
              //       onChanged: (String? value) {
              //         settings.currency = value!;
              //         Navigator.of(context).pop(settings);
              //       },
              //     ),
              //   ],
              // ),
            ],
          ),
        );
      },
    );
  }
}
