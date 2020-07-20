import 'package:fokus/model/currency_type.dart';
import 'package:meta/meta.dart';

class Currency {
	String name;
	CurrencyType icon;

	Currency({this.icon, this.name});

	factory Currency.fromJson(Map<String, dynamic> json) => Currency()..fromJson(json);

	@protected
	void fromJson(Map<String, dynamic> json) {
		icon = CurrencyType.values[json['icon']];
		name = json['name'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['icon'] = this.icon.index;
		data['name'] = this.name;
		return data;
	}
}
