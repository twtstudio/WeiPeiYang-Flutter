import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/lounge/provider/view_state_model.dart';
import 'loading.dart';

class ListLoadSteps<T extends ViewStateListModel> extends StatefulWidget {
  final T model;
  final Widget busyV;
  final Widget errorV;
  final Widget emptyV;
  final Widget successV;
  final Widget defaultV;
  final double errorHeight;

  const ListLoadSteps(
      {Key key,
      @required this.model,
      this.busyV,
      this.errorV,
      this.emptyV,
      this.successV,
      this.defaultV,
      this.errorHeight})
      : super(key: key);

  @override
  _ListLoadStepsState<T> createState() => _ListLoadStepsState<T>();
}

class _ListLoadStepsState<T extends ViewStateListModel> extends State<ListLoadSteps<T>> {
  @override
  Widget build(BuildContext context) {
    Widget body;

    // TODO: 这地方在 set idle 后 会build两次，暂时不知道原因。
    if (widget.model.isBusy) {
      body = KeyedSubtree(
        key: const ValueKey<ViewState>(ViewState.busy),
        child: Row(
          children: [
            Expanded(
              child: widget.busyV ??
                  Container(
                    height: widget.errorHeight ?? 40,
                    child: Center(
                      child: Loading(),
                    ),
                  ),
            ),
          ],
        ),
      );
    } else if (widget.model.isError && widget.model.list.isEmpty) {
      body = KeyedSubtree(
        key: const ValueKey<ViewState>(ViewState.error),
        child: widget.errorV ?? Container(
          height: 40,
          color: Colors.red,
        ),
      );
    } else if (widget.model.isEmpty) {
      body = KeyedSubtree(
        key: const ValueKey<ViewState>(ViewState.empty),
        child: widget.emptyV ?? Container(),
      );
    } else if (widget.model.isIdle && widget.model.list.isNotEmpty) {
      debugPrint('build ????????????????????????????????');
      body = KeyedSubtree(
        key: const ValueKey<ViewState>(ViewState.idle),
        child: widget.successV ?? Container(),
      );
    } else {
      body = widget.defaultV ?? Container();
    }
    return AnimatedSwitcher(
        layoutBuilder: (Widget currentChild, List<Widget> previousChildren) {
          return Stack(
            children: <Widget>[
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
            alignment: Alignment.topLeft,
          );
        },
        duration: const Duration(milliseconds: 300),
        child: body);
  }
}
