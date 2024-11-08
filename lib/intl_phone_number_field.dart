// ignore_for_file: non_constant_identifier_names

library intl_phone_number_field;

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'models/country_code_model.dart';
import 'models/country_config.dart';
import 'models/dialog_config.dart';
import 'models/phone_config.dart';
import 'util/general_util.dart';
import 'view/country_code_bottom_sheet.dart';
import 'view/flag_view.dart';
import 'view/rixa_textfield.dart';

export 'package:flutter_multi_formatter/formatters/masked_input_formatter.dart';

export 'models/country_code_model.dart';
export 'models/country_config.dart';
export 'models/dialog_config.dart';
export 'models/phone_config.dart';

class InternationalPhoneNumberInput extends StatefulWidget {
  final TextEditingController controller;
  final double? height;
  final bool inactive;
  final DialogConfig dialogConfig;
  final CountryConfig countryConfig;
  final PhoneConfig phoneConfig;
  final CountryCodeModel initCountry;
  final dynamic Function(IntPhoneNumber number)? onInputChanged;
  final Color? dividerColor;

  final MaskedInputFormatter? formatter;
  final List<TextInputFormatter> inputFormatters;
  final Future<String?> Function()? loadFromJson;
  final String? Function(IntPhoneNumber number)? validator;
  InternationalPhoneNumberInput(
      {super.key,
      TextEditingController? controller,
      this.height = 60,
      this.inputFormatters = const [],
      CountryCodeModel? initCountry,
      this.onInputChanged,
      this.dividerColor,
      this.loadFromJson,
      this.formatter,
      this.validator,
      this.inactive = false,
      DialogConfig? dialogConfig,
      CountryConfig? countryConfig,
      PhoneConfig? phoneConfig})
      : dialogConfig = dialogConfig ?? DialogConfig(),
        controller = controller ?? TextEditingController(),
        countryConfig = countryConfig ?? CountryConfig(),
        initCountry = initCountry ??
            CountryCodeModel(name: "Iran", dial_code: "+98", code: "IR"),
        phoneConfig = phoneConfig ?? PhoneConfig();

  @override
  State<InternationalPhoneNumberInput> createState() =>
      _InternationalPhoneNumberInputState();
}

