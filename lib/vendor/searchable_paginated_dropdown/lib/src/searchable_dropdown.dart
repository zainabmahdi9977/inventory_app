import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inventory_app/vendor/searchable_paginated_dropdown/lib/searchable_paginated_dropdown.dart';
import 'package:inventory_app/vendor/searchable_paginated_dropdown/lib/src/extensions/context_extension.dart';
import 'package:inventory_app/vendor/searchable_paginated_dropdown/lib/src/extensions/custom_global_key_extension.dart';
import 'package:inventory_app/vendor/searchable_paginated_dropdown/lib/src/utils/custom_inkwell.dart';
import 'package:inventory_app/vendor/searchable_paginated_dropdown/lib/src/utils/custom_search_bar.dart';

class SearchableDropdown<T> extends StatefulWidget {
  const SearchableDropdown({
    Key? key,
    SearchableDropdownController<T>? controller,
    Widget? hintText,
    Widget Function(Widget)? backgroundDecoration,
    String? searchHintText,
    Widget? noRecordText,
    double? dropDownMaxHeight,
    EdgeInsetsGeometry? margin,
    Widget? trailingIcon,
    Widget? trailingClearIcon,
    Widget? leadingIcon,
    void Function(T?)? onChanged,
    List<SearchableDropdownMenuItem<T>>? items,
    T? value,
    bool isEnabled = true,
    VoidCallback? disabledOnTap,
    VoidCallback? onDismissDropdown,
    VoidCallback? onShowDropdown,
    double? width,
    bool isDialogExpanded = true,
    bool hasTrailingClearIcon = true,
    double? dialogOffset,
    double? rightpadding
  }) : this._(
          key: key,
          hintText: hintText,
          controller: controller,
          backgroundDecoration: backgroundDecoration,
          searchHintText: searchHintText,
          noRecordText: noRecordText,
          dropDownMaxHeight: dropDownMaxHeight,
          margin: margin,
          trailingIcon: trailingIcon,
          trailingClearIcon: trailingClearIcon,
          leadingIcon: leadingIcon,
          onChanged: onChanged,
          items: items,
          initialValue: value,
          isEnabled: isEnabled,
          disabledOnTap: disabledOnTap,
          onDismissDropdown: onDismissDropdown,
          onShowDropdown: onShowDropdown,
          width: width,
          isDialogExpanded: isDialogExpanded,
          hasTrailingClearIcon: hasTrailingClearIcon,
          dialogOffset: dialogOffset,
          rightpadding:rightpadding
        );

  const SearchableDropdown.paginated({
    required Future<List<SearchableDropdownMenuItem<T>>?> Function(
      int,
      String?,
    )?
        paginatedRequest,
    int? requestItemCount,
    Key? key,
    SearchableDropdownController<T>? controller,
    Widget? hintText,
    Widget Function(Widget)? backgroundDecoration,
    String? searchHintText,
    Widget? noRecordText,
    double? dropDownMaxHeight,
    EdgeInsetsGeometry? margin,
    Widget? trailingIcon,
    Widget? trailingClearIcon,
    Widget? leadingIcon,
    void Function(T?)? onChanged,
    bool isEnabled = true,
    VoidCallback? disabledOnTap,
    VoidCallback? onDismissDropdown,
    VoidCallback? onShowDropdown,
    Duration? changeCompletionDelay,
    double? width,
    bool isDialogExpanded = true,
    bool hasTrailingClearIcon = true,
    SearchableDropdownMenuItem<T>? initialValue,
    double? dialogOffset,
    double? rightpadding
  }) : this._(
          key: key,
          controller: controller,
          paginatedRequest: paginatedRequest,
          requestItemCount: requestItemCount,
          hintText: hintText,
          backgroundDecoration: backgroundDecoration,
          searchHintText: searchHintText,
          noRecordText: noRecordText,
          dropDownMaxHeight: dropDownMaxHeight,
          margin: margin,
          trailingIcon: trailingIcon,
          trailingClearIcon: trailingClearIcon,
          leadingIcon: leadingIcon,
          onChanged: onChanged,
          isEnabled: isEnabled,
          disabledOnTap: disabledOnTap,
          onDismissDropdown: onDismissDropdown,
          onShowDropdown: onShowDropdown,
          changeCompletionDelay: changeCompletionDelay,
          width: width,
          isDialogExpanded: isDialogExpanded,
          hasTrailingClearIcon: hasTrailingClearIcon,
          initialFutureValue: initialValue,
          dialogOffset: dialogOffset,
          rightpadding: rightpadding
        );

