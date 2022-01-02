TRANSLATIONS += \
    $$PWD/fr_FR.ts

CONFIG += lrelease embed_translations
QM_FILES_RESOURCE_PREFIX = $$TARGET/translations
PRE_TARGETDEPS += compiler_lrelease_make_all
