if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_get_windows_sdk(WINDOWS_SDK)

    if (WINDOWS_SDK MATCHES "10.")
        set(LIBFILEPATH "$ENV{WindowsSdkDir}Lib\\${WINDOWS_SDK}\\um\\${TRIPLET_SYSTEM_ARCH}\\Ws2_32.Lib")
        set(HEADERSPATH "$ENV{WindowsSdkDir}Include\\${WINDOWS_SDK}\\um")
    elseif(WINDOWS_SDK MATCHES "8.")
        set(LIBFILEPATH "$ENV{WindowsSdkDir}Lib\\winv6.3\\um\\${TRIPLET_SYSTEM_ARCH}\\Ws2_32.Lib")
        set(HEADERSPATH "$ENV{WindowsSdkDir}Include\\um")
    else()
        message(FATAL_ERROR "Portfile not yet configured for Windows SDK with version: ${WINDOWS_SDK}")
    endif()
endif()

set(pkgver "14.7.69")

set(ENV{DEPOT_TOOLS_WIN_TOOLCHAIN} 0)

vcpkg_find_acquire_program(GIT)
get_filename_component(GIT_PATH ${GIT} DIRECTORY)
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_PATH ${PYTHON3} DIRECTORY)
vcpkg_find_acquire_program(GN)
get_filename_component(GN_PATH ${GN} DIRECTORY)
vcpkg_find_acquire_program(NINJA)
get_filename_component(NINJA_PATH ${NINJA} DIRECTORY)

vcpkg_add_to_path(PREPEND "${CURRENT_INSTALLED_DIR}/bin")
vcpkg_add_to_path(PREPEND "${CURRENT_INSTALLED_DIR}/debug/bin")
vcpkg_add_to_path(PREPEND "${GIT_PATH}")
vcpkg_add_to_path(PREPEND "${PYTHON3_PATH}")
vcpkg_add_to_path(PREPEND "${GN_PATH}")
vcpkg_add_to_path(PREPEND "${NINJA_PATH}")
if(VCPKG_TARGET_IS_WINDOWS)
  vcpkg_acquire_msys(MSYS_ROOT PACKAGES pkg-config)
  vcpkg_add_to_path("${MSYS_ROOT}/usr/bin")
endif()

set(VCPKG_KEEP_ENV_VARS PATH;DEPOT_TOOLS_WIN_TOOLCHAIN)

function(v8_fetch)
  set(oneValueArgs DESTINATION URL REF SOURCE)
  set(multipleValuesArgs PATCHES)
  cmake_parse_arguments(V8 "" "${oneValueArgs}" "${multipleValuesArgs}" ${ARGN})

  if(NOT DEFINED V8_DESTINATION)
    message(FATAL_ERROR "DESTINATION must be specified.")
  endif()

  if(NOT DEFINED V8_URL)
    message(FATAL_ERROR "The git url must be specified")
  endif()

  if(NOT DEFINED V8_REF)
    message(FATAL_ERROR "The git ref must be specified.")
  endif()

  if(EXISTS ${V8_SOURCE}/${V8_DESTINATION})
        vcpkg_execute_required_process(
                COMMAND ${GIT} reset --hard
                WORKING_DIRECTORY ${V8_SOURCE}/${V8_DESTINATION}
                LOGNAME build-${TARGET_TRIPLET})
  else()
        file(MAKE_DIRECTORY ${V8_SOURCE}/${V8_DESTINATION})
        vcpkg_execute_required_process(
                COMMAND ${GIT} init
                WORKING_DIRECTORY ${V8_SOURCE}/${V8_DESTINATION}
                LOGNAME build-${TARGET_TRIPLET})
        vcpkg_execute_required_process(
                COMMAND ${GIT} remote add origin ${V8_URL}
                WORKING_DIRECTORY ${V8_SOURCE}/${V8_DESTINATION}
                LOGNAME build-${TARGET_TRIPLET})
        vcpkg_execute_required_process(
                COMMAND ${GIT} fetch origin ${V8_REF}
                WORKING_DIRECTORY ${V8_SOURCE}/${V8_DESTINATION}
                LOGNAME build-${TARGET_TRIPLET})
        vcpkg_execute_required_process(
                COMMAND ${GIT} checkout FETCH_HEAD
                WORKING_DIRECTORY ${V8_SOURCE}/${V8_DESTINATION}
                LOGNAME build-${TARGET_TRIPLET})
  endif()
  foreach(PATCH ${V8_PATCHES})
        vcpkg_execute_required_process(
                        COMMAND ${GIT} apply ${PATCH}
                        WORKING_DIRECTORY ${V8_SOURCE}/${V8_DESTINATION}
                        LOGNAME build-${TARGET_TRIPLET})
  endforeach()
