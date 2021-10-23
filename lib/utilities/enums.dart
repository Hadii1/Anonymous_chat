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

enum DestinationAfterAuth {
  NAME_GENERATOR_SCREEN,
  HOME_SCREEN,
}
enum UserState {
  AUTHENTICATETD_AND_NICKNAMED,
  NOT_AUTHENTICATTED,
  AUTHENTICATED_NOT_NICKNAMED
}
enum DataChangeType {
  ADDED,
  DELETED,
  MODIFIED,
}

enum MessageServeUpdateType {
  MESSAGE_READ,
  MESSAGE_RECIEVED,
}

enum GetDataSource {
  LOCAL,
  ONLINE,
}

enum SetDataSource {
  LOCAL,
  ONLINE,
  BOTH,
}

enum RoomsUpdateType {
  ROOM_DELETED,
  // ROOM_MODIFIED, // A message(s) sent/received/read
  ROOM_ADDED,
}