  const SearchableDropdown.future({
    required Future<List<SearchableDropdownMenuItem<T>>?> Function()?
        futureRequest,
    Key? key,
    SearchableDropdownController<T>? controller,
    Widget? hintText,
    Widget Function(Widget)? backgroundDecoration,
    String? searchHintText,
    Widget? noRecordText,
    double? dropDownMaxHeight,
    EdgeInsetsGeometry? margin,
    Widget? trailingIcon,
    Widget? trailingClearIcon,
    Widget? leadingIcon,
    void Function(T?)? onChanged,
    bool isEnabled = true,
    VoidCallback? disabledOnTap,
    VoidCallback? onDismissDropdown,
    VoidCallback? onShowDropdown,
    Duration? changeCompletionDelay,
    double? width,
    bool isDialogExpanded = true,
    bool hasTrailingClearIcon = true,
    SearchableDropdownMenuItem<T>? initialValue,
    double? dialogOffset,
    double? rightpadding
  }) : this._(
          futureRequest: futureRequest,
          key: key,
          controller: controller,
          hintText: hintText,
          backgroundDecoration: backgroundDecoration,
          searchHintText: searchHintText,
          noRecordText: noRecordText,
          dropDownMaxHeight: dropDownMaxHeight,
          margin: margin,
          trailingIcon: trailingIcon,
          trailingClearIcon: trailingClearIcon,
          leadingIcon: leadingIcon,
          onChanged: onChanged,
          isEnabled: isEnabled,
          disabledOnTap: disabledOnTap,
          onDismissDropdown: onDismissDropdown,
          onShowDropdown: onShowDropdown,
          changeCompletionDelay: changeCompletionDelay,
          width: width,
          isDialogExpanded: isDialogExpanded,
          hasTrailingClearIcon: hasTrailingClearIcon,
          initialFutureValue: initialValue,
          dialogOffset: dialogOffset,
          rightpadding: rightpadding
        );

  const SearchableDropdown._({
    super.key,
    this.controller,
    this.hintText,
    this.backgroundDecoration,
    this.searchHintText,
    this.noRecordText,
    this.dropDownMaxHeight,
    this.margin,
    this.trailingIcon,
    this.trailingClearIcon,
    this.leadingIcon,
    this.onChanged,
    this.items,
    this.initialValue,
    this.initialFutureValue,
    this.isEnabled = true,
    this.disabledOnTap,
    this.onDismissDropdown,
    this.onShowDropdown,
    this.futureRequest,
    this.paginatedRequest,
    this.requestItemCount,
    this.changeCompletionDelay,
    this.width,
    this.isDialogExpanded = true,
    this.hasTrailingClearIcon = true,
    this.dialogOffset, 
    this.rightpadding,
  });

  //Is dropdown enabled
  final bool isEnabled;

  //If its true dialog will be expanded all width of screen, otherwise dialog will be same size of dropdown.
  final bool isDialogExpanded;

  /// Activates clear icon trailing.
  final bool hasTrailingClearIcon;

  /// Height of dropdown's dialog, default: context.deviceHeight*0.3.
  final double? dropDownMaxHeight;

  final double? width;

  /// Dialog offset from dropdown.
  final double? dialogOffset;
 final double? rightpadding;
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

  //Initial value of future and paginated dropdown
  final SearchableDropdownMenuItem<T>? initialFutureValue;

  /// SearchBar hint text.
  final String? searchHintText;
  //Initial value of dropdown
  final T? initialValue;

  //Triggers this function if dropdown pressed while disabled
  final VoidCallback? disabledOnTap;

  //Triggers this function on dropdown dismissed
  final VoidCallback? onDismissDropdown;

  //Triggers this function on dropdown open
  final VoidCallback? onShowDropdown;

  /// Returns selected Item.
  final void Function(T? value)? onChanged;

  /// Hint text shown when the dropdown is empty.
  final Widget? hintText;

  /// Shows if there is no record found.
  final Widget? noRecordText;

  /// Dropdown trailing icon.
  final Widget? trailingIcon;

  /// Dropdown trailing clear icon.
  final Widget? trailingClearIcon;

  /// Dropdown trailing icon.
  final Widget? leadingIcon;

  /// Background decoration of dropdown, i.e. with this you can wrap dropdown with Card.
  final Widget Function(Widget child)? backgroundDecoration;

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  late final SearchableDropdownController<T> dropdownController;