endfunction()

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://chromium.googlesource.com/v8/v8.git
    REF 365b1f25f3a1eb6f8b65fa514a1e776fa6eb5c42
    PATCHES ${CURRENT_PORT_DIR}/v8.patch
)

message(STATUS "Fetching submodules")
v8_fetch(
        DESTINATION build
        URL https://chromium.googlesource.com/chromium/src/build.git
        REF d6fa48045e5e4e0a7d8ede09e580a46821663aad
        SOURCE ${SOURCE_PATH}
        PATCHES ${CURRENT_PORT_DIR}/build.patch)
v8_fetch(
        DESTINATION buildtools
        URL https://chromium.googlesource.com/chromium/src/buildtools.git
        REF 6a18683f555b4ac8b05ac8395c29c84483ac9588
        SOURCE ${SOURCE_PATH})
v8_fetch(
        DESTINATION third_party/zlib
        URL https://chromium.googlesource.com/chromium/src/third_party/zlib.git
        REF 7eda07b1e067ef3fd7eea0419c88b5af45c9a776
        SOURCE ${SOURCE_PATH})
v8_fetch(
        DESTINATION third_party/googletest/src
        URL https://chromium.googlesource.com/external/github.com/google/googletest.git
        REF 4fe3307fb2d9f86d19777c7eb0e4809e9694dde7
        SOURCE ${SOURCE_PATH})
v8_fetch(
        DESTINATION third_party/jinja2
        URL https://chromium.googlesource.com/chromium/src/third_party/jinja2.git
        REF c3027d884967773057bf74b957e3fea87e5df4d7
        SOURCE ${SOURCE_PATH})
v8_fetch(
        DESTINATION third_party/markupsafe
        URL https://chromium.googlesource.com/chromium/src/third_party/markupsafe.git
        REF 4256084ae14175d38a3ff7d339dca83ae49ccec6
        SOURCE ${SOURCE_PATH})
v8_fetch(
        DESTINATION third_party/abseil-cpp
        URL https://chromium.googlesource.com/chromium/src/third_party/abseil-cpp.git
        REF d801f302ff17ed31204520e27ebed47e4fdcfc55
        SOURCE ${SOURCE_PATH})
v8_fetch(
        DESTINATION third_party/dragonbox/src
        URL https://chromium.googlesource.com/external/github.com/jk-jeon/dragonbox.git
        REF beeeef91cf6fef89a4d4ba5e95d47ca64ccb3a44
        SOURCE ${SOURCE_PATH})
v8_fetch(
        DESTINATION third_party/fp16/src
        URL https://chromium.googlesource.com/external/github.com/Maratyszcza/FP16.git
        REF 3d2de1816307bac63c16a297e8c4dc501b4076df
        SOURCE ${SOURCE_PATH})
v8_fetch(
        DESTINATION third_party/fast_float/src
        URL https://chromium.googlesource.com/external/github.com/fastfloat/fast_float.git
        REF cb1d42aaa1e14b09e1452cfdef373d051b8c02a4
        SOURCE ${SOURCE_PATH})
v8_fetch(
        DESTINATION third_party/simdutf
        URL https://chromium.googlesource.com/chromium/src/third_party/simdutf.git
        REF f7356eed293f8208c40b3c1b344a50bd70971983
        SOURCE ${SOURCE_PATH})
v8_fetch(
        DESTINATION third_party/highway/src
        URL https://chromium.googlesource.com/external/github.com/google/highway.git
        REF 84379d1c73de9681b54fbe1c035a23c7bd5d272d
        SOURCE ${SOURCE_PATH})

vcpkg_execute_required_process(
        COMMAND ${PYTHON3} build/util/lastchange.py -o build/util/LASTCHANGE
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME build-${TARGET_TRIPLET}
)

file(MAKE_DIRECTORY "${SOURCE_PATH}/third_party/icu")
configure_file("${CURRENT_PORT_DIR}/zlib.gn" "${SOURCE_PATH}/third_party/zlib/BUILD.gn" COPYONLY)
configure_file("${CURRENT_PORT_DIR}/icu.gn" "${SOURCE_PATH}/third_party/icu/BUILD.gn" COPYONLY)
file(WRITE "${SOURCE_PATH}/build/config/gclient_args.gni" "checkout_google_benchmark = false\ncheckout_src_internal = false\n")
if(VCPKG_TARGET_IS_WINDOWS)
	string(REGEX REPLACE "\\\\+$" "" WindowsSdkDir $ENV{WindowsSdkDir})
	file(APPEND "${SOURCE_PATH}/build/config/gclient_args.gni" "windows_sdk_path = \"${WindowsSdkDir}\"\n")
