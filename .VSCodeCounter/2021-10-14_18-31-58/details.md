# Details

Date : 2021-10-14 18:31:58

Directory /Users/hadihammoud/development/flutter projects/Chat App/anonymous_chat

Total : 98 files,  9162 codes, 1945 comments, 1199 blanks, all 12306 lines

[summary](results.md)

## Files
| filename | language | code | comment | blank | total |
| :--- | :--- | ---: | ---: | ---: | ---: |
| [README.md](/README.md) | Markdown | 17 | 0 | 5 | 22 |
| [analysis_option.yaml](/analysis_option.yaml) | YAML | 1 | 0 | 1 | 2 |
| [assets/data.json](/assets/data.json) | JSON | 1,232 | 0 | 0 | 1,232 |
| [lib/database_entities/message_entity.dart](/lib/database_entities/message_entity.dart) | Dart | 136 | 15 | 19 | 170 |
| [lib/database_entities/room_entity.dart](/lib/database_entities/room_entity.dart) | Dart | 43 | 1 | 11 | 55 |
| [lib/interfaces/auth_interface.dart](/lib/interfaces/auth_interface.dart) | Dart | 15 | 14 | 9 | 38 |
| [lib/interfaces/chat_persistance_interface.dart](/lib/interfaces/chat_persistance_interface.dart) | Dart | 0 | 0 | 1 | 1 |
| [lib/interfaces/database_interface.dart](/lib/interfaces/database_interface.dart) | Dart | 61 | 1 | 30 | 92 |
| [lib/interfaces/local_storage_interface.dart](/lib/interfaces/local_storage_interface.dart) | Dart | 10 | 13 | 5 | 28 |
| [lib/interfaces/search_service_interface.dart](/lib/interfaces/search_service_interface.dart) | Dart | 7 | 0 | 4 | 11 |
| [lib/main.dart](/lib/main.dart) | Dart | 12 | 0 | 4 | 16 |
| [lib/mappers/chat_room_mapper.dart](/lib/mappers/chat_room_mapper.dart) | Dart | 159 | 15 | 34 | 208 |
| [lib/mappers/contact_mapper.dart](/lib/mappers/contact_mapper.dart) | Dart | 51 | 13 | 8 | 72 |
| [lib/mappers/message_mapper.dart](/lib/mappers/message_mapper.dart) | Dart | 81 | 13 | 15 | 109 |
| [lib/models/activity_status.dart](/lib/models/activity_status.dart) | Dart | 47 | 17 | 13 | 77 |
| [lib/models/chat_room.dart](/lib/models/chat_room.dart) | Dart | 33 | 0 | 8 | 41 |
| [lib/models/contact.dart](/lib/models/contact.dart) | Dart | 20 | 13 | 5 | 38 |
| [lib/models/local_user.dart](/lib/models/local_user.dart) | Dart | 64 | 0 | 13 | 77 |
| [lib/models/message.dart](/lib/models/message.dart) | Dart | 65 | 2 | 10 | 77 |
| [lib/models/tag.dart](/lib/models/tag.dart) | Dart | 90 | 0 | 15 | 105 |
| [lib/providers/activity_status_provider.dart](/lib/providers/activity_status_provider.dart) | Dart | 58 | 13 | 14 | 85 |
| [lib/providers/archived_rooms_provider.dart](/lib/providers/archived_rooms_provider.dart) | Dart | 36 | 13 | 12 | 61 |
| [lib/providers/auth_provider.dart](/lib/providers/auth_provider.dart) | Dart | 148 | 2 | 28 | 178 |
| [lib/providers/blocked_contacts_provider.dart](/lib/providers/blocked_contacts_provider.dart) | Dart | 47 | 13 | 13 | 73 |
| [lib/providers/chat_provider.dart](/lib/providers/chat_provider.dart) | Dart | 188 | 3 | 39 | 230 |
| [lib/providers/connectivity_provider.dart](/lib/providers/connectivity_provider.dart) | Dart | 33 | 14 | 8 | 55 |
| [lib/providers/errors_provider.dart](/lib/providers/errors_provider.dart) | Dart | 18 | 0 | 4 | 22 |
| [lib/providers/initial_settings_providers.dart](/lib/providers/initial_settings_providers.dart) | Dart | 44 | 16 | 16 | 76 |
| [lib/providers/loading_provider.dart](/lib/providers/loading_provider.dart) | Dart | 8 | 0 | 4 | 12 |
| [lib/providers/media_sending_provider.dart](/lib/providers/media_sending_provider.dart) | Dart | 0 | 40 | 7 | 47 |
| [lib/providers/suggestions_provider.dart](/lib/providers/suggestions_provider.dart) | Dart | 50 | 0 | 13 | 63 |
| [lib/providers/tag_searching_provider.dart](/lib/providers/tag_searching_provider.dart) | Dart | 119 | 17 | 31 | 167 |
| [lib/providers/tags_provider.dart](/lib/providers/tags_provider.dart) | Dart | 73 | 0 | 15 | 88 |
| [lib/providers/user_auth_events_provider.dart](/lib/providers/user_auth_events_provider.dart) | Dart | 15 | 14 | 7 | 36 |
| [lib/providers/user_rooms_provider.dart](/lib/providers/user_rooms_provider.dart) | Dart | 115 | 0 | 22 | 137 |
| [lib/services.dart/algolia.dart](/lib/services.dart/algolia.dart) | Dart | 30 | 0 | 9 | 39 |
| [lib/services.dart/authentication.dart](/lib/services.dart/authentication.dart) | Dart | 45 | 18 | 12 | 75 |
| [lib/services.dart/firestore.dart](/lib/services.dart/firestore.dart) | Dart | 404 | 3 | 54 | 461 |
| [lib/services.dart/local_database.dart](/lib/services.dart/local_database.dart) | Dart | 266 | 25 | 44 | 335 |
| [lib/services.dart/local_storage.dart](/lib/services.dart/local_storage.dart) | Dart | 34 | 0 | 11 | 45 |
| [lib/services.dart/push_notificaitons.dart](/lib/services.dart/push_notificaitons.dart) | Dart | 27 | 15 | 11 | 53 |
| [lib/services.dart/storage.dart](/lib/services.dart/storage.dart) | Dart | 0 | 33 | 11 | 44 |
| [lib/syncer/rooms_syncer.dart](/lib/syncer/rooms_syncer.dart) | Dart | 0 | 51 | 16 | 67 |
| [lib/utilities/app_navigator.dart](/lib/utilities/app_navigator.dart) | Dart | 36 | 0 | 3 | 39 |
| [lib/utilities/constants.dart](/lib/utilities/constants.dart) | Dart | 36 | 13 | 3 | 52 |
| [lib/utilities/custom_exceptions.dart](/lib/utilities/custom_exceptions.dart) | Dart | 6 | 13 | 4 | 23 |
| [lib/utilities/enums.dart](/lib/utilities/enums.dart) | Dart | 31 | 14 | 6 | 51 |
| [lib/utilities/extentions.dart](/lib/utilities/extentions.dart) | Dart | 76 | 0 | 10 | 86 |
| [lib/utilities/fading_route.dart](/lib/utilities/fading_route.dart) | Dart | 16 | 13 | 5 | 34 |
| [lib/utilities/general_functions.dart](/lib/utilities/general_functions.dart) | Dart | 45 | 15 | 12 | 72 |
| [lib/utilities/theme_widget.dart](/lib/utilities/theme_widget.dart) | Dart | 180 | 1 | 22 | 203 |
| [lib/views/about_screen.dart](/lib/views/about_screen.dart) | Dart | 59 | 14 | 4 | 77 |
| [lib/views/archived_contacts_list.dart](/lib/views/archived_contacts_list.dart) | Dart | 143 | 13 | 5 | 161 |
| [lib/views/blocked_contacts_list.dart](/lib/views/blocked_contacts_list.dart) | Dart | 229 | 14 | 10 | 253 |
| [lib/views/chats_screen.dart](/lib/views/chats_screen.dart) | Dart | 153 | 0 | 15 | 168 |
| [lib/views/home_screen.dart](/lib/views/home_screen.dart) | Dart | 99 | 0 | 12 | 111 |
| [lib/views/login_screen.dart](/lib/views/login_screen.dart) | Dart | 174 | 0 | 11 | 185 |
| [lib/views/nickname_screen.dart](/lib/views/nickname_screen.dart) | Dart | 413 | 13 | 24 | 450 |
| [lib/views/room_screen.dart](/lib/views/room_screen.dart) | Dart | 272 | 0 | 13 | 285 |
| [lib/views/settings_screen.dart](/lib/views/settings_screen.dart) | Dart | 186 | 2 | 5 | 193 |
| [lib/views/splash_screen.dart](/lib/views/splash_screen.dart) | Dart | 55 | 28 | 5 | 88 |
| [lib/views/tags_screen.dart](/lib/views/tags_screen.dart) | Dart | 508 | 0 | 29 | 537 |
| [lib/views/welcome_Screen.dart](/lib/views/welcome_Screen.dart) | Dart | 46 | 13 | 5 | 64 |
| [lib/widgets/age.dart](/lib/widgets/age.dart) | Dart | 0 | 289 | 29 | 318 |
| [lib/widgets/animated_widgets.dart](/lib/widgets/animated_widgets.dart) | Dart | 110 | 1 | 21 | 132 |
| [lib/widgets/chat_bubble.dart](/lib/widgets/chat_bubble.dart) | Dart | 217 | 13 | 11 | 241 |
| [lib/widgets/chat_header.dart](/lib/widgets/chat_header.dart) | Dart | 228 | 0 | 9 | 237 |
| [lib/widgets/chat_message_field.dart](/lib/widgets/chat_message_field.dart) | Dart | 191 | 14 | 24 | 229 |
| [lib/widgets/connectivity_state_notificaiton.dart](/lib/widgets/connectivity_state_notificaiton.dart) | Dart | 7 | 13 | 3 | 23 |
| [lib/widgets/connectrivity_widget.dart](/lib/widgets/connectrivity_widget.dart) | Dart | 0 | 14 | 5 | 19 |
| [lib/widgets/country_widget.dart](/lib/widgets/country_widget.dart) | Dart | 0 | 541 | 32 | 573 |
| [lib/widgets/cta_button.dart](/lib/widgets/cta_button.dart) | Dart | 40 | 0 | 5 | 45 |
| [lib/widgets/custom_expansion_tile.dart](/lib/widgets/custom_expansion_tile.dart) | Dart | 186 | 87 | 33 | 306 |
| [lib/widgets/custom_image.dart](/lib/widgets/custom_image.dart) | Dart | 0 | 98 | 14 | 112 |
| [lib/widgets/custom_route.dart](/lib/widgets/custom_route.dart) | Dart | 17 | 13 | 5 | 35 |
| [lib/widgets/custom_tab_bar.dart](/lib/widgets/custom_tab_bar.dart) | Dart | 121 | 2 | 15 | 138 |
| [lib/widgets/custom_text_field.dart](/lib/widgets/custom_text_field.dart) | Dart | 100 | 0 | 13 | 113 |
| [lib/widgets/error_notification.dart](/lib/widgets/error_notification.dart) | Dart | 72 | 0 | 5 | 77 |
| [lib/widgets/error_widget.dart](/lib/widgets/error_widget.dart) | Dart | 67 | 13 | 7 | 87 |
| [lib/widgets/gender.dart](/lib/widgets/gender.dart) | Dart | 0 | 134 | 10 | 144 |
| [lib/widgets/keyboard_hider.dart](/lib/widgets/keyboard_hider.dart) | Dart | 17 | 1 | 4 | 22 |
| [lib/widgets/loading_widget.dart](/lib/widgets/loading_widget.dart) | Dart | 34 | 0 | 3 | 37 |
| [lib/widgets/message_reply.dart](/lib/widgets/message_reply.dart) | Dart | 102 | 26 | 15 | 143 |
| [lib/widgets/onboarding_title_text.dart](/lib/widgets/onboarding_title_text.dart) | Dart | 37 | 0 | 3 | 40 |
| [lib/widgets/password_field.dart](/lib/widgets/password_field.dart) | Dart | 102 | 0 | 10 | 112 |
| [lib/widgets/progress_indicator.dart](/lib/widgets/progress_indicator.dart) | Dart | 50 | 13 | 4 | 67 |
| [lib/widgets/rewind_button.dart](/lib/widgets/rewind_button.dart) | Dart | 27 | 0 | 3 | 30 |
| [lib/widgets/search_field.dart](/lib/widgets/search_field.dart) | Dart | 78 | 1 | 9 | 88 |
| [lib/widgets/settings_tile.dart](/lib/widgets/settings_tile.dart) | Dart | 36 | 13 | 5 | 54 |
| [lib/widgets/shaded_container.dart](/lib/widgets/shaded_container.dart) | Dart | 31 | 14 | 4 | 49 |
| [lib/widgets/step_counter_bar.dart](/lib/widgets/step_counter_bar.dart) | Dart | 125 | 2 | 11 | 138 |
| [lib/widgets/suggestion_header.dart](/lib/widgets/suggestion_header.dart) | Dart | 101 | 3 | 6 | 110 |
| [lib/widgets/tags_row.dart](/lib/widgets/tags_row.dart) | Dart | 127 | 0 | 12 | 139 |
| [lib/widgets/titled_app_bar.dart](/lib/widgets/titled_app_bar.dart) | Dart | 99 | 0 | 7 | 106 |
| [lib/widgets/top_padding.dart](/lib/widgets/top_padding.dart) | Dart | 18 | 13 | 5 | 36 |
| [lib/widgets/typing_indicator.dart](/lib/widgets/typing_indicator.dart) | Dart | 98 | 13 | 15 | 126 |
| [pubspec.yaml](/pubspec.yaml) | YAML | 59 | 17 | 21 | 97 |
| [test/widget_test.dart](/test/widget_test.dart) | Dart | 0 | 24 | 7 | 31 |

[summary](results.md)