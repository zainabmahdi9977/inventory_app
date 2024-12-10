import 'package:flutter/material.dart';
import 'package:inventory_app/vendor/searchable_paginated_dropdown/lib/searchable_paginated_dropdown.dart';



@immutable
class SearchableDropdownFormField<T> extends FormField<T> {
  SearchableDropdownFormField({
    required List<SearchableDropdownMenuItem<T>>? items,
    Key? key,
    SearchableDropdownController<T>? controller,
    void Function(T?)? onSaved,
    String? Function(T?)? validator,
    T? initialValue,
    AutovalidateMode? autovalidateMode,
    Widget? hintText,
    EdgeInsetsGeometry? margin,
    bool isEnabled = true,
    VoidCallback? disabledOnTap,
    Widget Function(String?)? errorWidget,
    Widget Function(Widget)? backgroundDecoration,
    void Function(T?)? onChanged,
    Widget? noRecordTex,
    Widget? trailingIcon,
    Widget? trailingClearIcon,
    Widget? leadingIcon,
    String? searchHintText,
    double? dropDownMaxHeight,
    bool isDialogExpanded = true,
    bool hasTrailingClearIcon = true,
    double? dialogOffset,
  }) : this._(
          controller: controller,
          items: items,
          key: key,
          onSaved: onSaved,
          validator: validator,
          initialValue: initialValue,
          autovalidateMode: autovalidateMode,
          hintText: hintText,
          margin: margin,
          isEnabled: isEnabled,
          disabledOnTap: disabledOnTap,
          errorWidget: errorWidget,
          backgroundDecoration: backgroundDecoration,
          onChanged: onChanged,
          noRecordText: noRecordTex,
          trailingIcon: trailingIcon,
          trailingClearIcon: trailingClearIcon,
          leadingIcon: leadingIcon,
          searchHintText: searchHintText,
          dropDownMaxHeight: dropDownMaxHeight,
          isDialogExpanded: isDialogExpanded,
          hasTrailingClearIcon: hasTrailingClearIcon,
          dialogOffset: dialogOffset,
        );

  SearchableDropdownFormField.paginated({
    required Future<List<SearchableDropdownMenuItem<T>>?> Function(
      int,
      String?,
    )?
        paginatedRequest,
    int? requestItemCount,
    Key? key,
    SearchableDropdownController<T>? controller,
    void Function(T?)? onSaved,
    String? Function(T?)? validator,
    SearchableDropdownMenuItem<T>? initialValue,
    AutovalidateMode? autovalidateMode,
    Widget? hintText,
    EdgeInsetsGeometry? margin,
    bool isEnabled = true,
    VoidCallback? disabledOnTap,
    Widget Function(String?)? errorWidget,
    Widget Function(Widget)? backgroundDecoration,
    void Function(T?)? onChanged,
    Widget? noRecordTex,
    Widget? trailingIcon,
    Widget? trailingClearIcon,
    Widget? leadingIcon,
    String? searchHintText,
    Duration? changeCompletionDelay,
    double? dropDownMaxHeight,
    bool isDialogExpanded = true,
    bool hasTrailingClearIcon = true,
    double? dialogOffset,
  }) : this._(
          controller: controller,
          paginatedRequest: paginatedRequest,
          key: key,
          onSaved: onSaved,
          validator: validator,
          initialValue: initialValue?.value,
          initialFutureValue: initialValue,
          autovalidateMode: autovalidateMode,
          hintText: hintText,
          margin: margin,
          isEnabled: isEnabled,
          disabledOnTap: disabledOnTap,
          errorWidget: errorWidget,
          backgroundDecoration: backgroundDecoration,
          onChanged: onChanged,
          noRecordText: noRecordTex,
          trailingIcon: trailingIcon,
          trailingClearIcon: trailingClearIcon,
          leadingIcon: leadingIcon,
          searchHintText: searchHintText,
          dropDownMaxHeight: dropDownMaxHeight,
          requestItemCount: requestItemCount,
          changeCompletionDelay: changeCompletionDelay,
          isDialogExpanded: isDialogExpanded,
          hasTrailingClearIcon: hasTrailingClearIcon,
          dialogOffset: dialogOffset,
        );