endif()

if(VCPKG_TARGET_IS_LINUX)
    set(UNIX_CURRENT_INSTALLED_DIR ${CURRENT_INSTALLED_DIR})
    set(LIBS "-ldl -lpthread")
    set(REQUIRES ", gmodule-2.0, gobject-2.0, gthread-2.0")
elseif(VCPKG_TARGET_IS_WINDOWS)
    execute_process(COMMAND cygpath "${CURRENT_INSTALLED_DIR}" OUTPUT_VARIABLE UNIX_CURRENT_INSTALLED_DIR)
    string(STRIP ${UNIX_CURRENT_INSTALLED_DIR} UNIX_CURRENT_INSTALLED_DIR)
    set(LIBS "-lWinmm -lDbgHelp")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(is_component_build true)
    set(v8_monolithic false)
    set(v8_use_external_startup_data true)
    set(targets :v8_libbase :v8_libplatform :v8)
else()
    set(is_component_build false)
    set(v8_monolithic true)
    set(v8_use_external_startup_data false)
    set(targets :v8_monolith)
endif()

message(STATUS "Generating v8 build files. Please wait...")

vcpkg_gn_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS "is_component_build=${is_component_build} target_cpu=\"${VCPKG_TARGET_ARCHITECTURE}\" v8_monolithic=${v8_monolithic} v8_use_external_startup_data=${v8_use_external_startup_data} use_sysroot=false is_clang=false use_custom_libcxx=false v8_enable_verify_heap=false icu_use_data_file=false"
    OPTIONS_DEBUG "is_debug=true enable_iterator_debugging=true pkg_config_libdir=\"${UNIX_CURRENT_INSTALLED_DIR}/debug/lib/pkgconfig\""
    OPTIONS_RELEASE "is_debug=false enable_iterator_debugging=false pkg_config_libdir=\"${UNIX_CURRENT_INSTALLED_DIR}/lib/pkgconfig\""
)

message(STATUS "Building v8. Please wait...")

vcpkg_gn_install(
    SOURCE_PATH "${SOURCE_PATH}"
    TARGETS ${targets}
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(CFLAGS "-DV8_COMPRESS_POINTERS -DV8_31BIT_SMIS_ON_64BIT_ARCH")
endif()

file(INSTALL "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}/include" FILES_MATCHING PATTERN "*.h")

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(PREFIX ${CURRENT_PACKAGES_DIR})
    configure_file("${CURRENT_PORT_DIR}/v8.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/v8.pc" @ONLY)
    configure_file("${CURRENT_PORT_DIR}/v8_libbase.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/v8_libbase.pc" @ONLY)
    configure_file("${CURRENT_PORT_DIR}/v8_libplatform.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/v8_libplatform.pc" @ONLY)
    file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/snapshot_blob.bin" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")

    set(PREFIX ${CURRENT_PACKAGES_DIR}/debug)
    configure_file("${CURRENT_PORT_DIR}/v8.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/v8.pc" @ONLY)
    configure_file("${CURRENT_PORT_DIR}/v8_libbase.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/v8_libbase.pc" @ONLY)
    configure_file("${CURRENT_PORT_DIR}/v8_libplatform.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/v8_libplatform.pc" @ONLY)
    configure_file("${CURRENT_PORT_DIR}/V8Config-shared.cmake" "${CURRENT_PACKAGES_DIR}/share/v8/V8Config.cmake" @ONLY)
    file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/snapshot_blob.bin" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
else()
    set(PREFIX ${CURRENT_PACKAGES_DIR})
    configure_file("${CURRENT_PORT_DIR}/v8_monolith.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/v8_monolith.pc" @ONLY)
    set(PREFIX ${CURRENT_PACKAGES_DIR}/debug)
    configure_file("${CURRENT_PORT_DIR}/v8_monolith.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/v8_monolith.pc" @ONLY)
    configure_file("${CURRENT_PORT_DIR}/V8Config-static.cmake" "${CURRENT_PACKAGES_DIR}/share/v8/V8Config.cmake" @ONLY)
endif()


vcpkg_copy_pdbs()

# v8 libraries are listed as SYSTEM_LIBRARIES because the pc files reference each other.
vcpkg_fixup_pkgconfig(SYSTEM_LIBRARIES m dl pthread Winmm DbgHelp v8_libbase v8_libplatform v8)

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
