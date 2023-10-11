cmake_minimum_required(VERSION 3.27.0)
project(JohelEGP_Proposals
        VERSION 1.0.0
        DESCRIPTION "My papers for JTC1/SC22/WG21."
        HOMEPAGE_URL "https://github.com/JohelEGP/proposals"
        LANGUAGES NONE)

include("cmake/modules/JohelEGPProposalsResolveDependencies.cmake")
include(JEGPAddStandardeseSources)

add_subdirectory("number_concepts")
