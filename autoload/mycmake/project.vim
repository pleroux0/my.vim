function! mycmake#project#clear_vars()
  unlet! t:project_build_dir
  unlet! t:project_source_dir
endfunction

function! mycmake#project#is_set()
  let l:build_set = exists("t:project_build_dir")
  let l:source_set = exists("t:project_source_dir")

  if !l:build_set
    echo "Project missing build folder"
  endif

  if !l:source_set
    echo "Project missing source folder"
  endif

  return l:build_set && l:source_set
endfunction
