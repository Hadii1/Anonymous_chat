// Copyright 2021 Hadi Hammoud
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:anonymous_chat/widgets/loading_widget.dart';
import 'package:anonymous_chat/widgets/onboarding_title_text.dart';

class CountryWidget extends StatefulWidget {
  final Function(CountryInfo) onChanged;
  final CountryInfo? initialData;

  const CountryWidget({
    required this.onChanged,
    required this.initialData,
  });

  @override
  _CountryWidgetState createState() => _CountryWidgetState();
}

class _CountryWidgetState extends State<CountryWidget> {
  late CountryInfo? selectedCountry;

  List<CountryInfo>? countries;

  @override
  void initState() {
    selectedCountry = widget.initialData;
    rootBundle.loadString('assets/data.json').then((String s) {
      Future.delayed(Duration(seconds: 10)).then((value) {
        var d = json.decode(s);
        List<CountryInfo> list = [];
        d.forEach((a) {
          list.add(CountryInfo.fromMap(a));
        });
        if (mounted) {
          setState(() {
            countries = list;
          });
        }
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TitleText(title: 'COUNTRY OF ORIGIN'),
        SizedBox(
          height: 50,
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 250),
            child: countries == null
                ? LoadingWidget()
                : ListView.builder(
                    itemCount: countries!.length,
                    itemBuilder: (context, index) {
                      return _CountriesList(
                        onChanged: widget.onChanged,
                        countriesList: countries!,
                        selectedCountry: selectedCountry,
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class CountryInfo {
  final String name;
  final String iso;
  final String code;

  CountryInfo(this.name, this.iso, this.code);

  factory CountryInfo.fromMap(Map<String, dynamic> map) {
    return CountryInfo(
      map['name'],
      map['Iso'],
      map['countryCode'],
    );
  }

  factory CountryInfo.fromJson(String source) =>
      CountryInfo.fromMap(json.decode(source));
}

class _CountriesList extends StatelessWidget {
  _CountriesList({
    required this.onChanged,
    required this.countriesList,
    required this.selectedCountry,
  });
  final Function(CountryInfo) onChanged;
  final List<CountryInfo> countriesList;
  final CountryInfo? selectedCountry;

  @override
  Widget build(BuildContext context) {
    AppStyle style = AppTheming.of(context).style;
    return Padding(
      padding: const EdgeInsets.only(bottom: 100.0),
      child: Column(
        children: List.generate(
          countriesList.length,
          (index) {
            CountryInfo info = countriesList[index];
            return InkWell(
              onTap: () => onChanged(info),
              child: Material(
                color: Colors.black,
                shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(1),
                  side: BorderSide(
                    width: 0.35,
                    color: style.borderColor,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: AnimatedDefaultTextStyle(
                          duration: Duration(milliseconds: 300),
                          style: selectedCountry != null &&
                                  selectedCountry!.name == info.name
                              ? style.bodyText
                                  .copyWith(color: style.accentColor)
                              : style.bodyText,
                          child: Text(
                            info.name,
                            style: style.bodyText,
                          ),
                        ),
                      ),
                      InkResponse(
                        focusColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        radius: 10,
                        splashColor: style.accentColor,
                        onTap: () {
                          onChanged(info);
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selectedCountry != null &&
                                    info.name == selectedCountry!.name
                                ? style.accentColor
                                : Colors.black,
                            border: Border.all(
                              color: style.accentColor,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: AnimatedCrossFade(
                              crossFadeState: selectedCountry != null &&
                                      selectedCountry!.name == info.name
                                  ? CrossFadeState.showFirst
                                  : CrossFadeState.showSecond,
                              duration: Duration(milliseconds: 250),
                              firstChild: Icon(
                                Icons.minimize,
                                color: Colors.black,
                                size: 18,
                              ),
                              secondChild: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
