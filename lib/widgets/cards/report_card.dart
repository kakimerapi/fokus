import 'package:flutter/material.dart';
import 'package:fokus/model/ui/task/ui_task_report.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/string_utils.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/forms/report_form.dart';
import 'package:fokus/widgets/general/app_avatar.dart';
import 'package:intl/intl.dart';

class ReportCard extends StatefulWidget {
	final UITaskReport report;
	final bool hideBottomBar;

	ReportCard({@required this.report, this.hideBottomBar = false});

  @override
  _ReportCardState createState() => new _ReportCardState();
}

class _ReportCardState extends State<ReportCard> {
	static const String _pageKey = 'page.caregiverSection.rating.content';
	final Radius defaultRadius = Radius.circular(AppBoxProperties.roundedCornersRadius);

  @override
  Widget build(BuildContext context) {
		return Material(
			type: MaterialType.transparency,
			child: SingleChildScrollView(
				clipBehavior: Clip.none,
				child: Column(
					children: [
						Container(
							decoration: AppBoxProperties.elevatedContainer.copyWith(
								borderRadius: widget.hideBottomBar ?
									BorderRadius.all(defaultRadius)
									: BorderRadius.vertical(top: defaultRadius)
							),
							child: _buildReportDetails(context)
						),
						if(!widget.hideBottomBar)
							_buildBottomBar(context)
					]
				)
			)
		);
  }

	Widget _buildReportTile(IconData icon, Widget content, String tooltip) {
		return Tooltip(
			message: tooltip,
			child: Row(
				crossAxisAlignment: CrossAxisAlignment.center,
				children: [
					Padding(
						padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0).copyWith(right: 16.0),
						child: Icon(icon, size: 28, color: Colors.grey[600])
					),
					Expanded(child: content)
				]
			)
		);
	}
	
	Widget _buildReportDetails(BuildContext context) {
		return Padding(
			padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0), 
			child: Column(
				mainAxisSize: MainAxisSize.min,
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Text(
						widget.report.planName,
						maxLines: 1,
						overflow: TextOverflow.ellipsis,
						style: TextStyle(color: AppColors.mediumTextColor, fontSize: 15.0)
					),
					Text(
						widget.report.task.name,
						maxLines: 3,
						overflow: TextOverflow.ellipsis,
						style: Theme.of(context).textTheme.headline3
					),
					SizedBox(height: 6.0),
					Divider(color: Colors.grey[400]),
					Tooltip(
						message: AppLocales.of(context).translate('$_pageKey.raportCard.carriedOutBy'),
						child: ListTile(
							leading: AppAvatar(widget.report.child.avatar, size: 48.0),
							title: Text(widget.report.child.name),
							subtitle: Text(getChildCardSubtitle(context, widget.report.child)),
							visualDensity: VisualDensity.compact
						)
					),
					Divider(color: Colors.grey[400]),
					_buildReportTile(
						Icons.event,
						Text(
							widget.report.taskDate.toAppString(DateFormat.yMEd(AppLocales.of(context).locale.toString()).add_jm()),
							softWrap: false,
							overflow: TextOverflow.fade,
						),
						AppLocales.of(context).translate('$_pageKey.raportCard.raportDate')
					),
					_buildReportTile(
						Icons.timer,
						Text(
							AppLocales.of(context).translate('$_pageKey.raportCard.timeFormat', {
								'HOURS_NUM': widget.report.taskTimer~/60,
								'MINUTES_NUM': widget.report.taskTimer%60
							}),
							softWrap: false,
							overflow: TextOverflow.fade,
						),
						AppLocales.of(context).translate('$_pageKey.raportCard.raportTime')
					),
					_buildReportTile(
						Icons.notifications_active,
						RichText(
							softWrap: false,
							overflow: TextOverflow.fade,
							text: TextSpan(
								text: AppLocales.of(context).translate('$_pageKey.raportCard.breakCount', {
									'BREAKS_NUM': widget.report.breakCount
								}) + ' ',
								style: Theme.of(context).textTheme.bodyText2,
								children: [
									if(widget.report.breakCount > 0)
										TextSpan(
											text: '(${AppLocales.of(context).translate('$_pageKey.raportCard.totalBreakTime')}: ' +
												AppLocales.of(context).translate('$_pageKey.raportCard.timeFormat', {
													'HOURS_NUM': widget.report.breakTimer~/60,
													'MINUTES_NUM': widget.report.breakTimer%60
												}) + ')',
											style: TextStyle(color: AppColors.mediumTextColor, fontSize: 13.0)
										)
								]
							)
						),
						AppLocales.of(context).translate('$_pageKey.raportCard.raportBreaks')
					)
				]
			)
		);
	}

	void updateReports(UITaskReportMark mark, String comment) {
		setState(() {
			widget.report.ratingMark = mark;
			widget.report.ratingComment = comment;
		});
	}

	Widget _buildBottomBar(BuildContext context) {
		bool isNotRated = widget.report.ratingMark.value == null;
		bool isRejected = widget.report.ratingMark.value == 0;

		return Container(
			width: double.infinity,
			margin: EdgeInsets.only(bottom: 20.0),
			padding: EdgeInsets.symmetric(vertical: isNotRated ? 12.0 : 4.0, horizontal: AppBoxProperties.screenEdgePadding),
			decoration: BoxDecoration(
				color: isNotRated ? Colors.grey[200] : (isRejected ? Colors.red[100] : Colors.green[100]),
				borderRadius: BorderRadius.vertical(bottom: defaultRadius)
			),
			child: isNotRated ?
				Column(
					crossAxisAlignment: CrossAxisAlignment.stretch,
					children: [
						RaisedButton.icon(
							color: AppColors.caregiverButtonColor,
							materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
							padding: EdgeInsets.symmetric(vertical: 8.0),
							colorBrightness: Brightness.dark,
							onPressed: () { 
								Navigator.of(context).push(MaterialPageRoute(
									builder: (context) => ReportForm(
										report: widget.report,
										saveCallback: updateReports
									)
								));
							},
							icon: Icon(Icons.rate_review),
							label: Text(AppLocales.of(context).translate('$_pageKey.rateTaskButton'))
						)
					]
				)
				: ListTile(
					leading: Icon(
						isRejected ? Icons.block : Icons.done,
						color: isRejected ? Colors.red : Colors.green,
						size: 32.0
					),
					title: Text(
						isRejected ?
							AppLocales.of(context).translate('$_pageKey.raportCard.rejectedLabel')
							: AppLocales.of(context).translate('$_pageKey.raportCard.ratedOnLabel', {'STARS_NUM': widget.report.ratingMark.value.toString()})
					),
					subtitle: Text(
						isRejected ?
							AppLocales.of(context).translate('$_pageKey.raportCard.rejectedHint')
							: AppLocales.of(context).translate('$_pageKey.raportCard.ratedOnHint', {
                'POINTS_NUM': (widget.report.ratingMark.value*widget.report.task.points.quantity/5.0).round().toString()
              })
					),
					visualDensity: VisualDensity.compact,
					contentPadding: EdgeInsets.zero
				)
		);
	}

}