  SearchableDropdownFormField.future({
    required Future<List<SearchableDropdownMenuItem<T>>?> Function()?
        futureRequest,
    SearchableDropdownController<T>? controller,
    Key? key,
    void Function(T?)? onSaved,
    String? Function(T?)? validator,
    SearchableDropdownMenuItem<T>? initialValue,
    AutovalidateMode? autovalidateMode,
    Widget? hintText,
    EdgeInsetsGeometry? margin,
    bool isEnabled = true,
    VoidCallback? disabledOnTap,
    Widget Function(String?)? errorWidget,
    Widget Function(Widget)? backgroundDecoration,
    void Function(T?)? onChanged,
    Widget? noRecordTex,
    Widget? trailingIcon,
    Widget? trailingClearIcon,
    Widget? leadingIcon,
    String? searchHintText,
    double? dropDownMaxHeight,
    Duration? changeCompletionDelay,
    bool isDialogExpanded = true,
    bool hasTrailingClearIcon = true,
    double? dialogOffset,
  }) : this._(
          controller: controller,
          futureRequest: futureRequest,
          key: key,
          onSaved: onSaved,
          validator: validator,
          initialValue: initialValue?.value,
          initialFutureValue: initialValue,
          autovalidateMode: autovalidateMode,
          hintText: hintText,
          margin: margin,
          isEnabled: isEnabled,
          disabledOnTap: disabledOnTap,
          errorWidget: errorWidget,
          backgroundDecoration: backgroundDecoration,
          onChanged: onChanged,
          noRecordText: noRecordTex,
          trailingIcon: trailingIcon,
          trailingClearIcon: trailingClearIcon,
          leadingIcon: leadingIcon,
          searchHintText: searchHintText,
          dropDownMaxHeight: dropDownMaxHeight,
          changeCompletionDelay: changeCompletionDelay,
          isDialogExpanded: isDialogExpanded,
          hasTrailingClearIcon: hasTrailingClearIcon,
          dialogOffset: dialogOffset,
        );

