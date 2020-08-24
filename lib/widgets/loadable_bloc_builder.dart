import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/logic/reloadable/reloadable_cubit.dart';
import 'package:logging/logging.dart';

class LoadableBlocBuilder<CubitType extends ReloadableCubit> extends StatelessWidget {
	final BlocWidgetBuilder<DataLoadSuccess> builder;
	final Widget loadingIndicator = Expanded(child: Center(child: CircularProgressIndicator()));

  LoadableBlocBuilder({this.builder});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CubitType, LoadableState>(
	    builder: (context, state) {
		    if (state is DataLoadInitial)
			    context.bloc<CubitType>().loadData();
		    else if (state is DataLoadSuccess)
			    return builder(context, state);
		    else if (state is DataLoadInProgress)
		      return loadingIndicator;
		    return Container();
	    }
    );
  }
}