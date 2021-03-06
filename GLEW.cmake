#
# GLEW 2.0.0
#

SET(GLEW_TARGET "GLEW-2.0.0")

SET(GLEW_PACKAGE_TARGET "${GLEW_TARGET}-Package")
ExternalProject_Add(${GLEW_PACKAGE_TARGET}
    URL "http://downloads.sourceforge.net/project/glew/glew/2.0.0/glew-2.0.0.tgz"
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND "")
ExternalProject_Get_Property(${GLEW_PACKAGE_TARGET} SOURCE_DIR)
SET(GLEW_PACKAGE_SOURCE_DIR ${SOURCE_DIR})
FILE(MAKE_DIRECTORY "${GLEW_PACKAGE_SOURCE_DIR}/build/cmake")
FILE(WRITE "${GLEW_PACKAGE_SOURCE_DIR}/build/cmake/.ignore")

IF(MSVC)
    SET(GLEW_WIN64_VS2012_OPTIONS "${PLATFORM_WIN64_VS2012}" "${GENERATOR_VS2012_WIN64}")
    SET(GLEW_WIN64_VS2015_OPTIONS "${PLATFORM_WIN64_VS2015}" "${GENERATOR_VS2015_WIN64}")

    FOREACH(OPTIONS "${GLEW_WIN64_VS2012_OPTIONS}" "${GLEW_WIN64_VS2015_OPTIONS}")
        LIST(GET OPTIONS 0 PLATFORM)
        LIST(GET OPTIONS 1 GENERATOR)

        #
        FOREACH(BUILD_TYPE ${CMAKE_CONFIGURATION_TYPES})
            SET(INSTALL_DIR "${CMAKE_INSTALL_PREFIX}/${PLATFORM}/${BUILD_TYPE}/${GLEW_TARGET}")
            SET(CMAKE_ARGS "-DCMAKE_INSTALL_PREFIX=${INSTALL_DIR}")

            MESSAGE(${INSTALL_DIR})

            #
            SET(GLEW_INSTALL_TARGET ${GLEW_TARGET}-${PLATFORM}-${BUILD_TYPE})
            MESSAGE(${GLEW_INSTALL_TARGET})

            ExternalProject_Add(${GLEW_INSTALL_TARGET}
                DEPENDS ${GLEW_PACKAGE_TARGET}
                SOURCE_DIR ${GLEW_PACKAGE_SOURCE_DIR}/build/cmake
                CMAKE_GENERATOR ${GENERATOR}
                CMAKE_ARGS ${CMAKE_ARGS}
                CMAKE_CACHE_ARGS "-DCMAKE_C_FLAGS_DEBUG:INTERNAL=/D_DEBUG /MDd /Zi /Ob0 /Od"
                BUILD_COMMAND ${CMAKE_COMMAND} --build . --config ${BUILD_TYPE} --target install
                INSTALL_DIR ${INSTALL_DIR})
        ENDFOREACH()
    ENDFOREACH()
ELSE()
ENDIF()
