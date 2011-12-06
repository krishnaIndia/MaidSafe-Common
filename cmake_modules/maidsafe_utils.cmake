#==============================================================================#
#                                                                              #
#  Copyright (c) 2011 maidsafe.net limited                                     #
#  All rights reserved.                                                        #
#                                                                              #
#  Redistribution and use in source and binary forms, with or without          #
#  modification, are permitted provided that the following conditions are met: #
#                                                                              #
#      * Redistributions of source code must retain the above copyright        #
#        notice, this list of conditions and the following disclaimer.         #
#      * Redistributions in binary form must reproduce the above copyright     #
#        notice, this list of conditions and the following disclaimer in the   #
#        documentation and/or other materials provided with the distribution.  #
#      * Neither the name of the maidsafe.net limited nor the names of its     #
#        contributors may be used to endorse or promote products derived from  #
#        this software without specific prior written permission.              #
#                                                                              #
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" #
#  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE   #
#  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE  #
#  ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE  #
#  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR         #
#  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF        #
#  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS    #
#  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN     #
#  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)     #
#  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE  #
#  POSSIBILITY OF SUCH DAMAGE.                                                 #
#                                                                              #
#==============================================================================#
#                                                                              #
#  Written by maidsafe.net team                                                #
#                                                                              #
#==============================================================================#
#                                                                              #
#  Utility functions.                                                          #
#                                                                              #
#==============================================================================#


FUNCTION(MS_ADD_EXECUTABLE EXE)
  SET(FILES ${ARGV})
  LIST(REMOVE_AT FILES 0)
  SET(ALL_EXECUTABLES ${ALL_EXECUTABLES} ${EXE} PARENT_SCOPE)
  ADD_EXECUTABLE(${EXE} ${FILES})
  IF(NOT MSVC)
    # Force renaming of exes to match standard CMake library renaming policy
    SET_TARGET_PROPERTIES(${EXE} PROPERTIES
                            DEBUG_OUTPUT_NAME ${EXE}-d
                            RELWITHDEBINFO_OUTPUT_NAME ${EXE}-rwdi
                            MINSIZEREL_OUTPUT_NAME ${EXE}-msr)
  ENDIF()
ENDFUNCTION()

FUNCTION(INSTALL_HEADERS DESTINATION)
  SET(FILES ${ARGV})
  LIST(REMOVE_AT FILES 0 1)
  INSTALL(CODE "FILE(GLOB_RECURSE INSTALLED \"\${CMAKE_INSTALL_PREFIX}/${DESTINATION}/*.h*\")\nIF(INSTALLED)\nFILE(REMOVE \${INSTALLED})\nENDIF()")
  INSTALL(FILES ${FILES} DESTINATION ${DESTINATION})
ENDFUNCTION()

FUNCTION(ADD_COVERAGE_EXCLUDE REGEX)
  FILE(APPEND ${PROJECT_BINARY_DIR}/CTestCustom.cmake "SET(CTEST_CUSTOM_COVERAGE_EXCLUDE \${CTEST_CUSTOM_COVERAGE_EXCLUDE} \"${REGEX}\")\n")
ENDFUNCTION()

FUNCTION(ADD_MEMCHECK_IGNORE TEST_NAME)
  FILE(APPEND ${PROJECT_BINARY_DIR}/CTestCustom.cmake "SET(CTEST_CUSTOM_MEMCHECK_IGNORE \${CTEST_CUSTOM_MEMCHECK_IGNORE} \"${TEST_NAME}\")\n")
ENDFUNCTION()

