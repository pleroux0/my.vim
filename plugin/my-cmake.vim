command! ProjectClearVars call mycmake#project#clear_vars()

command! ConanClearVars call mycmake#conan#clear_vars()
command! ConanInstall call mycmake#conan#install()
command! ConanBuild call mycmake#conan#build()

command! CMakeClearVars call mycmake#cmake#clear_vars()
command! CMakeConfigure call mycmake#configure()

" command! CMakeClean
" command! CMakeCD

" command! CTest
" command! CTestVerbose
" command! CTestMemCheck
" command! CTestCoverage

" command! CCMake

command! UpdateCompilerCommands call mycmake#cmake#update_compiler_commands()
