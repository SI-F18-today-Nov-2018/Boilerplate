submodule(assertion_interface) assertion_implementation
  implicit none

contains

    module procedure assert
      if (.not. assertion) then
        block
          integer, parameter :: max_digits=32
          character(len=max_digits) my_image
          character(len=:), allocatable :: error_message
          write(my_image,*) this_image()
          error_message = "Assertion '" // description // "' failed on image " // my_image
          if (present(diagnostic_data)) then
            select type(diagnostic_data)
              type is(character(len=*))
                 error_message = error_message // diagnostic_data
              class default
                 error_message = error_message // "with unrecognized diagnostic_data type"
            end select
          end if
          error stop error_message
        end block
      end if
    end procedure

end submodule
