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

set(pkgver "14.3.127.17")

vcpkg_find_acquire_program(GIT)
get_filename_component(GIT_PATH ${GIT} DIRECTORY)
vcpkg_find_acquire_program(GN)
get_filename_component(GN_PATH ${GN} DIRECTORY)
vcpkg_find_acquire_program(NINJA)
get_filename_component(NINJA_PATH ${NINJA} DIRECTORY)


vcpkg_add_to_path(PREPEND "${CURRENT_INSTALLED_DIR}/bin")
vcpkg_add_to_path(PREPEND "${CURRENT_INSTALLED_DIR}/debug/bin")
vcpkg_add_to_path(PREPEND "${GIT_PATH}")
vcpkg_add_to_path(PREPEND "${GN_PATH}")
vcpkg_add_to_path(PREPEND "${NINJA_PATH}")
if(VCPKG_TARGET_IS_WINDOWS)
  vcpkg_acquire_msys(MSYS_ROOT PACKAGES pkg-config)
  vcpkg_add_to_path("${MSYS_ROOT}/usr/bin")
endif()

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH_DEPOTTOOLS
    URL https://chromium.googlesource.com/chromium/tools/depot_tools.git
    REF 70179d9d8456c21de05524f45bc3e4a681819f63
)
vcpkg_add_to_path(PREPEND "${SOURCE_PATH_DEPOTTOOLS}")

set(ENV{DEPOT_TOOLS_WIN_TOOLCHAIN} 0)
set(ENV{DEPOT_TOOLS_UPDATE} 0)
set(VCPKG_KEEP_ENV_VARS PATH;DEPOT_TOOLS_WIN_TOOLCHAIN;DEPOT_TOOLS_UPDATE)

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://chromium.googlesource.com/v8/v8.git
    REF beee9f5cafde91bbd086077a11db16cb9768e62a
)

vcpkg_execute_required_process(
    COMMAND gclient.bat config https://chromium.googlesource.com/v8/v8
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME build-${TARGET_TRIPLET}
)
vcpkg_execute_required_process(
    COMMAND gclient.bat sync
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME build-${TARGET_TRIPLET}
)

vcpkg_execute_required_process(
    COMMAND vpython3.bat tools/dev/gm.py x64.release
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME build-${TARGET_TRIPLET}
)