  @override
  void initState() {
    dropdownController = widget.controller ?? SearchableDropdownController<T>();
    dropdownController
      ..paginatedRequest = widget.paginatedRequest
      ..futureRequest = widget.futureRequest
      ..requestItemCount = widget.requestItemCount ?? 0
      ..items = widget.items
      ..searchedItems.value = widget.items;
    if (widget.initialFutureValue != null) {
      dropdownController.selectedItem.value = widget.initialFutureValue;
    }
    for (final element in widget.items ?? <SearchableDropdownMenuItem<T>>[]) {
      if (element.value == widget.initialValue) {
        dropdownController.selectedItem.value = element;
        return;
      }
    }

    if (dropdownController.paginatedRequest == null) return;
    super.initState();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      dropdownController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dropdownWidget = _DropDown(
      controller: dropdownController,
      isEnabled: widget.isEnabled,
      disabledOnTap: widget.disabledOnTap,
      onDismissDropdown: widget.onDismissDropdown,
      onShowDropdown: widget.onShowDropdown,
      dropDownMaxHeight: widget.dropDownMaxHeight,
      futureRequest: widget.futureRequest,
      hintText: widget.hintText,
      leadingIcon: widget.leadingIcon,
      margin: widget.margin,
      noRecordText: widget.noRecordText,
      onChanged: widget.onChanged,
      paginatedRequest: widget.paginatedRequest,
      searchHintText: widget.searchHintText,
      trailingIcon: widget.trailingIcon,
      trailingClearIcon: widget.trailingClearIcon,
      changeCompletionDelay: widget.changeCompletionDelay,
      isDialogExpanded: widget.isDialogExpanded,
      hasTrailingClearIcon: widget.hasTrailingClearIcon,
      dialogOffset: widget.dialogOffset ?? 35,
      rightpadding:widget.rightpadding ??0 ,
  
    );

    return SizedBox(
      key: dropdownController.key,
      width: widget.width ?? MediaQuery.of(context).size.width,
      child:
          widget.backgroundDecoration?.call(dropdownWidget) ?? dropdownWidget,
    );
  }
}

class _DropDown<T> extends StatelessWidget {
  const _DropDown({
    required this.controller,
    required this.isEnabled,
    required this.isDialogExpanded,
    required this.dialogOffset,
   
    this.leadingIcon,
    this.trailingIcon,
    this.trailingClearIcon,
    this.disabledOnTap,
    this.onDismissDropdown,
    this.onShowDropdown,
    this.margin,
    this.hintText,
   required this.rightpadding,
    this.dropDownMaxHeight,
    this.futureRequest,
    this.paginatedRequest,
    this.noRecordText,
    this.onChanged,
    this.searchHintText,
    this.changeCompletionDelay,
    this.hasTrailingClearIcon = true,
  });

