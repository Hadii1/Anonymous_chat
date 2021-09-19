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

import 'dart:async';
import 'dart:convert';

import 'package:anonymous_chat/widgets/keyboard_hider.dart';
import 'package:anonymous_chat/widgets/search_field.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:anonymous_chat/widgets/onboarding_title_text.dart';

import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CountryWidget extends StatefulWidget {
  final Function(MapEntry<String, String>?) onSelected;
  final MapEntry<String, String>? initialData;

  const CountryWidget({
    required this.onSelected,
    required this.initialData,
  });

  @override
  _CountryWidgetState createState() => _CountryWidgetState();
}

class _CountryWidgetState extends State<CountryWidget> {
  late MapEntry<String, String>? selectedCountry;

  final Map<String, String> allCountries = {
    'Afghanistan': '+93',
    'Åland Islands': '+358',
    'Albania': '+355',
    'Algeria': '+213',
    'American Samoa': '+1684',
    'Andorra': '+376',
    'Angola': '+244',
    'Anguilla': '+1264',
    'Antarctica': '+672',
    'Antigua and Barbuda': '+1268',
    'Argentina': '+54',
    'Armenia': '+374',
    'Aruba': '+297',
    'Australia': '+61',
    'Austria': '+43',
    'Azerbaijan': '+994',
    'Bahamas': '+1242',
    'Bahrain': '+973',
    'Bangladesh': '+880',
    'Barbados': '+1246',
    'Belarus': '+375',
    'Belgium': '+32',
    'Belize': '+501',
    'Benin': '+229',
    'Bermuda': '+1441',
    'Bhutan': '+975',
    'Bolivia, Plurinational State of bolivia': '+591',
    'Bosnia and Herzegovina': '+387',
    'Botswana': '+267',
    'Bouvet Island': '+47',
    'Brazil': '+55',
    'British Indian Ocean Territory': '+246',
    'Brunei Darussalam': '+673',
    'Bulgaria': '+359',
    'Burkina Faso': '+226',
    'Burundi': '+257',
    'Cambodia': '+855',
    'Cameroon': '+237',
    'Canada': '+1',
    'Cape Verde': '+238',
    'Cayman Islands': '+ 345',
    'Central African Republic': '+236',
    'Chad': '+235',
    'Chile': '+56',
    'China': '+86',
    'Christmas Island': '+61',
    'Cocos (Keeling) Islands': '+61',
    'Colombia': '+57',
    'Comoros': '+269',
    'Congo': '+242',
    'Congo, The Democratic Republic of the Congo': '+243',
    'Cook Islands': '+682',
    'Costa Rica': '+506',
    'Cote d\'Ivoire': '+225',
    'Croatia': '+385',
    'Cuba': '+53',
    'Cyprus': '+357',
    'Czech Republic': '+420',
    'Denmark': '+45',
    'Djibouti': '+253',
    'Dominica': '+1767',
    'Dominican Republic': '+1849',
    'Ecuador': '+593',
    'Egypt': '+20',
    'El Salvador': '+503',
    'Equatorial Guinea': '+240',
    'Eritrea': '+291',
    'Estonia': '+372',
    'Ethiopia': '+251',
    'Falkland Islands (Malvinas)': '+500',
    'Faroe Islands': '+298',
    'Fiji': '+679',
    'Finland': '+358',
    'France': '+33',
    'French Guiana': '+594',
    'French Polynesia': '+689',
    'French Southern Territories': '+262',
    'Gabon': '+241',
    'Gambia': '+220',
    'Georgia': '+995',
    'Germany': '+49',
    'Ghana': '+233',
    'Gibraltar': '+350',
    'Greece': '+30',
    'Greenland': '+299',
    'Grenada': '+1473',
    'Guadeloupe': '+590',
    'Guam': '+1671',
    'Guatemala': '+502',
    'Guernsey': '+44',
    'Guinea': '+224',
    'Guinea-Bissau': '+245',
    'Guyana': '+592',
    'Haiti': '+509',
    'Heard Island and Mcdonald Islands': '+0',
    'Holy See (Vatican City State)': '+379',
    'Honduras': '+504',
    'Hong Kong': '+852',
    'Hungary': '+36',
    'Iceland': '+354',
    'India': '+91',
    'Indonesia': '+62',
    'Iran, Islamic Republic of Persian Gulf': '+98',
    'Iraq': '+964',
    'Ireland': '+353',
    'Isle of Man': '+44',
    'Israel': '+972',
    'Italy': '+39',
    'Jamaica': '+1876',
    'Japan': '+81',
    'Jersey': '+44',
    'Jordan': '+962',
    'Kazakhstan': '+7',
    'Kenya': '+254',
    'Kiribati': '+686',
    'Korea, Democratic People\'s Republic of Korea': '+850',
    'Korea, Republic of South Korea': '+82',
    'Kosovo': '+383',
    'Kuwait': '+965',
    'Kyrgyzstan': '+996',
    'Laos': '+856',
    'Latvia': '+371',
    'Lebanon': '+961',
    'Lesotho': '+266',
    'Liberia': '+231',
    'Libyan Arab Jamahiriya': '+218',
    'Liechtenstein': '+423',
    'Lithuania': '+370',
    'Luxembourg': '+352',
    'Macao': '+853',
    'Macedonia': '+389',
    'Madagascar': '+261',
    'Malawi': '+265',
    'Malaysia': '+60',
    'Maldives': '+960',
    'Mali': '+223',
    'Malta': '+356',
    'Marshall Islands': '+692',
    'Martinique': '+596',
    'Mauritania': '+222',
    'Mauritius': '+230',
    'Mayotte': '+262',
    'Mexico': '+52',
    'Micronesia, Federated States of Micronesia': '+691',
    'Moldova': '+373',
    'Monaco': '+377',
    'Mongolia': '+976',
    'Montenegro': '+382',
    'Montserrat': '+1664',
    'Morocco': '+212',
    'Mozambique': '+258',
    'Myanmar': '+95',
    'Namibia': '+264',
    'Nauru': '+674',
    'Nepal': '+977',
    'Netherlands': '+31',
    'Netherlands Antilles': '+599',
    'New Caledonia': '+687',
    'New Zealand': '+64',
    'Nicaragua': '+505',
    'Niger': '+227',
    'Nigeria': '+234',
    'Niue': '+683',
    'Norfolk Island': '+672',
    'Northern Mariana Islands': '+1670',
    'Norway': '+47',
    'Oman': '+968',
    'Pakistan': '+92',
    'Palau': '+680',
    'Palestinian Territory, Occupied': '+970',
    'Panama': '+507',
    'Papua New Guinea': '+675',
    'Paraguay': '+595',
    'Peru': '+51',
    'Philippines': '+63',
    'Pitcairn': '+64',
    'Poland': '+48',
    'Portugal': '+351',
    'Puerto Rico': '+1939',
    'Qatar': '+974',
    'Romania': '+40',
    'Russia': '+7',
    'Rwanda': '+250',
    'Reunion': '+262',
    'Saint Barthelemy': '+590',
    'Saint Helena, Ascension and Tristan Da Cunha': '+290',
    'Saint Kitts and Nevis': '+1869',
    'Saint Lucia': '+1758',
    'Saint Martin': '+590',
    'Saint Pierre and Miquelon': '+508',
    'Saint Vincent and the Grenadines': '+1784',
    'Samoa': '+685',
    'San Marino': '+378',
    'Sao Tome and Principe': '+239',
    'Saudi Arabia': '+966',
    'Senegal': '+221',
    'Serbia': '+381',
    'Seychelles': '+248',
    'Sierra Leone': '+232',
    'Singapore': '+65',
    'Slovakia': '+421',
    'Slovenia': '+386',
    'Solomon Islands': '+677',
    'Somalia': '+252',
    'South Africa': '+27',
    'South Sudan': '+211',
    'South Georgia and the South Sandwich Islands': '+500',
    'Spain': '+34',
    'Sri Lanka': '+94',
    'Sudan': '+249',
    'Suriname': '+597',
    'Svalbard and Jan Mayen': '+47',
    'Swaziland': '+268',
    'Sweden': '+46',
    'Switzerland': '+41',
    'Syrian Arab Republic': '+963',
    'Taiwan': '+886',
    'Tajikistan': '+992',
    'Tanzania, United Republic of Tanzania': '+255',
    'Thailand': '+66',
    'Timor-Leste': '+670',
    'Togo': '+228',
    'Tokelau': '+690',
    'Tonga': '+676',
    'Trinidad and Tobago': '+1868',
    'Tunisia': '+216',
    'Turkey': '+90',
    'Turkmenistan': '+993',
    'Turks and Caicos Islands': '+1649',
    'Tuvalu': '+688',
    'Uganda': '+256',
    'Ukraine': '+380',
    'United Arab Emirates': '+971',
    'United Kingdom': '+44',
    'United States': '+1',
    'Uruguay': '+598',
    'Uzbekistan': '+998',
    'Vanuatu': '+678',
    'Venezuela, Bolivarian Republic of Venezuela': '+58',
    'Vietnam': '+84',
    'Virgin Islands, British': '+1284',
    'Virgin Islands, U.S.': '+1340',
    'Wallis and Futuna': '+681',
    'Yemen': '+967',
    'Zambia': '+260',
    'Zimbabwe': '+263',
  };
  late Map<String, String> currentCountries;

