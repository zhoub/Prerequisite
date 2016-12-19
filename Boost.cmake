#
# Boost 1.61
#

OPTION(BOOST_USE_LOCAL OFF)
IF(BOOST_USE_LOCAL)
    FIND_PATH(BOOST_SOURCE_DIR NAMES boost.css REQUIRED)
    FILE(STRINGS ${BOOST_SOURCE_DIR}/boost/version.hpp BOOST_LIB_VERSION_MACRO REGEX "#define BOOST_LIB_VERSION")
    STRING(REGEX MATCH "1_[0-9]+" BOOST_LIB_VERSION ${BOOST_LIB_VERSION_MACRO})
    MESSAGE("Found Boost ${BOOST_LIB_VERSION}")

    SET(BOOST_TARGET "Boost-${BOOST_LIB_VERSION}")
ELSE()
    SET(BOOST_TARGET "Boost-1.61.0")

    SET(BOOST_DOWNLOAD_TARGET "${BOOST_TARGET}-Download")
    ExternalProject_Add(${BOOST_DOWNLOAD_TARGET}
        URL "https://sourceforge.net/projects/boost/files/boost/1.61.0/boost_1_61_0.7z"
        CONFIGURE_COMMAND ""
        BUILD_COMMAND ""
        INSTALL_COMMAND "")
    ExternalProject_Get_Property(${BOOST_DOWNLOAD_TARGET} SOURCE_DIR)
    SET(BOOST_SOURCE_DIR ${SOURCE_DIR})
    FILE(WRITE "${BOOST_SOURCE_DIR}/.ignore")
ENDIF()

#
SET(BOOST_WITH_COMPONENTS --with-locale
    --with-system
    --with-thread
    --with-chrono
    --with-date_time
    --with-filesystem
    --with-program_options)

#
OPTION(BOOST_WITH_PYTHON OFF)
IF(BOOST_WITH_PYTHON)
    FIND_PACKAGE(PythonInterp REQUIRED)
ENDIF()

IF(BOOST_WITH_PYTHON)
    LIST(APPEND BOOST_WITH_COMPONENTS --with-python)
ENDIF()

#
IF(MSVC)
    SET(BOOST_WIN64_VS2012_OPTIONS "${PLATFORM_WIN64_VS2012}" "toolset=msvc-12.0" "address-model=64")
    SET(BOOST_WIN64_VS2015_OPTIONS "${PLATFORM_WIN64_VS2015}" "toolset=msvc-14.0" "address-model=64")

    IF(BOOST_WITH_PYTHON)
        SET(BOOST_BOOTSTRAP_COMMAND bootstrap.bat --with-python=${PYTHON_EXECUTABLE})
    ELSE()
        SET(BOOST_BOOTSTRAP_COMMAND bootstrap.bat)
    ENDIF()

    FOREACH(OPTIONS "${BOOST_WIN64_VS2012_OPTIONS}" "${BOOST_WIN64_VS2015_OPTIONS}")
        LIST(GET OPTIONS 0 PLATFORM)
        LIST(GET OPTIONS 1 TOOLSET)
        LIST(GET OPTIONS 2 ADDRESS_MODEL)

        #
        FOREACH(BUILD_TYPE "Debug" "Release")
            #
            SET(STAGE_DIR "${CMAKE_INSTALL_PREFIX}/${PLATFORM}/${BUILD_TYPE}/${BOOST_TARGET}")

            STRING(TOLOWER ${BUILD_TYPE} VARIANT_TYPE)
            SET(B2_COMMAND b2
                ${TOOLSET}
                ${ADDRESS_MODEL}
                ${BOOST_WITH_COMPONENTS}
                link=static,shared runtime-link=shared threading=multi variant=${VARIANT_TYPE}
                --stagedir=${STAGE_DIR} stage)

            #
            SET(BOOST_INSTALL_TARGET ${BOOST_TARGET}-${PLATFORM}-${BUILD_TYPE})
            MESSAGE(${BOOST_INSTALL_TARGET})

            ExternalProject_Add(${BOOST_INSTALL_TARGET}
                SOURCE_DIR ${BOOST_SOURCE_DIR}
                CONFIGURE_COMMAND ""
                BUILD_IN_SOURCE 1
                BUILD_COMMAND bootstrap.bat COMMAND ${B2_COMMAND}
                INSTALL_COMMAND "")
            IF(NOT BOOST_USE_LOCAL)
                ADD_DEPENDENCIES(${BOOST_INSTALL_TARGET} ${BOOST_DOWNLOAD_TARGET})
            ENDIF()
        ENDFOREACH()
    ENDFOREACH()
ELSEIF(UNIX)
    IF(APPLE)
        SET(BOOST_OSX_CLANG_OPTIONS       "${PLATFORM_OSX_CLANG}"       "${GENERATOR_MAKEFILE}")
        SET(BOOST_OSX_CLANG_CPP11_OPTIONS "${PLATFORM_OSX_CLANG_CPP11}" "${GENERATOR_MAKEFILE}")

        FOREACH(OPTIONS "${BOOST_OSX_CLANG_OPTIONS}" "${BOOST_OSX_CLANG_CPP11_OPTIONS}")
            LIST(GET OPTIONS 0 PLATFORM)
            LIST(GET OPTIONS 1 GENERATOR)

            #
            IF ("${PLATFORM}" MATCHES "${COMPILER_CXX_STANDARD_11}")
                SET(CXX_FLAGS
                    "-std=c++11"
                    "-stdlib=libc++"
                    "-mmacosx-version-min=${OSX_TARGET_MAVERICKS}"
                    "-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk")
            ELSE()
                SET(CXX_FLAGS
                    "-std=c++98"
                    "-stdlib=libstdc++"
                    "-mmacosx-version-min=${OSX_TARGET_MOUNTAIN_LION}"
                    "-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.8.sdk")
            ENDIF()

            #
            FOREACH(BUILD_TYPE "Debug" "Release")
                #
                SET(STAGE_DIR "${CMAKE_INSTALL_PREFIX}/${PLATFORM}/${BUILD_TYPE}/${BOOST_TARGET}")

                STRING(TOLOWER ${BUILD_TYPE} VARIANT_TYPE)
                SET(B2_COMMAND b2
                    ${TOOLSET}
                    ${ADDRESS_MODEL}
                    ${BOOST_WITH_COMPONENTS}
                    link=static,shared runtime-link=shared threading=multi variant=${VARIANT_TYPE}
                    --stagedir=${STAGE_DIR} stage)

                #
                SET(BOOST_INSTALL_TARGET ${BOOST_TARGET}-${PLATFORM}-${BUILD_TYPE})
                MESSAGE(${BOOST_INSTALL_TARGET})

                ExternalProject_Add(${BOOST_INSTALL_TARGET}
                    SOURCE_DIR ${BOOST_SOURCE_DIR}
                    CONFIGURE_COMMAND ""
                    BUILD_IN_SOURCE 1
                    BUILD_COMMAND bootstrap.sh COMMAND ${B2_COMMAND}
                    INSTALL_COMMAND "")
                IF(NOT BOOST_USE_LOCAL)
                    ADD_DEPENDENCIES(${BOOST_INSTALL_TARGET} ${BOOST_DOWNLOAD_TARGET})
                ENDIF()
            ENDFOREACH()
        ENDFOREACH()
    ELSE()
        # TODO: Linux
    ENDIF()
ENDIF()