  final bool isEnabled;
  final bool isDialogExpanded;
  final bool hasTrailingClearIcon;
  final double? dropDownMaxHeight;
  final double dialogOffset;
  final double rightpadding;
  final Duration? changeCompletionDelay;
  final EdgeInsetsGeometry? margin;
  final Future<List<SearchableDropdownMenuItem<T>>?> Function()? futureRequest;
  final Future<List<SearchableDropdownMenuItem<T>>?> Function(
    int page,
    String? searchKey,
  )? paginatedRequest;
  final SearchableDropdownController<T> controller;
  final String? searchHintText;
  final VoidCallback? disabledOnTap;
  final VoidCallback? onDismissDropdown;
  final VoidCallback? onShowDropdown;
  final void Function(T? value)? onChanged;
  final Widget? trailingIcon;
  final Widget? trailingClearIcon;
  final Widget? leadingIcon;
  final Widget? hintText;
  final Widget? noRecordText;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (isEnabled) {
          showDropdownDialog(context, controller, dialogOffset: dialogOffset , rightpadding: rightpadding);
        } else {
          disabledOnTap?.call();
        }
      },
      child: Padding(
        padding: margin ?? const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  if (leadingIcon != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 3),
                      child: leadingIcon,
                    ),
                  Flexible(
                    child: _DropDownText(
                      controller: controller,
                      hintText: hintText,
                    ),
                  ),
                ],
              ),
            ),
            ValueListenableBuilder(
              valueListenable: controller.selectedItem,
              builder: (context, value, child) {
                if (value == null || !hasTrailingClearIcon) {
                  return trailingIcon ??
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 24,
                      );
                }
                return CustomInkwell(
                  padding: EdgeInsets.zero,
                  onTap: () {
                    controller.selectedItem.value = null;
                    onChanged?.call(null);
                  },
                  child: trailingClearIcon ??
                      const Icon(
                        Icons.clear,
                        size: 24,
                      ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void showDropdownDialog(
    BuildContext context,
    SearchableDropdownController<T> controller, {
    /// Dialog offset from dropdown.
    required double dialogOffset,
     required double rightpadding,
  }) {
    var isReversed = false;
    final deviceHeight = context.deviceHeight;
    final dropdownGlobalPointBounds = controller.key.globalPaintBounds;
    final alertDialogMaxHeight = dropDownMaxHeight ?? deviceHeight * 0.35;

    final dropdownPositionFromBottom = dropdownGlobalPointBounds != null
        ? deviceHeight - dropdownGlobalPointBounds.bottom
        : null;
    var dialogPositionFromBottom = dropdownPositionFromBottom != null
        ? dropdownPositionFromBottom - alertDialogMaxHeight
        : null;
    if (dialogPositionFromBottom != null) {
      //If dialog couldn't fit the screen, reverse it
      if (dialogPositionFromBottom <= 0) {
        isReversed = true;
        final dropdownHeight = dropdownGlobalPointBounds?.height ?? 54;
        dialogPositionFromBottom +=
            alertDialogMaxHeight + dropdownHeight - dialogOffset;
      } else {
        dialogPositionFromBottom -= dialogOffset;
      }
    }
    if (controller.items == null) {
      if (paginatedRequest != null) {
        controller.getItemsWithPaginatedRequest(page: 1, isNewSearch: true);
      }
      if (futureRequest != null) controller.getItemsWithFutureRequest();
    } else {
      controller.searchedItems.value = controller.items;
    }
    //Call needs to be outside showDialog in case it has setState
    onShowDropdown?.call();
    //Show the dialog
    showDialog<void>(
      context: context,
      builder: (context) {
        var reCalculatePosition = dialogPositionFromBottom;
        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        //If keyboard pushes the dialog, recalculate the dialog's position.
        if (reCalculatePosition != null &&
            reCalculatePosition <= keyboardHeight) {
          reCalculatePosition =
              (keyboardHeight - reCalculatePosition) + reCalculatePosition;
        }
        return Padding(
          padding: EdgeInsets.only(
            bottom: reCalculatePosition ?? 0,
            left: isDialogExpanded ? 16 : dropdownGlobalPointBounds?.left ?? 0,
            right: isDialogExpanded ? 16 : rightpadding==0?dropdownGlobalPointBounds?.left ?? 0:rightpadding,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: isDialogExpanded
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: alertDialogMaxHeight,
                width:
                    isDialogExpanded ? null : dropdownGlobalPointBounds?.width,
                child: _DropDownCard(
                  controller: controller,
                  isReversed: isReversed,
                  noRecordText: noRecordText,
                  onChanged: onChanged,
                  paginatedRequest: paginatedRequest,
                  searchHintText: searchHintText,
                  changeCompletionDelay: changeCompletionDelay,
                ),
              ),
            ],
          ),
        );
      },
      barrierColor: Colors.transparent,
    ).then(((_) => onDismissDropdown?.call()));
  }
}

class _DropDownText<T> extends StatelessWidget {
  const _DropDownText({
    required this.controller,
    this.hintText,
  });

  final SearchableDropdownController<T> controller;
  final Widget? hintText;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller.selectedItem,
      builder: (context, SearchableDropdownMenuItem<T>? selectedItem, child) =>
          selectedItem?.child ??
          (selectedItem?.label != null
              ? Text(
                  selectedItem!.label,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                )
              : hintText) ??
          const SizedBox.shrink(),
    );
  }
}

class _DropDownCard<T> extends StatelessWidget {
  const _DropDownCard({
    required this.controller,
    required this.isReversed,
    this.searchHintText,
    this.paginatedRequest,
    this.onChanged,
    this.noRecordText,
    this.changeCompletionDelay,
  });