  @override
  void initState() {
    selectedCountry = widget.initialData;
    currentCountries = Map.from(allCountries);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardHider(
      child: Column(
        children: [
          TitleText(title: 'COUNTRY OF ORIGIN'),
          AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 24,
              ),
              child: CountriesSearchField(
                allCountries: allCountries,
                onChanged: (Map<String, String> value) {
                  setState(() {
                    currentCountries = value;
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 250),
              child: ImplicitlyAnimatedList<MapEntry<String, String>>(
                items: currentCountries.entries.toList(),
                removeItemBuilder: (context, animation, item) =>
                    SizeFadeTransition(
                  animation: animation,
                  curve: Curves.easeOut,
                  child: CountryTile(
                    item: item,
                    onTap: (_) {},
                    initialSelected: selectedCountry != null &&
                        selectedCountry!.key == item.key,
                  ),
                ),
                itemBuilder: (context, animation, item, i) {
                  return SizeFadeTransition(
                    animation: animation,
                    curve: Curves.easeOut,
                    child: CountryTile(
                      item: item,
                      initialSelected: selectedCountry != null &&
                          selectedCountry!.key == item.key,
                      onTap: (selected) {
                        if (selected) {
                          selectedCountry = item;
                          widget.onSelected(selectedCountry!);
                          setState(() {});
                        } else {
                          widget.onSelected(null);
                          selectedCountry = null;
                          setState(() {});
                        }
                        widget.onSelected(selectedCountry);
                      },
                    ),
                  );
                },
                areItemsTheSame: (a, b) => a.key == b.key,
              ),
            ),
          ),
          SizedBox(height: 120),
        ],
      ),
    );
  }
}