# Searches for and removes old test directories that may have been left in %temp%
FUNCTION(CLEANUP_TEMP_DIR)
  IF(WIN32)
    IF(NOT CLEAN_TEMP)
      SET(CLEAN_TEMP "OFF" CACHE INTERNAL "Cleanup of temp test folders, options are: ONCE, OFF, ALWAYS" FORCE)
    ENDIF(NOT CLEAN_TEMP)
    EXECUTE_PROCESS(COMMAND CMD /C ECHO %TEMP% OUTPUT_VARIABLE temp_path OUTPUT_STRIP_TRAILING_WHITESPACE)
    STRING(REPLACE "\\" "/" temp_path ${temp_path})
    FILE(GLOB maidsafe_temp_dirs ${temp_path}/MaidSafe_Test*)
    FILE(GLOB sigmoid_temp_dirs ${temp_path}/Sigmoid_Test*)
    SET(temp_dirs ${maidsafe_temp_dirs} ${sigmoid_temp_dirs})
    LIST(LENGTH temp_dirs temp_dir_count)
    IF(NOT ${temp_dir_count} EQUAL 0)
      MESSAGE("")
      IF(CLEAN_TEMP MATCHES ONCE OR CLEAN_TEMP MATCHES ALWAYS)
        MESSAGE("Cleaning up temporary test folders.\n")
        FOREACH(temp_dir ${temp_dirs})
          FILE(REMOVE_RECURSE ${temp_dir})
          MESSAGE("-- Removed ${temp_dir}")
        ENDFOREACH()
      ELSE()
        MESSAGE("The following temporary test folders could be cleaned up:\n")
        FOREACH(temp_dir ${temp_dirs})
          MESSAGE("-- Found ${temp_dir}")
        ENDFOREACH()
        MESSAGE("")
        MESSAGE("To cleanup, run cmake ../.. -DCLEAN_TEMP=ONCE or cmake ../.. -DCLEAN_TEMP=ALWAYS")
      ENDIF()
      MESSAGE("================================================================================")
    ENDIF()
    IF(NOT CLEAN_TEMP MATCHES ALWAYS)
      SET(CLEAN_TEMP "OFF" CACHE INTERNAL "Cleanup of temp test folders, options are: ONCE, OFF, ALWAYS" FORCE)
    ENDIF()
  ENDIF()
ENDFUNCTION()

