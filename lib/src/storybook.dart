import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'models/dto/atribute_dto.dart';
import 'widgets/content_widget.dart';
import 'widgets/device_widget.dart';

abstract class Storybook<T extends StatefulWidget> extends State {
  String nameObjectInDisplay();

  String title();

  String description();

  List<AtributeDto> atributs();

  Widget buildComponentWidget(BuildContext context);

  void onUpdateAtributs(List<AtributeDto> atributs);

  getWhereAtribut(List<AtributeDto> atributs, String name) {
    final atribute = atributs.where((e) => e.name == name).first;
    return atribute.selectedValue?.value;
  }

  String? selectedConstructor;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (kIsWeb) _buildContent(),
          _buildDevice(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Expanded(
      child: ContentWidget(
        atributs: atributs(),
        onAtributs: (atributs) {
          onUpdateAtributs(atributs);
        },
        description: description(),
        title: title(),
        constructor: selectedConstructor,
        nameObjectInDisplay: nameObjectInDisplay(),
        onSelectedConstructor: (String? constructor) {
          setState(() {
            selectedConstructor = constructor;
          });
        },
        updatePreviewCode: updatePreviewCode,
      ),
    );
  }

  @protected
  @mustCallSuper
  String updatePreviewCode() {
    final atributes = atributs()
        .where(
          (e) {
            final constructor = e.builders == null ||
                e.builders!.contains(this.selectedConstructor);
            final ignoreInDisplay = e.selectedValue?.ignoreInDisplay ?? true;
            return constructor && !ignoreInDisplay;
          },
        )
        .map((e) => "\n    ${e.name}: ${e.toStringValue},")
        .join();
    final constructor =
        this.selectedConstructor == null ? '' : '.${this.selectedConstructor}';
    final nameClass = nameObjectInDisplay();
    return "$nameClass$constructor($atributes\n)";
  }

  Widget _buildDevice() {
    final height = kIsWeb ? 630.0 : MediaQuery.of(context).size.height;
    final width = kIsWeb ? 520.0 : MediaQuery.of(context).size.width;
    final deviceWidget = DeviceWidget(
      decoration: kIsWeb
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                width: 8,
                color: Colors.black,
              ),
            )
          : null,
      margin: kIsWeb ? null : EdgeInsets.zero,
      height: height,
      width: width,
      buildComponentWidget: buildComponentWidget,
    );
    if (kIsWeb) {
      return deviceWidget;
    }

    return Expanded(child: deviceWidget);
  }
}
