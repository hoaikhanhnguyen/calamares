# Internal macro for adding the C++ / Qt translations to the
# build and install tree. Should be called only once, from
# src/calamares/CMakeLists.txt.
macro(add_calamares_translations language)
    list( APPEND CALAMARES_LANGUAGES ${ARGV} )

    set( calamares_i18n_qrc_content "<!DOCTYPE RCC><RCC version=\"1.0\">\n" )

    # calamares and qt language files
    set( calamares_i18n_qrc_content "${calamares_i18n_qrc_content}<qresource prefix=\"/lang\">\n" )
    foreach( lang ${CALAMARES_LANGUAGES} )
        set( calamares_i18n_qrc_content "${calamares_i18n_qrc_content}<file>calamares_${lang}.qm</file>\n" )
        list( APPEND TS_FILES "${CMAKE_SOURCE_DIR}/lang/calamares_${lang}.ts" )
    endforeach()

    set( calamares_i18n_qrc_content "${calamares_i18n_qrc_content}</qresource>\n" )
    set( calamares_i18n_qrc_content "${calamares_i18n_qrc_content}</RCC>\n" )

    file( WRITE ${CMAKE_BINARY_DIR}/lang/calamares_i18n.qrc "${calamares_i18n_qrc_content}" )

    qt5_add_translation(QM_FILES ${TS_FILES})

    ## HACK HACK HACK - around rcc limitations to allow out of source-tree building
    set( trans_file calamares_i18n )
    set( trans_srcfile ${CMAKE_BINARY_DIR}/lang/${trans_file}.qrc )
    set( trans_infile ${CMAKE_CURRENT_BINARY_DIR}/${trans_file}.qrc )
    set( trans_outfile ${CMAKE_CURRENT_BINARY_DIR}/qrc_${trans_file}.cxx )

    # Copy the QRC file to the output directory
    add_custom_command(
        OUTPUT ${trans_infile}
        COMMAND ${CMAKE_COMMAND} -E copy ${trans_srcfile} ${trans_infile}
        MAIN_DEPENDENCY ${trans_srcfile}
    )

    # Run the resource compiler (rcc_options should already be set)
    add_custom_command(
        OUTPUT ${trans_outfile}
        COMMAND "${Qt5Core_RCC_EXECUTABLE}"
        ARGS ${rcc_options} -name ${trans_file} -o ${trans_outfile} ${trans_infile}
        MAIN_DEPENDENCY ${trans_infile}
        DEPENDS ${QM_FILES}
    )
endmacro()

# Internal macro for Python translations
#
# Translations of the Python modules that don't have their own
# lang/ subdirectories -- these are collected in top-level
# lang/python_<lang>.po
macro(add_calamares_python_translations language)
    set( CALAMARES_LANGUAGES "" )
    list( APPEND CALAMARES_LANGUAGES ${ARGV} )

    set( TS_FILES "" )  # Actually po / mo files
    foreach( lang ${CALAMARES_LANGUAGES} )
        if( lang STREQUAL "en" )
            message( STATUS "Skipping Python translations for en_US" )
        else()
            list( APPEND TS_FILES "${CMAKE_SOURCE_DIR}/lang/python/${lang}/LC_MESSAGES/python.po;${CMAKE_SOURCE_DIR}/lang/python/${lang}/LC_MESSAGES/python.mo" )
        endif()
    endforeach()

    file( MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/_lang )
    file( COPY ${CMAKE_SOURCE_DIR}/lang/python DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/_lang )

    install(
        FILES ${TS_FILES}
        DESTINATION ${CMAKE_INSTALL_DATADIR}/calamares/lang/
    )
endmacro()