  SearchableDropdownFormField._({
    this.controller,
    this.items,
    this.futureRequest,
    this.paginatedRequest,
    this.requestItemCount,
    super.key,
    super.onSaved,
    super.validator,
    super.initialValue,
    super.autovalidateMode,
    this.initialFutureValue,
    this.hintText,
    this.margin,
    this.isEnabled = true,
    this.disabledOnTap,
    this.errorWidget,
    this.backgroundDecoration,
    this.onChanged,
    this.noRecordText,
    this.trailingIcon,
    this.trailingClearIcon,
    this.leadingIcon,
    this.searchHintText,
    this.dropDownMaxHeight,
    this.changeCompletionDelay,
    this.isDialogExpanded = true,
    this.hasTrailingClearIcon = true,
    this.dialogOffset,
  })  : assert(initialValue == null || controller == null,
            'You can use controllers initial item value',),
        super(
          builder: (FormFieldState<T> state) {
            return Padding(
              padding: margin ?? const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (items != null)
                    SearchableDropdown<T>(
                      controller: controller,
                      key: key,
                      backgroundDecoration: backgroundDecoration,
                      hintText: hintText,
                      margin: EdgeInsets.zero,
                      leadingIcon: leadingIcon,
                      trailingIcon: trailingIcon,
                      trailingClearIcon: trailingClearIcon,
                      noRecordText: noRecordText,
                      dropDownMaxHeight: dropDownMaxHeight,
                      searchHintText: searchHintText,
                      isEnabled: isEnabled,
                      disabledOnTap: disabledOnTap,
                      items: items,
                      value: initialValue,
                      onChanged: (value) {
                        state.didChange(value);
                        if (onChanged != null) onChanged(value);
                      },
                      isDialogExpanded: isDialogExpanded,
                      dialogOffset: dialogOffset,
                    ),
                  if (paginatedRequest != null)
                    SearchableDropdown<T>.paginated(
                      controller: controller,
                      paginatedRequest: paginatedRequest,
                      requestItemCount: requestItemCount,
                      key: key,
                      backgroundDecoration: backgroundDecoration,
                      hintText: hintText,
                      margin: EdgeInsets.zero,
                      leadingIcon: leadingIcon,
                      trailingIcon: trailingIcon,
                      trailingClearIcon: trailingClearIcon,
                      noRecordText: noRecordText,
                      dropDownMaxHeight: dropDownMaxHeight,
                      searchHintText: searchHintText,
                      isEnabled: isEnabled,
                      disabledOnTap: disabledOnTap,
                      initialValue: initialFutureValue,
                      onChanged: (value) {
                        state.didChange(value);
                        if (onChanged != null) onChanged(value);
                      },
                      changeCompletionDelay: changeCompletionDelay,
                      isDialogExpanded: isDialogExpanded,
                      dialogOffset: dialogOffset,
                    ),
                  if (futureRequest != null)
                    SearchableDropdown<T>.future(
                      controller: controller,
                      futureRequest: futureRequest,
                      key: key,
                      backgroundDecoration: backgroundDecoration,
                      hintText: hintText,
                      margin: EdgeInsets.zero,
                      leadingIcon: leadingIcon,
                      trailingIcon: trailingIcon,
                      trailingClearIcon: trailingClearIcon,
                      noRecordText: noRecordText,
                      dropDownMaxHeight: dropDownMaxHeight,
                      searchHintText: searchHintText,
                      isEnabled: isEnabled,
                      disabledOnTap: disabledOnTap,
                      initialValue: initialFutureValue,
                      onChanged: (value) {
                        state.didChange(value);
                        if (onChanged != null) onChanged(value);
                      },
                      changeCompletionDelay: changeCompletionDelay,
                      isDialogExpanded: isDialogExpanded,
                      dialogOffset: dialogOffset,
                    ),
                  if (state.hasError)
                    errorWidget != null
                        ? errorWidget(state.errorText)
                        : Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              state.errorText ?? '',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                ],
              ),
            );
          },
        );

  /// Is dropdown enabled.
  final bool isEnabled;

  /// If its true dialog will be expanded all width of screen, otherwise dialog will be same size of dropdown.
  final bool isDialogExpanded;

  /// Activates clear icon trailing.
  final bool hasTrailingClearIcon;

  /// Dialog offset from dropdown.
  final double? dialogOffset;

  /// Height of dropdown's dialog, default: MediaQuery.of(context).size.height*0.3.
  final double? dropDownMaxHeight;

  /// Delay of dropdown's search callback after typing complete.
  final Duration? changeCompletionDelay;

  /// Dropdowns margin padding with other widgets.
  final EdgeInsetsGeometry? margin;

  /// Future service which is returns DropdownMenuItem list.
  final Future<List<SearchableDropdownMenuItem<T>>?> Function()? futureRequest;

  /// Paginated request service which is returns DropdownMenuItem list.
  final Future<List<SearchableDropdownMenuItem<T>>?> Function(
    int page,
    String? searchKey,
  )? paginatedRequest;

  /// Paginated request item count which returns in one page, this value is using for knowledge about isDropdown has more item or not.
  final int? requestItemCount;

  /// Dropdown items.
  final List<SearchableDropdownMenuItem<T>>? items;

  final SearchableDropdownController<T>? controller;

  /// Initial value for future and paginated dropdowns.
  final SearchableDropdownMenuItem<T>? initialFutureValue;

  /// SearchBar hint text.
  final String? searchHintText;

  //Triggers this function if dropdown pressed while disabled
  final VoidCallback? disabledOnTap;

  /// Returns selected Item.
  final void Function(T? value)? onChanged;

  /// Hint text shown when the dropdown is empty.
  final Widget? hintText;

  /// Shows if there is no record found.
  final Widget? noRecordText;

  /// Dropdown trailing icon.
  final Widget? trailingIcon;

  /// Dropdown trailing clear icon that clears current selected value.
  final Widget? trailingClearIcon;

  /// Dropdown trailing icon.
  final Widget? leadingIcon;

  /// Validation Error widget which is shown under dropdown.
  final Widget Function(String? errorText)? errorWidget;

  /// Background decoration of dropdown, i.e. with this you can wrap dropdown with Card.
  final Widget Function(Widget child)? backgroundDecoration;
}
