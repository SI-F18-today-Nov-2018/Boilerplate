module assertion_interface
  !! author: Damian Rouson
  !!
  !! Initiate error termination if a logical assertion evaluates to .false.
  implicit none

  logical, parameter :: assertions=.true.

  interface
    !! Interface block for module subroutines

    pure module subroutine assert(assertion,description,diagnostic_data)
      !! Interface body for checking runtime constraints
      implicit none
      logical, intent(in) :: assertion                  !! Required runtime constraint (usually and expersion)
      character(len=*), intent(in) :: description       !! English statement of the constraint
      class(*), intent(in), optional :: diagnostic_data !! Unlimited polymorphic data describing an error condition
    end subroutine

  end interface

end module
