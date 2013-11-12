/*  Copyright 2012 MaidSafe.net limited

    This MaidSafe Software is licensed to you under (1) the MaidSafe.net Commercial License,
    version 1.0 or later, or (2) The General Public License (GPL), version 3, depending on which
    licence you accepted on initial access to the Software (the "Licences").

    By contributing code to the MaidSafe Software, or to this project generally, you agree to be
    bound by the terms of the MaidSafe Contributor Agreement, version 1.0, found in the root
    directory of this project at LICENSE, COPYING and CONTRIBUTOR respectively and also
    available at: http://www.maidsafe.net/licenses

    Unless required by applicable law or agreed to in writing, the MaidSafe Software distributed
    under the GPL Licence is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS
    OF ANY KIND, either express or implied.

    See the Licences for the specific language governing permissions and limitations relating to
    use of the MaidSafe Software.                                                                 */

#ifndef MAIDSAFE_COMMON_CONFIG_H_
#define MAIDSAFE_COMMON_CONFIG_H_

#include <string>
#include "boost/preprocessor/stringize.hpp"

#ifdef _MSC_VER
#define MAIDSAFE_NOEXCEPT
#define MAIDSAFE_DELETE
#else
#define MAIDSAFE_NOEXCEPT noexcept(true)
#define MAIDSAFE_DELETE = delete
#endif

namespace maidsafe {

#if defined APPLICATION_VERSION_MAJOR && defined APPLICATION_VERSION_MINOR && defined \
    APPLICATION_VERSION_PATCH
inline const std::string kApplicationVersion() {
  return BOOST_PP_STRINGIZE(APPLICATION_VERSION_MAJOR) + std::string(".") +
         BOOST_PP_STRINGIZE(APPLICATION_VERSION_MINOR) + std::string(".") +
         BOOST_PP_STRINGIZE(APPLICATION_VERSION_PATCH);
}

#else
#error APPLICATION_VERSION_MAJOR, APPLICATION_VERSION_MINOR and APPLICATION_VERSION_PATCH \
         must be defined.
#endif

std::string kTargetPlatform();

std::string kTargetArchitecture();

}  // namespace maidsafe

#endif  // MAIDSAFE_COMMON_CONFIG_H_