# Searches for and removes old generated .pb.cc and .pb.h files in the source tree
FUNCTION(REMOVE_OLD_PROTO_FILES)
  FILE(GLOB_RECURSE PB_FILES RELATIVE ${PROJECT_SOURCE_DIR}/src ${PROJECT_SOURCE_DIR}/src/*.pb.*)
  LIST(LENGTH PB_FILES PB_FILES_COUNT)
  IF(NOT ${PB_FILES_COUNT} EQUAL 0)
    FOREACH(PB_FILE ${PB_FILES})
      GET_FILENAME_COMPONENT(PB_FILE_PATH ${PB_FILE} PATH)
      GET_FILENAME_COMPONENT(PB_FILE_WE ${PB_FILE} NAME_WE)
      LIST(FIND PROTO_FILES "${PB_FILE_PATH}/${PB_FILE_WE}.proto" FOUND)
      IF (FOUND EQUAL -1)
        FILE(REMOVE ${PROJECT_SOURCE_DIR}/src/${PB_FILE})
        STRING(REGEX REPLACE "[\\/.:]" "_" PROTO_CACHE_NAME "${PB_FILE_PATH}/${PB_FILE_WE}.proto")
        UNSET(${PROTO_CACHE_NAME} CACHE)
        MESSAGE("-- Removed ${PB_FILE}")
      ENDIF()
    ENDFOREACH()
  ENDIF()
ENDFUNCTION()

FUNCTION(TEST_SUMMARY_OUTPUT)
  LIST(LENGTH ALL_GTESTS GTEST_COUNT)
  MESSAGE("\n${MAIDSAFE_TEST_TYPE_MESSAGE}.   ${GTEST_COUNT} Google Tests.\n")
  MESSAGE("    To include all tests,                ${ERROR_MESSAGE_CMAKE_PATH} -DMAIDSAFE_TEST_TYPE=ALL")
  MESSAGE("    To include behavioural tests,        ${ERROR_MESSAGE_CMAKE_PATH} -DMAIDSAFE_TEST_TYPE=BEH")
  MESSAGE("    To include functional tests,        ${ERROR_MESSAGE_CMAKE_PATH} -DMAIDSAFE_TEST_TYPE=FUNC")
  MESSAGE("================================================================================")
ENDFUNCTION()

# Checks VERSION_H file for dependent MaidSafe library versions.  For a project
# with e.g. "#define MAIDSAFE_COMMON_VERSION 010215" in its version.h then the following
# variables are set:
# ${THIS_VERSION_FILE}            maidsafe/common/version.h
# ${THIS_VERSION}                 MAIDSAFE_COMMON_VERSION
# ${${THIS_VERSION}}              10215
# ${CPACK_PACKAGE_VERSION_MAJOR}  1
# ${CPACK_PACKAGE_VERSION_MINOR}  02
# ${CPACK_PACKAGE_VERSION_PATCH}  15
# ${CPACK_PACKAGE_VERSION}        1.02.15
# ${MAIDSAFE_LIBRARY_POSTFIX}     -1_02_15
# Also, the MAIDSAFE_LIBRARY_POSTFIX is appended to each of the CMAKE_<build type>_POSTFIX variables.
# Finally, a preprocessor definition CMAKE_${THIS_VERSION} is added to force a re-run of CMake
# after changing the version in version.h
FUNCTION(HANDLE_VERSIONS VERSION_H)
  FILE(GLOB THIS_VERSION_FILE RELATIVE ${PROJECT_SOURCE_DIR}/src ${VERSION_H})
  SET(THIS_VERSION_FILE ${THIS_VERSION_FILE} PARENT_SCOPE)
  FILE(STRINGS ${VERSION_H} VERSIONS REGEX "#define [A-Z_]+VERSION [0-9]+$")
  FOREACH(VERSN ${VERSIONS})
    STRING(REPLACE "#define " "" VERSN ${VERSN})
    STRING(REGEX REPLACE "[ ]+" ";" VERSN ${VERSN})
    LIST(GET VERSN 0 VERSION_VARIABLE_NAME)
    LIST(GET VERSN 1 VERSION_VARIABLE_VALUE)
    STRING(REGEX MATCH "THIS_NEEDS_" IS_DEPENDENCY ${VERSION_VARIABLE_NAME})
    IF(IS_DEPENDENCY)
      STRING(REGEX REPLACE "THIS_NEEDS_" "" DEPENDENCY_VARIABLE_NAME ${VERSION_VARIABLE_NAME})
      IF(NOT ${${DEPENDENCY_VARIABLE_NAME}} MATCHES ${VERSION_VARIABLE_VALUE})
        SET(ERROR_MESSAGE "\n\nThis project needs ${DEPENDENCY_VARIABLE_NAME} ${VERSION_VARIABLE_VALUE}\n")
        SET(ERROR_MESSAGE "${ERROR_MESSAGE}Found ${DEPENDENCY_VARIABLE_NAME} ${${DEPENDENCY_VARIABLE_NAME}}\n\n")
        MESSAGE(FATAL_ERROR "${ERROR_MESSAGE}")
      ENDIF()
    ELSE()
      SET(${VERSION_VARIABLE_NAME} ${VERSION_VARIABLE_VALUE} PARENT_SCOPE)
      SET(THIS_VERSION ${VERSION_VARIABLE_NAME} PARENT_SCOPE)
      MATH(EXPR VERSION_MAJOR ${VERSION_VARIABLE_VALUE}/10000)
      MATH(EXPR VERSION_MINOR ${VERSION_VARIABLE_VALUE}/100%100)
      MATH(EXPR VERSION_PATCH ${VERSION_VARIABLE_VALUE}%100)
      IF(VERSION_MINOR LESS 10)
        SET(VERSION_MINOR 0${VERSION_MINOR})
      ENDIF()
      IF(VERSION_PATCH LESS 10)
        SET(VERSION_PATCH 0${VERSION_PATCH})
      ENDIF()
      SET(CPACK_PACKAGE_VERSION_MAJOR ${VERSION_MAJOR} PARENT_SCOPE)
      SET(CPACK_PACKAGE_VERSION_MINOR ${VERSION_MINOR} PARENT_SCOPE)
      SET(CPACK_PACKAGE_VERSION_PATCH ${VERSION_PATCH} PARENT_SCOPE)
      SET(CPACK_PACKAGE_VERSION ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH} PARENT_SCOPE)
      SET(MAIDSAFE_LIBRARY_POSTFIX -${VERSION_MAJOR}_${VERSION_MINOR}_${VERSION_PATCH})
      SET(MAIDSAFE_LIBRARY_POSTFIX ${MAIDSAFE_LIBRARY_POSTFIX} PARENT_SCOPE)
      SET(CMAKE_RELEASE_POSTFIX ${CMAKE_RELEASE_POSTFIX}${MAIDSAFE_LIBRARY_POSTFIX} PARENT_SCOPE)
      SET(CMAKE_DEBUG_POSTFIX ${CMAKE_DEBUG_POSTFIX}${MAIDSAFE_LIBRARY_POSTFIX} PARENT_SCOPE)
      SET(CMAKE_RELWITHDEBINFO_POSTFIX ${CMAKE_RELWITHDEBINFO_POSTFIX}${MAIDSAFE_LIBRARY_POSTFIX} PARENT_SCOPE)
      SET(CMAKE_MINSIZEREL_POSTFIX ${CMAKE_MINSIZEREL_POSTFIX}${MAIDSAFE_LIBRARY_POSTFIX} PARENT_SCOPE)
      ADD_DEFINITIONS(-DCMAKE_${VERSION_VARIABLE_NAME}=${VERSION_VARIABLE_VALUE})
    ENDIF()
  ENDFOREACH()
ENDFUNCTION()

FUNCTION(ADD_VERSION_INFO_TO_INSTALLED_FILE)
  INSTALL(CODE "STRING(TOLOWER \${CMAKE_INSTALL_CONFIG_NAME} CMAKE_INSTALL_CONFIG_NAME_LOWER)")
  INSTALL(CODE "FIND_FILE(INSTALL_FILE ${EXPORT_NAME}-\${CMAKE_INSTALL_CONFIG_NAME_LOWER}.cmake PATHS \${CMAKE_INSTALL_PREFIX}/share/maidsafe)")
  INSTALL(CODE "FILE(APPEND \${INSTALL_FILE} \"\\n\\n# Definition of this library's version\\n\")")
  INSTALL(CODE "FILE(APPEND \${INSTALL_FILE} \"SET(${THIS_VERSION} ${${THIS_VERSION}})\\n\")")
ENDFUNCTION()

FUNCTION(CHECK_INSTALL_HEADER_HAS_VERSION_GUARD HEADER)
  GET_FILENAME_COMPONENT(HEADER_NAME ${HEADER} NAME)
  IF(${HEADER_NAME} STREQUAL "version.h")
    RETURN()
  ENDIF()
  FILE(STRINGS ${HEADER} VERSION_LINE REGEX "#if ${THIS_VERSION} != ${${THIS_VERSION}}")
  IF("${VERSION_LINE}" STREQUAL "")
    SET(ERROR_MESSAGE "\n\n${HEADER} is missing the version guard block.\n")
    SET(ERROR_MESSAGE "${ERROR_MESSAGE}Ensure the following code is included in the file:\n\n")
    SET(ERROR_MESSAGE "${ERROR_MESSAGE}\t#include \"${THIS_VERSION_FILE}\"\n")
    SET(ERROR_MESSAGE "${ERROR_MESSAGE}\t#if ${THIS_VERSION} != ${${THIS_VERSION}}\n")
    SET(ERROR_MESSAGE "${ERROR_MESSAGE}\t#  error This API is not compatible with the installed library.\\\n")
    SET(ERROR_MESSAGE "${ERROR_MESSAGE}\t    Please update the ${EXPORT_NAME} library.\n")
    SET(ERROR_MESSAGE "${ERROR_MESSAGE}\t#endif\n\n\n")
    MESSAGE(FATAL_ERROR ${ERROR_MESSAGE})
  ENDIF()
ENDFUNCTION()

FUNCTION(FINAL_MESSAGE)
  MESSAGE("\nThe library and headers will be installed to:\n")
  MESSAGE("    \"${CMAKE_INSTALL_PREFIX_MESSAGE}\"\n\n")
  MESSAGE("To include this project in any other MaidSafe project, use:\n")
  MESSAGE("    -DMAIDSAFE_COMMON_INSTALL_DIR:PATH=\"${CMAKE_INSTALL_PREFIX_MESSAGE}\"\n\n")
  MESSAGE("To build and install this project now, run:\n")
  IF(MSVC)
    MESSAGE("    cmake --build . --config Release --target install")
    MESSAGE("    cmake --build . --config Debug --target install")
  ELSE()
    MESSAGE("    cmake --build . --target install")
  ENDIF()
  MESSAGE("\n\n================================================================================"\n)
ENDFUNCTION()
