PROGRAM cal_x

      IMPLICIT NONE

      INTEGER :: i, y, m
      REAL :: x(165)

      i = 0
      DO y = 1,55
         DO m = 1,3
            i = i + 1
            x(i) = m + (y-1)*12
         END DO
      END DO

      DO i = 1, 165
         write(*,*) i, x(i)
      END DO

END PROGRAM cal_x
