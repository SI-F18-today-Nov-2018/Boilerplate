program main
  !! author: Izaak Beekman
  !!
  !! Ensure the assertion utility is functioning properly

   use assertion_interface, only : assert
   implicit none

   call assert( 2 == 5, "This should fail!")

 end program
