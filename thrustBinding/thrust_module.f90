    module thrust
    
    interface thrustsort
    
    subroutine sort_int_by_key( N, keys, values ) bind(C,name="sort_int_by_key_wrapper")
      use, intrinsic :: iso_c_binding
      integer( kind = c_int ) :: N
      real( kind = c_double ), dimension(*), INTENT(INOUT) :: keys
      integer( kind = c_int ),  dimension(*), INTENT(INOUT) :: values
    end subroutine

    subroutine sort_int( N, data ) bind(C,name="sort_int_wrapper")
      use, intrinsic :: iso_c_binding
      integer( kind = c_int ) :: N
      integer( kind = c_int ), dimension(*), INTENT(INOUT) :: data
    end subroutine

    end interface

    end module thrust

