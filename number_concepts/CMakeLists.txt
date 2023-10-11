set(document_number_header "Document Number")
set(document_number "DxxxxR0") # Set the `cover_footer` to `""` when releasing a P-paper.
set(previous_document_number "DxxxxR0")
# set(cover_footer "")
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
& \\href{https://github.com/mpusz/mp-units/pull/492}{mpusz/mp-units\\#492} \\\\
& \\href{${PROJECT_HOMEPAGE_URL}/discussions}{discussions} \\\\
& \\href{${PROJECT_HOMEPAGE_URL}/issues}{issues}")
jegp_add_standardese_sources(
  JohelEGP_Proposals_number_concepts
  LIBRARIES paper-revs;paper-intro paper-history;paper-design;paper-evolution
            paper-comparisons;paper-acknowledgements;paper-references paper-api;intro;numbers
  EXTENSIONS macros_extensions
  PDF_PATH "number_concepts.pdf")