  final bool isReversed;
  final Duration? changeCompletionDelay;
  final Future<List<SearchableDropdownMenuItem<T>>?> Function(
    int page,
    String? searchKey,
  )? paginatedRequest;
  final SearchableDropdownController<T> controller;
  final String? searchHintText;
  final void Function(T? value)? onChanged;
  final Widget? noRecordText;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment:
          isReversed ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Card(
            margin: EdgeInsets.zero,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                verticalDirection:
                    isReversed ? VerticalDirection.up : VerticalDirection.down,
                children: [
                  _DropDownSearchBar(
                    controller: controller,
                    searchHintText: searchHintText,
                    changeCompletionDelay: changeCompletionDelay,
                  ),
                  Flexible(
                    child: _DropDownListView(
                      dropdownController: controller,
                      paginatedRequest: paginatedRequest,
                      isReversed: isReversed,
                      noRecordText: noRecordText,
                      onChanged: onChanged,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DropDownSearchBar<T> extends StatelessWidget {
  const _DropDownSearchBar({
    required this.controller,
    this.searchHintText,
    this.changeCompletionDelay,
  });
  final Duration? changeCompletionDelay;
  final SearchableDropdownController<T> controller;
  final String? searchHintText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: CustomSearchBar(
        changeCompletionDelay:
            changeCompletionDelay ?? const Duration(milliseconds: 200),
        hintText: searchHintText ?? 'Search',
        isOutlined: true,
        leadingIcon: const Icon(Icons.search, size: 24),
        onChangeComplete: (value) {
          controller.searchText = value;
          if (controller.items != null) {
            controller.fillSearchedList(value);
            return;
          }
          controller.getItemsWithPaginatedRequest(
            key: value == '' ? null : value,
            page: 1,
            isNewSearch: true,
          );
        },
      ),
    );
  }
}

class _DropDownListView<T> extends StatefulWidget {
  const _DropDownListView({
    required this.dropdownController,
    required this.isReversed,
    this.paginatedRequest,
    this.noRecordText,
    this.onChanged,
  });

  final bool isReversed;
  final Future<List<SearchableDropdownMenuItem<T>>?> Function(
    int page,
    String? searchKey,
  )? paginatedRequest;
  final SearchableDropdownController<T> dropdownController;
  final void Function(T? value)? onChanged;
  final Widget? noRecordText;

  @override
  State<_DropDownListView<T>> createState() => _DropDownListViewState<T>();
}

class _DropDownListViewState<T> extends State<_DropDownListView<T>> {
  ScrollController scrollController = ScrollController();
  Timer? timer;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(scrollControllerListener);
  }

  @override
  void dispose() {
    super.dispose();
    scrollController
      ..removeListener(scrollControllerListener)
      ..dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.paginatedRequest != null
          ? widget.dropdownController.paginatedItemList
          : widget.dropdownController.searchedItems,
      builder: (
        context,
        List<SearchableDropdownMenuItem<T>>? itemList,
        child,
      ) =>
          itemList == null
              ? const Center(child: CircularProgressIndicator.adaptive())
              : itemList.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(8),
                      child: widget.noRecordText ?? const Text('No record'),
                    )
                  : Scrollbar(
                      thumbVisibility: true,
                      controller: scrollController,
                      child: NotificationListener(
                        child: ListView.builder(
                          controller: scrollController,
                          padding:
                              listViewPadding(isReversed: widget.isReversed),
                          itemCount: itemList.length + 1,
                          shrinkWrap: true,
                          reverse: widget.isReversed,
                          itemBuilder: (context, index) {
                            if (index < itemList.length) {
                              final item = itemList.elementAt(index);
                              return CustomInkwell(
                                child: item.child,
                                onTap: () {
                                  widget.dropdownController.selectedItem.value =
                                      item;
                                  widget.onChanged?.call(item.value);
                                  Navigator.pop(context);
                                  item.onTap?.call();
                                },
                              );
                            } else {
                              return ValueListenableBuilder(
                                valueListenable:
                                    widget.dropdownController.status,
                                builder: (
                                  context,
                                  SearchableDropdownStatus state,
                                  child,
                                ) {
                                  if (state == SearchableDropdownStatus.busy) {
                                    return const Center(
                                      child:
                                          CircularProgressIndicator.adaptive(),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              );
                            }
                          },
                        ),
                      ),
                    ),
    );
  }

  EdgeInsets listViewPadding({required bool isReversed}) {
    final itemHeight = widget.paginatedRequest != null
        ? 48.0
        : 0.0; // Offset to show progress indicator; Only needed on paginated dropdown
    return EdgeInsets.only(
      left: 8,
      right: 8,
      bottom: isReversed ? 0 : itemHeight,
      top: isReversed ? itemHeight : 0,
    );
  }

  void scrollControllerListener({
    double sensitivity = 150.0,
    Duration throttleDuration = const Duration(milliseconds: 400),
  }) {
    if (timer != null) return;

    timer = Timer(throttleDuration, () => timer = null);

    final position = scrollController.position;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = position.pixels;
    final dropdownController = widget.dropdownController;
    final searchText = dropdownController.searchText;
    if (maxScroll - currentScroll <= sensitivity) {
      if (searchText.isNotEmpty) {
        dropdownController.getItemsWithPaginatedRequest(
            page: dropdownController.page, key: searchText,);
      } else {
        dropdownController.getItemsWithPaginatedRequest(
            page: dropdownController.page,);
      }
    }
  }
}