class _InternationalPhoneNumberInputState
    extends State<InternationalPhoneNumberInput> {
  List<CountryCodeModel>? countries;
  late CountryCodeModel selected;

  String? errorText;
  late FocusNode node;

  @override
  void initState() {
    selected = widget.initCountry;
    if (widget.loadFromJson == null) {
      getAllCountry();
    } else {
      widget.loadFromJson!()
          .then((data) => data != null ? loadFromJson(data) : getAllCountry());
    }
    node = widget.phoneConfig.focusNode ?? FocusNode();
    if (widget.phoneConfig.autovalidateMode == AutovalidateMode.always &&
        widget.validator != null) {
      String? error = widget.validator!(IntPhoneNumber(
          code: selected.code,
          dial_code: selected.dial_code,
          number: widget.controller.text.trimLeft().trimRight()));
      if (errorText != error) {
        errorText = error;
      }
    }
    node.addListener(listenNode);
    widget.controller.addListener(controllerOnChange);
    super.initState();
  }

  void controllerOnChange() {
    if (widget.onInputChanged != null) {
      widget.onInputChanged!(IntPhoneNumber(
          code: selected.code,
          dial_code: selected.dial_code,
          number: widget.controller.text.trimLeft().trimRight()));
    }
    if (widget.validator != null) {
      String? error = widget.validator!(IntPhoneNumber(
          code: selected.code,
          dial_code: selected.dial_code,
          number: widget.controller.text.trimLeft().trimRight()));
      if (errorText != error) {
        setState(() {
          errorText = error;
        });
      }
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(controllerOnChange);
    node.removeListener(listenNode);
    super.dispose();
  }

  void listenNode() {
    if (node.hasFocus &&
        widget.phoneConfig.autovalidateMode ==
            AutovalidateMode.onUserInteraction &&
        widget.validator != null) {
      String? error = widget.validator!(IntPhoneNumber(
          code: selected.code,
          dial_code: selected.dial_code,
          number: widget.controller.text.trimLeft().trimRight()));
      if (errorText != error) {
        errorText = error;
        if (mounted) setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Expanded(
            //     flex: 3,
            //     child: SizedBox(
            //       height: widget.height,
            //       child: TextButton(
            //         onPressed: () {
            //           if (!widget.inactive && countries != null) {
            //             showModalBottomSheet(
            //                 shape: const RoundedRectangleBorder(
            //                   borderRadius: BorderRadius.vertical(
            //                     top: Radius.circular(30),
            //                   ),
            //                 ),
            //                 barrierColor: Colors.black.withOpacity(0.6),
            //                 isScrollControlled: true,
            //                 backgroundColor:
            //                     widget.dialogConfig.backgroundColor,
            //                 context: context,
            //                 builder: (context) {
            //                   return SingleChildScrollView(
            //                     child: CountryCodeBottomSheet(
            //                       countries: countries!,
            //                       selected: selected,
            //                       onSelected: (countryCodeModel) {
            //                         setState(() {
            //                           selected = countryCodeModel;
            //                         });
            //                         if (widget.onInputChanged != null) {
            //                           widget.onInputChanged!(IntPhoneNumber(
            //                               code: selected.code,
            //                               dial_code: selected.dial_code,
            //                               number: widget.controller.text
            //                                   .trimLeft()
            //                                   .trimRight()));
            //                         }
            //                       },
            //                       dialogConfig: widget.dialogConfig,
            //                     ),
            //                   );
            //                 });
            //           }
            //         },
            //         style: TextButton.styleFrom(
            //           minimumSize: Size.zero,
            //           padding: EdgeInsets.zero,
            //           tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            //         ),
            //         child: Container(
            //           width: double.infinity,
            //           height: double.infinity,
            //           decoration: widget.countryConfig.decoration,
            //           child: Row(
            //             mainAxisAlignment: MainAxisAlignment.center,
            //             children: [
            //               FlagView(
            //                 countryCodeModel: selected,
            //                 isFlat: widget.countryConfig.flatFlag,
            //                 size: widget.countryConfig.flagSize,
            //               ),
            //               const SizedBox(width: 8),
            //               Text(
            //                 selected.dial_code,
            //                 style: widget.countryConfig.textStyle,
            //               )
            //             ],
            //           ),
            //         ),
            //       ),
            //     )),
            Expanded(
                flex: 7,
                child: RixaTextField(
                  prefixIcon: GestureDetector(
                    onTap: () {
                      if (!widget.inactive && countries != null) {
                        showModalBottomSheet(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(30),
                              ),
                            ),
                            barrierColor: Colors.black.withOpacity(0.6),
                            isScrollControlled: true,
                            backgroundColor:
                                widget.dialogConfig.backgroundColor,
                            context: context,
                            builder: (context) {
                              return SingleChildScrollView(
                                child: CountryCodeBottomSheet(
                                  countries: countries!,
                                  selected: selected,
                                  onSelected: (countryCodeModel) {
                                    setState(() {
                                      selected = countryCodeModel;
                                    });
                                    if (widget.onInputChanged != null) {
                                      widget.onInputChanged!(IntPhoneNumber(
                                          code: selected.code,
                                          dial_code: selected.dial_code,
                                          number: widget.controller.text
                                              .trimLeft()
                                              .trimRight()));
                                    }
                                  },
                                  dialogConfig: widget.dialogConfig,
                                ),
                              );
                            });
                      }
                    },
                    child: SizedBox(
                      width: 120,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: 8),
                          FlagView(
                            countryCodeModel: selected,
                            isFlat: widget.countryConfig.flatFlag,
                            size: widget.countryConfig.flagSize,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            selected.dial_code,
                            style: widget.countryConfig.textStyle,
                          ),
                          const SizedBox(width: 8),
                          VerticalDivider(
                            endIndent: 12,
                            indent: 12,
                            thickness: 2,
                            color: (widget.dividerColor != null)
                                ? widget.dividerColor
                                : Colors.black,
                          )
                        ],
                      ),
                    ),
                  ),
                  hintText: widget.phoneConfig.hintText ?? "",
                  hintStyle: widget.phoneConfig.hintStyle,
                  textStyle: widget.phoneConfig.textStyle,
                  controller: widget.controller,
                  focusNode: node,
                  decoration: widget.phoneConfig.decoration,
                  errorStyle: widget.phoneConfig.errorStyle,
                  backgroundColor: widget.phoneConfig.backgroundColor,
                  labelStyle: widget.phoneConfig.labelStyle,
                  textInputAction: widget.phoneConfig.textInputAction,
                  labelText: widget.phoneConfig.labelText,
                  floatingLabelStyle: widget.phoneConfig.floatingLabelStyle,
                  radius: widget.phoneConfig.radius,
                  isUnderline: false,
                  textInputType: TextInputType.number,
                  expands: true,
                  autoFocus: widget.phoneConfig.autoFocus,
                  inputFormatters: [
                    ...widget.inputFormatters,
                    if (widget.formatter != null) widget.formatter!
                  ],
                  focusedColor: errorText != null
                      ? widget.phoneConfig.errorColor
                      : widget.phoneConfig.focusedColor,
                  enabledColor: errorText != null
                      ? widget.phoneConfig.errorColor
                      : widget.phoneConfig.enabledColor,
                  showCursor: widget.phoneConfig.showCursor,
                  borderWidth: widget.phoneConfig.borderWidth,
                )),
          ]),
        ),
        if ((widget.phoneConfig.popUpErrorText && errorText != null) ||
            !widget.phoneConfig.popUpErrorText)
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: widget.phoneConfig.errorPadding,
              child: Row(children: [
                Text(
                  errorText ?? "",
                  style: widget.phoneConfig.errorStyle,
                  maxLines: widget.phoneConfig.errorTextMaxLength,
                  overflow: TextOverflow.ellipsis,
                )
              ]),
            ),
          )
      ],
    );
  }

  Future<void> getAllCountry() async {
    if (widget.loadFromJson != null) {
    } else {
      countries = await GeneralUtil.loadJson();
    }
    setState(() {});
  }

  void loadFromJson(String data) {
    Iterable jsonResult = json.decode(data);
    countries = List<CountryCodeModel>.from(jsonResult.map((model) {
      try {
        return CountryCodeModel.fromJson(model);
      } catch (e, stackTrace) {
        log("Json Converter Failed: ", error: e, stackTrace: stackTrace);
      }
    }));
    setState(() {});
  }
}

class IntPhoneNumber {
  String code, dial_code, number;
  IntPhoneNumber(
      {required this.code, required this.dial_code, required this.number});
  String get fullNumber => "$dial_code $number";
  String get rawNumber => number.replaceAll(" ", "");
  String get rawDialCode => dial_code.replaceAll("+", "");
  String get rawFullNumber =>
      fullNumber.replaceAll(" ", "").replaceAll("+", "");
}