class CountriesSearchField extends StatefulWidget {
  final Map<String, String> allCountries;
  final Function(Map<String, String>) onChanged;

  const CountriesSearchField({
    required this.allCountries,
    required this.onChanged,
  });

  @override
  _CountriesSearchFieldState createState() => _CountriesSearchFieldState();
}

class _CountriesSearchFieldState extends State<CountriesSearchField> {
  Map<String, String> get countries => widget.allCountries;
  String? searchTerm;
  Timer? _debounceTimer;
  late Map<String, String> currentList;

  @override
  void initState() {
    assert(countries.length == 246);
    currentList = Map.from(countries);
    super.initState();
  }

  @override
  void dispose() {
    cancelTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SearchField(
      hint: 'Search countries',
      onChanged: (v) {
        cancelTimer();

        if (v.isEmpty) {
          currentList.clear();
          currentList = Map.from(countries);
          widget.onChanged(currentList);
        } else {
          _debounceTimer = Timer(Duration(milliseconds: 400), () {
            currentList.clear();
            currentList = Map.fromIterable(countries.keys
                .toList()
                .where((c) => c.toLowerCase().contains(v.toLowerCase())));
            widget.onChanged(currentList);
          });
        }
      },
    );
  }

  void cancelTimer() {
    if (_debounceTimer != null && _debounceTimer!.isActive)
      _debounceTimer!.cancel();
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

class CountryTile extends StatefulWidget {
  final MapEntry<String, String> item;
  final Function(bool selected) onTap;
  final bool initialSelected;

  const CountryTile({
    required this.item,
    required this.onTap,
    required this.initialSelected,
  });

  @override
  _CountryTileState createState() => _CountryTileState();
}

class _CountryTileState extends State<CountryTile> {
  late bool isSelected;

  @override
  void initState() {
    isSelected = widget.initialSelected;
    super.initState();
  }

  @override
  void didUpdateWidget(CountryTile oldWidget) {
    if (oldWidget.initialSelected != widget.initialSelected) {
      setState(() {
        isSelected = widget.initialSelected;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  Widget build(BuildContext context) {
    AppStyle style = AppTheming.of(context).style;
    return InkWell(
      // splashColor: Colors.transparent,
      // highlightColor: Colors.transparent,
      onTap: () {
        setState(() {
          isSelected = !isSelected;
          widget.onTap(isSelected);
        });
      },
      child: Material(
        color: Colors.transparent,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(1),
          side: BorderSide(
            width: 0.35,
            color: style.borderColor,
          ),
        ),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          color: isSelected ? style.accentColor.withOpacity(0.2) : Colors.black,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.item.key,
                    style: style.bodyText,
                  ),
                ),
                InkResponse(
                  focusColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  radius: 10,
                  splashColor: style.accentColor,
                  onTap: () {
                    setState(() {
                      isSelected = !isSelected;
                      widget.onTap(isSelected);
                    });
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? style.accentColor : Colors.black,
                      border: Border.all(
                        color: style.accentColor,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: AnimatedCrossFade(
                        crossFadeState: isSelected
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        duration: Duration(milliseconds: 250),
                        firstChild: Icon(
                          CupertinoIcons.minus,
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
      ),
    );
  }
}
