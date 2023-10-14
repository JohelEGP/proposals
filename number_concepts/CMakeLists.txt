FetchContent_Declare(GitHub_Logos URL "https://github.githubassets.com/images/modules/logos_page/github-mark.zip")
FetchContent_MakeAvailable(GitHub_Logos)
file(DOWNLOAD "https://github.com/isocpp/CppCoreGuidelines/blob/gh-pages/cpp_core_guidelines_16b.png?raw=true"
     "CppCoreGuidelines_Logo.png"
     EXPECTED_HASH
       SHA512=189ee8b298be1cb151df682f26800c178833d2482f79fbf4e06211090aaab2885d32543cb640c3e9d14c8f4513587441a2eea15630a7c11741a24227f5d5ef7d
)

set(CppCoreGuidelines_Logo "${CMAKE_CURRENT_BINARY_DIR}/../CppCoreGuidelines_Logo.png")
set(GitHub_Logo "${github_logos_SOURCE_DIR}/github-mark/github-mark.png")

configure_file("macros_extensions.tex.in" "${CMAKE_CURRENT_SOURCE_DIR}/macros_extensions.tex")

set(document_number_header "Document Number")
set(document_number "P3003R0") # Set the `cover_footer` to `""` when releasing a P-paper.
set(previous_document_number "D3003R0")
set(cover_footer "")
set(cover_title "The design of a library of number concepts")
set(pdf_title "${document_number} ${cover_title}")
set(pdf_subject "C++ Standards Committee Papers")
set(page_license "Unlicense")
set(first_library_chapter "nums")
set(last_library_chapter "nums")
set(pdf_creator "Johel Ernesto Guerrero Pe\\~{n}a")
set(reply_to_header "Reply to")
set(reply_to
    "${pdf_creator} \\\\
& \\href{mailto:johelegp@gmail.com}{johelegp@gmail.com} \\\\
& \\ghlogo{} \\href{https://github.com/JohelEGP/jegp.numbers}{JohelEGP/jegp.numbers} \\\\
& \\ghlogo{} \\href{${PROJECT_HOMEPAGE_URL}}{JohelEGP/proposals}")
jegp_add_standardese_sources(
  JohelEGP_Proposals_number_concepts
  LIBRARIES paper-revs;paper-intro paper-history;paper-design;paper-evolution
            paper-comparisons;paper-acknowledgements;paper-references paper-api;intro;numbers
  EXTENSIONS macros_extensions
  PDF_PATH "number_concepts.pdf")
