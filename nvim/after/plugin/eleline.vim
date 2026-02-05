" Override ElelineFsize to avoid expand() errors on special buffers.
if exists('*ElelineFsize')
  function! ElelineFsize(f) abort
    if &buftype !=# ''
      return ''
    endif

    let l:path = expand('%:p')
    if empty(l:path)
      return ''
    endif

    let l:size = getfsize(l:path)
    if l:size == 0 || l:size == -1 || l:size == -2
      return ''
    endif
    if l:size < 1024
      let size = l:size.' bytes'
    elseif l:size < 1024*1024
      let size = printf('%.1f', l:size/1024.0).'k'
    elseif l:size < 1024*1024*1024
      let size = printf('%.1f', l:size/1024.0/1024.0) . 'm'
    else
      let size = printf('%.1f', l:size/1024.0/1024.0/1024.0) . 'g'
    endif
    return '  '.size.' '
  endfunction
endif
