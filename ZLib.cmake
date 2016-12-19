#
# ZLib 1.2.8
#

SET(ZLIB_TARGET "ZLib-1.2.8")
ADD_CUSTOM_TARGET(${ZLIB_TARGET})

SET(ZLIB_DOWNLOAD_TARGET "${ZLIB_TARGET}-Download")
ExternalProject_Add(${ZLIB_DOWNLOAD_TARGET}
    URL "http://zlib.net/zlib-1.2.8.tar.gz"
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND "")
ExternalProject_Get_Property(${ZLIB_DOWNLOAD_TARGET} SOURCE_DIR)
SET(ZLIB_DOWNLOAD_SOURCE_DIR ${SOURCE_DIR})
FILE(MAKE_DIRECTORY "${ZLIB_DOWNLOAD_SOURCE_DIR}")
FILE(WRITE "${ZLIB_DOWNLOAD_SOURCE_DIR}/.ignore")

IF(MSVC)
    SET(ZLIB_WIN64_VS2012_OPTIONS "${PLATFORM_WIN64_VS2012}" "${GENERATOR_VS2012_WIN64}")
    SET(ZLIB_WIN64_VS2015_OPTIONS "${PLATFORM_WIN64_VS2015}" "${GENERATOR_VS2015_WIN64}")
    FOREACH(OPTIONS "${ZLIB_WIN64_VS2012_OPTIONS}" "${ZLIB_WIN64_VS2015_OPTIONS}")
        LIST(GET OPTIONS 0 PLATFORM)
        LIST(GET OPTIONS 1 GENERATOR)

        FOREACH(CONFIGURATION_TYPE ${CMAKE_CONFIGURATION_TYPES})
            SET(INSTALL_DIR "${CMAKE_INSTALL_PREFIX}/${PLATFORM}/${CONFIGURATION_TYPE}/${ZLIB_TARGET}")
            SET(CMAKE_ARGS "-DCMAKE_INSTALL_PREFIX=${INSTALL_DIR}")

            SET(ZLIB_INSTALL_TARGET ${ZLIB_TARGET}-${PLATFORM}-${CONFIGURATION_TYPE})
            MESSAGE(${ZLIB_INSTALL_TARGET})
            ExternalProject_Add(${ZLIB_INSTALL_TARGET}
                SOURCE_DIR ${ZLIB_DOWNLOAD_SOURCE_DIR}
                CMAKE_GENERATOR ${GENERATOR}
                CMAKE_ARGS ${CMAKE_ARGS}
                BUILD_COMMAND ${CMAKE_COMMAND} --build . --config ${CONFIGURATION_TYPE} --target install
                INSTALL_DIR ${INSTALL_DIR})
        ENDFOREACH()
    ENDFOREACH()
ELSEIF(UNIX)
    IF (APPLE)
        SET(ZLIB_OSX_CLANG_OPTIONS       "${PLATFORM_OSX_CLANG}"       "${GENERATOR_MAKEFILE}")
        SET(ZLIB_OSX_CLANG_CPP11_OPTIONS "${PLATFORM_OSX_CLANG_CPP11}" "${GENERATOR_MAKEFILE}")
        FOREACH(OPTIONS "${ZLIB_OSX_CLANG_OPTIONS}" "${ZLIB_OSX_CLANG_CPP11_OPTIONS}")
            LIST(GET OPTIONS 0 PLATFORM)
            LIST(GET OPTIONS 1 GENERATOR)

            SET(INSTALL_DIR "${CMAKE_INSTALL_PREFIX}/${PLATFORM}/${CMAKE_BUILD_TYPE}/${ZLIB_TARGET}")
            SET(CMAKE_ARGS
                "-DCMAKE_SKIP_RPATH=1"
                "-DCMAKE_SKIP_INSTALL_RPATH=1"
                "-DCMAKE_INSTALL_PREFIX=${INSTALL_DIR}"
                "-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}")

            IF ("${PLATFORM}" MATCHES "${COMPILER_CXX_STANDARD_11}")
                LIST(APPEND CMAKE_ARGS "-DCMAKE_CXX_STANDARD=11")
                LIST(APPEND CMAKE_ARGS "-DCMAKE_OSX_DEPLOYMENT_TARGET=${OSX_TARGET_MAVERICKS}")
                LIST(APPEND CMAKE_ARGS "-DCMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk")
            ELSE()
                LIST(APPEND CMAKE_ARGS "-DCMAKE_OSX_DEPLOYMENT_TARGET=${OSX_TARGET_MOUNTAIN_LION}")
                LIST(APPEND CMAKE_ARGS "-DCMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.8.sdk")
            ENDIF()

            SET(ZLIB_INSTALL_TARGET ${ZLIB_TARGET}-${PLATFORM}-${CMAKE_BUILD_TYPE})
            MESSAGE(${ZLIB_INSTALL_TARGET})

            ExternalProject_Add(${ZLIB_INSTALL_TARGET}
                DEPENDS ${ZLIB_DOWNLOAD_TARGET}
                SOURCE_DIR ${ZLIB_DOWNLOAD_SOURCE_DIR}
                CMAKE_GENERATOR ${GENERATOR}
                CMAKE_ARGS ${CMAKE_ARGS}
                INSTALL_DIR ${INSTALL_DIR})

            ADD_DEPENDENCIES(${ZLIB_TARGET} ${ZLIB_INSTALL_TARGET})
        ENDFOREACH()
    ELSE()
    ENDIF()
ENDIF()
