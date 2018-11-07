module structureted_grid_implementation
  !! author: Damian Rouson
  !!
  !! Establish a coarray for distributing structured-grid vertex locations across images.
  !! Use collective subroutines to distribute the grid dimensions and calculate this image's load

   use assertion_interface, only : assert, assertions
   implicit none

   private
   public :: get_grid_resolution
   public :: allocate_my_partition
   public :: my_partition_size

   real, allocatable :: x(:,:,:,:)[:]
     !! structured-grid vertex locations
   integer, parameter :: space_dimension=3

contains

  function get_grid_resolution(file_name) result(n)
    character(len=*), intent(in) :: file_name
    integer :: n(space_dimension)

    integer nx, ny, nz
    namelist/grid_resolution/ nx, ny, nz

    associate(me=>this_image(),ni=>num_images())
      block
        integer file_unit, stat
        integer, parameter :: reader=1, success=0

        if (me==reader) then
          open(newunit=file_unit,file=file_name,status='old',iostat=stat)
          if (assertions) call assert(stat==success,"file opened successfully")

          read(unit=file_unit,nml=grid_resolution,iostat=stat)
          if (assertions) call assert(stat==success,"file read successfully")

          close(unit=file_unit,iostat=stat)
          if (assertions) call assert(stat==success,"file closed successfully")
        end if

        n=[nx,ny,nz]
        call co_broadcast(n,source_image=reader)
      end block
    end associate

  end function

  subroutine allocate_my_partition(n)
    integer, intent(in) :: n(:)

    ! Requires
    call assert(size(n)==space_dimension,"valid resolution")

    associate(num_yz_planes=>n(1),ni=>num_images(),ny=>n(2),nz=>n(3))
      if (assertions) call assert(mod(num_yz_planes,ni)==0,"evenly divisible planes")
      associate(my_num_planes=>num_yz_planes/ni)
        allocate(x(my_num_planes,ny,nz,space_dimension)[*])
      end associate
    end associate

  end subroutine

  pure function my_partition_size() result(partition_size)
    integer partition_size
    partition_size = size(x)
  end function

end module

program main
  !! author: Damian Rouson
  !!
  !! Establish a coarray for distributing structured-grid vertex locations across images.
  !! Use collective subroutines to distribute the grid dimensions and verify load distribution

   use assertion_interface, only : assert
   use structureted_grid_implementation, only : get_grid_resolution, allocate_my_partition, my_partition_size

   implicit none

   integer, allocatable :: nx(:)

   nx = get_grid_resolution('grid.nml')
   call assert( size(nx)==3 .and. all(nx>0),"acceptable 3D grid resolution")

   call allocate_my_partition(nx)

   block
     integer load
     integer, parameter :: space_dimension=3
     load = my_partition_size()
     call co_sum( load )
     call assert( load == product(nx)*space_dimension, "all points distributed")
   end block

   sync all
   block
     integer, parameter :: reader=1
     if (this_image()==reader) print *,"Test passed."
   end block

end program
