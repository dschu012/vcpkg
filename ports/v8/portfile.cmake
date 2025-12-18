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

if(VCPKG_TARGET_IS_WINDOWS)
    set(GCLIENT_CMD gclient.bat)
    set(VPYTHON3_CMD vpython3.bat)
else()
    set(GCLIENT_CMD gclient)
    set(VPYTHON3_CMD vpython3)
endif()

vcpkg_execute_required_process(
    COMMAND ${GCLIENT_CMD}
    WORKING_DIRECTORY ${SOURCE_PATH_DEPOTTOOLS}
    LOGNAME gclient-init
)

set(ENV{DEPOT_TOOLS_WIN_TOOLCHAIN} 0)
set(ENV{DEPOT_TOOLS_UPDATE} 0)
set(VCPKG_KEEP_ENV_VARS PATH;DEPOT_TOOLS_WIN_TOOLCHAIN;DEPOT_TOOLS_UPDATE)

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://chromium.googlesource.com/v8/v8.git
    REF beee9f5cafde91bbd086077a11db16cb9768e62a
)

get_filename_component(PARENT_PATH ${SOURCE_PATH} DIRECTORY)
set(RENAMED_SOURCE_PATH ${PARENT_PATH}/v8)
file(RENAME ${SOURCE_PATH} ${RENAMED_SOURCE_PATH})

vcpkg_execute_required_process(
    COMMAND ${GCLIENT_CMD} config https://chromium.googlesource.com/v8/v8 --unmanaged
    WORKING_DIRECTORY ${PARENT_PATH}
    LOGNAME build-${TARGET_TRIPLET}-config
)

vcpkg_execute_required_process(
    COMMAND ${GCLIENT_CMD} sync
    WORKING_DIRECTORY ${PARENT_PATH}
    LOGNAME build-${TARGET_TRIPLET}-sync
)

vcpkg_execute_required_process(
    COMMAND ${VPYTHON3_CMD} tools/dev/gm.py ${VCPKG_TARGET_ARCHITECTURE}.release
    WORKING_DIRECTORY ${RENAMED_SOURCE_PATH}
    LOGNAME build-${TARGET_TRIPLET}-build
)
